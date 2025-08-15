#!/bin/bash

# Pipeline Trigger Script for Stage-3
# Helps users trigger the GitHub Actions pipeline with meaningful changes

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

# Check if we're in the right directory
check_directory() {
    if [[ ! -f "MASTER-SETUP-GUIDE.md" ]] || [[ ! -d "src-code" ]]; then
        log_error "Please run this script from the Stage-3 root directory"
        log_info "Expected location: Project-Stages/Project-Stage-3-Advanced-DevOps-Pipeline/"
        exit 1
    fi
}

# Check git status
check_git_status() {
    if ! git status >/dev/null 2>&1; then
        log_error "Not a git repository or git not configured"
        exit 1
    fi
    
    # Check if there are uncommitted changes
    if ! git diff-index --quiet HEAD --; then
        log_warning "You have uncommitted changes. Please commit or stash them first."
        git status --short
        exit 1
    fi
    
    # Check if we're on main branch
    local current_branch=$(git branch --show-current)
    if [[ "$current_branch" != "main" ]]; then
        log_warning "You're on branch '$current_branch', not 'main'"
        read -p "Continue anyway? (y/N): " confirm
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

# Get GitHub repository URL
get_github_url() {
    local remote_url=$(git config --get remote.origin.url)
    if [[ $remote_url == *"github.com"* ]]; then
        # Convert SSH to HTTPS format for display
        local repo_path=$(echo "$remote_url" | sed 's/.*github.com[:/]\([^/]*\/[^.]*\).*/\1/')
        echo "https://github.com/$repo_path/actions"
    else
        echo "GitHub Actions URL not available"
    fi
}

# Trigger options
show_trigger_options() {
    echo "🚀 Stage-3 Pipeline Trigger Options"
    echo "===================================="
    echo ""
    echo "1. Version bump (recommended for releases)"
    echo "2. Feature development (add test comment)"
    echo "3. Documentation update (update README)"
    echo "4. Custom change (you specify the change)"
    echo "5. Cancel"
    echo ""
}

# Option 1: Version bump
trigger_version_bump() {
    log_info "Triggering pipeline with version bump..."
    
    # Update package.json version
    if [[ -f "src-code/package.json" ]]; then
        local current_version=$(grep '"version"' src-code/package.json | sed 's/.*"version": "\([^"]*\)".*/\1/')
        log_info "Current version: $current_version"
        
        # Simple version increment (patch version)
        local new_version=$(echo "$current_version" | awk -F. '{$NF = $NF + 1;} 1' | sed 's/ /./g')
        log_info "New version: $new_version"
        
        sed -i "s/\"version\": \"$current_version\"/\"version\": \"$new_version\"/" src-code/package.json
        
        git add src-code/package.json
        git commit -m "chore: bump version to $new_version

- Updated package.json version for release
- Triggering Stage-3 CI/CD pipeline
- Testing complete deployment workflow"
        
        log_success "Version bumped from $current_version to $new_version"
    else
        log_error "package.json not found in src-code directory"
        return 1
    fi
}

# Option 2: Feature development
trigger_feature_test() {
    log_info "Triggering pipeline with feature development change..."
    
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "// Pipeline trigger test - Feature development - $timestamp" >> src-code/frontend/src/App.js
    
    git add src-code/frontend/src/App.js
    git commit -m "feat: add pipeline trigger test comment

- Added test comment for pipeline triggering
- Testing Stage-3 CI/CD workflow
- Verifying feature development pipeline flow
- Timestamp: $timestamp"
    
    log_success "Feature test comment added to App.js"
}

# Option 3: Documentation update
trigger_docs_update() {
    log_info "Triggering pipeline with documentation update..."
    
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "" >> src-code/README.md
    echo "## Pipeline Test" >> src-code/README.md
    echo "Last pipeline test: $timestamp" >> src-code/README.md
    
    git add src-code/README.md
    git commit -m "docs: update README with pipeline test info

- Added pipeline test section to README
- Triggering Stage-3 CI/CD workflow
- Testing documentation update pipeline flow
- Timestamp: $timestamp"
    
    log_success "Documentation updated in src-code/README.md"
}

# Option 4: Custom change
trigger_custom_change() {
    log_info "Custom change option selected..."
    
    echo "Available files to modify:"
    find src-code -name "*.js" -o -name "*.json" -o -name "*.md" | head -10
    echo ""
    
    read -p "Enter the file path to modify (relative to current directory): " file_path
    if [[ ! -f "$file_path" ]]; then
        log_error "File not found: $file_path"
        return 1
    fi
    
    read -p "Enter the change description: " change_desc
    read -p "Enter content to add to the file: " content
    
    echo "$content" >> "$file_path"
    
    git add "$file_path"
    git commit -m "feat: $change_desc

- Custom change: $change_desc
- Modified: $file_path
- Triggering Stage-3 CI/CD pipeline
- Testing custom change workflow"
    
    log_success "Custom change applied to $file_path"
}

# Push changes and show monitoring info
push_and_monitor() {
    log_info "Pushing changes to trigger pipeline..."
    
    git push origin main
    
    if [[ $? -eq 0 ]]; then
        log_success "✅ Changes pushed successfully!"
        echo ""
        log_info "🔍 Monitor your pipeline at:"
        echo "$(get_github_url)"
        echo ""
        log_info "Expected pipeline jobs:"
        echo "1. ✅ Terraform Validation (2-3 minutes)"
        echo "2. ✅ Unit Tests (3-5 minutes)"
        echo "3. ✅ Security Scanning (2-4 minutes)"
        echo "4. ✅ Build and Push Images (5-8 minutes)"
        echo "5. ✅ Infrastructure Deployment (10-15 minutes)"
        echo "6. ✅ GitOps Deployment (3-5 minutes)"
        echo ""
        log_info "Total expected time: 25-40 minutes"
        echo ""
        log_success "🎉 Pipeline triggered successfully!"
    else
        log_error "❌ Failed to push changes"
        return 1
    fi
}

# Main function
main() {
    echo "🚀 Stage-3 Pipeline Trigger Helper"
    echo "=================================="
    echo ""
    
    check_directory
    check_git_status
    
    # Pull latest changes
    log_info "Pulling latest changes..."
    git pull origin main
    
    show_trigger_options
    read -p "Select an option (1-5): " choice
    
    case $choice in
        1)
            trigger_version_bump && push_and_monitor
            ;;
        2)
            trigger_feature_test && push_and_monitor
            ;;
        3)
            trigger_docs_update && push_and_monitor
            ;;
        4)
            trigger_custom_change && push_and_monitor
            ;;
        5)
            log_info "Operation cancelled"
            exit 0
            ;;
        *)
            log_error "Invalid option selected"
            exit 1
            ;;
    esac
}

# Execute main function
main "$@"
