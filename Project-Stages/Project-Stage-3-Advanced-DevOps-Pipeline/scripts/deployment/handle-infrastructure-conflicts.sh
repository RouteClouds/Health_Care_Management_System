#!/bin/bash

# Infrastructure Conflicts Handler
# Handles existing AWS resources that conflict with Terraform deployment
# Supports both import and cleanup strategies

set -euo pipefail

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

AWS_REGION="${AWS_REGION:-us-east-1}"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# Check infrastructure health and limits
check_infrastructure_health() {
    log_info "🏥 Running infrastructure health check..."
    
    # Check EIP usage and limits
    local eip_limit eip_used
    eip_limit=$(aws ec2 describe-account-attributes --attribute-names max-elastic-ips --query 'AccountAttributes[0].AttributeValues[0].AttributeValue' --output text)
    eip_used=$(aws ec2 describe-addresses --query 'Addresses | length(@)')
    
    log_info "📊 EIP Usage: $eip_used / $eip_limit"
    
    if [[ $eip_used -ge $eip_limit ]]; then
        log_warning "⚠️ EIP limit reached - NAT Gateway creation will fail"
        log_info "💡 Using single_nat_gateway = true in VPC module"
        return 1
    fi
    
    # Check for existing conflicting resources
    log_info "🔍 Checking for potential conflicts..."
    
    # KMS Alias
    if aws kms list-aliases --query "Aliases[?AliasName=='alias/eks/healthcare-eks-stage3-dev']" --output text | grep -q alias/eks/healthcare-eks-stage3-dev; then
        log_warning "⚠️ KMS alias conflict: alias/eks/healthcare-eks-stage3-dev exists"
    fi
    
    # CloudWatch Log Group
    if aws logs describe-log-groups --log-group-name-prefix "/aws/eks/healthcare-eks-stage3-dev" --query 'logGroups[].logGroupName' --output text 2>/dev/null | grep -q '/aws/eks/healthcare-eks-stage3-dev'; then
        log_warning "⚠️ CloudWatch log group conflict: /aws/eks/healthcare-eks-stage3-dev/cluster exists"
    fi
    
    # RDS Subnet Group
    if aws rds describe-db-subnet-groups --db-subnet-group-name healthcare-eks-stage3-dev-db-subnet-group >/dev/null 2>&1; then
        log_warning "⚠️ RDS subnet group conflict: healthcare-eks-stage3-dev-db-subnet-group exists"
    fi
    
    # S3 Assets Bucket
    local assets_bucket="healthcare-assets-stage3-dev-${ACCOUNT_ID}"
    if aws s3api head-bucket --bucket "$assets_bucket" 2>/dev/null; then
        log_warning "⚠️ S3 bucket conflict: $assets_bucket exists"
    fi
    
    log_success "✅ Infrastructure health check completed"
}

# Enhanced pre-import with multiple path attempts
pre_import_existing_resources() {
    log_info "📥 Detecting and importing existing resources..."
    
    # Get current Terraform state resources
    local existing_resources
    existing_resources=$(terraform state list 2>/dev/null || echo "")
    
    # KMS Alias - Try multiple possible paths
    if ! echo "$existing_resources" | grep -q "aws_kms_alias"; then
        if aws kms list-aliases --query "Aliases[?AliasName=='alias/eks/healthcare-eks-stage3-dev']" --output text | grep -q alias/eks/healthcare-eks-stage3-dev; then
            log_info "📥 Importing KMS alias..."
            
            # Try multiple possible module paths
            local kms_paths=(
                "module.healthcare_infrastructure.module.eks.aws_kms_alias.this[\"cluster\"]"
                "module.healthcare_infrastructure.module.eks.module.kms.aws_kms_alias.this[\"cluster\"]"
                "module.healthcare_infrastructure.aws_kms_alias.eks"
            )
            
            local imported=false
            for path in "${kms_paths[@]}"; do
                if terraform import "$path" alias/eks/healthcare-eks-stage3-dev 2>/dev/null; then
                    log_success "✅ KMS alias imported via path: $path"
                    imported=true
                    break
                fi
            done
            
            if [[ "$imported" == "false" ]]; then
                log_warning "⚠️ KMS alias import failed - may need manual intervention"
            fi
        fi
    else
        log_info "✅ KMS alias already in Terraform state"
    fi
    
    # CloudWatch Log Group
    if ! echo "$existing_resources" | grep -q "aws_cloudwatch_log_group"; then
        if aws logs describe-log-groups --log-group-name-prefix "/aws/eks/healthcare-eks-stage3-dev" --query 'logGroups[0].logGroupName' --output text 2>/dev/null | grep -q '/aws/eks/healthcare-eks-stage3-dev'; then
            log_info "📥 Importing CloudWatch log group..."
            
            local cw_paths=(
                "module.healthcare_infrastructure.module.eks.aws_cloudwatch_log_group.this[0]"
                "module.healthcare_infrastructure.module.eks.aws_cloudwatch_log_group.cluster[0]"
                "module.healthcare_infrastructure.aws_cloudwatch_log_group.eks"
            )
            
            local imported=false
            for path in "${cw_paths[@]}"; do
                if terraform import "$path" /aws/eks/healthcare-eks-stage3-dev/cluster 2>/dev/null; then
                    log_success "✅ CloudWatch log group imported via path: $path"
                    imported=true
                    break
                fi
            done
            
            if [[ "$imported" == "false" ]]; then
                log_warning "⚠️ CloudWatch log group import failed"
            fi
        fi
    else
        log_info "✅ CloudWatch log group already in Terraform state"
    fi
    
    # RDS Subnet Group
    if ! echo "$existing_resources" | grep -q "aws_db_subnet_group"; then
        if aws rds describe-db-subnet-groups --db-subnet-group-name healthcare-eks-stage3-dev-db-subnet-group >/dev/null 2>&1; then
            log_info "📥 Importing RDS subnet group..."
            
            if terraform import module.healthcare_infrastructure.aws_db_subnet_group.healthcare healthcare-eks-stage3-dev-db-subnet-group 2>/dev/null; then
                log_success "✅ RDS subnet group imported"
            else
                log_warning "⚠️ RDS subnet group import failed"
            fi
        fi
    else
        log_info "✅ RDS subnet group already in Terraform state"
    fi
    
    # S3 Assets Bucket
    if ! echo "$existing_resources" | grep -q "aws_s3_bucket.*healthcare_assets"; then
        local assets_bucket="healthcare-assets-stage3-dev-${ACCOUNT_ID}"
        if aws s3api head-bucket --bucket "$assets_bucket" 2>/dev/null; then
            log_info "📥 Importing S3 assets bucket..."
            
            if terraform import module.healthcare_infrastructure.aws_s3_bucket.healthcare_assets "$assets_bucket" 2>/dev/null; then
                log_success "✅ S3 assets bucket imported"
            else
                log_warning "⚠️ S3 assets bucket import failed"
            fi
        fi
    else
        log_info "✅ S3 assets bucket already in Terraform state"
    fi
    
    log_success "✅ Pre-import process completed"
}

