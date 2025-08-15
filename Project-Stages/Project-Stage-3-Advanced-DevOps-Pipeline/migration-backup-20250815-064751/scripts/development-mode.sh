#!/bin/bash

# =============================================================================
# Development Mode Script - Temporary Branch Protection Management
# Healthcare Management System - Stage 2 CI/CD Pipeline
# =============================================================================
# 
# This script helps during active development by temporarily managing
# branch protection rules. Use with caution!
#
# Usage: 
#   ./development-mode.sh disable  # Remove branch protection
#   ./development-mode.sh enable   # Restore branch protection
#   ./development-mode.sh status   # Check current status
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
    echo -e "${PURPLE}🔧 $1${NC}"
    echo "=============================================="
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

# Configuration backup file
BACKUP_FILE=".branch-protection-backup.json"

# Main function
main() {
    case "${1:-}" in
        "disable")
            disable_protection
            ;;
        "enable")
            enable_protection
            ;;
        "status")
            check_status
            ;;
        *)
            show_usage
            ;;
    esac
}

# Show usage information
show_usage() {
    print_header "Development Mode Script"
    echo "Temporarily manage branch protection during active development"
    echo ""
    echo "Usage:"
    echo "  ./development-mode.sh disable   # Remove branch protection"
    echo "  ./development-mode.sh enable    # Restore branch protection"
    echo "  ./development-mode.sh status    # Check current status"
    echo ""
    print_warning "⚠️  IMPORTANT WARNINGS:"
    echo "• Only use during active development phases"
    echo "• Always re-enable protection when done"
    echo "• Not recommended for production repositories"
    echo "• Team members should be notified"
    echo ""
    print_info "💡 Alternative: Use ./quick-update.sh for safer workflow"
}

# Check prerequisites
check_prerequisites() {
    # Check if GitHub CLI is available and authenticated
    if ! command -v gh &> /dev/null; then
        print_error "GitHub CLI (gh) not found"
        exit 1
    fi
    
    if ! gh auth status &> /dev/null; then
        print_error "GitHub CLI not authenticated. Run: gh auth login"
        exit 1
    fi
    
    # Check if we're in a git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        print_error "Not in a git repository"
        exit 1
    fi
}

# Check current protection status
check_status() {
    print_header "Branch Protection Status Check"
    
    check_prerequisites
    
    if gh api repos/:owner/:repo/branches/main/protection &>/dev/null; then
        print_success "Branch protection is ACTIVE"
        
        echo ""
        print_info "Current protection rules:"
        
        # Required status checks
        REQUIRED_CHECKS=$(gh api repos/:owner/:repo/branches/main/protection --jq '.required_status_checks.contexts[]' 2>/dev/null)
        if [ -n "$REQUIRED_CHECKS" ]; then
            echo "📋 Required status checks:"
            echo "$REQUIRED_CHECKS" | while read -r check; do
                echo "  • $check"
            done
        fi
        
        # Review requirements
        REVIEW_COUNT=$(gh api repos/:owner/:repo/branches/main/protection --jq '.required_pull_request_reviews.required_approving_review_count' 2>/dev/null)
        if [ "$REVIEW_COUNT" != "null" ] && [ "$REVIEW_COUNT" -gt 0 ]; then
            echo "👥 Required reviews: $REVIEW_COUNT"
        fi
        
        # Admin enforcement
        ENFORCE_ADMINS=$(gh api repos/:owner/:repo/branches/main/protection --jq '.enforce_admins' 2>/dev/null)
        echo "👑 Admin enforcement: $ENFORCE_ADMINS"
        
    else
        print_warning "Branch protection is DISABLED"
        
        if [ -f "$BACKUP_FILE" ]; then
            print_info "Backup configuration found - can be restored"
        else
            print_warning "No backup configuration found"
        fi
    fi
    
    # Check if backup exists
    if [ -f "$BACKUP_FILE" ]; then
        echo ""
        print_info "📄 Backup file exists: $BACKUP_FILE"
        echo "Created: $(stat -c %y "$BACKUP_FILE" 2>/dev/null || stat -f %Sm "$BACKUP_FILE" 2>/dev/null || echo "Unknown")"
    fi
}

