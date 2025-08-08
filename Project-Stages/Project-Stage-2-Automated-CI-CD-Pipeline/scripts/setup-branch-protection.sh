#!/bin/bash

# =============================================================================
# GitHub Branch Protection Setup Script
# Healthcare Management System - Stage 2 CI/CD Pipeline
# =============================================================================
# 
# This script configures branch protection rules for the main branch to ensure:
# - Required status checks (tests and quality gates)
# - Required pull request reviews
# - Protection against force pushes and deletions
# - Enforcement for administrators
#
# Usage: ./setup-branch-protection.sh
# Prerequisites: GitHub CLI (gh) must be installed and authenticated
# =============================================================================

set -e  # Exit on any error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}🔒 $1${NC}"
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
    print_status "Setting up GitHub branch protection rules..."
    echo ""
    
    # Check prerequisites
    check_prerequisites
    
    # Create branch protection configuration
    create_branch_protection_config
    
    # Apply branch protection rules
    apply_branch_protection
    
    # Verify configuration
    verify_branch_protection
    
    # Cleanup
    cleanup
    
    print_success "Branch protection setup completed successfully!"
    print_configuration_summary
    print_critical_next_steps
}

# Check if all prerequisites are met
check_prerequisites() {
    print_info "Checking prerequisites..."
    
    # Check if GitHub CLI is installed
    if ! command -v gh &> /dev/null; then
        print_error "GitHub CLI (gh) is not installed."
        print_info "Install it from: https://cli.github.com/"
        exit 1
    fi
    print_success "GitHub CLI is installed"
    
    # Check if GitHub CLI is authenticated
    if ! gh auth status &> /dev/null; then
        print_error "GitHub CLI is not authenticated."
        print_info "Run: gh auth login"
        exit 1
    fi
    print_success "GitHub CLI is authenticated"
    
    # Check if we can determine the repository
    if git rev-parse --git-dir > /dev/null 2>&1; then
        REPO_INFO=$(gh repo view --json owner,name 2>/dev/null || echo "")
        if [ -n "$REPO_INFO" ]; then
            REPO_OWNER=$(echo "$REPO_INFO" | jq -r '.owner.login')
            REPO_NAME=$(echo "$REPO_INFO" | jq -r '.name')
            print_success "Repository detected: $REPO_OWNER/$REPO_NAME"
            USE_PLACEHOLDER=true
        else
            print_warning "Could not detect repository information"
            get_repository_info
        fi
    else
        print_warning "Not in a git repository"
        get_repository_info
    fi
}

# Get repository information from user
get_repository_info() {
    print_info "Available repositories:"
    gh repo list --limit 10 2>/dev/null || print_warning "Could not list repositories"
    echo ""
    
    read -p "Enter your GitHub username: " REPO_OWNER
    read -p "Enter your repository name: " REPO_NAME
    
    if [ -z "$REPO_OWNER" ] || [ -z "$REPO_NAME" ]; then
        print_error "Repository owner and name are required"
        exit 1
    fi
    
    USE_PLACEHOLDER=false
    print_info "Using repository: $REPO_OWNER/$REPO_NAME"
}

# Create branch protection configuration file
create_branch_protection_config() {
    print_info "Creating branch protection configuration..."
    
    cat > branch-protection.json << 'EOF'
{
  "required_status_checks": {
    "strict": true,
    "contexts": ["security-analysis", "unit-testing", "code-quality"]
  },
  "enforce_admins": true,
  "required_pull_request_reviews": {
    "required_approving_review_count": 1,
    "dismiss_stale_reviews": true,
    "require_code_owner_reviews": false,
    "require_last_push_approval": false
  },
  "restrictions": null,
  "allow_force_pushes": false,
  "allow_deletions": false,
  "block_creations": false,
  "required_linear_history": false,
  "allow_fork_syncing": true
}
EOF
    
    print_success "Branch protection configuration created"
}

# Apply branch protection rules
apply_branch_protection() {
    print_info "Applying branch protection rules to main branch..."
    
    if [ "$USE_PLACEHOLDER" = true ]; then
        # Use placeholder syntax (works when in git repository)
        gh api repos/:owner/:repo/branches/main/protection \
            --method PUT \
            --input branch-protection.json
    else
        # Use explicit repository specification
        gh api repos/$REPO_OWNER/$REPO_NAME/branches/main/protection \
            --method PUT \
            --input branch-protection.json
    fi
    
    if [ $? -eq 0 ]; then
        print_success "Branch protection rules applied successfully"
    else
        print_error "Failed to apply branch protection rules"
        print_troubleshooting_info
        exit 1
    fi
}

