#!/bin/bash

# Stage 1 - Setup Tools Script
# Health Care Management System - Basic CI/CD Deployment

set -e

echo "🚀 Stage 1: Setting up required tools for basic CI/CD deployment"
echo "================================================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Check if running on Ubuntu/Debian
if ! command -v apt &> /dev/null; then
    print_error "This script is designed for Ubuntu/Debian systems"
    exit 1
fi

print_info "Updating package list..."
sudo apt update

# Install Docker
print_info "Installing Docker..."
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    rm get-docker.sh
    print_status "Docker installed successfully"
else
    print_warning "Docker is already installed"
fi

# Verify kubectl (your current version is perfect!)
print_info "Verifying kubectl installation..."
if command -v kubectl &> /dev/null; then
    KUBECTL_VERSION=$(kubectl version --client --short 2>/dev/null | grep "Client Version" | cut -d' ' -f3)
    print_status "kubectl $KUBECTL_VERSION is installed"

    # Check if version is compatible with EKS 1.32
    if [[ "$KUBECTL_VERSION" =~ v1\.(3[1-4]|[4-9][0-9])\. ]]; then
        print_status "kubectl $KUBECTL_VERSION is compatible with EKS 1.32 (±1 version skew)"
    else
        print_warning "kubectl $KUBECTL_VERSION may not be optimal for EKS 1.32"
        print_info "Recommended: kubectl v1.31.x - v1.33.x for EKS 1.32"
    fi
else
    print_error "kubectl not found. Please install kubectl first."
    print_info "Your system should have kubectl v1.33.3 which is perfect for EKS 1.32"
    exit 1
fi

# Install AWS CLI
print_info "Installing AWS CLI..."
if ! command -v aws &> /dev/null; then
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
    rm -rf aws awscliv2.zip
    print_status "AWS CLI installed successfully"
else
    print_warning "AWS CLI is already installed"
fi

# Install eksctl
print_info "Installing eksctl..."
if ! command -v eksctl &> /dev/null; then
    curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
    sudo mv /tmp/eksctl /usr/local/bin
    print_status "eksctl installed successfully"
else
    print_warning "eksctl is already installed"
fi

# Install additional useful tools
print_info "Installing additional tools..."
sudo apt install -y jq curl wget unzip

echo ""
echo "🎉 Tool installation completed!"
echo "================================"

# Verify installations
echo ""
print_info "Verifying installations..."
echo "Docker version: $(docker --version)"
echo "kubectl version: $(kubectl version --client --short 2>/dev/null || echo 'kubectl not found')"
echo "AWS CLI version: $(aws --version)"
echo "eksctl version: $(eksctl version)"

echo ""
print_warning "IMPORTANT: You may need to log out and log back in for Docker group permissions to take effect"
print_info "Next steps:"
echo "1. Configure AWS credentials: aws configure"
echo "2. Build and push Docker images to Docker Hub"
echo "3. Run: ./scripts/create-eks-cluster.sh (creates EKS 1.32 cluster)"
echo "4. Run: ./scripts/deploy-to-eks.sh"

echo ""
print_status "Setup completed! Ready for Stage 1 deployment."