# Disable branch protection
disable_protection() {
    print_header "Disabling Branch Protection"
    
    check_prerequisites
    
    # Check if protection is currently active
    if ! gh api repos/:owner/:repo/branches/main/protection &>/dev/null; then
        print_warning "Branch protection is already disabled"
        return 0
    fi
    
    print_warning "⚠️  You are about to DISABLE branch protection!"
    echo ""
    echo "This means:"
    echo "• Direct pushes to main branch will be allowed"
    echo "• No required status checks"
    echo "• No required pull request reviews"
    echo "• Potential security and quality risks"
    echo ""
    
    read -p "🤔 Are you sure you want to proceed? (type 'yes' to confirm): " CONFIRM
    if [ "$CONFIRM" != "yes" ]; then
        print_info "Operation cancelled"
        return 0
    fi
    
    print_info "📄 Backing up current protection configuration..."
    
    # Backup current configuration
    gh api repos/:owner/:repo/branches/main/protection > "$BACKUP_FILE"
    
    if [ $? -eq 0 ]; then
        print_success "Configuration backed up to: $BACKUP_FILE"
    else
        print_error "Failed to backup configuration"
        exit 1
    fi
    
    print_info "🔓 Removing branch protection..."
    
    # Remove branch protection
    gh api repos/:owner/:repo/branches/main/protection --method DELETE
    
    if [ $? -eq 0 ]; then
        print_success "Branch protection disabled successfully"
        echo ""
        print_warning "🚨 IMPORTANT REMINDERS:"
        echo "• Branch protection is now OFF"
        echo "• You can push directly to main branch"
        echo "• Remember to re-enable when done: ./development-mode.sh enable"
        echo "• Consider using ./quick-update.sh for safer workflow"
        echo ""
        print_info "💡 Quick development workflow:"
        echo "  1. Make your changes"
        echo "  2. git add . && git commit -m 'your message'"
        echo "  3. git push origin main"
        echo "  4. ./development-mode.sh enable  # Re-enable protection"
    else
        print_error "Failed to disable branch protection"
        exit 1
    fi
}

# Enable branch protection
enable_protection() {
    print_header "Enabling Branch Protection"
    
    check_prerequisites
    
    # Check if protection is already active
    if gh api repos/:owner/:repo/branches/main/protection &>/dev/null; then
        print_warning "Branch protection is already enabled"
        return 0
    fi
    
    # Check if backup exists
    if [ ! -f "$BACKUP_FILE" ]; then
        print_warning "No backup configuration found"
        print_info "Using default configuration instead..."
        
        # Use the setup script to create default protection
        if [ -f "./setup-branch-protection.sh" ]; then
            print_info "Running setup-branch-protection.sh..."
            ./setup-branch-protection.sh
            return $?
        else
            print_error "No backup found and setup script not available"
            print_info "Please run: ./setup-branch-protection.sh"
            exit 1
        fi
    fi
    
    print_info "📄 Restoring branch protection from backup..."
    
    # Restore from backup
    gh api repos/:owner/:repo/branches/main/protection \
        --method PUT \
        --input "$BACKUP_FILE"
    
    if [ $? -eq 0 ]; then
        print_success "Branch protection restored successfully"
        
        # Clean up backup file
        rm -f "$BACKUP_FILE"
        print_info "Backup file cleaned up"
        
        echo ""
        print_success "🔒 Branch protection is now ACTIVE"
        echo "• Required status checks enforced"
        echo "• Pull request reviews required"
        echo "• Direct pushes to main blocked"
        echo ""
        print_info "💡 For future changes, use: ./quick-update.sh"
        
    else
        print_error "Failed to restore branch protection"
        print_info "Backup file preserved: $BACKUP_FILE"
        print_info "Try running: ./setup-branch-protection.sh"
        exit 1
    fi
}

# Run main function
main "$@"
