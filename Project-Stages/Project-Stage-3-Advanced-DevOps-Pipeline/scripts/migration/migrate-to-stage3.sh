#!/bin/bash

# Stage-3 Automated Migration Script
# Applies comprehensive naming convention changes from Stage-2 to Stage-3
# Based on: Naming-Convention-For-Stage-3.md

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
STAGE3_DIR="/home/ubuntu/Projects/Health_Care_Management_System/Project-Stages/Project-Stage-3-Advanced-DevOps-Pipeline"
BACKUP_DIR="${STAGE3_DIR}/migration-backup-$(date +%Y%m%d-%H%M%S)"
AWS_ACCOUNT_ID="867344452513"  # Replace with actual account ID
AWS_REGION="us-east-1"
ECR_REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

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

# Backup function
create_backup() {
    log_info "Creating backup of files before migration..."
    mkdir -p "$BACKUP_DIR"
    
    # Backup critical files
    cp -r "$STAGE3_DIR/src-code" "$BACKUP_DIR/" 2>/dev/null || true
    cp -r "$STAGE3_DIR/k8s" "$BACKUP_DIR/" 2>/dev/null || true
    cp -r "$STAGE3_DIR/helm-charts" "$BACKUP_DIR/" 2>/dev/null || true
    cp -r "$STAGE3_DIR/scripts" "$BACKUP_DIR/" 2>/dev/null || true
    cp -r "$STAGE3_DIR/configs" "$BACKUP_DIR/" 2>/dev/null || true
    
    log_success "Backup created at: $BACKUP_DIR"
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

# Main migration function
migrate_naming_conventions() {
    log_info "🚀 Starting Stage-3 naming convention migration..."
    
    cd "$STAGE3_DIR"
    
    # Section 1: Package.json Files
    log_info "📦 Section 1: Updating Package.json Files"
    
    # 1.1 Root package.json
    safe_replace "src-code/package.json" \
        '"name": "healthcare-management-system"' \
        '"name": "healthcare-management-system-stage3"' \
        "Root package name"
    
    safe_replace "src-code/package.json" \
        "Stage 2 Pipeline Active" \
        "Stage 3 Advanced DevOps" \
        "Root package description"
    
    # 1.2 Backend package.json
    safe_replace "src-code/backend/package.json" \
        '"name": "healthcare-backend"' \
        '"name": "healthcare-backend-stage3"' \
        "Backend package name"
    
    # 1.3 Frontend package.json
    safe_replace "src-code/frontend/package.json" \
        '"name": "routeclouds-health"' \
        '"name": "routeclouds-health-stage3"' \
        "Frontend package name"
    
    # Section 2: Kubernetes Deployment Files
    log_info "☸️ Section 2: Updating Kubernetes Deployment Files"
    
    # 2.1 Frontend deployment
    safe_replace "k8s/frontend-deployment.yaml" \
        "routeclouds/healthcare-frontend:latest" \
        "${ECR_REGISTRY}/healthcare-frontend-stage3:latest" \
        "Frontend deployment image"
    
    # 2.2 Backend deployment
    safe_replace "k8s/backend-deployment.yaml" \
        "routeclouds/healthcare-backend:latest" \
        "${ECR_REGISTRY}/healthcare-backend-stage3:latest" \
        "Backend deployment image"
    
    # 2.3 Environment-specific deployments
    safe_replace "k8s/environments/development/frontend-deployment.yaml" \
        "routeclouds/healthcare-frontend:v1.0" \
        "${ECR_REGISTRY}/healthcare-frontend-stage3:dev" \
        "Development frontend image"
    
    safe_replace "k8s/environments/development/backend-deployment.yaml" \
        "routeclouds/healthcare-backend:v1.0" \
        "${ECR_REGISTRY}/healthcare-backend-stage3:dev" \
        "Development backend image"
    
    # Section 3: Database Configuration
    log_info "🗄️ Section 3: Updating Database Configuration"
    
    # 3.1 Database initialization
    safe_replace "src-code/backend/prisma/init.sql" \
        "healthcare_db" \
        "healthcare_stage3_db" \
        "Database name references"
    
    safe_replace "src-code/backend/prisma/init.sql" \
        "healthcare_user" \
        "healthcare_stage3_user" \
        "Database user references"
    
    # Section 4: Helm Chart Values
    log_info "⎈ Section 4: Updating Helm Chart Values"
    
    # 4.1 Development values
    safe_replace "helm-charts/healthcare-system/values/development.yaml" \
        "Stage 2" \
        "Stage 3" \
        "Helm chart stage reference"
    
    safe_replace "helm-charts/healthcare-system/values/development.yaml" \
        "healthcare-dev.local" \
        "healthcare-stage3-dev.local" \
        "Development domain"
    
    safe_replace "helm-charts/healthcare-system/values/development.yaml" \
        "api-healthcare-dev.local" \
        "api-healthcare-stage3-dev.local" \
        "Development API domain"
    
    safe_replace "helm-charts/healthcare-system/values/development.yaml" \
        "postgresql://healthcare:password@healthcare-system-postgresql:5432/healthcare_db" \
        "postgresql://healthcare_stage3:password@healthcare-system-stage3-postgresql:5432/healthcare_stage3_db" \
        "Development database URL"
    
    safe_replace "helm-charts/healthcare-system/values/development.yaml" \
        'username: "healthcare"' \
        'username: "healthcare_stage3"' \
        "Development database username"
    
    safe_replace "helm-charts/healthcare-system/values/development.yaml" \
        'database: "healthcare_db"' \
        'database: "healthcare_stage3_db"' \
        "Development database name"
    
    # 4.2 Production values
    safe_replace "helm-charts/healthcare-system/values/production.yaml" \
        "healthcare.example.com" \
        "stage3.healthcare.example.com" \
        "Production domain"
    
    safe_replace "helm-charts/healthcare-system/values/production.yaml" \
        "api.healthcare.example.com" \
        "api.stage3.healthcare.example.com" \
        "Production API domain"
    
    # Section 5: Scripts and Automation
    log_info "📜 Section 5: Updating Scripts and Automation"
    
    # 5.1 Build and push script
    safe_replace "scripts/deployment/build-and-push-images.sh" \
        "Stage 2" \
        "Stage 3" \
        "Build script stage reference"
    
    safe_replace "scripts/deployment/build-and-push-images.sh" \
        'DOCKER_REGISTRY="routeclouds"' \
        'ECR_REGISTRY="'${ECR_REGISTRY}'"' \
        "Docker registry configuration"
    
    safe_replace "scripts/deployment/build-and-push-images.sh" \
        'BACKEND_IMAGE="${DOCKER_REGISTRY}/healthcare-backend"' \
        'BACKEND_IMAGE="${ECR_REGISTRY}/healthcare-backend-stage3"' \
        "Backend image name"
    
    safe_replace "scripts/deployment/build-and-push-images.sh" \
        'FRONTEND_IMAGE="${DOCKER_REGISTRY}/healthcare-frontend"' \
        'FRONTEND_IMAGE="${ECR_REGISTRY}/healthcare-frontend-stage3"' \
        "Frontend image name"
    
    # 5.2 Force deployment script
    safe_replace "scripts/force-deployment-update.sh" \
        'DOCKERHUB_USERNAME="routeclouds"' \
        'ECR_REGISTRY="'${ECR_REGISTRY}'"' \
        "Force deployment registry"
    
    safe_replace "scripts/force-deployment-update.sh" \
        'routeclouds/healthcare-frontend' \
        "${ECR_REGISTRY}/healthcare-frontend-stage3" \
        "Force deployment frontend image"
    
    safe_replace "scripts/force-deployment-update.sh" \
        'routeclouds/healthcare-backend' \
        "${ECR_REGISTRY}/healthcare-backend-stage3" \
        "Force deployment backend image"
    
    # Section 6: Configuration Templates
    log_info "⚙️ Section 6: Updating Configuration Templates"
    
    # 6.1 Docker configuration
    safe_replace "configs/docker-config.env.template" \
        "DOCKER_HUB_USERNAME=your-dockerhub-username" \
        "ECR_REGISTRY=${ECR_REGISTRY}" \
        "Docker configuration registry"
    
    safe_replace "configs/docker-config.env.template" \
        "DOCKER_HUB_PASSWORD=your-dockerhub-password" \
        "ECR_REPOSITORY_FRONTEND=healthcare-frontend-stage3" \
        "Docker configuration frontend repo"
    
    # Add ECR backend repository line
    if validate_file_exists "configs/docker-config.env.template"; then
        echo "ECR_REPOSITORY_BACKEND=healthcare-backend-stage3" >> "configs/docker-config.env.template"
    fi
    
    # Section 7: Application Code
    log_info "💻 Section 7: Updating Application Code"
    
    # 7.1 Backend application
    safe_replace "src-code/backend/src/app.ts" \
        "RouteClouds Health Platform API" \
        "RouteClouds Health Platform API - Stage 3" \
        "Backend API message"
    
    # 7.2 Frontend components
    safe_replace "src-code/frontend/src/components/layout/Header.tsx" \
        "RouteClouds Health" \
        "RouteClouds Health - Stage 3" \
        "Frontend header title"
    
    safe_replace "src-code/frontend/src/components/layout/Footer.tsx" \
        "RouteClouds Health" \
        "RouteClouds Health - Stage 3" \
        "Frontend footer title"
}

# Validation function
validate_migration() {
    log_info "🔍 Validating migration results..."
    
    local errors=0
    
    # Check for remaining Stage-2 references
    log_info "Checking for remaining Stage-2 references..."
    if grep -r "routeclouds/healthcare" "$STAGE3_DIR" --exclude-dir=migration-backup* --exclude-dir=Extra --exclude="*.md" 2>/dev/null; then
        log_warning "Found remaining routeclouds/healthcare references"
        ((errors++))
    fi
    
    # Check for Stage-3 implementations
    log_info "Verifying Stage-3 implementations..."
    if grep -r "healthcare.*stage3" "$STAGE3_DIR" --exclude-dir=migration-backup* --exclude-dir=Extra 2>/dev/null | wc -l | grep -q "^[1-9]"; then
        log_success "Found Stage-3 naming implementations"
    else
        log_error "No Stage-3 naming found"
        ((errors++))
    fi
    
    if [[ $errors -eq 0 ]]; then
        log_success "✅ Migration validation passed"
        return 0
    else
        log_error "❌ Migration validation failed with $errors errors"
        return 1
    fi
}

# Main execution
main() {
    echo "🚀 Stage-3 Automated Migration Script"
    echo "======================================"
    echo "This script will apply comprehensive naming convention changes"
    echo "from Stage-2 to Stage-3 based on Naming-Convention-For-Stage-3.md"
    echo ""
    
    # Confirm execution
    read -p "Do you want to proceed with the migration? (y/N): " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        log_info "Migration cancelled by user"
        exit 0
    fi
    
    # Create backup
    create_backup
    
    # Execute migration
    migrate_naming_conventions
    
    # Validate results
    if validate_migration; then
        log_success "🎉 Stage-3 migration completed successfully!"
        log_info "Backup available at: $BACKUP_DIR"
        log_info "Next steps:"
        log_info "1. Review changes with: git diff"
        log_info "2. Test applications with new naming"
        log_info "3. Update AWS account ID if needed: $AWS_ACCOUNT_ID"
    else
        log_error "Migration completed with warnings. Please review manually."
        log_info "Backup available for rollback at: $BACKUP_DIR"
    fi
}

# Execute main function
main "$@"
