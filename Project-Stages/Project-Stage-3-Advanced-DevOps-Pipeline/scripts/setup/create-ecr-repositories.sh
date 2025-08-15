#!/bin/bash

# Create ECR Repositories for Stage-3
# This script creates the required ECR repositories for the Stage-3 pipeline

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
FRONTEND_REPO="healthcare-frontend-stage3"
BACKEND_REPO="healthcare-backend-stage3"

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

# Create ECR repository
create_ecr_repo() {
    local repo_name=$1
    
    log_info "Creating ECR repository: $repo_name"
    
    # Check if repository already exists
    if aws ecr describe-repositories --repository-names "$repo_name" --region "$AWS_REGION" &> /dev/null; then
        log_warning "Repository $repo_name already exists"
        return 0
    fi
    
    # Create repository
    if aws ecr create-repository \
        --repository-name "$repo_name" \
        --region "$AWS_REGION" \
        --image-scanning-configuration scanOnPush=true \
        --encryption-configuration encryptionType=AES256 &> /dev/null; then
        
        log_success "✅ Created repository: $repo_name"
        
        # Set lifecycle policy to manage image retention
        local lifecycle_policy='{
            "rules": [
                {
                    "rulePriority": 1,
                    "description": "Keep last 10 images",
                    "selection": {
                        "tagStatus": "any",
                        "countType": "imageCountMoreThan",
                        "countNumber": 10
                    },
                    "action": {
                        "type": "expire"
                    }
                }
            ]
        }'
        
        aws ecr put-lifecycle-policy \
            --repository-name "$repo_name" \
            --region "$AWS_REGION" \
            --lifecycle-policy-text "$lifecycle_policy" &> /dev/null
        
        log_info "Set lifecycle policy for $repo_name"
        return 0
    else
        log_error "❌ Failed to create repository: $repo_name"
        return 1
    fi
}

# Get repository URI
get_repo_uri() {
    local repo_name=$1
    aws ecr describe-repositories \
        --repository-names "$repo_name" \
        --region "$AWS_REGION" \
        --query 'repositories[0].repositoryUri' \
        --output text 2>/dev/null
}

# Main function
main() {
    echo "🏗️ ECR Repository Setup for Stage-3"
    echo "===================================="
    echo ""
    
    check_aws_cli
    
    local errors=0
    
    # Create frontend repository
    create_ecr_repo "$FRONTEND_REPO" || ((errors++))
    
    # Create backend repository
    create_ecr_repo "$BACKEND_REPO" || ((errors++))
    
    echo ""
    echo "📊 Repository Summary"
    echo "===================="
    
    # Display repository information
    local frontend_uri=$(get_repo_uri "$FRONTEND_REPO")
    local backend_uri=$(get_repo_uri "$BACKEND_REPO")
    
    if [[ -n "$frontend_uri" ]]; then
        log_success "Frontend Repository: $frontend_uri"
    else
        log_error "Frontend repository not found"
        ((errors++))
    fi
    
    if [[ -n "$backend_uri" ]]; then
        log_success "Backend Repository: $backend_uri"
    else
        log_error "Backend repository not found"
        ((errors++))
    fi
    
    echo ""
    echo "🔧 Next Steps"
    echo "============="
    echo "1. Repositories are ready for Docker image pushes"
    echo "2. GitHub Actions pipeline will use these repositories"
    echo "3. Images will be tagged with commit SHA and 'latest'"
    echo ""
    echo "📋 Repository Names for GitHub Secrets:"
    echo "- ECR_REPOSITORY_FRONTEND: $FRONTEND_REPO"
    echo "- ECR_REPOSITORY_BACKEND: $BACKEND_REPO"
    echo ""
    
    if [ $errors -eq 0 ]; then
        log_success "🎉 All ECR repositories created successfully!"
        return 0
    else
        log_error "❌ $errors errors occurred during repository creation"
        return 1
    fi
}

# Execute main function
main "$@"
