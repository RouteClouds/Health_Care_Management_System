#!/bin/bash

# =============================================================================
# Quick Git Update Helper Script
# Healthcare Management System - Stage 2 CI/CD Pipeline
# =============================================================================
# 
# This script helps repository owners quickly push changes following
# the standard workflow (branch protection compliant)
#
# Usage: ./quick-update.sh
# =============================================================================

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Function to print colored output
print_header() {
    echo -e "${PURPLE}🚀 $1${NC}"
    echo "=============================================="
}

print_step() {
    echo -e "${BLUE}📋 $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}📋 $1${NC}"
}

# Main function
main() {
    print_header "Quick Git Update Helper"
    echo "This script helps you push changes following the standard workflow"
    echo ""
    
    check_prerequisites
    get_user_input
    create_update_branch
    commit_changes
    push_and_create_pr
    show_next_steps
}

# Check prerequisites
check_prerequisites() {
    print_step "Checking prerequisites..."
    
    # Check if we're in a git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        print_error "Not in a git repository"
        exit 1
    fi
    
    # Check if GitHub CLI is available and authenticated
    if ! command -v gh &> /dev/null; then
        print_error "GitHub CLI (gh) not found. Install from: https://cli.github.com/"
        exit 1
    fi
    
    if ! gh auth status &> /dev/null; then
        print_error "GitHub CLI not authenticated. Run: gh auth login"
        exit 1
    fi
    
    # Check for uncommitted changes
    if git diff --quiet && git diff --cached --quiet; then
        print_warning "No changes detected. Make sure you've made your changes first."
        read -p "Continue anyway? (y/n): " CONTINUE
        if [ "$CONTINUE" != "y" ]; then
            print_info "Make your changes first, then run this script again"
            exit 0
        fi
    fi
    
    print_success "Prerequisites check passed"
}

# Get user input
get_user_input() {
    print_step "Getting update information..."
    
    echo ""
    echo "📝 What changes did you make? (This will be your commit message)"
    echo "Examples:"
    echo "  - docs: Update Stage-2 master guide with better examples"
    echo "  - fix: Correct branch protection script status check names"
    echo "  - feat: Add new validation script for setup process"
    echo ""
    
    read -p "📝 Commit message: " COMMIT_MSG
    
    if [ -z "$COMMIT_MSG" ]; then
        print_error "Commit message is required!"
        exit 1
    fi
    
    # Generate branch name
    DATE=$(date +%Y%m%d-%H%M)
    BRANCH_NAME="update-$DATE"
    
    echo ""
    print_info "Branch name will be: $BRANCH_NAME"
    print_info "Commit message: $COMMIT_MSG"
    
    echo ""
    read -p "🚀 Proceed with update? (y/n): " PROCEED
    if [ "$PROCEED" != "y" ]; then
        print_info "Update cancelled"
        exit 0
    fi
}

# Create update branch
create_update_branch() {
    print_step "Creating update branch..."
    
    # Update main branch
    print_info "Updating main branch..."
    git checkout main
    git pull origin main
    
    # Create new branch
    print_info "Creating branch: $BRANCH_NAME"
    git checkout -b "$BRANCH_NAME"
    
    print_success "Update branch created"
}

# Commit changes
commit_changes() {
    print_step "Committing changes..."
    
    # Show what will be committed
    echo ""
    print_info "Files to be committed:"
    git status --short
    
    echo ""
    read -p "📋 Add all changes? (y/n): " ADD_ALL
    
    if [ "$ADD_ALL" = "y" ]; then
        git add .
    else
        print_info "Add files manually with: git add <filename>"
        print_info "Then run: git commit -m \"$COMMIT_MSG\""
        exit 0
    fi
    
    # Commit with message
    git commit -m "$COMMIT_MSG"
    
    print_success "Changes committed"
}

# Push and create PR
push_and_create_pr() {
    print_step "Pushing branch and creating pull request..."
    
    # Push branch
    print_info "Pushing branch to GitHub..."
    git push -u origin "$BRANCH_NAME"
    
    # Create PR body
    PR_BODY="## Changes Made
$COMMIT_MSG

## Details
- **Branch**: $BRANCH_NAME
- **Created**: $(date)
- **Type**: Repository update

## Testing
- [x] Changes reviewed locally
- [ ] All status checks will run automatically
- [ ] Ready for review and merge

## Notes
This PR was created using the quick-update helper script to follow proper branch protection workflow.

---
*Created by quick-update.sh on $(date)*"
    
    # Create pull request
    print_info "Creating pull request..."
    PR_URL=$(gh pr create \
        --title "$COMMIT_MSG" \
        --body "$PR_BODY")
    
    print_success "Pull request created: $PR_URL"
}

# Show next steps
show_next_steps() {
    echo ""
    print_header "Update Complete!"
    
    echo "✅ Your changes have been pushed following the standard workflow"
    echo ""
    echo "📋 What happens next:"
    echo "  1. GitHub Actions will run tests automatically"
    echo "  2. Status checks must pass (security, testing, quality)"
    echo "  3. Pull request review may be required"
    echo "  4. After approval, you can merge the changes"
    echo ""
    echo "🔍 Monitor your pull request:"
    echo "  • View in browser: gh pr view --web"
    echo "  • Check status: gh pr view"
    echo "  • View checks: gh pr checks"
    echo ""
    echo "🚀 When ready to merge:"
    echo "  • Merge PR: gh pr merge --squash"
    echo "  • Or use GitHub web interface"
    echo ""
    
    # Check if user wants to open PR in browser
    read -p "🌐 Open pull request in browser now? (y/n): " OPEN_BROWSER
    if [ "$OPEN_BROWSER" = "y" ]; then
        gh pr view --web
    fi
    
    print_success "Quick update process completed!"
}

# Run main function
main "$@"
