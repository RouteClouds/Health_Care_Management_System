#!/bin/bash

# Create AWS Backend Resources for Stage-3 Terraform
# This script creates the S3 bucket and DynamoDB table required for Terraform backend

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration - Auto-detect AWS Account ID and generate unique bucket name
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text 2>/dev/null)
AWS_REGION="us-east-1"

# Generate 4-digit random suffix for unique bucket naming
RANDOM_SUFFIX=$(shuf -i 1000-9999 -n 1)
S3_BUCKET="healthcare-terraform-state-stage3-${AWS_ACCOUNT_ID}-${RANDOM_SUFFIX}"
DYNAMODB_TABLE="healthcare-terraform-locks-stage3"

# Store bucket name for other scripts
BUCKET_NAME_FILE="${HOME}/.healthcare-stage3-bucket-name"

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

# Check AWS CLI configuration
check_aws_config() {
    log_info "Checking AWS configuration..."

    if ! aws sts get-caller-identity > /dev/null 2>&1; then
        log_error "AWS CLI not configured or credentials invalid"
        log_info "Please run: aws configure"
        exit 1
    fi

    # Validate AWS Account ID was retrieved
    if [[ -z "$AWS_ACCOUNT_ID" ]]; then
        log_error "Failed to retrieve AWS Account ID"
        exit 1
    fi

    log_success "AWS configuration verified"
    log_info "AWS Account ID: $AWS_ACCOUNT_ID"
    log_info "S3 Bucket Name: $S3_BUCKET (with random suffix: $RANDOM_SUFFIX)"
}

# Create S3 bucket for Terraform state
create_s3_bucket() {
    log_info "Creating S3 bucket: $S3_BUCKET"
    
    # Check if bucket already exists
    if aws s3 ls "s3://$S3_BUCKET" > /dev/null 2>&1; then
        log_warning "S3 bucket $S3_BUCKET already exists"
        return 0
    fi
    
    # Create bucket
    if aws s3 mb "s3://$S3_BUCKET" --region "$AWS_REGION"; then
        log_success "S3 bucket created: $S3_BUCKET"
    else
        log_error "Failed to create S3 bucket"
        exit 1
    fi
    
    # Enable versioning
    log_info "Enabling versioning on S3 bucket..."
    if aws s3api put-bucket-versioning \
        --bucket "$S3_BUCKET" \
        --versioning-configuration Status=Enabled; then
        log_success "Versioning enabled on S3 bucket"
    else
        log_warning "Failed to enable versioning"
    fi
    
    # Enable encryption
    log_info "Enabling encryption on S3 bucket..."
    if aws s3api put-bucket-encryption \
        --bucket "$S3_BUCKET" \
        --server-side-encryption-configuration '{
            "Rules": [
                {
                    "ApplyServerSideEncryptionByDefault": {
                        "SSEAlgorithm": "AES256"
                    }
                }
            ]
        }'; then
        log_success "Encryption enabled on S3 bucket"
    else
        log_warning "Failed to enable encryption"
    fi
}

# Create DynamoDB table for state locking
create_dynamodb_table() {
    log_info "Creating DynamoDB table: $DYNAMODB_TABLE"
    
    # Check if table already exists
    if aws dynamodb describe-table --table-name "$DYNAMODB_TABLE" --region "$AWS_REGION" > /dev/null 2>&1; then
        log_warning "DynamoDB table $DYNAMODB_TABLE already exists"
        return 0
    fi
    
    # Create table
    if aws dynamodb create-table \
        --table-name "$DYNAMODB_TABLE" \
        --attribute-definitions AttributeName=LockID,AttributeType=S \
        --key-schema AttributeName=LockID,KeyType=HASH \
        --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
        --region "$AWS_REGION" > /dev/null; then
        log_success "DynamoDB table created: $DYNAMODB_TABLE"
    else
        log_error "Failed to create DynamoDB table"
        exit 1
    fi
    
    # Wait for table to be active
    log_info "Waiting for DynamoDB table to be active..."
    if aws dynamodb wait table-exists --table-name "$DYNAMODB_TABLE" --region "$AWS_REGION"; then
        log_success "DynamoDB table is active"
    else
        log_warning "Timeout waiting for table to be active"
    fi
}

# Verify resources
verify_resources() {
    log_info "Verifying created resources..."
    
    # Verify S3 bucket
    if aws s3 ls "s3://$S3_BUCKET" > /dev/null 2>&1; then
        log_success "✅ S3 bucket verified: $S3_BUCKET"
    else
        log_error "❌ S3 bucket verification failed"
        exit 1
    fi
    
    # Verify DynamoDB table
    if aws dynamodb describe-table --table-name "$DYNAMODB_TABLE" --region "$AWS_REGION" > /dev/null 2>&1; then
        log_success "✅ DynamoDB table verified: $DYNAMODB_TABLE"
    else
        log_error "❌ DynamoDB table verification failed"
        exit 1
    fi
}

# Save bucket name for other scripts
save_bucket_name() {
    log_info "Saving bucket name for other scripts..."

    # Save to file for other scripts to use
    echo "$S3_BUCKET" > "$BUCKET_NAME_FILE"

    # Also save to environment variables file if it exists
    if [[ -f "${HOME}/.healthcare-stage3-env" ]]; then
        sed -i "/^S3_BUCKET=/d" "${HOME}/.healthcare-stage3-env"
        echo "S3_BUCKET=$S3_BUCKET" >> "${HOME}/.healthcare-stage3-env"
    fi

    log_success "Bucket name saved to $BUCKET_NAME_FILE"
}

# Update terraform backend configurations
update_terraform_backend() {
    log_info "Updating Terraform backend configurations..."

    local terraform_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

    # Update main backend.tf
    if [[ -f "$terraform_dir/terraform/backend.tf" ]]; then
        sed -i "s/healthcare-terraform-state-stage3-[0-9]*/healthcare-terraform-state-stage3-${AWS_ACCOUNT_ID}-${RANDOM_SUFFIX}/g" "$terraform_dir/terraform/backend.tf"
        log_success "Updated terraform/backend.tf"
    fi

    # Update environments/dev/providers.tf
    if [[ -f "$terraform_dir/terraform/environments/dev/providers.tf" ]]; then
        sed -i "s/healthcare-terraform-state-stage3-[0-9]*/healthcare-terraform-state-stage3-${AWS_ACCOUNT_ID}-${RANDOM_SUFFIX}/g" "$terraform_dir/terraform/environments/dev/providers.tf"
        log_success "Updated terraform/environments/dev/providers.tf"
    fi

    log_success "Terraform backend configurations updated"
}

# Main execution
main() {
    echo "🚀 AWS Backend Resources Setup for Stage-3"
    echo "==========================================="
    echo "S3 Bucket: $S3_BUCKET"
    echo "DynamoDB Table: $DYNAMODB_TABLE"
    echo "AWS Region: $AWS_REGION"
    echo ""
    
    # Confirm execution
    read -p "Create AWS backend resources? (y/N): " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        log_info "Setup cancelled by user"
        exit 0
    fi
    
    # Execute setup
    check_aws_config
    create_s3_bucket
    create_dynamodb_table
    verify_resources
    save_bucket_name
    update_terraform_backend

    log_success "🎉 AWS backend resources created successfully!"
    echo ""
    log_info "Next steps:"
    log_info "1. Run: cd terraform/environments/dev"
    log_info "2. Run: terraform init"
    log_info "3. Run: terraform plan"
    log_info "4. Run: terraform apply"
}

# Execute main function
main "$@"
