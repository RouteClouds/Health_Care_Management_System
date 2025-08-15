#!/bin/bash

# AWS Account ID Update Script
# Updates all files with the correct AWS Account ID for Stage-3

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
STAGE3_DIR="/home/ubuntu/Projects/Health_Care_Management_System/Project-Stages/Project-Stage-3-Advanced-DevOps-Pipeline"
OLD_ACCOUNT_ID="123456789012"
NEW_ACCOUNT_ID="867344452513"
AWS_REGION="us-east-1"
OLD_ECR_REGISTRY="${OLD_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
NEW_ECR_REGISTRY="${NEW_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

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

# Validation function
validate_file_exists() {
    local file="$1"
    if [[ ! -f "$file" ]]; then
        log_warning "File not found: $file (skipping)"
        return 1
    fi
    return 0
}

# Replace function with validation
safe_replace() {
    local file="$1"
    local search="$2"
    local replace="$3"
    local description="$4"
    
    if ! validate_file_exists "$file"; then
        return 0
    fi
    
    # Check if pattern exists
    if grep -q "$search" "$file"; then
        log_info "Updating $description in $(basename "$file")"
        sed -i "s|$search|$replace|g" "$file"
        
        # Verify change was made
        if grep -q "$replace" "$file"; then
            log_success "✅ Updated: $description"
        else
            log_error "❌ Failed to update: $description"
        fi
    else
        log_warning "Pattern not found in $file: $search"
    fi
}

# Main update function
update_aws_account_id() {
    log_info "🔄 Updating AWS Account ID from $OLD_ACCOUNT_ID to $NEW_ACCOUNT_ID"
    
    cd "$STAGE3_DIR"
    
    # Update ECR registry references
    log_info "📦 Updating ECR Registry References"
    
    # Kubernetes deployment files
    safe_replace "k8s/frontend-deployment.yaml" \
        "$OLD_ECR_REGISTRY" \
        "$NEW_ECR_REGISTRY" \
        "Frontend deployment ECR registry"
    
    safe_replace "k8s/backend-deployment.yaml" \
        "$OLD_ECR_REGISTRY" \
        "$NEW_ECR_REGISTRY" \
        "Backend deployment ECR registry"
    
    # Environment-specific deployments
    safe_replace "k8s/environments/development/frontend-deployment.yaml" \
        "$OLD_ECR_REGISTRY" \
        "$NEW_ECR_REGISTRY" \
        "Development frontend ECR registry"
    
    safe_replace "k8s/environments/development/backend-deployment.yaml" \
        "$OLD_ECR_REGISTRY" \
        "$NEW_ECR_REGISTRY" \
        "Development backend ECR registry"
    
    # Scripts
    log_info "📜 Updating Script Files"
    
    safe_replace "scripts/deployment/build-and-push-images.sh" \
        "$OLD_ECR_REGISTRY" \
        "$NEW_ECR_REGISTRY" \
        "Build script ECR registry"
    
    safe_replace "scripts/force-deployment-update.sh" \
        "$OLD_ECR_REGISTRY" \
        "$NEW_ECR_REGISTRY" \
        "Force deployment ECR registry"
    
    safe_replace "scripts/force-pod-restart.sh" \
        "$OLD_ECR_REGISTRY" \
        "$NEW_ECR_REGISTRY" \
        "Pod restart script ECR registry"
    
    safe_replace "scripts/migration/migrate-to-stage3.sh" \
        "$OLD_ACCOUNT_ID" \
        "$NEW_ACCOUNT_ID" \
        "Migration script AWS Account ID"
    
    # Helm charts
    log_info "⎈ Updating Helm Chart Files"
    
    safe_replace "helm-charts/healthcare-system/Chart.yaml" \
        "$OLD_ECR_REGISTRY" \
        "$NEW_ECR_REGISTRY" \
        "Helm Chart ECR registry"
    
    safe_replace "helm-charts/healthcare-system/values.yaml" \
        "$OLD_ECR_REGISTRY" \
        "$NEW_ECR_REGISTRY" \
        "Helm values ECR registry"
    
    # Configuration templates
    log_info "⚙️ Updating Configuration Templates"
    
    safe_replace "configs/docker-config.env.template" \
        "$OLD_ECR_REGISTRY" \
        "$NEW_ECR_REGISTRY" \
        "Docker config ECR registry"
    
    # Documentation files
    log_info "📚 Updating Documentation"
    
    safe_replace "Naming-Convention-For-Stage-3.md" \
        "$OLD_ACCOUNT_ID" \
        "$NEW_ACCOUNT_ID" \
        "Naming convention documentation AWS Account ID"
    
    safe_replace "Naming-Convention-For-Stage-3.md" \
        "$OLD_ECR_REGISTRY" \
        "$NEW_ECR_REGISTRY" \
        "Naming convention documentation ECR registry"
    
    # Update any remaining references in all YAML/YML files
    log_info "🔍 Scanning for remaining references"
    
    find . -name "*.yaml" -o -name "*.yml" | grep -v migration-backup | grep -v Extra | grep -v Test-Archive | while read file; do
        if grep -q "$OLD_ACCOUNT_ID" "$file" 2>/dev/null; then
            log_info "Found remaining reference in $file"
            sed -i "s|$OLD_ACCOUNT_ID|$NEW_ACCOUNT_ID|g" "$file"
            log_success "Updated $file"
        fi
        if grep -q "$OLD_ECR_REGISTRY" "$file" 2>/dev/null; then
            log_info "Found remaining ECR reference in $file"
            sed -i "s|$OLD_ECR_REGISTRY|$NEW_ECR_REGISTRY|g" "$file"
            log_success "Updated ECR reference in $file"
        fi
    done
}