# Verify branch protection configuration
verify_branch_protection() {
    print_info "Verifying branch protection configuration..."
    
    if [ "$USE_PLACEHOLDER" = true ]; then
        PROTECTION_STATUS=$(gh api repos/:owner/:repo/branches/main/protection 2>/dev/null || echo "")
    else
        PROTECTION_STATUS=$(gh api repos/$REPO_OWNER/$REPO_NAME/branches/main/protection 2>/dev/null || echo "")
    fi
    
    if [ -n "$PROTECTION_STATUS" ]; then
        print_success "Branch protection is active"
        
        # Check specific protections
        echo "$PROTECTION_STATUS" | jq -r '
            "📊 Protection Summary:",
            "   • Required status checks: " + (.required_status_checks.contexts | join(", ")),
            "   • Strict mode: " + (.required_status_checks.strict | tostring),
            "   • Required reviews: " + (.required_pull_request_reviews.required_approving_review_count | tostring),
            "   • Dismiss stale reviews: " + (.required_pull_request_reviews.dismiss_stale_reviews | tostring),
            "   • Enforce for admins: " + (.enforce_admins | tostring),
            "   • Allow force pushes: " + (.allow_force_pushes | tostring),
            "   • Allow deletions: " + (.allow_deletions | tostring)
        ' 2>/dev/null || print_info "Protection details available via GitHub web interface"
    else
        print_warning "Could not verify branch protection status"
    fi
}

# Clean up temporary files
cleanup() {
    if [ -f "branch-protection.json" ]; then
        rm -f branch-protection.json
        print_info "Cleaned up temporary files"
    fi
}

# Print configuration summary
print_configuration_summary() {
    echo ""
    print_info "🎉 Branch Protection Configuration Complete!"
    echo ""
    echo "Your main branch is now protected with:"
    echo "  🔒 Required status checks: Run Tests, Quality & Security Gates"
    echo "  👥 Required pull request reviews: 1"
    echo "  🔄 Dismiss stale reviews: Yes"
    echo "  👑 Enforce for administrators: Yes"
    echo "  🚫 Force pushes: Disabled"
    echo "  🗑️  Branch deletions: Disabled"
    echo ""
    print_info "Next steps:"
    echo "  1. Create a pull request to test the protection rules"
    echo "  2. Ensure your CI/CD pipeline includes 'Run Tests' and 'Quality & Security Gates' jobs"
    echo "  3. Configure your team members as collaborators if needed"
    echo ""
}

# Print critical next steps warning
print_critical_next_steps() {
    echo ""
    print_error "🚨 CRITICAL: Branch Protection is Active - READ THIS!"
    echo ""
    print_warning "Your main branch will now BLOCK ALL MERGES until you complete these steps:"
    echo ""
    echo "1. 📋 GITHUB ACTIONS WORKFLOW ALREADY EXISTS (.github/workflows/stage2-ci-cd.yml)"
    echo "   - ✅ Job 'security-analysis' - Security scanning with Trivy"
    echo "   - ✅ Job 'unit-testing' - Jest unit tests with coverage"
    echo "   - ✅ Job 'code-quality' - SonarQube code quality analysis"
    echo "   - These jobs must pass for pull requests to be merged!"
    echo ""
    echo "2. 🧪 TEST WITH A PULL REQUEST"
    echo "   - Create a test branch and pull request"
    echo "   - Verify that status checks run and pass/fail correctly"
    echo "   - Confirm merge is blocked until checks pass"
    echo ""
    echo "3. ✅ VERIFY STATUS CHECK NAMES MATCH"
    echo "   - Run: gh api repos/:owner/:repo/branches/main/protection --jq '.required_status_checks.contexts'"
    echo "   - Should show: [\"security-analysis\", \"unit-testing\", \"code-quality\"]"
    echo ""
    print_info "Next step: Continue with Step 6 of STAGE-2-MASTER-GUIDE.md to create the GitHub Actions workflow"
    echo ""
    print_warning "Until the workflow is created, your repository will reject all merge attempts!"
}

# Print troubleshooting information
print_troubleshooting_info() {
    echo ""
    print_warning "Troubleshooting Information:"
    echo ""
    echo "Common issues and solutions:"
    echo ""
    echo "1. 422 Unprocessable Entity Error:"
    echo "   - Ensure the main branch exists in your repository"
    echo "   - Check that you have admin permissions on the repository"
    echo ""
    echo "2. 404 Not Found Error:"
    echo "   - Verify the repository owner and name are correct"
    echo "   - Ensure the repository exists and is accessible"
    echo ""
    echo "3. Authentication Error:"
    echo "   - Run: gh auth login"
    echo "   - Ensure you have the necessary permissions"
    echo ""
    echo "4. Branch doesn't exist:"
    echo "   - Create the main branch: git checkout -b main && git push -u origin main"
    echo ""
    echo "For more help, visit: https://docs.github.com/en/rest/branches/branch-protection"
}

# Handle script interruption
trap cleanup EXIT

# Run main function
main "$@"
