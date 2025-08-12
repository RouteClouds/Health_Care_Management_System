#!/bin/bash

# Healthcare Management System - Automated Environment Setup
# This script automatically sets up the development environment
# Run this script after cloning the repository

set -e  # Exit on any error

echo "🏥 Healthcare Management System - Automated Setup"
echo "================================================="
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

echo "🔍 Checking Prerequisites..."
echo "----------------------------"

# Check Node.js
if ! command_exists node; then
    print_status "ERROR" "Node.js not found. Please install Node.js 18.x or higher first."
    echo "Visit: https://nodejs.org/"
    exit 1
fi

NODE_VERSION=$(node --version)
NODE_MAJOR=$(echo $NODE_VERSION | cut -d'.' -f1 | sed 's/v//')
if [ "$NODE_MAJOR" -lt 18 ]; then
    print_status "ERROR" "Node.js version $NODE_VERSION is too old. Please install 18.x or higher."
    exit 1
fi

print_status "SUCCESS" "Node.js version: $NODE_VERSION"

# Check npm
if ! command_exists npm; then
    print_status "ERROR" "npm not found. Please install npm."
    exit 1
fi

NPM_VERSION=$(npm --version)
print_status "SUCCESS" "npm version: $NPM_VERSION"

echo ""
echo "📁 Verifying Project Structure..."
echo "---------------------------------"

# Check if we're in the correct directory
if [ ! -f "package.json" ]; then
    print_status "ERROR" "package.json not found. Please run this script from src-code directory"
    exit 1
fi

print_status "SUCCESS" "Found package.json - in correct directory"

# Check workspace structure
if [ ! -d "frontend" ] || [ ! -d "backend" ]; then
    print_status "ERROR" "Frontend or backend directory missing"
    exit 1
fi

print_status "SUCCESS" "Frontend and backend directories found"

echo ""
echo "🔧 Installing Dependencies..."
echo "-----------------------------"

# Step 1: Install root dependencies
print_status "INFO" "Installing root workspace dependencies..."
if npm install; then
    print_status "SUCCESS" "Root dependencies installed"
else
    print_status "ERROR" "Failed to install root dependencies"
    exit 1
fi

# Step 2: Install frontend dependencies
print_status "INFO" "Installing frontend dependencies..."
if (cd frontend && npm install); then
    print_status "SUCCESS" "Frontend dependencies installed"
else
    print_status "ERROR" "Failed to install frontend dependencies"
    exit 1
fi

# Step 3: Install backend dependencies
print_status "INFO" "Installing backend dependencies..."
if (cd backend && npm install); then
    print_status "SUCCESS" "Backend dependencies installed"
else
    print_status "ERROR" "Failed to install backend dependencies"
    exit 1
fi

echo ""
echo "🔒 Verifying Package Lock Files..."
echo "----------------------------------"

# Verify all package-lock.json files exist
LOCK_FILES=("package-lock.json" "frontend/package-lock.json" "backend/package-lock.json")
for lock_file in "${LOCK_FILES[@]}"; do
    if [ -f "$lock_file" ]; then
        print_status "SUCCESS" "$lock_file exists"
    else
        print_status "ERROR" "$lock_file missing"
        exit 1
    fi
done

echo ""
echo "🏗️  Testing Build Processes..."
echo "------------------------------"

# Test frontend build
print_status "INFO" "Testing frontend build..."
if (cd frontend && npm run build); then
    print_status "SUCCESS" "Frontend build successful"
else
    print_status "ERROR" "Frontend build failed"
    exit 1
fi

# Test backend build
print_status "INFO" "Testing backend build..."
if (cd backend && npm run build); then
    print_status "SUCCESS" "Backend build successful"
else
    print_status "ERROR" "Backend build failed"
    exit 1
fi

echo ""
echo "🧪 Running Tests..."
echo "------------------"

# Run frontend tests
print_status "INFO" "Running frontend tests..."
if (cd frontend && npm test); then
    print_status "SUCCESS" "Frontend tests passed"
else
    print_status "WARNING" "Frontend tests failed or skipped"
fi

# Run backend tests
print_status "INFO" "Running backend tests..."
if (cd backend && npm test); then
    print_status "SUCCESS" "Backend tests passed"
else
    print_status "WARNING" "Backend tests failed or skipped"
fi

echo ""
echo "🎉 Setup Complete!"
echo "=================="

print_status "SUCCESS" "Environment setup completed successfully!"
echo ""
echo "📋 What was configured:"
echo "   ✅ Root workspace dependencies installed"
echo "   ✅ Frontend dependencies installed with package-lock.json"
echo "   ✅ Backend dependencies installed with package-lock.json"
echo "   ✅ Build processes verified"
echo "   ✅ Basic tests executed"
echo ""
echo "🚀 Next Steps:"
echo "   1. Start development: npm run dev"
echo "   2. Commit changes: git add . && git commit -m 'setup: complete environment setup'"
echo "   3. Push to trigger CI/CD: git push origin main"
echo "   4. Monitor pipeline: https://github.com/your-repo/actions"
echo ""
echo "📚 Documentation:"
echo "   - Setup Guide: docs/How-To-Setup-Src-Code-Project.md"
echo "   - Troubleshooting: docs/How-To-Setup-Src-Code-Project.md#troubleshooting"
echo ""
echo "🔍 Validate anytime: ./validate-setup.sh"
