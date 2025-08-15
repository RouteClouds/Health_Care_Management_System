#!/bin/bash

# =============================================================================
# Stage-2 Setup Validation Script
# Healthcare Management System - Stage 2 CI/CD Pipeline
# =============================================================================
# 
# This script validates the complete Stage-2 setup including:
# - Prerequisites (Node.js, Docker, AWS CLI, GitHub CLI)
# - Repository configuration
# - GitHub secrets
# - Branch protection rules
# - CI/CD workflow files
# - Testing setup
#
# Usage: ./validate-stage2-setup.sh
# =============================================================================

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Counters
TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0
WARNING_CHECKS=0

# Function to print colored output
print_header() {
    echo -e "${PURPLE}🚀 $1${NC}"
    echo "=============================================="
}

print_check() {
    echo -e "${BLUE}🔍 Checking: $1${NC}"
    ((TOTAL_CHECKS++))
}

print_pass() {
    echo -e "${GREEN}✅ PASS: $1${NC}"
    ((PASSED_CHECKS++))
}

print_fail() {
    echo -e "${RED}❌ FAIL: $1${NC}"
    ((FAILED_CHECKS++))
}

print_warning() {
    echo -e "${YELLOW}⚠️  WARNING: $1${NC}"
    ((WARNING_CHECKS++))
}

print_info() {
    echo -e "${BLUE}📋 INFO: $1${NC}"
}

print_section() {
    echo ""
    echo -e "${PURPLE}📊 $1${NC}"
    echo "----------------------------------------------"
}

# Main validation function
main() {
    print_header "Stage-2 Setup Validation"
    echo "This script will validate your complete Stage-2 CI/CD setup"
    echo ""
    
    validate_prerequisites
    validate_repository_setup
    validate_github_secrets
    validate_branch_protection
    validate_workflow_files
    validate_testing_setup
    validate_configuration_files
    
    print_final_summary
}

# Validate prerequisites
validate_prerequisites() {
    print_section "Prerequisites Validation"
    
    # Node.js
    print_check "Node.js installation and version"
    if command -v node &> /dev/null; then
        NODE_VERSION=$(node --version)
        if [[ "$NODE_VERSION" =~ ^v([0-9]+) ]] && [ "${BASH_REMATCH[1]}" -ge 18 ]; then
            print_pass "Node.js $NODE_VERSION (>= 18.x required)"
        else
            print_fail "Node.js $NODE_VERSION (>= 18.x required)"
        fi
    else
        print_fail "Node.js not installed"
    fi
    
    # npm
    print_check "npm installation"
    if command -v npm &> /dev/null; then
        NPM_VERSION=$(npm --version)
        print_pass "npm $NPM_VERSION"
    else
        print_fail "npm not installed"
    fi
    
    # Docker
    print_check "Docker installation"
    if command -v docker &> /dev/null; then
        DOCKER_VERSION=$(docker --version | cut -d' ' -f3 | cut -d',' -f1)
        print_pass "Docker $DOCKER_VERSION"
    else
        print_fail "Docker not installed"
    fi
    
    # AWS CLI
    print_check "AWS CLI installation"
    if command -v aws &> /dev/null; then
        AWS_VERSION=$(aws --version 2>&1 | cut -d' ' -f1 | cut -d'/' -f2)
        print_pass "AWS CLI $AWS_VERSION"
    else
        print_warning "AWS CLI not installed (required for EKS deployment)"
    fi
    
    # GitHub CLI
    print_check "GitHub CLI installation and authentication"
    if command -v gh &> /dev/null; then
        GH_VERSION=$(gh --version | head -n1 | cut -d' ' -f3)
        print_pass "GitHub CLI $GH_VERSION"
        
        if gh auth status &> /dev/null; then
            print_pass "GitHub CLI authenticated"
        else
            print_fail "GitHub CLI not authenticated (run: gh auth login)"
        fi
    else
        print_fail "GitHub CLI not installed"
    fi
    
    # Git
    print_check "Git installation and configuration"
    if command -v git &> /dev/null; then
        GIT_VERSION=$(git --version | cut -d' ' -f3)
        print_pass "Git $GIT_VERSION"
        
        if git config user.name &> /dev/null && git config user.email &> /dev/null; then
            print_pass "Git user configuration set"
        else
            print_warning "Git user configuration not set (run: git config --global user.name/user.email)"
        fi
    else
        print_fail "Git not installed"
    fi
}

