#!/bin/bash

# Clean Dependencies Script for Stage-1
# Removes conflicting node_modules and reinstalls clean Stage-1 dependencies

set -e

echo "🧹 Cleaning Stage-1 Dependencies"
echo "================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Determine script location and set paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STAGE_DIR="$(dirname "$SCRIPT_DIR")"
SRC_CODE_DIR="$STAGE_DIR/src-code"

# Check if source code directory exists
if [ ! -d "$SRC_CODE_DIR" ]; then
    print_error "Source code directory not found: $SRC_CODE_DIR"
    exit 1
fi

print_status "Using source code directory: $SRC_CODE_DIR"
cd "$SRC_CODE_DIR"

print_status "Step 1: Removing conflicting node_modules directories..."

# Remove all node_modules directories
if [ -d "node_modules" ]; then
    print_status "Removing root node_modules..."
    rm -rf node_modules
    print_success "Root node_modules removed"
fi

if [ -d "backend/node_modules" ]; then
    print_status "Removing backend node_modules..."
    rm -rf backend/node_modules
    print_success "Backend node_modules removed"
fi

if [ -d "frontend/node_modules" ]; then
    print_status "Removing frontend node_modules..."
    rm -rf frontend/node_modules
    print_success "Frontend node_modules removed"
fi

print_status "Step 2: Removing package-lock.json files for clean install..."

# Remove package-lock.json files
if [ -f "package-lock.json" ]; then
    rm -f package-lock.json
    print_success "Root package-lock.json removed"
fi

if [ -f "backend/package-lock.json" ]; then
    rm -f backend/package-lock.json
    print_success "Backend package-lock.json removed"
fi

if [ -f "frontend/package-lock.json" ]; then
    rm -f frontend/package-lock.json
    print_success "Frontend package-lock.json removed"
fi

print_status "Step 3: Installing clean Stage-1 dependencies..."

# Install root dependencies if package.json exists
if [ -f "package.json" ]; then
    print_status "Installing root dependencies..."
    npm install
    print_success "Root dependencies installed"
fi

# Install backend dependencies
if [ -f "backend/package.json" ]; then
    print_status "Installing backend dependencies..."
    cd backend
    npm install
    cd ..
    print_success "Backend dependencies installed"
fi

# Install frontend dependencies
if [ -f "frontend/package.json" ]; then
    print_status "Installing frontend dependencies..."
    cd frontend
    npm install
    cd ..
    print_success "Frontend dependencies installed"
fi

print_success "✅ Dependency cleanup completed!"
echo ""
echo "📋 Summary:"
echo "✅ Removed conflicting node_modules directories"
echo "✅ Removed package-lock.json files"
echo "✅ Installed clean Stage-1 dependencies"
echo ""
echo "🔄 Next Steps:"
echo "1. Run Docker build: ./scripts/build-and-push-images.sh"
echo "2. The NPM CI error should now be resolved"
echo ""
echo "🎉 Stage-1 dependencies are now clean and ready for Docker build!"
