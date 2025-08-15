#!/bin/bash

# Automated Tool Installation Script for Stage-3 Healthcare Management System
# Installs all required tools: AWS CLI, Terraform, kubectl, Helm, Docker

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

# Check if running as root
check_sudo() {
    if [[ $EUID -eq 0 ]]; then
        log_error "This script should not be run as root. Please run as a regular user."
        exit 1
    fi
    
    # Check if user has sudo privileges
    if ! sudo -n true 2>/dev/null; then
        log_info "This script requires sudo privileges for package installation."
        log_info "You may be prompted for your password."
    fi
}

# Detect OS
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if [ -f /etc/debian_version ]; then
            OS="debian"
            log_info "Detected Debian/Ubuntu system"
        elif [ -f /etc/redhat-release ]; then
            OS="redhat"
            log_info "Detected RedHat/CentOS/Fedora system"
        else
            OS="linux"
            log_info "Detected generic Linux system"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
        log_info "Detected macOS system"
    else
        log_error "Unsupported operating system: $OSTYPE"
        exit 1
    fi
}

# Install AWS CLI v2
install_aws_cli() {
    log_info "Installing AWS CLI v2..."
    
    if command -v aws >/dev/null 2>&1; then
        local version=$(aws --version 2>&1 | cut -d/ -f2 | cut -d' ' -f1)
        log_warning "AWS CLI already installed (version: $version)"
        return 0
    fi
    
    case $OS in
        "debian")
            curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
            sudo apt-get update && sudo apt-get install -y unzip
            unzip awscliv2.zip
            sudo ./aws/install
            rm -rf aws awscliv2.zip
            ;;
        "redhat")
            curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
            sudo yum install -y unzip
            unzip awscliv2.zip
            sudo ./aws/install
            rm -rf aws awscliv2.zip
            ;;
        "macos")
            if command -v brew >/dev/null 2>&1; then
                brew install awscli
            else
                curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
                sudo installer -pkg AWSCLIV2.pkg -target /
                rm AWSCLIV2.pkg
            fi
            ;;
    esac
    
    if command -v aws >/dev/null 2>&1; then
        log_success "✅ AWS CLI installed successfully"
        aws --version
    else
        log_error "❌ AWS CLI installation failed"
        return 1
    fi
}

# Install Terraform
install_terraform() {
    log_info "Installing Terraform..."
    
    if command -v terraform >/dev/null 2>&1; then
        local version=$(terraform version | head -1 | cut -d' ' -f2)
        log_warning "Terraform already installed ($version)"
        return 0
    fi
    
    local TERRAFORM_VERSION="1.6.0"
    
    case $OS in
        "debian"|"redhat"|"linux")
            wget "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip"
            sudo apt-get update && sudo apt-get install -y unzip 2>/dev/null || sudo yum install -y unzip 2>/dev/null
            unzip "terraform_${TERRAFORM_VERSION}_linux_amd64.zip"
            sudo mv terraform /usr/local/bin/
            rm "terraform_${TERRAFORM_VERSION}_linux_amd64.zip"
            ;;
        "macos")
            if command -v brew >/dev/null 2>&1; then
                brew tap hashicorp/tap
                brew install hashicorp/tap/terraform
            else
                wget "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_darwin_amd64.zip"
                unzip "terraform_${TERRAFORM_VERSION}_darwin_amd64.zip"
                sudo mv terraform /usr/local/bin/
                rm "terraform_${TERRAFORM_VERSION}_darwin_amd64.zip"
            fi
            ;;
    esac
    
    if command -v terraform >/dev/null 2>&1; then
        log_success "✅ Terraform installed successfully"
        terraform version
    else
        log_error "❌ Terraform installation failed"
        return 1
    fi
}

# Install kubectl
install_kubectl() {
    log_info "Installing kubectl..."
    
    if command -v kubectl >/dev/null 2>&1; then
        local version=$(kubectl version --client --short 2>/dev/null | cut -d' ' -f3)
        log_warning "kubectl already installed ($version)"
        return 0
    fi
    
    case $OS in
        "debian"|"redhat"|"linux")
            curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
            chmod +x kubectl
            sudo mv kubectl /usr/local/bin/
            ;;
        "macos")
            if command -v brew >/dev/null 2>&1; then
                brew install kubectl
            else
                curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/darwin/amd64/kubectl"
                chmod +x kubectl
                sudo mv kubectl /usr/local/bin/
            fi
            ;;
    esac
    
    if command -v kubectl >/dev/null 2>&1; then
        log_success "✅ kubectl installed successfully"
        kubectl version --client
    else
        log_error "❌ kubectl installation failed"
        return 1
    fi
}

