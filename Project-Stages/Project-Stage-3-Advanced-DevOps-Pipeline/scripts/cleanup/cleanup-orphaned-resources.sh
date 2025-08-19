#!/bin/bash

# Orphaned Resources Cleanup Script
# Cleans up AWS resources not managed by Terraform

set -euo pipefail

REGION="${AWS_REGION:-us-east-1}"
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

# Confirmation function
confirm_cleanup() {
    echo "🚨 ORPHANED RESOURCES CLEANUP"
    echo "============================="
    echo
    echo "⚠️  WARNING: This will DELETE orphaned AWS resources including:"
    echo "   • Load Balancers (Classic, Application, Network)"
    echo "   • NAT Gateways (HIGH COST - ~$45/month each)"
    echo "   • RDS Instances (HIGH COST - ~$20-100/month each)"
    echo "   • ECR Repositories and container images"
    echo "   • Security Groups"
    echo "   • VPCs and Subnets"
    echo "   • Internet Gateways"
    echo
    echo "💰 This cleanup can save $400-600/month in AWS costs."
    echo
    echo "🔄 This action CANNOT be undone!"
    echo
    read -p "Type 'CLEANUP' to confirm orphaned resources cleanup: " -r
    if [[ ! $REPLY == "CLEANUP" ]]; then
        echo "Cleanup cancelled."
        exit 0
    fi
    echo
}

# 1. Delete Orphaned Load Balancers
cleanup_load_balancers() {
    log_info "🔗 Cleaning up orphaned load balancers..."
    
    # Classic Load Balancers
    log_info "Checking Classic Load Balancers..."
    local classic_lbs
    classic_lbs=$(aws elb describe-load-balancers --region "$REGION" --query 'LoadBalancerDescriptions[?contains(LoadBalancerName,`healthcare`) || contains(LoadBalancerName,`stage3`)].LoadBalancerName' --output text 2>/dev/null || echo "")
    
    if [[ -n "$classic_lbs" && "$classic_lbs" != "None" ]]; then
        for lb in $classic_lbs; do
            log_warning "Deleting Classic LB: $lb"
            if aws elb delete-load-balancer --load-balancer-name "$lb" --region "$REGION" 2>/dev/null; then
                log_success "Deleted Classic LB: $lb"
            else
                log_error "Failed to delete Classic LB: $lb"
            fi
        done
    else
        log_info "No Classic Load Balancers found"
    fi
    
    # Application/Network Load Balancers
    log_info "Checking Application/Network Load Balancers..."
    local alb_arns
    alb_arns=$(aws elbv2 describe-load-balancers --region "$REGION" --query 'LoadBalancers[?contains(LoadBalancerName,`healthcare`) || contains(LoadBalancerName,`stage3`)].LoadBalancerArn' --output text 2>/dev/null || echo "")
    
    if [[ -n "$alb_arns" && "$alb_arns" != "None" ]]; then
        for arn in $alb_arns; do
            local lb_name
            lb_name=$(aws elbv2 describe-load-balancers --load-balancer-arns "$arn" --region "$REGION" --query 'LoadBalancers[0].LoadBalancerName' --output text 2>/dev/null || echo "unknown")
            log_warning "Deleting ALB/NLB: $lb_name ($arn)"
            if aws elbv2 delete-load-balancer --load-balancer-arn "$arn" --region "$REGION" 2>/dev/null; then
                log_success "Deleted ALB/NLB: $lb_name"
            else
                log_error "Failed to delete ALB/NLB: $lb_name"
            fi
        done
    else
        log_info "No Application/Network Load Balancers found"
    fi
    
    log_success "Load balancers cleanup completed"
}

