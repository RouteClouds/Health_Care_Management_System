# 🚀 **Master Setup Guide - Complete Stage 2 Implementation**

## 📖 **Document Index**

### 🎯 **Getting Started (15 minutes)**
- [Prerequisites Check](#prerequisites-check) - System requirements and tools
- [Tool Installation](#tool-installation) - Automated and manual installation
- [Environment Validation](#environment-validation) - Verify setup is correct

### 🔧 **Core Setup (60 minutes)**
- [Source Code Setup](#source-code-setup) - Dependencies and environment
- [GitHub Configuration](#github-configuration) - Secrets and branch protection
- [Infrastructure Creation](#infrastructure-creation) - EKS cluster setup
- [Testing Setup](#testing-setup) - Unit, integration, and E2E testing

### 🚀 **Pipeline Setup (30 minutes)**
- [CI/CD Pipeline](#cicd-pipeline) - GitHub Actions workflow
- [Quality Gates](#quality-gates) - SonarQube and code quality
- [Security Scanning](#security-scanning) - Trivy vulnerability scanning

### 🌍 **Deployment (20 minutes)**
- [Multi-Environment Setup](#multi-environment-setup) - Dev, staging, production
- [Verification & Testing](#verification-testing) - End-to-end validation

### 📜 **Reference**
- [Script Reference](#script-reference) - All automation scripts
- [Quick Commands](#quick-commands) - Essential commands
- [Success Indicators](#success-indicators) - How to verify success

---

## 🎯 **Prerequisites Check**

### **System Requirements**
- **Operating System**: Linux/macOS/Windows with WSL2
- **Node.js**: Version 18.x or 20.x
- **Docker**: Latest version with daemon running
- **Git**: Version 2.x or higher
- **Internet**: Stable connection for downloads

### **Account Requirements**
- **GitHub Account**: With repository access
- **AWS Account**: With EKS permissions
- **Docker Hub Account**: For image registry

### **Quick Validation**
```bash
# Run this to check all prerequisites
cd Project-Stages/Project-Stage-2-Automated-CI-CD-Pipeline
./scripts/validate-stage2-setup.sh
```

---

## 🛠️ **Tool Installation**

### **Option A: Automated Installation (Recommended)**
```bash
# Install all required tools automatically
./scripts/setup-tools.sh

# Verify installation
./scripts/validate-infrastructure.sh
```

### **Option B: Manual Installation**
```bash
# AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip && sudo ./aws/install

# kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# eksctl
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin

# GitHub CLI
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update && sudo apt install gh

# Node.js 20 LTS
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs
```

---

## ✅ **Environment Validation**

### **Comprehensive Validation**
```bash
# Run complete environment check
./scripts/validate-stage2-setup.sh

# Expected output: All green checkmarks
# If any failures, follow the provided instructions
```

### **Individual Tool Verification**
```bash
# Check versions
node --version    # Should show v18.x.x or v20.x.x
npm --version     # Should show 8.x.x or higher
docker --version  # Should show 20.x.x or higher
aws --version     # Should show aws-cli/2.x.x
kubectl version --client  # Should show v1.28+
eksctl version    # Should show 0.150+
gh --version      # Should show gh version 2.x.x
```

---

## 💻 **Source Code Setup**

### **Automated Setup (Recommended)**
```bash
# Navigate to source code directory
cd src-code

# Run automated environment setup
./setup-environment.sh

# This script will:
# ✅ Install all dependencies (root, frontend, backend)
# ✅ Generate required package-lock.json files
# ✅ Test build processes
# ✅ Verify environment is ready
```

### **Validation**
```bash
# Validate setup and port configurations
./validate-setup.sh
./validate-port-config.sh

# Both should show all green checkmarks
```

### **Manual Setup (If Automated Fails)**
```bash
# Install root dependencies
npm install

# Install frontend dependencies
cd frontend && npm install && cd ..

# Install backend dependencies  
cd backend && npm install && cd ..

# Test builds
cd frontend && npm run build && cd ..
cd backend && npm run build && cd ..
```

---

## 🔑 **GitHub Configuration**

### **Authentication Setup**
```bash
# Login to GitHub CLI
gh auth login

# Select: GitHub.com → HTTPS → Yes (authenticate Git) → Login with web browser
```

### **Repository Secrets**
```bash
# Set required secrets
gh secret set AWS_ACCESS_KEY_ID --body "your-aws-access-key"
gh secret set AWS_SECRET_ACCESS_KEY --body "your-aws-secret-key"
gh secret set DOCKER_HUB_USERNAME --body "your-dockerhub-username"
gh secret set DOCKER_HUB_ACCESS_TOKEN --body "your-dockerhub-token"
gh secret set EKS_CLUSTER_NAME --body "healthcare-cluster-stage2"
gh secret set EKS_CLUSTER_REGION --body "us-east-1"
```

### **Branch Protection**
```bash
# Set up branch protection rules
./scripts/setup-branch-protection.sh

# Test branch protection
./scripts/test-branch-protection.sh
```

---

## ☸️ **Infrastructure Creation**

### **EKS Cluster Setup**
```bash
# Create complete EKS infrastructure
./scripts/deployment/create-eks-cluster.sh

# This creates:
# ✅ EKS cluster with 3 worker nodes
# ✅ Development, staging, production namespaces
# ✅ RBAC and service accounts
# ✅ Load balancers and ingress controllers
```

### **Verification**
```bash
# Verify cluster is ready
kubectl get nodes
kubectl get namespaces

# Should show 3 Ready nodes and healthcare namespaces
```

---

## 🧪 **Testing Setup**

### **Automated Testing Infrastructure**
```bash
# Set up complete testing infrastructure
./scripts/fix-testing-setup.sh

# This configures:
# ✅ Jest unit testing framework
# ✅ Selenium WebDriver for E2E tests
# ✅ React Testing Library
# ✅ Test environment configuration
```

### **Test Validation**
```bash
# Run tests to verify setup
cd src-code
npm test -- --testPathIgnorePatterns=tests/e2e

# Should show all unit tests passing
```

---

## 🚀 **CI/CD Pipeline**

### **GitHub Actions Workflow**
The pipeline is already configured in `.github/workflows/stage2-ci.yml` and includes:

- **Unit Testing**: Jest tests with coverage
- **Quality Gates**: SonarQube code analysis
- **Security Scanning**: Trivy vulnerability scanning
- **Docker Build**: Automated image building
- **E2E Testing**: Selenium browser testing
- **Multi-Environment Deployment**: Automated deployment to EKS

### **Pipeline Trigger**
```bash
# Trigger the pipeline
git add .
git commit -m "feat: trigger Stage 2 CI/CD pipeline"
git push origin main

# Monitor pipeline
gh run list --limit 5
gh run watch
```

---

## 📊 **Quality Gates**

### **SonarQube Configuration**
Quality gates are automatically configured with:
- **Code Coverage**: Minimum 80%
- **Duplicated Lines**: Maximum 3%
- **Maintainability Rating**: A
- **Reliability Rating**: A
- **Security Rating**: A

### **Manual Quality Check**
```bash
# Run quality analysis locally
./scripts/validate-configs.js
```

---

## 🔒 **Security Scanning**

### **Trivy Security Scanning**
Automated security scanning includes:
- **Dependency Vulnerabilities**: NPM packages
- **Container Vulnerabilities**: Docker images
- **Infrastructure Vulnerabilities**: Kubernetes configs

### **Manual Security Check**
```bash
# Run security scan locally
trivy fs . --severity HIGH,CRITICAL
```

---

## 🌍 **Multi-Environment Setup**

### **Environment Configuration**
- **Development**: `healthcare-dev` namespace
- **Staging**: `healthcare-staging` namespace  
- **Production**: `healthcare-prod` namespace

### **Deployment Verification**
```bash
# Check all environments
kubectl get pods -n healthcare-dev
kubectl get pods -n healthcare-staging
kubectl get pods -n healthcare-prod

# Get service URLs
kubectl get services -n healthcare-dev
```

---

## ✅ **Verification & Testing**

### **Complete System Test**
```bash
# 1. Verify source code setup
./src-code/validate-setup.sh
./src-code/validate-port-config.sh

# 2. Verify infrastructure
kubectl get nodes
kubectl get pods --all-namespaces

# 3. Verify pipeline
gh run list --limit 1

# 4. Test application endpoints
curl -I http://$(kubectl get service frontend-service -n healthcare-dev -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
```

### **Success Indicators**
- ✅ All validation scripts pass
- ✅ EKS cluster has 3 Ready nodes
- ✅ All namespaces have running pods
- ✅ GitHub Actions pipeline completes successfully
- ✅ Application responds to HTTP requests
- ✅ Frontend-backend communication works

---

## 📜 **Script Reference**

### **Setup Scripts**
- `setup-tools.sh` - Install all required tools
- `setup-environment.sh` - Configure source code environment
- `validate-stage2-setup.sh` - Comprehensive validation

### **Testing Scripts**
- `fix-testing-setup.sh` - Complete testing infrastructure
- `validate-setup.sh` - Environment validation
- `validate-port-config.sh` - Port configuration validation

### **Security Scripts**
- `setup-branch-protection.sh` - GitHub branch protection
- `validate-configs.js` - Configuration validation

### **Deployment Scripts**
- `create-eks-cluster.sh` - EKS infrastructure
- `deploy-healthcare.sh` - Application deployment

---

## ⚡ **Quick Commands**

### **Reset Commands**
```bash
# Reset source code environment
rm -rf src-code/node_modules src-code/frontend/node_modules src-code/backend/node_modules
cd src-code && ./setup-environment.sh

# Reset EKS cluster
eksctl delete cluster --name healthcare-cluster-stage2 --region us-east-1
./scripts/deployment/create-eks-cluster.sh
```

### **Monitoring Commands**
```bash
# Watch pipeline
gh run watch

# Monitor pods
kubectl get pods --all-namespaces -w

# Check logs
kubectl logs -f deployment/frontend-deployment -n healthcare-dev
```

---

## 🎯 **Success Indicators**

### **Environment Setup Complete**
- [ ] All tools installed and verified
- [ ] Source code dependencies installed
- [ ] All validation scripts pass
- [ ] GitHub authentication working

### **Infrastructure Ready**
- [ ] EKS cluster running with 3 nodes
- [ ] All namespaces created
- [ ] Load balancers configured
- [ ] kubectl access working

### **Pipeline Active**
- [ ] GitHub Actions workflow exists
- [ ] Branch protection configured
- [ ] Secrets configured
- [ ] Pipeline runs successfully

### **Application Deployed**
- [ ] All pods running in all environments
- [ ] Services accessible via LoadBalancer
- [ ] Frontend-backend communication working
- [ ] Health checks passing

---

**🎉 Congratulations! You have successfully completed Stage 2 CI/CD Pipeline Setup!**

**Next Steps**: Monitor your pipeline, test deployments, and proceed to Stage 3 for advanced features.

---

**📞 Support**: For issues, check [Troubleshooting Guide](TROUBLESHOOTING.md) or [Operations Guide](OPERATIONS.md)