# Validation function
validate_update() {
    log_info "🔍 Validating AWS Account ID update..."
    
    local errors=0
    
    # Check for remaining old account ID references
    log_info "Checking for remaining old Account ID references..."
    if find . -name "*.yaml" -o -name "*.yml" -o -name "*.sh" -o -name "*.md" | grep -v migration-backup | grep -v Extra | grep -v Test-Archive | xargs grep -l "$OLD_ACCOUNT_ID" 2>/dev/null; then
        log_warning "Found remaining old Account ID references"
        ((errors++))
    fi
    
    # Check for new account ID implementations
    log_info "Verifying new Account ID implementations..."
    if find . -name "*.yaml" -o -name "*.yml" -o -name "*.sh" | grep -v migration-backup | grep -v Extra | grep -v Test-Archive | xargs grep -l "$NEW_ACCOUNT_ID" 2>/dev/null | wc -l | grep -q "^[1-9]"; then
        log_success "Found new Account ID implementations"
    else
        log_error "No new Account ID found"
        ((errors++))
    fi
    
    if [[ $errors -eq 0 ]]; then
        log_success "✅ AWS Account ID update validation passed"
        return 0
    else
        log_error "❌ AWS Account ID update validation failed with $errors errors"
        return 1
    fi
}

# Main execution
main() {
    echo "🔄 AWS Account ID Update Script"
    echo "==============================="
    echo "Updating from: $OLD_ACCOUNT_ID"
    echo "Updating to:   $NEW_ACCOUNT_ID"
    echo "ECR Registry:  $NEW_ECR_REGISTRY"
    echo ""
    
    # Confirm execution
    read -p "Do you want to proceed with the AWS Account ID update? (y/N): " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        log_info "Update cancelled by user"
        exit 0
    fi
    
    # Execute update
    update_aws_account_id
    
    # Validate results
    if validate_update; then
        log_success "🎉 AWS Account ID update completed successfully!"
        log_info "Updated Account ID: $NEW_ACCOUNT_ID"
        log_info "Updated ECR Registry: $NEW_ECR_REGISTRY"
        log_info "Next steps:"
        log_info "1. Review changes with: git diff"
        log_info "2. Test ECR authentication: aws ecr get-login-password --region $AWS_REGION"
        log_info "3. Create ECR repositories if needed"
    else
        log_error "Update completed with warnings. Please review manually."
    fi
}

# Execute main function
main "$@"
