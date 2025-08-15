#!/bin/bash

# Cleanup Existing Resources Script
# This script removes existing AWS resources that conflict with Terraform deployment

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Configuration
AWS_REGION="${AWS_REGION:-us-east-1}"
CLUSTER_NAME="healthcare-eks-stage3-dev"
KMS_ALIAS="alias/eks/healthcare-eks-stage3-dev"
LOG_GROUP="/aws/eks/healthcare-eks-stage3-dev/cluster"
DB_SUBNET_GROUP="healthcare-eks-stage3-dev-db-subnet-group"
S3_BUCKET="healthcare-assets-stage3-dev-867344452513"

# Check AWS CLI
check_aws_cli() {
    if ! command -v aws &> /dev/null; then
        log_error "AWS CLI not found. Please install AWS CLI first."
        exit 1
    fi
    
    # Check AWS credentials
    if ! aws sts get-caller-identity &> /dev/null; then
        log_error "AWS credentials not configured. Please run 'aws configure' first."
        exit 1
    fi
    
    local account_id=$(aws sts get-caller-identity --query Account --output text)
    log_info "Using AWS Account: $account_id"
    log_info "Using AWS Region: $AWS_REGION"
}

# Clean up KMS Alias
cleanup_kms_alias() {
    log_info "Checking KMS alias: $KMS_ALIAS"
    
    if aws kms describe-key --key-id "$KMS_ALIAS" --region "$AWS_REGION" &> /dev/null; then
        log_warning "KMS alias $KMS_ALIAS exists. Deleting..."
        
        # Get the target key ID
        local key_id=$(aws kms list-aliases --query "Aliases[?AliasName=='$KMS_ALIAS'].TargetKeyId" --output text --region "$AWS_REGION")
        
        if [[ -n "$key_id" ]]; then
            # Delete the alias first
            if aws kms delete-alias --alias-name "$KMS_ALIAS" --region "$AWS_REGION"; then
                log_success "✅ Deleted KMS alias: $KMS_ALIAS"
                
                # Schedule key deletion (minimum 7 days)
                if aws kms schedule-key-deletion --key-id "$key_id" --pending-window-in-days 7 --region "$AWS_REGION" &> /dev/null; then
                    log_success "✅ Scheduled KMS key deletion: $key_id"
                else
                    log_warning "⚠️ Could not schedule key deletion (may already be scheduled)"
                fi
            else
                log_error "❌ Failed to delete KMS alias: $KMS_ALIAS"
                return 1
            fi
        fi
    else
        log_info "KMS alias $KMS_ALIAS does not exist"
    fi
}

# Clean up CloudWatch Log Group
cleanup_log_group() {
    log_info "Checking CloudWatch log group: $LOG_GROUP"
    
    if aws logs describe-log-groups --log-group-name-prefix "$LOG_GROUP" --region "$AWS_REGION" --query 'logGroups[0]' --output text &> /dev/null; then
        log_warning "Log group $LOG_GROUP exists. Deleting..."
        
        if aws logs delete-log-group --log-group-name "$LOG_GROUP" --region "$AWS_REGION"; then
            log_success "✅ Deleted log group: $LOG_GROUP"
        else
            log_error "❌ Failed to delete log group: $LOG_GROUP"
            return 1
        fi
    else
        log_info "Log group $LOG_GROUP does not exist"
    fi
}

# Clean up RDS DB Subnet Group
cleanup_db_subnet_group() {
    log_info "Checking RDS DB subnet group: $DB_SUBNET_GROUP"
    
    if aws rds describe-db-subnet-groups --db-subnet-group-name "$DB_SUBNET_GROUP" --region "$AWS_REGION" &> /dev/null; then
        log_warning "DB subnet group $DB_SUBNET_GROUP exists. Deleting..."
        
        if aws rds delete-db-subnet-group --db-subnet-group-name "$DB_SUBNET_GROUP" --region "$AWS_REGION"; then
            log_success "✅ Deleted DB subnet group: $DB_SUBNET_GROUP"
        else
            log_error "❌ Failed to delete DB subnet group: $DB_SUBNET_GROUP"
            return 1
        fi
    else
        log_info "DB subnet group $DB_SUBNET_GROUP does not exist"
    fi
}

# Clean up S3 Bucket
cleanup_s3_bucket() {
    log_info "Checking S3 bucket: $S3_BUCKET"
    
    if aws s3 ls "s3://$S3_BUCKET" --region "$AWS_REGION" &> /dev/null; then
        log_warning "S3 bucket $S3_BUCKET exists. Deleting..."
        
        # Empty the bucket first
        log_info "Emptying S3 bucket..."
        if aws s3 rm "s3://$S3_BUCKET" --recursive --region "$AWS_REGION"; then
            log_success "✅ Emptied S3 bucket: $S3_BUCKET"
        fi
        
        # Delete the bucket
        if aws s3 rb "s3://$S3_BUCKET" --region "$AWS_REGION"; then
            log_success "✅ Deleted S3 bucket: $S3_BUCKET"
        else
            log_error "❌ Failed to delete S3 bucket: $S3_BUCKET"
            return 1
        fi
    else
        log_info "S3 bucket $S3_BUCKET does not exist"
    fi
}

# Main function
main() {
    echo "🧹 Cleanup Existing Resources for Stage-3"
    echo "=========================================="
    echo ""
    
    check_aws_cli
    
    local errors=0
    
    # Clean up resources in reverse dependency order
    cleanup_s3_bucket || ((errors++))
    cleanup_db_subnet_group || ((errors++))
    cleanup_log_group || ((errors++))
    cleanup_kms_alias || ((errors++))
    
    echo ""
    echo "📊 Cleanup Summary"
    echo "=================="
    
    if [ $errors -eq 0 ]; then
        log_success "🎉 All conflicting resources cleaned up successfully!"
        echo ""
        echo "🚀 Next Steps:"
        echo "1. Run Terraform apply again"
        echo "2. Monitor the deployment progress"
        echo "3. Verify all resources are created successfully"
        return 0
    else
        log_error "❌ $errors errors occurred during cleanup"
        echo ""
        echo "🔧 Manual Cleanup Required:"
        echo "1. Check AWS console for remaining resources"
        echo "2. Delete any remaining conflicting resources manually"
        echo "3. Retry Terraform deployment"
        return 1
    fi
}

# Execute main function
main "$@"
