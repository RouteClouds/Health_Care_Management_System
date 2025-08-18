#!/bin/bash

# Stage-3 Environment Variables Setup Script
# This script configures all necessary environment variables for Stage-3 deployment

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Logging functions
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    # Check AWS CLI
    if ! command -v aws &> /dev/null; then
        log_error "AWS CLI is not installed. Please install it first."
        exit 1
    fi
    
    # Check AWS credentials
    if ! aws sts get-caller-identity &> /dev/null; then
        log_error "AWS credentials not configured. Please run 'aws configure' first."
        exit 1
    fi
    
    log_success "Prerequisites check completed"
}

# Get current directory and validate
validate_project_directory() {
    log_info "Validating project directory..."
    
    CURRENT_DIR=$(pwd)
    
    # Check if we're in the correct directory
    if [[ ! "$CURRENT_DIR" == *"Project-Stage-3-Advanced-DevOps-Pipeline" ]]; then
        log_error "Please run this script from the Stage-3 project directory:"
        log_error "cd Project-Stages/Project-Stage-3-Advanced-DevOps-Pipeline"
        exit 1
    fi
    
    # Validate directory structure
    if [[ ! -d "scripts" ]] || [[ ! -d "terraform" ]] || [[ ! -d "src-code" ]]; then
        log_error "Invalid project directory structure. Please ensure you're in the correct Stage-3 directory."
        exit 1
    fi
    
    log_success "Project directory validated"
}

# Setup environment variables
setup_environment_variables() {
    log_info "Setting up Stage-3 environment variables..."
    
    # Get current directory as project root
    export STAGE3_PROJECT_ROOT=$(pwd)
    
    # Set AWS region (default to us-east-1)
    export AWS_REGION="us-east-1"
    
    # Get AWS Account ID
    log_info "Getting AWS Account ID..."
    export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
    
    if [[ -z "$AWS_ACCOUNT_ID" ]]; then
        log_error "Failed to get AWS Account ID. Please check your AWS credentials."
        exit 1
    fi
    
    # Set predefined cluster and ECR names (these will be created later)
    export STAGE3_CLUSTER_NAME="healthcare-eks-stage3-dev"
    export STAGE3_ECR_REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
    
    # Additional useful variables
    export STAGE3_NAMESPACE="healthcare-stage3-dev"
    export STAGE3_DB_NAME="healthcare_db"
    export STAGE3_ENVIRONMENT="dev"
    
    log_success "Environment variables configured"
}

# Save environment variables to bashrc
save_environment_variables() {
    log_info "Saving environment variables to ~/.bashrc..."
    
    # Create backup of bashrc
    cp ~/.bashrc ~/.bashrc.backup.$(date +%Y%m%d_%H%M%S)
    
    # Remove any existing Stage-3 environment variables
    sed -i '/# Stage-3 Environment Variables/,/# End Stage-3 Environment Variables/d' ~/.bashrc
    
    # Add new environment variables
    cat >> ~/.bashrc << EOF

# Stage-3 Environment Variables
export STAGE3_PROJECT_ROOT="${STAGE3_PROJECT_ROOT}"
export AWS_REGION="${AWS_REGION}"
export AWS_ACCOUNT_ID="${AWS_ACCOUNT_ID}"
export STAGE3_CLUSTER_NAME="${STAGE3_CLUSTER_NAME}"
export STAGE3_ECR_REGISTRY="${STAGE3_ECR_REGISTRY}"
export STAGE3_NAMESPACE="${STAGE3_NAMESPACE}"
export STAGE3_DB_NAME="${STAGE3_DB_NAME}"
export STAGE3_ENVIRONMENT="${STAGE3_ENVIRONMENT}"
# End Stage-3 Environment Variables
EOF
    
    log_success "Environment variables saved to ~/.bashrc"
}

# Display environment variables
display_environment_variables() {
    log_info "Current Stage-3 environment variables:"
    
    echo "=================================="
    echo "STAGE3_PROJECT_ROOT: $STAGE3_PROJECT_ROOT"
    echo "AWS_REGION: $AWS_REGION"
    echo "AWS_ACCOUNT_ID: $AWS_ACCOUNT_ID"
    echo "STAGE3_CLUSTER_NAME: $STAGE3_CLUSTER_NAME"
    echo "STAGE3_ECR_REGISTRY: $STAGE3_ECR_REGISTRY"
    echo "STAGE3_NAMESPACE: $STAGE3_NAMESPACE"
    echo "STAGE3_DB_NAME: $STAGE3_DB_NAME"
    echo "STAGE3_ENVIRONMENT: $STAGE3_ENVIRONMENT"
    echo "=================================="
}

