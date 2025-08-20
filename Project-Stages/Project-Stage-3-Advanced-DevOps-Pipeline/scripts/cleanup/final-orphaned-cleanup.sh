#!/bin/bash

# Final Orphaned Resources Cleanup Script
# Based on latest audit findings - removes remaining orphaned resources
# Since EKS and RDS are gone, we can safely remove all healthcare VPCs

set -euo pipefail

REGION="${AWS_REGION:-us-east-1}"
DRY_RUN="${1:-false}"

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

# Execute command with dry run support
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
            log_warning "$description failed (may not exist)"
        fi
    fi
}

# Clean up remaining Load Balancers
cleanup_remaining_load_balancers() {
    log_info "🔗 Cleaning up remaining Load Balancers..."

    # From audit: Classic LB and Network LB
    log_info "Deleting Classic Load Balancer..."
    execute_command "aws elb delete-load-balancer --load-balancer-name 'a46a32210135848f797d5b74ea975657' --region '$REGION'" \
        "Delete Classic Load Balancer a46a32210135848f797d5b74ea975657" || true

    log_info "Deleting Network Load Balancer..."
    # Get the ARN for the NLB
    local nlb_arn
    nlb_arn=$(aws elbv2 describe-load-balancers --region "$REGION" --query "LoadBalancers[?LoadBalancerName=='a4947ed79d2d04c99b7a728821a64139'].LoadBalancerArn" --output text 2>/dev/null || echo "")

    if [[ -n "$nlb_arn" && "$nlb_arn" != "None" ]]; then
        execute_command "aws elbv2 delete-load-balancer --load-balancer-arn '$nlb_arn' --region '$REGION'" \
            "Delete Network Load Balancer a4947ed79d2d04c99b7a728821a64139"
    else
        log_warning "Network Load Balancer ARN not found, may already be deleted"
    fi

    if [[ "$DRY_RUN" == "false" ]]; then
        log_info "⏳ Waiting for Load Balancers to be deleted..."
        sleep 30
    fi
}

# Clean up remaining NAT Gateways (highest cost)
cleanup_remaining_nat_gateways() {
    log_info "🚪 Cleaning up remaining NAT Gateways (saves \$90/month)..."
    
    # From audit: nat-0a8f1e114490f33a9, nat-0cd9828d7e9330c9c
    local nat_gateways=("nat-0a8f1e114490f33a9" "nat-0cd9828d7e9330c9c")
    
    for nat in "${nat_gateways[@]}"; do
        execute_command "aws ec2 delete-nat-gateway --nat-gateway-id '$nat' --region '$REGION'" \
            "Delete NAT Gateway $nat (saves \$45/month)"
    done
    
    if [[ "$DRY_RUN" == "false" ]]; then
        log_info "⏳ Waiting for NAT Gateways to be deleted..."
        sleep 60
    fi
}

# Clean up remaining Elastic IPs
cleanup_elastic_ips() {
    log_info "💰 Cleaning up remaining Elastic IPs..."
    
    # From audit: eipalloc-0c256fc3a561fd6bc, eipalloc-0bc8aa6b3cb9e173c
    local eips=("eipalloc-0c256fc3a561fd6bc" "eipalloc-0bc8aa6b3cb9e173c")
    
    for eip in "${eips[@]}"; do
        execute_command "aws ec2 release-address --allocation-id '$eip' --region '$REGION'" \
            "Release Elastic IP $eip"
    done
}