# Alternative cleanup strategy
cleanup_conflicting_resources() {
    log_info "🧹 Cleaning up conflicting resources..."
    
    # Get current Terraform state resources
    local existing_resources
    existing_resources=$(terraform state list 2>/dev/null || echo "")
    
    # Only clean resources not managed by current Terraform state
    
    # Clean KMS alias if not in state
    if ! echo "$existing_resources" | grep -q "aws_kms_alias"; then
        if aws kms list-aliases --query "Aliases[?AliasName=='alias/eks/healthcare-eks-stage3-dev']" --output text | grep -q alias/eks/healthcare-eks-stage3-dev; then
            log_info "🗑️ Deleting existing KMS alias..."
            if aws kms delete-alias --alias-name alias/eks/healthcare-eks-stage3-dev 2>/dev/null; then
                log_success "✅ KMS alias deleted"
            else
                log_warning "⚠️ KMS alias deletion failed"
            fi
        fi
    fi
    
    # Clean CloudWatch log group if not in state
    if ! echo "$existing_resources" | grep -q "aws_cloudwatch_log_group"; then
        if aws logs describe-log-groups --log-group-name-prefix "/aws/eks/healthcare-eks-stage3-dev" --query 'logGroups[0].logGroupName' --output text 2>/dev/null | grep -q '/aws/eks/healthcare-eks-stage3-dev'; then
            log_info "🗑️ Deleting existing CloudWatch log group..."
            if aws logs delete-log-group --log-group-name /aws/eks/healthcare-eks-stage3-dev/cluster 2>/dev/null; then
                log_success "✅ CloudWatch log group deleted"
            else
                log_warning "⚠️ CloudWatch log group deletion failed"
            fi
        fi
    fi
    
    # Clean RDS subnet group if not in state
    if ! echo "$existing_resources" | grep -q "aws_db_subnet_group"; then
        if aws rds describe-db-subnet-groups --db-subnet-group-name healthcare-eks-stage3-dev-db-subnet-group >/dev/null 2>&1; then
            log_info "🗑️ Deleting existing RDS subnet group..."
            if aws rds delete-db-subnet-group --db-subnet-group-name healthcare-eks-stage3-dev-db-subnet-group 2>/dev/null; then
                log_success "✅ RDS subnet group deleted"
            else
                log_warning "⚠️ RDS subnet group deletion failed"
            fi
        fi
    fi
    
    # Clean S3 assets bucket if not in state (with confirmation)
    if ! echo "$existing_resources" | grep -q "aws_s3_bucket.*healthcare_assets"; then
        local assets_bucket="healthcare-assets-stage3-dev-${ACCOUNT_ID}"
        if aws s3api head-bucket --bucket "$assets_bucket" 2>/dev/null; then
            log_warning "🗑️ S3 bucket cleanup requires manual confirmation"
            log_info "To delete manually: aws s3 rb s3://$assets_bucket --force"
        fi
    fi
    
    log_success "✅ Cleanup process completed"
}

# Main execution function
handle_infrastructure_conflicts() {
    local strategy="${1:-import}"
    
    log_info "🔧 Handling infrastructure conflicts with strategy: $strategy"
    
    # Always run health check first
    check_infrastructure_health
    
    case "$strategy" in
        "import")
            log_info "📥 Using import strategy..."
            pre_import_existing_resources
            ;;
        "cleanup")
            log_info "🧹 Using cleanup strategy..."
            cleanup_conflicting_resources
            ;;
        "skip")
            log_info "⏭️ Skipping conflict handling..."
            ;;
        *)
            log_error "❌ Invalid conflict strategy: $strategy"
            log_info "Valid strategies: import, cleanup, skip"
            exit 1
            ;;
    esac
    
    log_success "✅ Infrastructure conflict handling completed"
}

# If script is run directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    STRATEGY="${1:-import}"
    handle_infrastructure_conflicts "$STRATEGY"
fi