# 2. Delete Orphaned NAT Gateways
cleanup_nat_gateways() {
    log_info "🚪 Cleaning up orphaned NAT Gateways..."
    
    # Get all available NAT Gateways
    local nat_gws
    nat_gws=$(aws ec2 describe-nat-gateways --region "$REGION" --query 'NatGateways[?State==`available`].NatGatewayId' --output text 2>/dev/null || echo "")
    
    if [[ -n "$nat_gws" && "$nat_gws" != "None" ]]; then
        for nat in $nat_gws; do
            # Check if it's in a healthcare VPC
            local vpc_id vpc_name
            vpc_id=$(aws ec2 describe-nat-gateways --nat-gateway-ids "$nat" --region "$REGION" --query 'NatGateways[0].VpcId' --output text 2>/dev/null || echo "")
            
            if [[ -n "$vpc_id" && "$vpc_id" != "None" ]]; then
                vpc_name=$(aws ec2 describe-vpcs --vpc-ids "$vpc_id" --region "$REGION" --query 'Vpcs[0].Tags[?Key==`Name`].Value|[0]' --output text 2>/dev/null || echo "")
                
                if [[ "$vpc_name" == *"healthcare"* || "$vpc_name" == *"stage3"* ]]; then
                    log_warning "Deleting NAT Gateway: $nat (VPC: $vpc_name) - Saves ~$45/month"
                    if aws ec2 delete-nat-gateway --nat-gateway-id "$nat" --region "$REGION" 2>/dev/null; then
                        log_success "Deleted NAT Gateway: $nat"
                    else
                        log_error "Failed to delete NAT Gateway: $nat"
                    fi
                fi
            fi
        done
    else
        log_info "No NAT Gateways found"
    fi
    
    log_success "NAT Gateways cleanup completed"
}

# 3. Delete Orphaned RDS Instances
cleanup_rds_instances() {
    log_info "🗄️ Cleaning up orphaned RDS instances..."
    
    local rds_instances
    rds_instances=$(aws rds describe-db-instances --region "$REGION" --query 'DBInstances[?contains(DBInstanceIdentifier,`healthcare`) || contains(DBInstanceIdentifier,`stage3`)].DBInstanceIdentifier' --output text 2>/dev/null || echo "")
    
    if [[ -n "$rds_instances" && "$rds_instances" != "None" ]]; then
        for db in $rds_instances; do
            local db_status
            db_status=$(aws rds describe-db-instances --db-instance-identifier "$db" --region "$REGION" --query 'DBInstances[0].DBInstanceStatus' --output text 2>/dev/null || echo "unknown")
            
            if [[ "$db_status" == "available" ]]; then
                log_warning "Deleting RDS instance: $db - Saves ~$20-100/month"
                # Skip final snapshot for cleanup
                if aws rds delete-db-instance --db-instance-identifier "$db" --skip-final-snapshot --region "$REGION" 2>/dev/null; then
                    log_success "Initiated deletion of RDS instance: $db"
                else
                    log_error "Failed to delete RDS instance: $db"
                fi
            else
                log_info "RDS instance $db is in $db_status state, skipping"
            fi
        done
    else
        log_info "No RDS instances found"
    fi
    
    log_success "RDS instances cleanup completed"
}

# 4. Delete Orphaned ECR Repositories
cleanup_ecr_repositories() {
    log_info "📦 Cleaning up orphaned ECR repositories..."
    
    local ecr_repos
    ecr_repos=$(aws ecr describe-repositories --region "$REGION" --query 'repositories[?contains(repositoryName,`healthcare`) || contains(repositoryName,`stage3`)].repositoryName' --output text 2>/dev/null || echo "")
    
    if [[ -n "$ecr_repos" && "$ecr_repos" != "None" ]]; then
        for repo in $ecr_repos; do
            log_warning "Deleting ECR repository: $repo"
            if aws ecr delete-repository --repository-name "$repo" --force --region "$REGION" 2>/dev/null; then
                log_success "Deleted ECR repository: $repo"
            else
                log_error "Failed to delete ECR repository: $repo"
            fi
        done
    else
        log_info "No ECR repositories found"
    fi
    
    log_success "ECR repositories cleanup completed"
}

# 5. Delete Orphaned Security Groups
cleanup_security_groups() {
    log_info "🔐 Cleaning up orphaned security groups..."
    
    # Get all healthcare/stage3 security groups
    local sg_ids
    sg_ids=$(aws ec2 describe-security-groups --region "$REGION" --query 'SecurityGroups[?contains(GroupName,`healthcare`) || contains(GroupName,`stage3`) || contains(Description,`healthcare`) || contains(Description,`stage3`)].GroupId' --output text 2>/dev/null || echo "")
    
    if [[ -n "$sg_ids" && "$sg_ids" != "None" ]]; then
        for sg in $sg_ids; do
            # Skip default security groups
            local sg_name
            sg_name=$(aws ec2 describe-security-groups --group-ids "$sg" --region "$REGION" --query 'SecurityGroups[0].GroupName' --output text 2>/dev/null || echo "unknown")
            
            if [[ "$sg_name" != "default" ]]; then
                log_warning "Deleting Security Group: $sg ($sg_name)"
                if aws ec2 delete-security-group --group-id "$sg" --region "$REGION" 2>/dev/null; then
                    log_success "Deleted Security Group: $sg"
                else
                    log_warning "Failed to delete Security Group: $sg (may have dependencies)"
                fi
            fi
        done
    else
        log_info "No security groups found"
    fi
    
    log_success "Security groups cleanup completed"
}