# Clean up duplicate VPC (vpc-0a86b53a910003112)
cleanup_duplicate_vpc() {
    log_info "🌐 Cleaning up duplicate VPC (vpc-0a86b53a910003112)..."
    
    local vpc_id="vpc-0a86b53a910003112"
    
    # 1. Delete Security Groups (non-default)
    log_info "🔐 Deleting Security Groups in VPC $vpc_id..."
    local sg_ids=("sg-08ffb5a46cf5da109" "sg-0309a56581085ae3f" "sg-01731990869f4a07c")
    
    for sg in "${sg_ids[@]}"; do
        execute_command "aws ec2 delete-security-group --group-id '$sg' --region '$REGION'" \
            "Delete Security Group $sg"
    done
    
    # 2. Delete Route Tables (non-main)
    log_info "🛣️ Deleting Route Tables in VPC $vpc_id..."
    local route_tables=("rtb-0e8823597d503b3f4" "rtb-0db8d32073dde7e10" "rtb-03b7feb42eb860f79" "rtb-0abe52312ee2e88b4")
    
    for rtb in "${route_tables[@]}"; do
        # Disassociate first
        execute_command "aws ec2 describe-route-tables --route-table-ids '$rtb' --region '$REGION' --query 'RouteTables[0].Associations[].RouteTableAssociationId' --output text | xargs -r -n1 aws ec2 disassociate-route-table --association-id --region '$REGION'" \
            "Disassociate Route Table $rtb" || true
        
        execute_command "aws ec2 delete-route-table --route-table-id '$rtb' --region '$REGION'" \
            "Delete Route Table $rtb"
    done
    
    # 3. Delete Subnets
    log_info "🏠 Deleting Subnets in VPC $vpc_id..."
    local subnets=("subnet-0b7a213bcd24cbf8a" "subnet-0f2345699607ce2e7" "subnet-09406b833277a5c86" "subnet-09a57b5a503ccfd5b" "subnet-0b6c5861a3795e691" "subnet-010b1c3984f31da53")
    
    for subnet in "${subnets[@]}"; do
        execute_command "aws ec2 delete-subnet --subnet-id '$subnet' --region '$REGION'" \
            "Delete Subnet $subnet"
    done
    
    # 4. Detach and Delete Internet Gateway
    log_info "🌍 Deleting Internet Gateway in VPC $vpc_id..."
    local igw_id="igw-0ce3548bf5a2b84df"
    
    execute_command "aws ec2 detach-internet-gateway --internet-gateway-id '$igw_id' --vpc-id '$vpc_id' --region '$REGION'" \
        "Detach Internet Gateway $igw_id"
    execute_command "aws ec2 delete-internet-gateway --internet-gateway-id '$igw_id' --region '$REGION'" \
        "Delete Internet Gateway $igw_id"
    
    # 5. Delete VPC
    log_info "🌐 Deleting VPC $vpc_id..."
    execute_command "aws ec2 delete-vpc --vpc-id '$vpc_id' --region '$REGION'" \
        "Delete VPC $vpc_id"
}

# Clean up ECR repositories
cleanup_ecr_repositories() {
    log_info "📦 Cleaning up ECR repositories..."
    
    local repos=("healthcare-backend-stage3" "healthcare-frontend-stage3")
    
    for repo in "${repos[@]}"; do
        execute_command "aws ecr delete-repository --repository-name '$repo' --force --region '$REGION'" \
            "Delete ECR repository $repo"
    done
}

# Clean up S3 buckets
cleanup_s3_buckets() {
    log_info "🗄️ Cleaning up S3 buckets..."
    
    local buckets=(
        "healthcare-terraform-state-stage3-867344452513"
        "healthcare-terraform-state-stage3-867344452513-2738"
        "healthcare-terraform-state-stage3-867344452513-8840"
    )
    
    for bucket in "${buckets[@]}"; do
        execute_command "aws s3 rm 's3://$bucket' --recursive --region '$REGION'" \
            "Empty S3 bucket $bucket" || true
        execute_command "aws s3 rb 's3://$bucket' --region '$REGION'" \
            "Delete S3 bucket $bucket"
    done
}

# Main execution
main() {
    if [[ "$DRY_RUN" == "true" ]]; then
        log_warning "🔍 DRY RUN MODE - No resources will be deleted"
    else
        log_warning "🚨 FINAL CLEANUP - Removing ALL remaining orphaned resources"
        echo ""
        echo "Based on latest audit, this will remove:"
        echo "  🔗 2 Load Balancers (1 Classic + 1 Network)"
        echo "  🚪 2 NAT Gateways (saves \$90/month)"
        echo "  💰 2 Elastic IPs"
        echo "  🌐 1 duplicate VPC (vpc-0a86b53a910003112)"
        echo "  🏠 6 subnets in duplicate VPC"
        echo "  🔐 3 security groups in duplicate VPC"
        echo "  🛣️ 4 route tables in duplicate VPC"
        echo "  🌍 1 internet gateway in duplicate VPC"
        echo "  📦 2 ECR repositories"
        echo "  🗄️ 3 S3 Terraform state buckets"
        echo ""
        echo "💰 Total monthly savings: ~\$90"
        echo ""
        read -p "Type 'FINAL-CLEANUP' to confirm: " -r
        if [[ ! $REPLY == "FINAL-CLEANUP" ]]; then
            echo "Final cleanup cancelled."
            exit 0
        fi
    fi
    
    echo ""
    log_info "🚀 Starting final orphaned resources cleanup..."
    
    # Execute cleanup in dependency order
    cleanup_remaining_load_balancers
    cleanup_remaining_nat_gateways
    cleanup_elastic_ips
    cleanup_duplicate_vpc
    cleanup_ecr_repositories
    cleanup_s3_buckets
    
    log_success "🎉 Final orphaned resources cleanup completed!"
    log_info "💰 Monthly savings: ~\$90"
    log_info "📊 Run audit script again to verify complete cleanup"
}

# Show usage
if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
    echo "Final Orphaned Resources Cleanup Script"
    echo ""
    echo "Based on latest audit findings (aws-resources-audit-20250820-042222.txt)"
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
    echo "This removes ALL remaining orphaned resources for complete cleanup."
    exit 0
fi

# Run main function
main "$@"
