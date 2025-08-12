#!/bin/bash

# Healthcare Management System - Setup Validation Script
# This script validates that the development environment is properly configured
# Run this script after cloning the repository to ensure smooth CI/CD pipeline execution

set -e  # Exit on any error

echo "🏥 Healthcare Management System - Setup Validation"
echo "=================================================="
echo ""

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    local status=$1
    local message=$2
    if [ "$status" = "SUCCESS" ]; then
        echo -e "${GREEN}✅ $message${NC}"
    elif [ "$status" = "ERROR" ]; then
        echo -e "${RED}❌ $message${NC}"
    elif [ "$status" = "WARNING" ]; then
        echo -e "${YELLOW}⚠️  $message${NC}"
    elif [ "$status" = "INFO" ]; then
        echo -e "${BLUE}ℹ️  $message${NC}"
    fi
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Validation counters
ERRORS=0
WARNINGS=0

echo "🔍 Checking Prerequisites..."
echo "----------------------------"

# Check Node.js version
if command_exists node; then
    NODE_VERSION=$(node --version)
    NODE_MAJOR=$(echo $NODE_VERSION | cut -d'.' -f1 | sed 's/v//')
    if [ "$NODE_MAJOR" -ge 18 ]; then
        print_status "SUCCESS" "Node.js version: $NODE_VERSION (✓ >= 18.x required)"
    else
        print_status "ERROR" "Node.js version: $NODE_VERSION (✗ >= 18.x required)"
        ERRORS=$((ERRORS + 1))
    fi
else
    print_status "ERROR" "Node.js not found. Please install Node.js 18.x or higher"
    ERRORS=$((ERRORS + 1))
fi

# Check npm version
if command_exists npm; then
    NPM_VERSION=$(npm --version)
    print_status "SUCCESS" "npm version: $NPM_VERSION"
else
    print_status "ERROR" "npm not found. Please install npm"
    ERRORS=$((ERRORS + 1))
fi

# Check Docker (optional for local development)
if command_exists docker; then
    DOCKER_VERSION=$(docker --version)
    print_status "SUCCESS" "Docker version: $DOCKER_VERSION"
else
    print_status "WARNING" "Docker not found. Required for containerized deployment"
    WARNINGS=$((WARNINGS + 1))
fi

echo ""
echo "📁 Checking Project Structure..."
echo "--------------------------------"

# Check if we're in the correct directory
if [ ! -f "package.json" ]; then
    print_status "ERROR" "package.json not found. Please run this script from src-code directory"
    ERRORS=$((ERRORS + 1))
    exit 1
fi

# Check workspace configuration
if grep -q '"workspaces"' package.json; then
    print_status "SUCCESS" "npm workspaces configuration found"
else
    print_status "ERROR" "npm workspaces configuration missing in package.json"
    ERRORS=$((ERRORS + 1))
fi

# Check frontend directory
if [ -d "frontend" ]; then
    print_status "SUCCESS" "Frontend directory exists"
    if [ -f "frontend/package.json" ]; then
        print_status "SUCCESS" "Frontend package.json exists"
    else
        print_status "ERROR" "Frontend package.json missing"
        ERRORS=$((ERRORS + 1))
    fi
else
    print_status "ERROR" "Frontend directory missing"
    ERRORS=$((ERRORS + 1))
fi

# Check backend directory
if [ -d "backend" ]; then
    print_status "SUCCESS" "Backend directory exists"
    if [ -f "backend/package.json" ]; then
        print_status "SUCCESS" "Backend package.json exists"
    else
        print_status "ERROR" "Backend package.json missing"
        ERRORS=$((ERRORS + 1))
    fi
else
    print_status "ERROR" "Backend directory missing"
    ERRORS=$((ERRORS + 1))
fi

echo ""
echo "🔒 Checking Package Lock Files..."
echo "---------------------------------"

# Check root package-lock.json
if [ -f "package-lock.json" ]; then
    print_status "SUCCESS" "Root package-lock.json exists"