# Verify environment setup
verify_environment_setup() {
    log_info "Verifying environment setup..."
    
    # Source the bashrc to load variables
    source ~/.bashrc
    
    # Check if variables are set
    local vars_to_check=(
        "STAGE3_PROJECT_ROOT"
        "AWS_REGION"
        "AWS_ACCOUNT_ID"
        "STAGE3_CLUSTER_NAME"
        "STAGE3_ECR_REGISTRY"
    )
    
    local all_set=true
    for var in "${vars_to_check[@]}"; do
        if [[ -z "${!var:-}" ]]; then
            log_error "Environment variable $var is not set"
            all_set=false
        fi
    done
    
    if [[ "$all_set" == "true" ]]; then
        log_success "All environment variables are properly configured"
    else
        log_error "Some environment variables are missing. Please run the script again."
        exit 1
    fi
}

# Create environment file for scripts
create_env_file() {
    log_info "Creating .env file for scripts..."

    cat > "${STAGE3_PROJECT_ROOT}/.env" << EOF
# Stage-3 Environment Configuration
# This file is used by scripts for consistent environment setup

STAGE3_PROJECT_ROOT=${STAGE3_PROJECT_ROOT}
AWS_REGION=${AWS_REGION}
AWS_ACCOUNT_ID=${AWS_ACCOUNT_ID}
STAGE3_CLUSTER_NAME=${STAGE3_CLUSTER_NAME}
STAGE3_ECR_REGISTRY=${STAGE3_ECR_REGISTRY}
STAGE3_NAMESPACE=${STAGE3_NAMESPACE}
STAGE3_DB_NAME=${STAGE3_DB_NAME}
STAGE3_ENVIRONMENT=${STAGE3_ENVIRONMENT}

# Generated on: $(date)
EOF

    log_success ".env file created at ${STAGE3_PROJECT_ROOT}/.env"
}

# Replace AWS Account ID in all configuration files
replace_aws_account_id() {
    log_info "Replacing AWS Account ID in configuration files..."

    local old_account_id="867344452513"
    local files_updated=0

    # Define file patterns to search
    local file_patterns=(
        "terraform/**/*.tf"
        "terraform/**/*.tfvars"
        "k8s/**/*.yaml"
        "k8s/**/*.yml"
        "gitops/**/*.yaml"
        "gitops/**/*.yml"
        "scripts/**/*.sh"
        "*.md"
        "docs/**/*.md"
    )

    log_info "Searching for files with old AWS Account ID: $old_account_id"

    # Process each file pattern
    for pattern in "${file_patterns[@]}"; do
        while IFS= read -r -d '' file; do
            if [[ -f "$file" ]] && grep -q "$old_account_id" "$file" 2>/dev/null; then
                log_info "Updating: $file"
                sed -i "s/$old_account_id/$AWS_ACCOUNT_ID/g" "$file"
                ((files_updated++))
            fi
        done < <(find . -path "./Test-Archive" -prune -o -path "./.git" -prune -o -name "$pattern" -type f -print0 2>/dev/null)
    done

    log_success "Updated $files_updated files with new AWS Account ID: $AWS_ACCOUNT_ID"
}

# Update ECR registry URLs
update_ecr_registry() {
    log_info "Updating ECR registry URLs..."

    local old_registry="867344452513.dkr.ecr.us-east-1.amazonaws.com"
    local files_updated=0

    # Define file patterns to search
    local file_patterns=(
        "k8s/**/*.yaml"
        "k8s/**/*.yml"
        "gitops/**/*.yaml"
        "gitops/**/*.yml"
        "scripts/**/*.sh"
    )

    log_info "Searching for files with old ECR registry: $old_registry"

    # Process each file pattern
    for pattern in "${file_patterns[@]}"; do
        while IFS= read -r -d '' file; do
            if [[ -f "$file" ]] && grep -q "$old_registry" "$file" 2>/dev/null; then
                log_info "Updating ECR registry in: $file"
                sed -i "s|$old_registry|$STAGE3_ECR_REGISTRY|g" "$file"
                ((files_updated++))
            fi
        done < <(find . -path "./Test-Archive" -prune -o -path "./.git" -prune -o -name "$pattern" -type f -print0 2>/dev/null)
    done

    log_success "Updated $files_updated files with new ECR registry: $STAGE3_ECR_REGISTRY"
}

# Main execution
main() {
    echo "🚀 Stage-3 Environment Variables Setup"
    echo "======================================"
    
    check_prerequisites
    validate_project_directory
    setup_environment_variables
    save_environment_variables
    create_env_file
    replace_aws_account_id
    update_ecr_registry
    display_environment_variables
    verify_environment_setup
    
    echo
    log_success "🎉 Environment setup completed successfully!"
    echo
    echo "📋 Next steps:"
    echo "1. Run 'source ~/.bashrc' to load variables in current session"
    echo "2. Proceed with AWS backend setup: ./scripts/setup/create-aws-backend.sh"
    echo "3. Create ECR repositories: ./scripts/setup/create-ecr-repositories.sh"
    echo
    echo "💡 Note: The cluster and ECR registry names are predefined and will be created in later steps."
}

# Execute main function
main "$@"
