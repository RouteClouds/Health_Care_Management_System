#!/bin/bash

# Enhanced Duplicate Resources Cleanup Script
# Based on audit findings and Cursor delete plan best practices
# Removes duplicate VPCs and associated resources while preserving the active infrastructure

set -euo pipefail

REGION="${AWS_REGION:-us-east-1}"
DRY_RUN="${1:-false}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Dry run execution
execute_command() {
    local cmd="$1"
    local description="$2"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "[DRY-RUN] $description"
        log_info "[DRY-RUN] Command: $cmd"
    else
        log_info "$description"
        if eval "$cmd"; then
            log_success "$description completed"
        else
            log_error "$description failed"
            return 1
        fi
    fi
}

# Wait for resource deletion
wait_for_deletion() {
    local resource_type="$1"
    local resource_id="$2"
    local max_wait="${3:-300}"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "[DRY-RUN] Would wait for $resource_type $resource_id deletion"
        return 0
    fi
    
    log_info "⏳ Waiting for $resource_type $resource_id to be deleted (max ${max_wait}s)..."
    local count=0
    while [[ $count -lt $max_wait ]]; do
        case "$resource_type" in
            "nat-gateway")
                if ! aws ec2 describe-nat-gateways --nat-gateway-ids "$resource_id" --region "$REGION" &>/dev/null; then
                    log_success "$resource_type $resource_id deleted"
                    return 0
                fi
                ;;
            "vpc")
                if ! aws ec2 describe-vpcs --vpc-ids "$resource_id" --region "$REGION" &>/dev/null; then
                    log_success "$resource_type $resource_id deleted"
                    return 0
                fi
                ;;
        esac
        sleep 10
        count=$((count + 10))
    done
    log_warning "$resource_type $resource_id deletion timeout after ${max_wait}s"
}

# Identify active vs duplicate VPCs
identify_vpcs() {
    log_info "🔍 Identifying VPCs and determining which to keep..."
    
    # Get all healthcare VPCs
    local vpcs
    vpcs=$(aws ec2 describe-vpcs --region "$REGION" \
        --filter "Name=tag:Name,Values=*healthcare*" \
        --query 'Vpcs[].[VpcId,Tags[?Key==`Name`].Value|[0]]' \
        --output text)
    
    if [[ -z "$vpcs" ]]; then
        log_error "No healthcare VPCs found"
        return 1
    fi
    
    echo "$vpcs" | while read -r vpc_id vpc_name; do
        log_info "Found VPC: $vpc_id ($vpc_name)"
        
        # Check if this VPC has the active EKS cluster
        local eks_vpc
        eks_vpc=$(aws eks describe-cluster --name "healthcare-eks-stage3-dev" --region "$REGION" \
            --query 'cluster.resourcesVpcConfig.vpcId' --output text 2>/dev/null || echo "")
        
        if [[ "$vpc_id" == "$eks_vpc" ]]; then
            log_success "✅ ACTIVE VPC (has EKS cluster): $vpc_id"
            echo "$vpc_id" > /tmp/active_vpc
        else
            log_warning "🗑️ DUPLICATE VPC (will be deleted): $vpc_id"
            echo "$vpc_id" >> /tmp/duplicate_vpcs
        fi
    done
}

