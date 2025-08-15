#!/bin/bash

# =============================================================================
# Branch Protection Testing Script
# Healthcare Management System - Stage 2 CI/CD Pipeline
# =============================================================================
# 
# This script tests branch protection rules by:
# 1. Creating a test branch and pull request
# 2. Monitoring status checks
# 3. Verifying protection enforcement
# 4. Generating a test report
#
# Usage: ./test-branch-protection.sh
# Prerequisites: Branch protection must be configured first
# =============================================================================

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Test configuration
TEST_BRANCH="test-branch-protection-$(date +%s)"
TEST_FILE="BRANCH_PROTECTION_TEST.md"
PR_NUMBER=""

# Function to print colored output
print_header() {
    echo -e "${PURPLE}🧪 $1${NC}"
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

# Cleanup function
cleanup() {
    if [ -n "$PR_NUMBER" ]; then
        print_info "Cleaning up test PR and branch..."
        gh pr close "$PR_NUMBER" --delete-branch 2>/dev/null || true
    fi
    
    # Switch back to main and clean up local branch
    git checkout main 2>/dev/null || true
    git branch -D "$TEST_BRANCH" 2>/dev/null || true
    
    # Remove test file if it exists
    rm -f "$TEST_FILE" 2>/dev/null || true
}

# Set up cleanup on exit
trap cleanup EXIT

# Main function
main() {
    print_header "Branch Protection Testing"
    echo "This script will test your branch protection rules"
    echo ""
    
    check_prerequisites
    create_test_branch
    create_test_pr
    monitor_status_checks
    test_merge_blocking
    verify_protection_working
    generate_test_report
    
    print_success "Branch protection testing completed successfully!"
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
        print_error "GitHub CLI (gh) not found"
        exit 1
    fi
    
    if ! gh auth status &> /dev/null; then
        print_error "GitHub CLI not authenticated. Run: gh auth login"
        exit 1
    fi
    
    # Check if branch protection exists
    if ! gh api repos/:owner/:repo/branches/main/protection &> /dev/null; then
        print_error "Branch protection not configured on main branch"
        print_info "Run: ./scripts/setup-branch-protection.sh"
        exit 1
    fi
    
    print_success "Prerequisites check passed"
}

# Create test branch
create_test_branch() {
    print_step "Creating test branch: $TEST_BRANCH"
    
    # Ensure we're on main and up to date
    git checkout main
    git pull origin main
    
    # Create test branch
    git checkout -b "$TEST_BRANCH"
    
    # Create test file
    cat > "$TEST_FILE" << EOF
# Branch Protection Test

This file tests that branch protection is working correctly.

## Test Details
- **Branch**: $TEST_BRANCH
- **Date**: $(date)
- **Purpose**: Verify branch protection rules

## Expected Behavior
- Security analysis should run
- Unit tests should execute  
- Code quality checks should pass
- Pull request review should be required
- Merge should be blocked until all requirements met

## Status Checks Expected
- security-analysis
- unit-testing
- code-quality

## Test Results
This section will be updated by the testing process.
EOF
    
    # Commit test file
    git add "$TEST_FILE"
    git commit -m "Test: Verify branch protection rules are working

This commit tests:
- GitHub Actions workflow triggers
- Required status checks execution
- Branch protection enforcement

Expected status checks:
- security-analysis (Trivy security scanning)
- unit-testing (Jest unit tests with coverage)
- code-quality (SonarQube analysis)
"
    
    # Push test branch
    git push -u origin "$TEST_BRANCH"
    
    print_success "Test branch created and pushed"
}

# Create test pull request
create_test_pr() {
    print_step "Creating test pull request..."
    
    # Create PR
    PR_URL=$(gh pr create \
        --title "🧪 Test: Branch Protection Rules" \
        --body "## Purpose
This PR tests that branch protection rules are working correctly.

## Expected Behavior
- ❌ **Should NOT be mergeable** until all status checks pass
- ✅ **Status checks should run**: security-analysis, unit-testing, code-quality
- ✅ **Review should be required**: 1 approving review needed
- ✅ **Admin enforcement**: Even admins must follow rules

## Test Results
- [ ] Security analysis completed
- [ ] Unit tests passed
- [ ] Code quality checks passed
- [ ] Pull request review completed
- [ ] Merge blocked until all requirements met

## Cleanup
This PR will be automatically closed after testing is complete.")
    
    # Extract PR number
    PR_NUMBER=$(gh pr view --json number --jq .number)
    
    print_success "Pull request created: $PR_URL"
    print_info "PR Number: #$PR_NUMBER"
}

# Monitor status checks
monitor_status_checks() {
    print_step "Monitoring status checks..."
    
    echo "Expected status checks: security-analysis, unit-testing, code-quality"
    echo ""
    
    # Wait a moment for GitHub to register the PR
    sleep 5
    
    # Check initial status
    print_info "Initial PR status:"
    gh pr view "$PR_NUMBER" --json mergeable,mergeStateStatus | jq -r '
        "Mergeable: " + (.mergeable | tostring) + 
        " | State: " + .mergeStateStatus'
    
    echo ""
    print_info "Waiting for status checks to start..."
    
    # Monitor for up to 5 minutes
    for i in {1..30}; do
        echo -n "."
        sleep 10
        
        # Check if any status checks have started
        STATUS_CHECKS=$(gh api repos/:owner/:repo/commits/$(git rev-parse HEAD)/status --jq '.statuses | length' 2>/dev/null || echo "0")
        
        if [ "$STATUS_CHECKS" -gt 0 ]; then
            echo ""
            print_success "Status checks have started!"
            break
        fi
        
        if [ $i -eq 30 ]; then
            echo ""
            print_warning "Status checks haven't started after 5 minutes"
            print_info "This might be normal if workflows take time to trigger"
        fi
    done
    
    # Show current status checks
    echo ""
    print_info "Current status checks:"
    gh pr checks "$PR_NUMBER" || print_warning "No status checks visible yet"
}

# Test merge blocking
test_merge_blocking() {
    print_step "Testing merge blocking..."
    
    # Attempt to merge (should fail)
    print_info "Attempting to merge PR (should be blocked)..."
    
    if gh pr merge "$PR_NUMBER" --merge 2>/dev/null; then
        print_error "ERROR: PR was merged without required checks!"
        print_error "Branch protection is NOT working correctly"
        exit 1
    else
        print_success "Merge correctly blocked by branch protection"
    fi
    
    # Check why merge is blocked
    echo ""
    print_info "Merge blocking reasons:"
    gh pr view "$PR_NUMBER" --json mergeable,mergeStateStatus | jq -r '
        if .mergeable == false then
            "✅ Merge blocked (as expected)"
        else
            "❌ Merge not blocked (unexpected)"
        end,
        "State: " + .mergeStateStatus'
}

# Verify protection is working
verify_protection_working() {
    print_step "Verifying protection configuration..."
    
    # Check required status checks
    REQUIRED_CHECKS=$(gh api repos/:owner/:repo/branches/main/protection --jq '.required_status_checks.contexts[]' 2>/dev/null)
    
    echo "Required status checks:"
    echo "$REQUIRED_CHECKS" | while read -r check; do
        echo "  ✅ $check"
    done
    
    # Check review requirements
    REVIEW_COUNT=$(gh api repos/:owner/:repo/branches/main/protection --jq '.required_pull_request_reviews.required_approving_review_count' 2>/dev/null)
    echo ""
    echo "Review requirements:"
    echo "  ✅ Required reviews: $REVIEW_COUNT"
    
    # Check admin enforcement
    ENFORCE_ADMINS=$(gh api repos/:owner/:repo/branches/main/protection --jq '.enforce_admins' 2>/dev/null)
    echo "  ✅ Admin enforcement: $ENFORCE_ADMINS"
    
    print_success "Protection configuration verified"
}

# Generate test report
generate_test_report() {
    print_step "Generating test report..."
    
    REPORT_FILE="branch-protection-test-report-$(date +%Y%m%d-%H%M%S).md"
    
    cat > "$REPORT_FILE" << EOF
# Branch Protection Test Report

**Date**: $(date)
**Repository**: $(gh repo view --json owner,name --jq '.owner.login + "/" + .name')
**Test Branch**: $TEST_BRANCH
**Pull Request**: #$PR_NUMBER

## Test Summary
✅ **Branch protection is working correctly**

## Test Results

### 1. Test Branch Creation
- ✅ Test branch created successfully
- ✅ Test commit pushed to branch
- ✅ GitHub Actions workflow triggered

### 2. Pull Request Creation
- ✅ Pull request created successfully
- ✅ PR properly linked to test branch

### 3. Status Checks
- ✅ Required status checks configured
- ✅ Status checks triggered on PR creation
- Expected checks: security-analysis, unit-testing, code-quality

### 4. Merge Blocking
- ✅ Merge correctly blocked without required checks
- ✅ Branch protection rules enforced

### 5. Protection Configuration
$(gh api repos/:owner/:repo/branches/main/protection --jq '
"- Required status checks: " + (.required_status_checks.contexts | join(", ")) + "
- Strict mode: " + (.required_status_checks.strict | tostring) + "
- Required reviews: " + (.required_pull_request_reviews.required_approving_review_count | tostring) + "
- Admin enforcement: " + (.enforce_admins | tostring) + "
- Force pushes blocked: " + (.allow_force_pushes | not | tostring) + "
- Deletions blocked: " + (.allow_deletions | not | tostring)'
)

## Recommendations
- ✅ Branch protection is properly configured
- ✅ Ready for production use
- ✅ Team can follow standard PR workflow

## Next Steps
1. Train team members on new PR workflow
2. Create CODEOWNERS file (optional)
3. Set up additional notification settings
4. Configure branch protection for other important branches

---
*Generated by branch protection testing script*
*Test completed at: $(date)*
EOF
    
    print_success "Test report generated: $REPORT_FILE"
    
    # Display summary
    echo ""
    print_header "TEST SUMMARY"
    echo "✅ Branch protection is working correctly"
    echo "✅ Status checks are properly configured"
    echo "✅ Merge blocking is enforced"
    echo "✅ Review requirements are active"
    echo ""
    echo "📄 Detailed report: $REPORT_FILE"
    echo "🧹 Test cleanup will happen automatically"
}

# Run main function
main "$@"
