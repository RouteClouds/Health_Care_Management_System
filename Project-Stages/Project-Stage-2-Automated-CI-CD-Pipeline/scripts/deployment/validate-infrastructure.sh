#!/bin/bash

# Tool Installation Validation Script
# Healthcare Management System - Stage 2
# Validates all required tools are properly installed and configured

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔍 Stage 2 Tool Installation Validation${NC}"
echo -e "${BLUE}========================================${NC}\n"

# Function to print status
print_status() {
    local status=$1
    local message=$2
    
    case $status in
        "success")
            echo -e "${GREEN}✅ $message${NC}"
            ;;
        "error")
            echo -e "${RED}❌ $message${NC}"
            ;;
        "warning")
            echo -e "${YELLOW}⚠️  $message${NC}"
            ;;
        "info")
            echo -e "${BLUE}ℹ️  $message${NC}"
            ;;
    esac
}

# Function to check command availability with version
check_command() {
    local cmd=$1
    local expected_version=$2
    local version_flag=$3

    if command -v "$cmd" &> /dev/null; then
        local version_output=$($cmd $version_flag 2>/dev/null | head -1)
        print_status "success" "$cmd is available: $version_output"
        return 0
    else
        print_status "error" "$cmd is not available"
        return 1
    fi
}

# Function to validate Node.js version
validate_nodejs() {
    print_status "info" "Validating Node.js installation..."

    if command -v node &> /dev/null; then
        local node_version=$(node --version)
        local major_version=$(echo $node_version | cut -d'.' -f1 | sed 's/v//')

        print_status "success" "Node.js $node_version is installed"

        if [ "$major_version" -ge 20 ]; then
            print_status "success" "Node.js version is compatible with selenium-webdriver (>=20.0.0)"
        else
            print_status "error" "Node.js version $node_version is too old. selenium-webdriver requires >=20.0.0"
            return 1
        fi

        # Check npm
        if command -v npm &> /dev/null; then
            local npm_version=$(npm --version)
            print_status "success" "NPM $npm_version is available"
        else
            print_status "error" "NPM is not available"
            return 1
        fi

        return 0
    else
        print_status "error" "Node.js is not installed"
        return 1
    fi
}

# Function to validate AWS configuration
validate_aws() {
    print_status "info" "Validating AWS configuration..."

    if command -v aws &> /dev/null; then
        print_status "success" "AWS CLI is installed"

        # Check AWS credentials
        if aws sts get-caller-identity &> /dev/null; then
            local account_id=$(aws sts get-caller-identity --query Account --output text)
            local user_arn=$(aws sts get-caller-identity --query Arn --output text)
            print_status "success" "AWS credentials are configured"
            print_status "info" "Account: $account_id"
            print_status "info" "User: $user_arn"
        else
            print_status "error" "AWS credentials are not configured"
            print_status "info" "Run: aws configure"
            return 1
        fi

        return 0
    else
        print_status "error" "AWS CLI is not installed"
        return 1
    fi
}

# Function to validate GitHub CLI
validate_github() {
    print_status "info" "Validating GitHub CLI..."

    if command -v gh &> /dev/null; then
        local gh_version=$(gh --version | head -1)
        print_status "success" "GitHub CLI is installed: $gh_version"

        # Check GitHub authentication
        if gh auth status &> /dev/null; then
            print_status "success" "GitHub CLI is authenticated"
        else
            print_status "warning" "GitHub CLI is not authenticated"
            print_status "info" "Run: gh auth login"
        fi

        return 0
    else
        print_status "error" "GitHub CLI is not installed"
        return 1
    fi
}

# Function to validate Docker
validate_docker() {
    print_status "info" "Validating Docker..."

    if command -v docker &> /dev/null; then
        local docker_version=$(docker --version)
        print_status "success" "Docker is installed: $docker_version"

        # Check Docker daemon
        if docker info &> /dev/null; then
            print_status "success" "Docker daemon is running"
        else
            print_status "error" "Docker daemon is not running"
            print_status "info" "Run: sudo systemctl start docker"
            return 1
        fi

        # Check Docker Hub login
        if docker info | grep -q "Username:"; then
            print_status "success" "Docker Hub is authenticated"
        else
            print_status "warning" "Docker Hub is not authenticated"
            print_status "info" "Run: docker login"
        fi

        return 0
    else
        print_status "error" "Docker is not installed"
        return 1
    fi
}

# Main validation function
main() {
    local exit_code=0

    echo -e "${BLUE}📋 Checking Core Tools${NC}"
    echo "========================"

    # Check required commands
    check_command "aws" "" "--version" || exit_code=1
    check_command "kubectl" "" "version --client --short" || exit_code=1
    check_command "eksctl" "" "version" || exit_code=1
    check_command "docker" "" "--version" || exit_code=1
    check_command "gh" "" "--version" || exit_code=1

    echo ""

    echo -e "${BLUE}🔍 Tool Configuration Validation${NC}"
    echo "=================================="

    # Run detailed validations
    validate_nodejs || exit_code=1
    echo ""

    validate_aws || exit_code=1
    echo ""

    validate_github || exit_code=1
    echo ""

    validate_docker || exit_code=1
    echo ""

    # Summary
    echo -e "${BLUE}📊 Validation Summary${NC}"
    echo "====================="

    if [ $exit_code -eq 0 ]; then
        print_status "success" "All tool validations passed!"
        print_status "info" "System is ready for Stage 2 CI/CD pipeline setup"
        echo ""
        print_status "info" "Next steps:"
        echo "  1. Set up testing infrastructure: ./scripts/fix-testing-setup.sh"
        echo "  2. Configure quality gates: node scripts/validate-configs.js"
        echo "  3. Create EKS cluster: ./scripts/deployment/create-eks-cluster.sh"
    else
        print_status "error" "Some validations failed"
        print_status "info" "Please fix the issues above before proceeding"
        echo ""
        print_status "info" "Common fixes:"
        echo "  - Run setup script: ./scripts/setup-tools.sh"
        echo "  - Configure AWS: aws configure"
        echo "  - Authenticate GitHub: gh auth login"
        echo "  - Login to Docker Hub: docker login"
    fi

    exit $exit_code
}

# Run main function
main "$@"