# Clean up duplicate VPC and all associated resources
cleanup_duplicate_vpc() {
    local vpc_id="$1"
    local vpc_name="$2"
    
    log_warning "🗑️ Cleaning up duplicate VPC: $vpc_id ($vpc_name)"
    
    # 1. Delete NAT Gateways first (highest cost)
    log_info "🚪 Deleting NAT Gateways in VPC $vpc_id..."
    local nat_gws
    nat_gws=$(aws ec2 describe-nat-gateways --region "$REGION" \
        --filter "Name=vpc-id,Values=$vpc_id" \
        --filter "Name=state,Values=available" \
        --query 'NatGateways[].NatGatewayId' --output text)
    
    if [[ -n "$nat_gws" && "$nat_gws" != "None" ]]; then
        for nat in $nat_gws; do
            execute_command "aws ec2 delete-nat-gateway --nat-gateway-id '$nat' --region '$REGION'" \
                "Delete NAT Gateway $nat (saves ~\$45/month)"
            wait_for_deletion "nat-gateway" "$nat" 600
        done
    fi
    
    # 2. Delete Load Balancers in this VPC
    log_info "🔗 Deleting Load Balancers in VPC $vpc_id..."
    
    # ALB/NLB
    local alb_arns
    alb_arns=$(aws elbv2 describe-load-balancers --region "$REGION" \
        --query "LoadBalancers[?VpcId=='$vpc_id'].LoadBalancerArn" --output text)
    
    if [[ -n "$alb_arns" && "$alb_arns" != "None" ]]; then
        for arn in $alb_arns; do
            execute_command "aws elbv2 delete-load-balancer --load-balancer-arn '$arn' --region '$REGION'" \
                "Delete ALB/NLB $arn"
        done
    fi
    
    # Classic ELB
    local classic_lbs
    classic_lbs=$(aws elb describe-load-balancers --region "$REGION" \
        --query "LoadBalancerDescriptions[?VPCId=='$vpc_id'].LoadBalancerName" --output text)
    
    if [[ -n "$classic_lbs" && "$classic_lbs" != "None" ]]; then
        for lb in $classic_lbs; do
            execute_command "aws elb delete-load-balancer --load-balancer-name '$lb' --region '$REGION'" \
                "Delete Classic LB $lb"
        done
    fi
    
    # 3. Delete Security Groups (non-default)
    log_info "🔐 Deleting Security Groups in VPC $vpc_id..."
    local sg_ids
    sg_ids=$(aws ec2 describe-security-groups --region "$REGION" \
        --filter "Name=vpc-id,Values=$vpc_id" \
        --query 'SecurityGroups[?GroupName!=`default`].GroupId' --output text)
    
    if [[ -n "$sg_ids" && "$sg_ids" != "None" ]]; then
        for sg in $sg_ids; do
            execute_command "aws ec2 delete-security-group --group-id '$sg' --region '$REGION'" \
                "Delete Security Group $sg" || log_warning "Security Group $sg may have dependencies"
        done
    fi
    
    # 4. Delete Route Tables (non-main)
    log_info "🛣️ Deleting Route Tables in VPC $vpc_id..."
    local route_tables
    route_tables=$(aws ec2 describe-route-tables --region "$REGION" \
        --filter "Name=vpc-id,Values=$vpc_id" \
        --query 'RouteTables[].RouteTableId' --output text)
    
    if [[ -n "$route_tables" && "$route_tables" != "None" ]]; then
        for rtb in $route_tables; do
            # Check if it's the main route table
            local is_main
            is_main=$(aws ec2 describe-route-tables --route-table-ids "$rtb" --region "$REGION" \
                --query 'RouteTables[0].Associations[?Main].Main' --output text)
            
            if [[ "$is_main" != "True" ]]; then
                # Disassociate first
                local associations
                associations=$(aws ec2 describe-route-tables --route-table-ids "$rtb" --region "$REGION" \
                    --query 'RouteTables[0].Associations[].RouteTableAssociationId' --output text)
                
                if [[ -n "$associations" && "$associations" != "None" ]]; then
                    for assoc in $associations; do
                        execute_command "aws ec2 disassociate-route-table --association-id '$assoc' --region '$REGION'" \
                            "Disassociate Route Table $rtb" || true
                    done
                fi
                
                execute_command "aws ec2 delete-route-table --route-table-id '$rtb' --region '$REGION'" \
                    "Delete Route Table $rtb"
            fi
        done
    fi
    
    # 5. Delete Subnets
    log_info "🏠 Deleting Subnets in VPC $vpc_id..."
    local subnets
    subnets=$(aws ec2 describe-subnets --region "$REGION" \
        --filter "Name=vpc-id,Values=$vpc_id" \
        --query 'Subnets[].SubnetId' --output text)
    
    if [[ -n "$subnets" && "$subnets" != "None" ]]; then
        for subnet in $subnets; do
            execute_command "aws ec2 delete-subnet --subnet-id '$subnet' --region '$REGION'" \
                "Delete Subnet $subnet"
        done
    fi
    
    # 6. Detach and Delete Internet Gateway
    log_info "🌍 Deleting Internet Gateway in VPC $vpc_id..."
    local igw_id
    igw_id=$(aws ec2 describe-internet-gateways --region "$REGION" \
        --filter "Name=attachment.vpc-id,Values=$vpc_id" \
        --query 'InternetGateways[0].InternetGatewayId' --output text)
    
    if [[ -n "$igw_id" && "$igw_id" != "None" ]]; then
        execute_command "aws ec2 detach-internet-gateway --internet-gateway-id '$igw_id' --vpc-id '$vpc_id' --region '$REGION'" \
            "Detach Internet Gateway $igw_id"
        execute_command "aws ec2 delete-internet-gateway --internet-gateway-id '$igw_id' --region '$REGION'" \
            "Delete Internet Gateway $igw_id"
    fi
    
    # 7. Finally, Delete VPC
    log_info "🌐 Deleting VPC $vpc_id..."
    execute_command "aws ec2 delete-vpc --vpc-id '$vpc_id' --region '$REGION'" \
        "Delete VPC $vpc_id"
    wait_for_deletion "vpc" "$vpc_id" 300
}

