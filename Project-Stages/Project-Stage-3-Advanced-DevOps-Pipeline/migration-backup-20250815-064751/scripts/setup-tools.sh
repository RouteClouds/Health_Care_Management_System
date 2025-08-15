#!/bin/bash

# Stage 2 - Setup Tools Script
# Health Care Management System - Automated CI/CD Pipeline

set -e

echo "🚀 Stage 2: Setting up required tools for automated CI/CD pipeline"
echo "=================================================================="

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

# Install Node.js 20 LTS (required for selenium-webdriver)
print_info "Installing Node.js 20 LTS..."
if ! command -v node &> /dev/null || [[ $(node --version | cut -d'.' -f1 | sed 's/v//') -lt 20 ]]; then
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
    sudo apt-get install -y nodejs
    print_status "Node.js 20 LTS installed successfully"
else
    NODE_VERSION=$(node --version)
    print_warning "Node.js $NODE_VERSION is already installed"
fi

# Install GitHub CLI
print_info "Installing GitHub CLI..."
if ! command -v gh &> /dev/null; then
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
    sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
    sudo apt update
    sudo apt install -y gh
    print_status "GitHub CLI installed successfully"
else
    print_warning "GitHub CLI is already installed"
fi

# Install additional useful tools
print_info "Installing additional tools..."
sudo apt install -y jq curl wget unzip git

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
echo "Node.js version: $(node --version)"
echo "NPM version: $(npm --version)"
echo "GitHub CLI version: $(gh --version | head -1)"

echo ""
print_warning "IMPORTANT: You may need to log out and log back in for Docker group permissions to take effect"
print_info "Next steps for Stage 2 CI/CD Pipeline:"
echo "1. Configure AWS credentials: aws configure"
echo "2. Authenticate GitHub CLI: gh auth login (NOTE: Use 'gh' not 'git')"
echo "3. Create EKS cluster: ./scripts/deployment/create-eks-cluster.sh"
echo "4. Set up testing infrastructure: ./scripts/fix-testing-setup.sh"
echo "5. Configure quality gates: node scripts/validate-configs.js"
echo "6. Set up CI/CD pipeline with GitHub Actions"

echo ""
print_status "Setup completed! Ready for Stage 2 automated CI/CD pipeline deployment."
