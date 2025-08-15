#!/bin/bash

# =============================================================================
# Git Repository Status Check Script
# Healthcare Management System - Stage 2 CI/CD Pipeline
# =============================================================================
# 
# This script provides a comprehensive overview of your Git repository status
# Helps you understand what's happening before making changes
#
# Usage: ./git-status-check.sh
# =============================================================================

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Function to print colored output
print_header() {
    echo -e "${PURPLE}📊 $1${NC}"
    echo "=============================================="
}

print_section() {
    echo ""
    echo -e "${BLUE}📋 $1${NC}"
    echo "----------------------------------------------"
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
    print_header "Git Repository Status Check"
    echo "Comprehensive overview of your repository status"
    echo ""
    
    check_basic_info
    check_branch_status
    check_changes
    check_commit_history
    check_remote_status
    check_branch_protection
    check_recent_activity
    provide_recommendations
}

# Check basic repository information
check_basic_info() {
    print_section "Basic Repository Information"
    
    # Current location
    echo "📍 Current Directory: $(pwd)"
    
    # Check if in git repository
    if git rev-parse --git-dir > /dev/null 2>&1; then
        print_success "In a Git repository"
        
        # Repository root
        REPO_ROOT=$(git rev-parse --show-toplevel)
        echo "🏠 Repository Root: $REPO_ROOT"
        
        # Repository URL
        if git remote get-url origin &> /dev/null; then
            REPO_URL=$(git remote get-url origin)
            echo "🌐 Remote URL: $REPO_URL"
        else
            print_warning "No remote origin configured"
        fi
        
    else
        print_error "Not in a Git repository"
        exit 1
    fi
}

# Check branch status
check_branch_status() {
    print_section "Branch Information"
    
    # Current branch
    CURRENT_BRANCH=$(git branch --show-current)
    echo "🌿 Current Branch: $CURRENT_BRANCH"
    
    # All branches
    echo ""
    echo "📋 Available Branches:"
    git branch -a | while read -r branch; do
        if [[ $branch == *"$CURRENT_BRANCH"* ]]; then
            echo -e "  ${GREEN}$branch${NC} ← Current"
        else
            echo "  $branch"
        fi
    done
    
    # Branch comparison with main
    if [ "$CURRENT_BRANCH" != "main" ]; then
        echo ""
        echo "🔄 Comparison with Main Branch:"
        
        COMMITS_AHEAD=$(git rev-list --count HEAD ^main 2>/dev/null || echo "0")
        COMMITS_BEHIND=$(git rev-list --count main ^HEAD 2>/dev/null || echo "0")
        
        if [ "$COMMITS_AHEAD" -gt 0 ]; then
            echo "  📈 Commits ahead of main: $COMMITS_AHEAD"
        fi
        
        if [ "$COMMITS_BEHIND" -gt 0 ]; then
            print_warning "Commits behind main: $COMMITS_BEHIND (consider updating)"
        fi
        
        if [ "$COMMITS_AHEAD" -eq 0 ] && [ "$COMMITS_BEHIND" -eq 0 ]; then
            print_success "Branch is up to date with main"
        fi
    fi
}

# Check for changes
check_changes() {
    print_section "Working Directory Status"
    
    # Check for uncommitted changes
    if git diff --quiet && git diff --cached --quiet; then
        print_success "No uncommitted changes"
    else
        print_warning "You have uncommitted changes"
        
        # Unstaged changes
        if ! git diff --quiet; then
            echo ""
            echo "📝 Unstaged Changes:"
            git diff --name-status | while read -r status file; do
                case $status in
                    M) echo "  📝 Modified: $file" ;;
                    A) echo "  ➕ Added: $file" ;;
                    D) echo "  ➖ Deleted: $file" ;;
                    *) echo "  ❓ $status: $file" ;;
                esac
            done
        fi
        
        # Staged changes
        if ! git diff --cached --quiet; then
            echo ""
            echo "📦 Staged Changes (ready to commit):"
            git diff --cached --name-status | while read -r status file; do
                case $status in
                    M) echo "  📝 Modified: $file" ;;
                    A) echo "  ➕ Added: $file" ;;
                    D) echo "  ➖ Deleted: $file" ;;
                    *) echo "  ❓ $status: $file" ;;
                esac
            done
        fi
        
        # Untracked files
        UNTRACKED=$(git ls-files --others --exclude-standard)
        if [ -n "$UNTRACKED" ]; then
            echo ""
            echo "❓ Untracked Files:"
            echo "$UNTRACKED" | while read -r file; do
                echo "  📄 $file"
            done
        fi
    fi
}

# Check commit history
check_commit_history() {
    print_section "Recent Commit History"
    
    echo "📚 Last 5 Commits:"
    git log --oneline -5 --decorate --graph
    
    # Check if there are commits on current branch not on main
    if [ "$(git branch --show-current)" != "main" ]; then
        echo ""
        echo "🆕 New Commits on Current Branch:"
        NEW_COMMITS=$(git log --oneline main..HEAD)
        if [ -n "$NEW_COMMITS" ]; then
            echo "$NEW_COMMITS"
        else
            echo "  (No new commits on this branch)"
        fi
    fi
}