# Install Helm
install_helm() {
    log_info "Installing Helm..."
    
    if command -v helm >/dev/null 2>&1; then
        local version=$(helm version --short 2>/dev/null | cut -d' ' -f1)
        log_warning "Helm already installed ($version)"
        return 0
    fi
    
    case $OS in
        "debian"|"redhat"|"linux"|"macos")
            curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
            ;;
    esac
    
    if command -v helm >/dev/null 2>&1; then
        log_success "✅ Helm installed successfully"
        helm version
    else
        log_error "❌ Helm installation failed"
        return 1
    fi
}

# Install Docker (optional)
install_docker() {
    log_info "Installing Docker (optional for local testing)..."
    
    if command -v docker >/dev/null 2>&1; then
        local version=$(docker --version | cut -d' ' -f3 | cut -d',' -f1)
        log_warning "Docker already installed (version: $version)"
        return 0
    fi
    
    case $OS in
        "debian")
            sudo apt-get update
            sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
            curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
            echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
            sudo apt-get update
            sudo apt-get install -y docker-ce docker-ce-cli containerd.io
            sudo systemctl start docker
            sudo systemctl enable docker
            sudo usermod -aG docker $USER
            ;;
        "redhat")
            sudo yum install -y yum-utils
            sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
            sudo yum install -y docker-ce docker-ce-cli containerd.io
            sudo systemctl start docker
            sudo systemctl enable docker
            sudo usermod -aG docker $USER
            ;;
        "macos")
            if command -v brew >/dev/null 2>&1; then
                brew install --cask docker
                log_info "Please start Docker Desktop manually after installation"
            else
                log_info "Please download Docker Desktop from https://www.docker.com/products/docker-desktop"
            fi
            ;;
    esac
    
    if command -v docker >/dev/null 2>&1; then
        log_success "✅ Docker installed successfully"
        docker --version
        log_info "Note: You may need to log out and back in for Docker group permissions to take effect"
    else
        log_warning "⚠️ Docker installation may require manual completion"
    fi
}

# Verify installations
verify_installations() {
    log_info "Verifying all installations..."
    
    local errors=0
    
    # Check each tool
    local tools=("aws" "terraform" "kubectl" "helm")
    for tool in "${tools[@]}"; do
        if command -v "$tool" >/dev/null 2>&1; then
            local version=$($tool version 2>/dev/null | head -1 || echo "version check failed")
            log_success "✅ $tool: $version"
        else
            log_error "❌ $tool: not found"
            ((errors++))
        fi
    done
    
    # Check Docker (optional)
    if command -v docker >/dev/null 2>&1; then
        local version=$(docker --version 2>/dev/null || echo "version check failed")
        log_success "✅ docker: $version"
    else
        log_warning "⚠️ docker: not installed (optional)"
    fi
    
    echo ""
    if [ $errors -eq 0 ]; then
        log_success "🎉 All required tools installed successfully!"
        log_info "Next steps:"
        log_info "1. Configure AWS credentials: aws configure"
        log_info "2. Run prerequisites test: ./scripts/validation/test-phase-deployment.sh prerequisites"
        return 0
    else
        log_error "❌ $errors tools failed to install. Please check the errors above."
        return 1
    fi
}

# Main installation function
main() {
    echo "🚀 Stage-3 Automated Tool Installation"
    echo "======================================"
    echo "This script will install:"
    echo "- AWS CLI v2"
    echo "- Terraform v1.6.0"
    echo "- kubectl (latest stable)"
    echo "- Helm v3 (latest)"
    echo "- Docker (optional)"
    echo ""
    
    # Confirm installation
    read -p "Continue with installation? (y/N): " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        log_info "Installation cancelled by user"
        exit 0
    fi
    
    # Run installation steps
    check_sudo
    detect_os
    
    install_aws_cli
    install_terraform
    install_kubectl
    install_helm
    
    # Ask about Docker
    echo ""
    read -p "Install Docker for local testing? (y/N): " docker_confirm
    if [[ "$docker_confirm" =~ ^[Yy]$ ]]; then
        install_docker
    fi
    
    echo ""
    verify_installations
}

# Execute main function
main "$@"