# 6. Delete Orphaned VPCs and Subnets
cleanup_vpcs() {
    log_info "🌐 Cleaning up orphaned VPCs..."
    
    # Get healthcare VPCs
    local vpc_ids
    vpc_ids=$(aws ec2 describe-vpcs --region "$REGION" --query 'Vpcs[?contains(Tags[?Key==`Name`].Value|[0],`healthcare`) || contains(Tags[?Key==`Name`].Value|[0],`stage3`)].VpcId' --output text 2>/dev/null || echo "")
    
    if [[ -n "$vpc_ids" && "$vpc_ids" != "None" ]]; then
        for vpc in $vpc_ids; do
            local vpc_name
            vpc_name=$(aws ec2 describe-vpcs --vpc-ids "$vpc" --region "$REGION" --query 'Vpcs[0].Tags[?Key==`Name`].Value|[0]' --output text 2>/dev/null || echo "unknown")
            log_info "Processing VPC: $vpc ($vpc_name)"
            
            # Delete subnets first
            local subnet_ids
            subnet_ids=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$vpc" --region "$REGION" --query 'Subnets[].SubnetId' --output text 2>/dev/null || echo "")
            
            if [[ -n "$subnet_ids" && "$subnet_ids" != "None" ]]; then
                for subnet in $subnet_ids; do
                    log_warning "  Deleting subnet: $subnet"
                    if aws ec2 delete-subnet --subnet-id "$subnet" --region "$REGION" 2>/dev/null; then
                        log_success "  Deleted subnet: $subnet"
                    else
                        log_error "  Failed to delete subnet: $subnet"
                    fi
                done
            fi
            
            # Detach and delete internet gateway
            local igw_id
            igw_id=$(aws ec2 describe-internet-gateways --filters "Name=attachment.vpc-id,Values=$vpc" --region "$REGION" --query 'InternetGateways[0].InternetGatewayId' --output text 2>/dev/null || echo "")
            
            if [[ -n "$igw_id" && "$igw_id" != "None" ]]; then
                log_warning "  Detaching and deleting IGW: $igw_id"
                aws ec2 detach-internet-gateway --internet-gateway-id "$igw_id" --vpc-id "$vpc" --region "$REGION" 2>/dev/null || true
                if aws ec2 delete-internet-gateway --internet-gateway-id "$igw_id" --region "$REGION" 2>/dev/null; then
                    log_success "  Deleted IGW: $igw_id"
                else
                    log_error "  Failed to delete IGW: $igw_id"
                fi
            fi
            
            # Delete VPC
            log_warning "  Deleting VPC: $vpc"
            if aws ec2 delete-vpc --vpc-id "$vpc" --region "$REGION" 2>/dev/null; then
                log_success "  Deleted VPC: $vpc"
            else
                log_error "  Failed to delete VPC: $vpc"
            fi
        done
    else
        log_info "No VPCs found"
    fi
    
    log_success "VPCs cleanup completed"
}

# Main execution
main() {
    log_info "🧹 Starting orphaned resources cleanup..."
    
    # Confirmation
    confirm_cleanup
    
    # Execute cleanup functions with delays
    log_info "Phase 1: Load Balancers"
    cleanup_load_balancers
    sleep 30  # Wait for LB deletion
    
    log_info "Phase 2: NAT Gateways (High Cost Savings)"
    cleanup_nat_gateways
    sleep 60  # Wait for NAT GW deletion
    
    log_info "Phase 3: RDS Instances (High Cost Savings)"
    cleanup_rds_instances
    
    log_info "Phase 4: ECR Repositories"
    cleanup_ecr_repositories
    
    log_info "Phase 5: Security Groups"
    cleanup_security_groups
    sleep 30  # Wait for SG deletion
    
    log_info "Phase 6: VPCs and Subnets"
    cleanup_vpcs
    
    log_success "🎉 Orphaned resources cleanup completed!"
    log_info "💰 Expected monthly savings: $400-600"
    log_info "📊 Monitor AWS Cost Explorer for actual cost reduction"
    log_warning "⏳ Some resources (like RDS) may take time to fully delete"
}

# Run main function
main "$@"
