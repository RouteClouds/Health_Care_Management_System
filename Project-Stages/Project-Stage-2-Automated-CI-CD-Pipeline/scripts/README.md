# 📜 **Scripts Guide - Automation Tools**

## 📖 **Scripts Index**

### 🛠️ **Setup Scripts**
- [setup-environment.sh](#setup-environment) - Complete environment setup
- [validate-setup.sh](#validate-setup) - Environment validation
- [validate-port-config.sh](#validate-port-config) - Port configuration check
- [setup-tools.sh](#setup-tools) - Install all required tools
- [validate-stage2-setup.sh](#validate-stage2-setup) - Comprehensive validation

### 🧪 **Testing Scripts**
- [fix-testing-setup.sh](#fix-testing-setup) - Testing infrastructure
- [validate-tests.js](#validate-tests) - Test validation

### 🔒 **Security Scripts**
- [setup-branch-protection.sh](#setup-branch-protection) - GitHub security
- [validate-configs.js](#validate-configs) - Configuration validation

### 🚀 **Deployment Scripts**
- [deploy-healthcare.sh](#deploy-healthcare) - Application deployment
- [create-eks-cluster.sh](#create-eks-cluster) - Infrastructure creation

### 📋 **Usage Patterns**
- [Script Execution Order](#execution-order) - Recommended sequence
- [Common Workflows](#common-workflows) - Typical usage scenarios
- [Troubleshooting Scripts](#troubleshooting-scripts) - Problem resolution

---

## 🎯 **Quick Start**

### **For New Users (Complete Setup)**
```bash
# 1. Validate prerequisites
./validate-stage2-setup.sh

# 2. Install tools
./setup-tools.sh

# 3. Create infrastructure
./deployment/create-eks-cluster.sh

# 4. Setup source code
cd ../src-code && ./setup-environment.sh
```

### **For Experienced Users (Individual Scripts)**
```bash
# Testing setup
./fix-testing-setup.sh

# Security configuration
./setup-branch-protection.sh

# Validation
./validate-configs.js
```

---

## 🛠️ **Setup Scripts**

### **setup-environment.sh**
**Location**: `../src-code/setup-environment.sh`
**Purpose**: Complete source code environment setup
**Usage**:
```bash
cd ../src-code
./setup-environment.sh
```
**What it does**:
- ✅ Validates Node.js and npm versions
- ✅ Installs root workspace dependencies
- ✅ Installs frontend dependencies
- ✅ Installs backend dependencies
- ✅ Generates package-lock.json files
- ✅ Tests build processes
- ✅ Runs basic tests

### **validate-setup.sh**
**Location**: `../src-code/validate-setup.sh`
**Purpose**: Environment validation and health check
**Usage**:
```bash
cd ../src-code
./validate-setup.sh
```
**What it checks**:
- ✅ Node.js and npm versions
- ✅ Project structure
- ✅ Package lock files
- ✅ Dependencies installation
- ✅ Build processes

### **validate-port-config.sh**
**Location**: `../src-code/validate-port-config.sh`
**Purpose**: Port configuration validation (prevents frontend-backend communication issues)
**Usage**:
```bash
cd ../src-code
./validate-port-config.sh
```
**What it checks**:
- ✅ Frontend API configuration (/api base URL)
- ✅ Backend port settings (3002)
- ✅ Nginx proxy configuration
- ✅ Kubernetes service ports
- ✅ No hardcoded localhost:3000 references
- ✅ Docker Compose port mappings

### **setup-tools.sh**
**Purpose**: Install all required tools automatically
**Usage**:
```bash
./setup-tools.sh
```
**What it installs**:
- ✅ AWS CLI v2
- ✅ kubectl
- ✅ eksctl
- ✅ GitHub CLI
- ✅ Docker (if not installed)
- ✅ Node.js 20 LTS (if needed)

### **validate-stage2-setup.sh**
**Purpose**: Comprehensive Stage 2 validation
**Usage**:
```bash
./validate-stage2-setup.sh
```
**What it validates**:
- ✅ All tool installations
- ✅ AWS credentials
- ✅ GitHub authentication
- ✅ Docker daemon
- ✅ Source code setup
- ✅ Infrastructure readiness

---

## 🧪 **Testing Scripts**

### **fix-testing-setup.sh**
**Purpose**: Complete testing infrastructure setup
**Usage**:
```bash
./fix-testing-setup.sh
```
**What it configures**:
- ✅ Jest unit testing framework
- ✅ Selenium WebDriver for E2E tests
- ✅ React Testing Library
- ✅ Test environment configuration
- ✅ Browser automation setup

### **validate-tests.js**
**Purpose**: Test validation and verification
**Usage**:
```bash
node validate-tests.js
```
**What it validates**:
- ✅ Test framework configuration
- ✅ Test file structure
- ✅ Mock configurations
- ✅ Test environment variables

---

## 🔒 **Security Scripts**

### **setup-branch-protection.sh**
**Purpose**: GitHub branch protection and security
**Usage**:
```bash
./setup-branch-protection.sh
```
**What it configures**:
- ✅ Branch protection rules
- ✅ Required status checks
- ✅ Pull request requirements
- ✅ Admin enforcement

### **validate-configs.js**
**Purpose**: Configuration validation and security checks
**Usage**:
```bash
node validate-configs.js
```
**What it validates**:
- ✅ Security configurations
- ✅ Environment variables
- ✅ Secrets management
- ✅ Access controls

---

## 🚀 **Deployment Scripts**

### **deploy-healthcare.sh**
**Purpose**: Application deployment to EKS
**Usage**:
```bash
./deployment/deploy-healthcare.sh
```
**What it deploys**:
- ✅ Frontend application
- ✅ Backend services
- ✅ Database configurations
- ✅ Load balancers
- ✅ Ingress controllers

### **create-eks-cluster.sh**
**Purpose**: EKS infrastructure creation
**Usage**:
```bash
./deployment/create-eks-cluster.sh
```
**What it creates**:
- ✅ EKS cluster with 3 worker nodes
- ✅ Development, staging, production namespaces
- ✅ RBAC and service accounts
- ✅ Load balancers and ingress controllers
- ✅ Monitoring and logging setup

---

## 📋 **Usage Patterns**

### **Script Execution Order**

#### **Complete New Setup**
```bash
# 1. Prerequisites validation
./validate-stage2-setup.sh

# 2. Tool installation
./setup-tools.sh

# 3. Source code setup
cd ../src-code && ./setup-environment.sh

# 4. Validation
./validate-setup.sh && ./validate-port-config.sh

# 5. Infrastructure creation
cd ../scripts && ./deployment/create-eks-cluster.sh

# 6. Security setup
./setup-branch-protection.sh

# 7. Testing setup
./fix-testing-setup.sh

# 8. Final validation
./validate-stage2-setup.sh
```

#### **Development Workflow**
```bash
# Daily development validation
cd ../src-code
./validate-setup.sh
./validate-port-config.sh

# Before committing
npm test
npm run build

# After configuration changes
cd ../scripts
./validate-configs.js
```

#### **Deployment Workflow**
```bash
# Pre-deployment validation
./validate-stage2-setup.sh

# Deploy application
./deployment/deploy-healthcare.sh

# Post-deployment verification
kubectl get pods --all-namespaces
kubectl get services --all-namespaces
```

---

### **Common Workflows**

#### **New Student Setup**
```bash
# One-time setup for new students
./validate-stage2-setup.sh    # Check prerequisites
./setup-tools.sh              # Install tools
cd ../src-code && ./setup-environment.sh  # Setup code
cd ../scripts && ./deployment/create-eks-cluster.sh  # Create infrastructure
```

#### **Daily Development**
```bash
# Daily validation routine
cd ../src-code
./validate-setup.sh           # Environment check
./validate-port-config.sh     # Port configuration check
npm run dev                   # Start development
```

#### **CI/CD Pipeline Trigger**
```bash
# Before pushing code
cd ../src-code
./validate-setup.sh && ./validate-port-config.sh
npm test && npm run build
git add . && git commit -m "feat: your changes"
git push origin main
```

---

### **Troubleshooting Scripts**

#### **Environment Issues**
```bash
# Reset and validate environment
cd ../src-code
rm -rf node_modules frontend/node_modules backend/node_modules
./setup-environment.sh
./validate-setup.sh
```

#### **Port Configuration Issues**
```bash
# Diagnose and fix port issues
cd ../src-code
./validate-port-config.sh
# Follow the specific error messages and solutions
```

#### **Infrastructure Issues**
```bash
# Reset infrastructure
eksctl delete cluster --name healthcare-cluster-stage2 --region us-east-1
./deployment/create-eks-cluster.sh
```

#### **Testing Issues**
```bash
# Reset testing setup
./fix-testing-setup.sh
cd ../src-code && npm test
```

---

## 🔍 **Script Dependencies**

### **Prerequisites for All Scripts**
- **Operating System**: Linux/macOS/Windows with WSL2
- **Internet Connection**: Required for downloads
- **User Permissions**: sudo access for tool installation

### **Tool Dependencies**
- **Node.js**: 18.x or 20.x (installed by setup-tools.sh)
- **Git**: Version 2.x+ (usually pre-installed)
- **curl/wget**: For downloads (usually pre-installed)

### **Account Dependencies**
- **GitHub Account**: With repository access
- **AWS Account**: With EKS permissions
- **Docker Hub Account**: For image registry

---

## 📊 **Success Indicators**

### **Setup Complete**
- [ ] All validation scripts pass without errors
- [ ] Tools installed and accessible
- [ ] Source code builds successfully
- [ ] Tests run without failures

### **Infrastructure Ready**
- [ ] EKS cluster running with 3 nodes
- [ ] All namespaces created
- [ ] kubectl access working
- [ ] Load balancers configured

### **Security Configured**
- [ ] Branch protection active
- [ ] GitHub secrets configured
- [ ] Access controls in place
- [ ] Configuration validation passes

---

## 📞 **Support**

### **Script Issues**
1. **Check Prerequisites**: Run `./validate-stage2-setup.sh`
2. **Review Logs**: Scripts provide detailed output
3. **Check Permissions**: Ensure proper access rights
4. **Consult Troubleshooting**: See [Troubleshooting Guide](../docs/TROUBLESHOOTING.md)

### **Common Script Errors**
- **Permission Denied**: Run with proper permissions or sudo
- **Command Not Found**: Install missing tools with `./setup-tools.sh`
- **Network Errors**: Check internet connection
- **Authentication Errors**: Verify GitHub/AWS credentials

---

**🎯 These scripts automate the entire Stage 2 setup process, making it easy for students to get started quickly and reliably.**

**📞 Support**: For script issues, check the [Troubleshooting Guide](../docs/TROUBLESHOOTING.md) or [Master Setup Guide](../docs/MASTER-SETUP-GUIDE.md).