# Validate repository setup
validate_repository_setup() {
    print_section "Repository Setup Validation"
    
    # Check if in git repository
    print_check "Git repository"
    if git rev-parse --git-dir > /dev/null 2>&1; then
        print_pass "In a git repository"
        
        # Check remote origin
        if git remote get-url origin &> /dev/null; then
            ORIGIN_URL=$(git remote get-url origin)
            print_pass "Remote origin configured: $ORIGIN_URL"
        else
            print_fail "No remote origin configured"
        fi
        
        # Check current branch
        CURRENT_BRANCH=$(git branch --show-current)
        if [ "$CURRENT_BRANCH" = "main" ]; then
            print_pass "On main branch"
        else
            print_warning "Not on main branch (current: $CURRENT_BRANCH)"
        fi
        
    else
        print_fail "Not in a git repository"
        return
    fi
    
    # Check repository structure
    print_check "Repository structure"
    REQUIRED_DIRS=("src-code" "scripts" "docs")
    for dir in "${REQUIRED_DIRS[@]}"; do
        if [ -d "$dir" ]; then
            print_pass "Directory exists: $dir"
        else
            print_fail "Missing directory: $dir"
        fi
    done
}

# Validate GitHub secrets
validate_github_secrets() {
    print_section "GitHub Secrets Validation"
    
    if ! command -v gh &> /dev/null || ! gh auth status &> /dev/null; then
        print_warning "Cannot validate secrets - GitHub CLI not available or not authenticated"
        return
    fi
    
    REQUIRED_SECRETS=("AWS_ACCESS_KEY_ID" "AWS_SECRET_ACCESS_KEY" "DOCKER_HUB_USERNAME" "DOCKER_HUB_ACCESS_TOKEN")
    OPTIONAL_SECRETS=("SONAR_TOKEN" "EKS_CLUSTER_NAME" "EKS_CLUSTER_REGION")
    
    print_check "Required GitHub secrets"
    SECRET_LIST=$(gh secret list 2>/dev/null || echo "")
    
    for secret in "${REQUIRED_SECRETS[@]}"; do
        if echo "$SECRET_LIST" | grep -q "$secret"; then
            print_pass "Secret configured: $secret"
        else
            print_fail "Missing required secret: $secret"
        fi
    done
    
    for secret in "${OPTIONAL_SECRETS[@]}"; do
        if echo "$SECRET_LIST" | grep -q "$secret"; then
            print_pass "Optional secret configured: $secret"
        else
            print_info "Optional secret not set: $secret"
        fi
    done
}

# Validate branch protection
validate_branch_protection() {
    print_section "Branch Protection Validation"
    
    if ! command -v gh &> /dev/null || ! gh auth status &> /dev/null; then
        print_warning "Cannot validate branch protection - GitHub CLI not available"
        return
    fi
    
    print_check "Main branch protection rules"
    PROTECTION_STATUS=$(gh api repos/:owner/:repo/branches/main/protection 2>/dev/null || echo "")
    
    if [ -n "$PROTECTION_STATUS" ]; then
        print_pass "Branch protection is enabled"
        
        # Check specific protections
        if echo "$PROTECTION_STATUS" | jq -e '.required_status_checks.strict' &> /dev/null; then
            print_pass "Strict status checks enabled"
        else
            print_warning "Strict status checks not enabled"
        fi
        
        if echo "$PROTECTION_STATUS" | jq -e '.required_pull_request_reviews' &> /dev/null; then
            print_pass "Pull request reviews required"
        else
            print_warning "Pull request reviews not required"
        fi
        
        if echo "$PROTECTION_STATUS" | jq -e '.enforce_admins' &> /dev/null; then
            print_pass "Admin enforcement enabled"
        else
            print_warning "Admin enforcement not enabled"
        fi
        
    else
        print_fail "Branch protection not configured"
        print_info "Run: ./scripts/setup-branch-protection.sh"
    fi
}