# Check remote status
check_remote_status() {
    print_section "Remote Repository Status"
    
    # List remotes
    echo "🌐 Configured Remotes:"
    git remote -v
    
    # Check if local is up to date with remote
    echo ""
    echo "🔄 Sync Status with Remote:"
    
    # Fetch latest info (quietly)
    git fetch --quiet 2>/dev/null || print_warning "Could not fetch from remote"
    
    CURRENT_BRANCH=$(git branch --show-current)
    
    # Check if remote branch exists
    if git show-ref --verify --quiet "refs/remotes/origin/$CURRENT_BRANCH"; then
        LOCAL_COMMIT=$(git rev-parse HEAD)
        REMOTE_COMMIT=$(git rev-parse "origin/$CURRENT_BRANCH")
        
        if [ "$LOCAL_COMMIT" = "$REMOTE_COMMIT" ]; then
            print_success "Local branch is up to date with remote"
        else
            print_warning "Local branch differs from remote"
            
            COMMITS_TO_PUSH=$(git rev-list --count "origin/$CURRENT_BRANCH"..HEAD 2>/dev/null || echo "0")
            COMMITS_TO_PULL=$(git rev-list --count HEAD.."origin/$CURRENT_BRANCH" 2>/dev/null || echo "0")
            
            if [ "$COMMITS_TO_PUSH" -gt 0 ]; then
                echo "  📤 Commits to push: $COMMITS_TO_PUSH"
            fi
            
            if [ "$COMMITS_TO_PULL" -gt 0 ]; then
                echo "  📥 Commits to pull: $COMMITS_TO_PULL"
            fi
        fi
    else
        print_info "Remote branch doesn't exist (new local branch)"
    fi
}

# Check branch protection
check_branch_protection() {
    print_section "Branch Protection Status"
    
    if command -v gh &> /dev/null && gh auth status &> /dev/null; then
        if gh api repos/:owner/:repo/branches/main/protection &>/dev/null; then
            print_success "Branch protection is ACTIVE on main branch"
            
            # Get protection details
            echo ""
            echo "🔒 Protection Rules:"
            
            REQUIRED_CHECKS=$(gh api repos/:owner/:repo/branches/main/protection --jq '.required_status_checks.contexts[]' 2>/dev/null)
            if [ -n "$REQUIRED_CHECKS" ]; then
                echo "  📋 Required status checks:"
                echo "$REQUIRED_CHECKS" | while read -r check; do
                    echo "    • $check"
                done
            fi
            
            REVIEW_COUNT=$(gh api repos/:owner/:repo/branches/main/protection --jq '.required_pull_request_reviews.required_approving_review_count' 2>/dev/null)
            if [ "$REVIEW_COUNT" != "null" ] && [ "$REVIEW_COUNT" -gt 0 ]; then
                echo "  👥 Required reviews: $REVIEW_COUNT"
            fi
            
            ENFORCE_ADMINS=$(gh api repos/:owner/:repo/branches/main/protection --jq '.enforce_admins' 2>/dev/null)
            if [ "$ENFORCE_ADMINS" = "true" ]; then
                echo "  👑 Admin enforcement: Enabled"
            fi
            
        else
            print_warning "Branch protection is NOT configured on main branch"
        fi
    else
        print_info "GitHub CLI not available - cannot check branch protection"
    fi
}

# Check recent activity
check_recent_activity() {
    print_section "Recent Activity"
    
    echo "👥 Recent Contributors (last month):"
    git shortlog -sn --since="1 month ago" | head -5
    
    echo ""
    echo "📅 Recent Branch Activity:"
    git for-each-ref --format='%(refname:short) %(committerdate:relative)' refs/heads/ | head -5
}

# Provide recommendations
provide_recommendations() {
    print_section "Recommendations"
    
    CURRENT_BRANCH=$(git branch --show-current)
    
    # Check what user should do next
    if git diff --quiet && git diff --cached --quiet; then
        if [ "$CURRENT_BRANCH" = "main" ]; then
            print_info "✨ Ready to start new work:"
            echo "  1. Create a new branch: git checkout -b feature-name"
            echo "  2. Make your changes"
            echo "  3. Use ./quick-update.sh to push changes"
        else
            print_info "✨ On feature branch with no changes:"
            echo "  1. Make your changes"
            echo "  2. Use ./quick-update.sh to push changes"
            echo "  3. Or switch to main: git checkout main"
        fi
    else
        print_info "✨ You have uncommitted changes:"
        echo "  1. Review changes: git diff"
        echo "  2. Stage changes: git add ."
        echo "  3. Use ./quick-update.sh to commit and push"
        echo "  4. Or commit manually: git commit -m 'your message'"
    fi
    
    echo ""
    print_info "🛠️ Available Helper Scripts:"
    echo "  • ./quick-update.sh - Easy way to push changes"
    echo "  • ./git-status-check.sh - This status check (run anytime)"
    echo "  • ./scripts/validate-stage2-setup.sh - Validate project setup"
    echo "  • ./scripts/test-branch-protection.sh - Test branch protection"
}

# Run main function
main "$@"
