#!/bin/bash

# Simple test script to debug issues

echo "🚀 Simple Test Script"
echo "===================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Test basic functionality
log_info "Testing basic functionality..."

# Check AWS CLI
if command -v aws >/dev/null 2>&1; then
    log_success "✅ AWS CLI installed"
    
    # Check AWS credentials
    if aws sts get-caller-identity >/dev/null 2>&1; then
        account_id=$(aws sts get-caller-identity --query Account --output text 2>/dev/null || echo "unknown")
        log_success "✅ AWS credentials working - Account: $account_id"
    else
        log_error "❌ AWS credentials not configured"
    fi
else
    log_error "❌ AWS CLI not installed"
fi

# Check other tools
tools=("terraform" "kubectl" "helm")
for tool in "${tools[@]}"; do
    if command -v "$tool" >/dev/null 2>&1; then
        version=$($tool version 2>/dev/null | head -1 || echo "version unknown")
        log_success "✅ $tool installed - $version"
    else
        log_error "❌ $tool not installed"
    fi
done

echo ""
log_success "🎉 Simple test completed!"