# Main execution
main() {
    if [[ "$DRY_RUN" == "true" ]]; then
        log_warning "🔍 DRY RUN MODE - No resources will be deleted"
    else
        log_warning "🚨 LIVE MODE - Resources will be permanently deleted"
        echo "⚠️  This will delete duplicate VPCs and associated resources"
        echo "💰 Expected savings: ~\$135/month (3 NAT Gateways)"
        echo ""
        read -p "Type 'DELETE-DUPLICATES' to confirm: " -r
        if [[ ! $REPLY == "DELETE-DUPLICATES" ]]; then
            echo "Cleanup cancelled."
            exit 0
        fi
    fi
    
    # Clean up temp files
    rm -f /tmp/active_vpc /tmp/duplicate_vpcs
    
    # Identify VPCs
    identify_vpcs
    
    if [[ ! -f /tmp/duplicate_vpcs ]]; then
        log_success "🎉 No duplicate VPCs found!"
        exit 0
    fi
    
    # Process duplicate VPCs
    while read -r vpc_id; do
        if [[ -n "$vpc_id" ]]; then
            cleanup_duplicate_vpc "$vpc_id" "healthcare-eks-stage3-dev-vpc"
        fi
    done < /tmp/duplicate_vpcs
    
    # Clean up temp files
    rm -f /tmp/active_vpc /tmp/duplicate_vpcs
    
    log_success "🎉 Duplicate VPC cleanup completed!"
    log_info "💰 Expected monthly savings: ~\$135 (3 NAT Gateways)"
    log_info "📊 Run audit script again to verify cleanup"
}

# Usage information
if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
    echo "Enhanced Duplicate Resources Cleanup Script"
    echo ""
    echo "Usage:"
    echo "  $0 [dry-run]     # Dry run mode (default: false)"
    echo "  $0 --help        # Show this help"
    echo ""
    echo "Examples:"
    echo "  $0 true          # Dry run - show what would be deleted"
    echo "  $0 false         # Live run - actually delete resources"
    echo "  $0               # Live run (default)"
    echo ""
    echo "This script removes duplicate VPCs while preserving the active EKS cluster VPC."
    exit 0
fi

# Run main function
main "$@"
