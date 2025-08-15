#!/bin/bash

# GitOps Image Tag Update Script
# This script updates image tags in GitOps manifests and commits changes
# Can be used as a fallback if GitHub Actions git push fails

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
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
GITOPS_DIR="$PROJECT_ROOT/gitops"
ECR_REGISTRY="${ECR_REGISTRY:-867344452513.dkr.ecr.us-east-1.amazonaws.com}"
IMAGE_TAG="${IMAGE_TAG:-latest}"

# Function to update image tags
update_image_tags() {
    local image_tag="$1"
    
    if [[ -z "$image_tag" ]]; then
        log_error "Image tag is required"
        echo "Usage: $0 <image_tag>"
        echo "Example: $0 c1bc0c062492e0496faf56b5cd466a70184f1874"
        exit 1
    fi
    
    log_info "Updating GitOps manifests with image tag: $image_tag"
    
    # Check if GitOps directory exists
    if [[ ! -d "$GITOPS_DIR" ]]; then
        log_error "GitOps directory not found: $GITOPS_DIR"
        exit 1
    fi
    
    cd "$GITOPS_DIR" || exit 1
    
    # Update frontend image tag
    local frontend_file="environments/dev/frontend.yaml"
    if [[ -f "$frontend_file" ]]; then
        log_info "Updating frontend image in $frontend_file"
        sed -i "s|image: .*healthcare-frontend.*|image: $ECR_REGISTRY/healthcare-frontend-stage3:$image_tag|g" "$frontend_file"
        
        # Verify update
        if grep -q "$ECR_REGISTRY/healthcare-frontend-stage3:$image_tag" "$frontend_file"; then
            log_success "✅ Frontend image updated successfully"
        else
            log_warning "⚠️ Frontend image update may have failed"
        fi
    else
        log_warning "Frontend manifest not found: $frontend_file"
    fi
    
    # Update backend image tag
    local backend_file="environments/dev/backend.yaml"
    if [[ -f "$backend_file" ]]; then
        log_info "Updating backend image in $backend_file"
        sed -i "s|image: .*healthcare-backend.*|image: $ECR_REGISTRY/healthcare-backend-stage3:$image_tag|g" "$backend_file"
        
        # Verify update
        if grep -q "$ECR_REGISTRY/healthcare-backend-stage3:$image_tag" "$backend_file"; then
            log_success "✅ Backend image updated successfully"
        else
            log_warning "⚠️ Backend image update may have failed"
        fi
    else
        log_warning "Backend manifest not found: $backend_file"
    fi
    
    # Show updated images
    echo ""
    log_info "=== Updated Image Tags ==="
    echo "Frontend:"
    grep "image:" "$frontend_file" 2>/dev/null || echo "  No frontend image found"
    echo "Backend:"
    grep "image:" "$backend_file" 2>/dev/null || echo "  No backend image found"
    echo ""
}

# Function to commit and push changes
commit_and_push() {
    local image_tag="$1"
    
    cd "$GITOPS_DIR" || exit 1
    
    # Configure git
    git config --local user.email "41898282+github-actions[bot]@users.noreply.github.com"
    git config --local user.name "github-actions[bot]"
    
    # Check if there are changes
    if git diff --quiet && git diff --staged --quiet; then
        log_info "No changes to commit"
        return 0
    fi
    
    # Add changes
    git add environments/dev/
    
    # Commit changes
    local commit_msg="Update Stage-3 image tags to $image_tag"
    if git commit -m "$commit_msg"; then
        log_success "✅ Changes committed: $commit_msg"
    else
        log_error "❌ Failed to commit changes"
        return 1
    fi
    
    # Push changes
    log_info "Pushing changes to repository..."
    if git push origin main; then
        log_success "✅ Changes pushed successfully"
    else
        log_error "❌ Failed to push changes"
        log_info "You may need to push manually or check repository permissions"
        return 1
    fi
}

# Function to show current image tags
show_current_tags() {
    cd "$GITOPS_DIR" || exit 1
    
    echo ""
    log_info "=== Current Image Tags ==="
    echo "Frontend:"
    grep "image:" environments/dev/frontend.yaml 2>/dev/null || echo "  No frontend image found"
    echo "Backend:"
    grep "image:" environments/dev/backend.yaml 2>/dev/null || echo "  No backend image found"
    echo ""
}

# Main function
main() {
    echo "🔄 GitOps Image Tag Update Script"
    echo "=================================="
    echo ""
    
    # Parse arguments
    case "${1:-}" in
        "show"|"status")
            show_current_tags
            exit 0
            ;;
        "help"|"-h"|"--help")
            echo "Usage: $0 <command> [image_tag]"
            echo ""
            echo "Commands:"
            echo "  <image_tag>     Update image tags and commit/push changes"
            echo "  show|status     Show current image tags"
            echo "  help            Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0 c1bc0c062492e0496faf56b5cd466a70184f1874"
            echo "  $0 show"
            echo ""
            echo "Environment Variables:"
            echo "  ECR_REGISTRY    ECR registry URL (default: 867344452513.dkr.ecr.us-east-1.amazonaws.com)"
            echo "  IMAGE_TAG       Default image tag (default: latest)"
            exit 0
            ;;
        "")
            log_error "Image tag is required"
            echo "Use '$0 help' for usage information"
            exit 1
            ;;
        *)
            local image_tag="$1"
            ;;
    esac
    
    # Show current state
    show_current_tags
    
    # Update image tags
    update_image_tags "$image_tag"
    
    # Commit and push changes
    commit_and_push "$image_tag"
    
    echo ""
    log_success "🎉 GitOps update completed successfully!"
    echo ""
    echo "Next steps:"
    echo "1. Verify changes in GitHub repository"
    echo "2. Check ArgoCD for automatic sync (if configured)"
    echo "3. Monitor application deployment status"
}

# Execute main function with all arguments
main "$@"