else
    print_status "ERROR" "Root package-lock.json missing - run 'npm install' in root directory"
    ERRORS=$((ERRORS + 1))
fi

# Check frontend package-lock.json
if [ -f "frontend/package-lock.json" ]; then
    print_status "SUCCESS" "Frontend package-lock.json exists (CRITICAL for Docker builds)"
else
    print_status "ERROR" "Frontend package-lock.json missing - run 'npm install' in frontend directory"
    ERRORS=$((ERRORS + 1))
fi

# Check backend package-lock.json
if [ -f "backend/package-lock.json" ]; then
    print_status "SUCCESS" "Backend package-lock.json exists"
else
    print_status "ERROR" "Backend package-lock.json missing - run 'npm install' in backend directory"
    ERRORS=$((ERRORS + 1))
fi

echo ""
echo "🔧 Checking Dependencies Installation..."
echo "---------------------------------------"

# Check if node_modules exist
if [ -d "node_modules" ]; then
    print_status "SUCCESS" "Root node_modules directory exists"
else
    print_status "WARNING" "Root node_modules missing - dependencies may not be installed"
    WARNINGS=$((WARNINGS + 1))
fi

if [ -d "frontend/node_modules" ]; then
    print_status "SUCCESS" "Frontend node_modules directory exists"
else
    print_status "WARNING" "Frontend node_modules missing - run 'npm install' in frontend directory"
    WARNINGS=$((WARNINGS + 1))
fi

if [ -d "backend/node_modules" ]; then
    print_status "SUCCESS" "Backend node_modules directory exists"
else
    print_status "WARNING" "Backend node_modules missing - run 'npm install' in backend directory"
    WARNINGS=$((WARNINGS + 1))
fi

echo ""
echo "🏗️  Testing Build Processes..."
echo "------------------------------"

# Test frontend build (if dependencies are installed)
if [ -d "frontend/node_modules" ]; then
    print_status "INFO" "Testing frontend build..."
    if (cd frontend && npm run build >/dev/null 2>&1); then
        print_status "SUCCESS" "Frontend build test passed"
    else
        print_status "ERROR" "Frontend build test failed - check dependencies"
        ERRORS=$((ERRORS + 1))
    fi
else
    print_status "WARNING" "Skipping frontend build test - dependencies not installed"
    WARNINGS=$((WARNINGS + 1))
fi

# Test backend build (if dependencies are installed)
if [ -d "backend/node_modules" ]; then
    print_status "INFO" "Testing backend build..."
    if (cd backend && npm run build >/dev/null 2>&1); then
        print_status "SUCCESS" "Backend build test passed"
    else
        print_status "ERROR" "Backend build test failed - check dependencies"
        ERRORS=$((ERRORS + 1))
    fi
else
    print_status "WARNING" "Skipping backend build test - dependencies not installed"
    WARNINGS=$((WARNINGS + 1))
fi

echo ""
echo "📋 Validation Summary"
echo "===================="

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    print_status "SUCCESS" "All validations passed! Your environment is ready for CI/CD pipeline."
    echo ""
    echo "🚀 Next Steps:"
    echo "   1. Commit your changes: git add . && git commit -m 'setup: initial environment setup'"
    echo "   2. Push to trigger pipeline: git push origin main"
    echo "   3. Monitor GitHub Actions: https://github.com/your-repo/actions"
    exit 0
elif [ $ERRORS -eq 0 ]; then
    print_status "WARNING" "Validation completed with $WARNINGS warning(s). Environment should work but consider fixing warnings."
    echo ""
    echo "🔧 Recommended Actions:"
    echo "   1. Install missing optional dependencies"
    echo "   2. Run setup commands as suggested above"
    exit 0
else
    print_status "ERROR" "Validation failed with $ERRORS error(s) and $WARNINGS warning(s)."
    echo ""
    echo "🛠️  Required Actions:"
    echo "   1. Fix all errors listed above"
    echo "   2. Run this script again to validate"
    echo "   3. See setup guide: docs/How-To-Setup-Src-Code-Project.md"
    exit 1
fi