# Validate workflow files
validate_workflow_files() {
    print_section "GitHub Actions Workflow Validation"
    
    print_check "GitHub Actions workflow directory"
    if [ -d ".github/workflows" ]; then
        print_pass ".github/workflows directory exists"
        
        # Check for Stage-2 workflow
        if [ -f ".github/workflows/stage2-ci-cd.yml" ]; then
            print_pass "Stage-2 CI/CD workflow file exists"
        else
            print_warning "Stage-2 CI/CD workflow file missing (will be created in Step 6)"
        fi
        
    else
        print_warning ".github/workflows directory missing (will be created in Step 6)"
    fi
}

# Validate testing setup
validate_testing_setup() {
    print_section "Testing Setup Validation"
    
    print_check "Source code directory"
    if [ -d "src-code" ]; then
        cd src-code
        
        # Check package.json
        if [ -f "package.json" ]; then
            print_pass "package.json exists"
            
            # Check testing dependencies
            if grep -q "jest" package.json; then
                print_pass "Jest testing framework configured"
            else
                print_fail "Jest not found in package.json"
            fi
            
            if grep -q "@testing-library" package.json; then
                print_pass "React Testing Library configured"
            else
                print_warning "React Testing Library not found"
            fi
            
        else
            print_fail "package.json missing in src-code"
        fi
        
        # Check Jest configuration
        if [ -f "jest.config.js" ]; then
            print_pass "Jest configuration file exists"
        else
            print_warning "Jest configuration file missing"
        fi
        
        # Check test directories
        if [ -d "src/test" ] || [ -d "tests" ]; then
            print_pass "Test directories exist"
        else
            print_warning "Test directories missing"
        fi
        
        cd ..
    else
        print_fail "src-code directory missing"
    fi
}

# Validate configuration files
validate_configuration_files() {
    print_section "Configuration Files Validation"
    
    CONFIG_FILES=("scripts/validate-configs.js" "scripts/setup-branch-protection.sh" "scripts/validate-stage2-setup.sh")
    
    for file in "${CONFIG_FILES[@]}"; do
        print_check "Configuration file: $file"
        if [ -f "$file" ]; then
            if [ -x "$file" ]; then
                print_pass "File exists and is executable: $file"
            else
                print_warning "File exists but not executable: $file (run: chmod +x $file)"
            fi
        else
            print_fail "Missing file: $file"
        fi
    done
}

# Print final summary
print_final_summary() {
    echo ""
    print_header "Validation Summary"
    
    echo "Total Checks: $TOTAL_CHECKS"
    echo -e "${GREEN}Passed: $PASSED_CHECKS${NC}"
    echo -e "${RED}Failed: $FAILED_CHECKS${NC}"
    echo -e "${YELLOW}Warnings: $WARNING_CHECKS${NC}"
    echo ""
    
    if [ $FAILED_CHECKS -eq 0 ]; then
        if [ $WARNING_CHECKS -eq 0 ]; then
            print_pass "🎉 All validations passed! Your Stage-2 setup is ready."
        else
            echo -e "${YELLOW}⚠️  Setup is mostly ready with some warnings to address.${NC}"
        fi
    else
        echo -e "${RED}❌ Setup has issues that need to be resolved before proceeding.${NC}"
        echo ""
        echo "Common solutions:"
        echo "1. Install missing prerequisites"
        echo "2. Run: gh auth login"
        echo "3. Configure GitHub secrets via web interface or CLI"
        echo "4. Run: ./scripts/setup-branch-protection.sh"
        echo "5. Ensure you're in the correct repository directory"
    fi
    
    echo ""
    print_info "For detailed setup instructions, see: docs/STAGE-2-MASTER-GUIDE.md"
}

# Run main function
main "$@"
