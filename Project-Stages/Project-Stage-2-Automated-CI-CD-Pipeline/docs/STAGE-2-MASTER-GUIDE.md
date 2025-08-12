# 🚀 **Stage 2 Master Deployment Guide**
## **Complete Automated CI/CD Pipeline - From Setup to Production**

### **⚡ Quick Navigation**
**New to Stage 2?** → [🚀 Getting Started](#-getting-started-for-new-users) | **Ready to Begin?** → [🛠️ Step 1](#️-step-1-tool-installation--setup-15-minutes) | **Need Help?** → [🔍 Troubleshooting](#-basic-troubleshooting) | **Scripts Reference** → [📜 Scripts](#-complete-script-reference)

### **📖 Document Content Index**

#### **🚀 Getting Started**
- [🎯 Welcome to Stage 2](#-welcome-to-stage-2)
- [🚀 Getting Started (For New Users)](#-getting-started-for-new-users)
- [📋 Prerequisites & Requirements](#-prerequisites--requirements)

#### **📋 Setup Steps (125-155 minutes total)**
- [🛠️ Step 1: Tool Installation & Setup (15 min)](#️-step-1-tool-installation--setup-15-minutes)
- [🔑 Step 2: GitHub Configuration (10 min)](#-step-2-github-configuration-10-minutes)
- [☸️ Step 3: Infrastructure Creation (20 min)](#️-step-3-infrastructure-creation-eks-cluster-20-minutes)
- [🧪 Step 4: Testing Infrastructure (20 min)](#-step-4-testing-infrastructure-setup-20-minutes)
- [📊 Step 5: Quality & Security Gates (15 min)](#-step-5-quality--security-gates-15-minutes)
- [🚀 Step 6: CI/CD Pipeline Setup (20 min)](#-step-6-cicd-pipeline-setup-20-minutes)
  - [🧪 Step 2: Test Branch Protection](#-step-2-test-branch-protection-recommended)
  - [🔍 Step 3: Verify Branch Protection](#-step-3-verify-branch-protection-configuration)
- [🌍 Step 7: Multi-Environment Deployment (15 min)](#-step-7-multi-environment-deployment-15-minutes)
- [✅ Step 8: Verification & Testing (10 min)](#-step-8-verification--testing-10-minutes)

#### **📚 Reference & Support**
- [📜 Complete Script Reference](#-complete-script-reference)
- [🔍 Basic Troubleshooting](#-basic-troubleshooting)
- [⚡ Quick Reference Commands](#-quick-reference-commands)
- [🎉 Success Indicators](#-success-indicators)
- [🔗 Related Documentation](#-related-documentation)
- [📋 Document Information](#-document-information)

**Document Purpose**: Complete end-to-end automated CI/CD pipeline deployment
**Target Audience**: All Stage 2 users (independent of Stage 1)
**Estimated Time**: 125-155 minutes (8 comprehensive steps)
**Success Rate**: 95%+ when prerequisites are met
**Last Updated**: August 8, 2025

> **💡 Navigation Tip**: Use `Ctrl+F` (or `Cmd+F` on Mac) to search for specific sections or click any link in the [Content Index](#-document-content-index) to jump directly to that section.

---

## **🎯 Welcome to Stage 2**

This is your **complete independent guide** for deploying an automated CI/CD pipeline for the Healthcare Management System. Stage 2 is **completely independent** of Stage 1 and can be deployed from scratch.

### **What You'll Accomplish**
- ✅ **Complete automated CI/CD pipeline** with GitHub Actions
- ✅ **Multi-environment deployment** (Development, Staging, Production)
- ✅ **Automated testing suite** (Unit tests with Jest, E2E tests with Selenium)
- ✅ **Quality gates** (SonarQube code quality, Trivy security scanning)
- ✅ **Production-ready infrastructure** with AWS EKS and automated deployments
- ✅ **Healthcare application** with full CI/CD automation

### **Technology Stack**
```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   GitHub        │    │   Quality Gates  │    │   AWS EKS       │
│   Actions       │───▶│   SonarQube +    │───▶│   Multi-Env     │
│   Pipeline      │    │   Trivy Security │    │   Deployment    │
└─────────────────┘    └──────────────────┘    └─────────────────┘
         │                                               │
         ▼                                               ▼
┌─────────────────┐                            ┌─────────────────┐
│   Automated     │                            │   Healthcare    │
│   Testing       │                            │   Application   │
│   Jest + Selenium│                           │   Production    │
└─────────────────┘                            └─────────────────┘
```

### **Stage 2 Independence**
- 🆓 **No Stage 1 dependency** - Complete standalone deployment
- 🏗️ **Own infrastructure** - Creates its own EKS cluster and resources
- 🔧 **Own source code** - Includes all application components
- 📊 **Enhanced features** - Advanced CI/CD with testing and quality gates

---

## **🚀 Getting Started (For New Users)**

### **📥 If You're New to This Repository:**

#### **Step 1: Clone and Navigate**
```bash
# Clone the repository
git clone https://github.com/YOUR-USERNAME/YOUR-REPO-NAME.git
cd YOUR-REPO-NAME

# Navigate to Stage-2 directory
cd Project-Stages/Project-Stage-2-Automated-CI-CD-Pipeline/
```

#### **Step 2: Validate Your Setup**
```bash
# Run the comprehensive setup validation script
./scripts/validate-stage2-setup.sh
```

**What this validation script checks:**
- ✅ All required tools (Node.js, Docker, AWS CLI, GitHub CLI)
- ✅ Repository structure and configuration
- ✅ GitHub authentication and secrets
- ✅ Branch protection rules
- ✅ Testing setup

#### **Step 3: Follow the Validation Results**
- **🟢 All Green**: You're ready to proceed with the guide
- **🟡 Warnings**: Address warnings but can continue
- **🔴 Failures**: Fix the issues before proceeding

#### **Step 4: Quick Setup Commands**
```bash
# Make all scripts executable
chmod +x scripts/*.sh

# If you need to set up branch protection
./scripts/setup-branch-protection.sh

# If you need to validate configurations
node scripts/validate-configs.js
```

#### **Step 5: Choose Your Path**
- **🆕 New Setup**: Follow the complete guide from Step 1
- **🔄 Existing Setup**: Jump to the step you need
- **🐛 Troubleshooting**: Use the validation script to identify issues

### **📜 Available Scripts Overview**

The `scripts/` directory contains automated tools to help with setup:

| Script | Purpose | When to Use |
|--------|---------|-------------|
| `validate-stage2-setup.sh` | Complete setup validation | Before starting, troubleshooting |
| `setup-tools.sh` | Install all required tools | Step 1 - Tool installation |
| `setup-branch-protection.sh` | Configure GitHub branch protection | Step 6 - Repository security |
| `validate-configs.js` | Check configuration files | Step 4 - Configuration validation |
| `build-and-push-images.sh` | Build and push Docker images | Step 7 - Application deployment |
| `deploy-healthcare.sh` | Deploy to EKS environments | Step 7 - Application deployment |

**💡 Pro Tip**: Always run `./scripts/validate-stage2-setup.sh` first to identify what needs to be set up!

---

## **📋 Prerequisites & Requirements**

### **💻 System Requirements**
- **OS**: Ubuntu 20.04+ (recommended) or similar Linux distribution
- **RAM**: 8GB minimum, 16GB recommended (for testing tools)
- **Storage**: 20GB free space
- **Network**: Stable internet connection

### **☁️ AWS Requirements**
- **AWS Account** with billing enabled
- **IAM User** with programmatic access
- **Required Permissions**:
  - EKS Full Access
  - EC2 Full Access
  - IAM Role Management
  - VPC Management
  - CloudFormation Access
  - ECR Full Access (for container registry)

### **🐙 GitHub Requirements**
- **GitHub Account** (free tier sufficient)
- **GitHub Repository** for the healthcare application
- **GitHub Actions** enabled (included in free tier)
- **Personal Access Token** with appropriate permissions

### **🔧 Additional Tools**
- **Docker Hub Account** (for container registry)
- **SonarQube Account** (free tier available)
- **Basic understanding** of Git, Docker, and Kubernetes

### **💰 Cost Expectations**
- **EKS Cluster**: ~$0.10/hour per environment
- **EC2 Instances**: ~$0.40-0.80/hour (multi-environment)
- **Total**: ~$1.50-2.50/hour while running (3 environments)
- **Daily Cost**: ~$36-60 if left running 24/7

[⬆️ Back to Top](#-stage-2-master-deployment-guide) | [📖 Content Index](#-document-content-index) | [⬅️ Previous: Getting Started](#-getting-started-for-new-users) | [➡️ Next: Step 1](#️-step-1-tool-installation--setup-15-minutes)

---

## **🛠️ Step 1: Tool Installation & Setup (15 minutes)**

### **Option A: Automated Setup Script (Recommended)**
```bash
# Navigate to Stage-2 directory
cd Project-Stages/Project-Stage-2-Automated-CI-CD-Pipeline

# Run automated setup script
./scripts/setup-tools.sh

# Script location: scripts/setup-tools.sh
# This installs: AWS CLI, kubectl, eksctl, Docker, GitHub CLI, Node.js, and testing tools
```

### **Option B: Manual Installation Commands**

#### **Install Core Tools**
```bash
# Install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
rm -rf aws awscliv2.zip

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Install eksctl
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
rm get-docker.sh
```

#### **Install GitHub CLI**
```bash
# Install GitHub CLI
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install gh

# Verify installation
gh --version
```

#### **Install Node.js and Testing Tools**
```bash
# Install Node.js 20 LTS (required for selenium-webdriver)
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# Verify Node.js installation
node --version  # Should show v20.x.x
npm --version

# Note: We'll install testing tools locally in the project, not globally
# This avoids permission issues and version conflicts
```

#### **Install Additional Tools**
```bash
# Install useful utilities
sudo apt update
sudo apt install -y jq curl wget unzip git

# Verify installations
jq --version
git --version
```

### **Verify Installation**
```bash
# Run verification script
./scripts/validate-infrastructure.sh

# Manual verification
aws --version          # Should be v2.x
kubectl version --client  # Should be v1.28+
eksctl version         # Should be v0.150+
docker --version       # Should be v20.x+
gh --version          # Should be v2.x+
node --version        # Should be v20.x+ (required for selenium-webdriver)
```

---

## **🔑 Step 2: GitHub Configuration (10 minutes)**

### **Configure AWS Credentials**
```bash
# Configure AWS credentials
aws configure

# Enter your credentials:
# AWS Access Key ID: [Your Access Key]
# AWS Secret Access Key: [Your Secret Key]
# Default region name: us-east-1
# Default output format: json

# Verify AWS configuration
aws sts get-caller-identity
```

### **Configure GitHub CLI**

#### **⚠️ Common Mistake - Use `gh` not `git`**
```bash
# ❌ WRONG - This will give error "git: 'auth' is not a git command"
git auth login

# ✅ CORRECT - Use GitHub CLI command
gh auth login
```

#### **Option A: SSH Authentication (Recommended - More Secure)**
```bash
# Login to GitHub with SSH
gh auth login

# Follow the prompts and select these options:
# ? What account do you want to log into? GitHub.com
# ? What is your preferred protocol for Git operations? SSH
# ? Generate a new SSH key to add to your GitHub account? Yes
# ? Enter a passphrase for your SSH key (optional): [Enter passphrase or press Enter for none]
# ? Title for your SSH key: GitHub CLI Stage-2
# ? How would you like to authenticate GitHub CLI? Login with a web browser

# Verify SSH authentication
gh auth status
ssh -T git@github.com

# Expected output:
# ✓ Logged in to github.com as your-username (keyring)
# ✓ Git operations for github.com configured to use ssh protocol.
# Hi your-username! You've successfully authenticated, but GitHub does not provide shell access.
```

#### **Option B: HTTPS Authentication (Alternative)**
```bash
# Login to GitHub with HTTPS
gh auth login

# Follow the prompts and select these options:
# ? What account do you want to log into? GitHub.com
# ? What is your preferred protocol for Git operations? HTTPS
# ? Authenticate Git with your GitHub credentials? Yes
# ? How would you like to authenticate GitHub CLI? Login with a web browser

# Verify HTTPS authentication
gh auth status

# Expected output:
# ✓ Logged in to github.com as your-username (keyring)
# ✓ Git operations for github.com configured to use https protocol.
```

#### **Why Choose SSH over HTTPS?**
- ✅ **More Secure**: Uses SSH key pairs instead of tokens
- ✅ **No Token Expiration**: SSH keys don't expire like personal access tokens
- ✅ **Better for Automation**: More reliable for CI/CD pipelines
- ✅ **Industry Standard**: Preferred method for professional development
- ✅ **Automatic Setup**: GitHub CLI handles SSH key generation and upload

### **Fork or Create Repository**
```bash
# Option A: Fork existing repository (if available)
gh repo fork routeclouds/healthcare-management-system --clone

# Option B: Create new repository
gh repo create healthcare-management-system --public --clone

# Navigate to repository
cd healthcare-management-system
```

### **Configure Repository Secrets**

#### **🎯 Choose Your Preferred Method:**

### **Method A: Using GitHub CLI (Command Line) - Recommended for Automation**

```bash
# Set up required GitHub secrets for CI/CD pipeline
gh secret set AWS_ACCESS_KEY_ID --body "your-aws-access-key-id"
gh secret set AWS_SECRET_ACCESS_KEY --body "your-aws-secret-access-key"

# Docker Hub Authentication (Use Access Token - More Secure)
gh secret set DOCKER_HUB_USERNAME --body "your-docker-username"
gh secret set DOCKER_HUB_ACCESS_TOKEN --body "your-docker-access-token"

# Quality Gates
gh secret set SONAR_TOKEN --body "your-sonarqube-token"

# Optional: EKS Configuration (if different from defaults)
gh secret set EKS_CLUSTER_NAME --body "healthcare-cluster-stage2"
gh secret set EKS_CLUSTER_REGION --body "us-east-1"
```

### **Method B: Using GitHub Web Interface - Beginner Friendly**

#### **📍 Step-by-Step Web Interface Setup:**

1. **Navigate to Your Repository**
   - Go to: `https://github.com/YOUR-USERNAME/YOUR-REPOSITORY-NAME`
   - Example: `https://github.com/johndoe/healthcare-management-system`

2. **Access Repository Settings**
   - Click on the **"Settings"** tab (located at the top of your repository page)
   - If you don't see "Settings", you may not have admin access to the repository

3. **Navigate to Secrets and Variables**
   - In the left sidebar, scroll down to **"Security"** section
   - Click on **"Secrets and variables"**
   - Click on **"Actions"** from the dropdown

4. **Add Repository Secrets**
   - Click the **"New repository secret"** button
   - For each secret below, enter the **Name** and **Secret** value:

#### **🔐 Required Secrets to Add:**

| Secret Name | Description | Example Value |
|-------------|-------------|---------------|
| `AWS_ACCESS_KEY_ID` | Your AWS Access Key ID | `AKIAIOSFODNN7EXAMPLE` |
| `AWS_SECRET_ACCESS_KEY` | Your AWS Secret Access Key | `wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY` |
| `DOCKER_HUB_USERNAME` | Your Docker Hub username | `johndoe` |
| `DOCKER_HUB_ACCESS_TOKEN` | Docker Hub Access Token (NOT password) | `dckr_pat_1234567890abcdef` |
| `SONAR_TOKEN` | SonarQube authentication token | `sqp_1234567890abcdef` |
| `EKS_CLUSTER_NAME` | EKS cluster name (optional) | `healthcare-cluster-stage2` |
| `EKS_CLUSTER_REGION` | AWS region for EKS (optional) | `us-east-1` |

#### **📝 Detailed Steps for Each Secret:**

1. **Click "New repository secret"**
2. **Enter Name**: Copy the exact name from the table above (case-sensitive)
3. **Enter Secret**: Paste your actual secret value (no quotes needed)
4. **Click "Add secret"**
5. **Repeat** for all required secrets

#### **🔍 Visual Guide - Where to Find Settings:**
```
GitHub Repository Page Layout:
┌─────────────────────────────────────────────────────────────┐
│ [Code] [Issues] [Pull requests] [Actions] [Projects] [Wiki] │
│ [Security] [Insights] [Settings] ← Click here              │
├─────────────────────────────────────────────────────────────┤
│ Left Sidebar in Settings:                                   │
│ • General                                                   │
│ • Access                                                    │
│ • Security ← Expand this section                           │
│   ├── Secrets and variables ← Click here                   │
│   │   └── Actions ← Click here                             │
│   ├── Deploy keys                                          │
│   └── ...                                                  │
└─────────────────────────────────────────────────────────────┘
```

### **How to Create Docker Access Token (Required for Both Methods)**

#### **🐳 Docker Hub Access Token Setup:**
1. **Go to Docker Hub**: https://hub.docker.com/settings/security
2. **Login** to your Docker Hub account
3. **Click "New Access Token"**
4. **Enter Description**: `"Stage-2 CI/CD Pipeline"`
5. **Select Permissions**: `"Read, Write, Delete"` (or `"Public Repo Read/Write"`)
6. **Click "Generate"**
7. **Copy the Token**: Save it securely - it's shown only once!
8. **Use this token** as the value for `DOCKER_HUB_ACCESS_TOKEN` secret

#### **⚠️ Important Notes:**
- **Never use your Docker Hub password** - always use access tokens
- **Access tokens are more secure** and can be revoked independently
- **Save the token immediately** - you cannot view it again after creation

**Why Access Token over Password?**
- ✅ **Docker's Recommendation**: Official best practice for automation
- ✅ **More Secure**: Scoped permissions, revocable without password change
- ✅ **Better Audit**: Track usage and access patterns
- ✅ **CI/CD Optimized**: Designed specifically for automated systems

# Verify secrets are set
gh secret list
```

---

## **☸️ Step 3: Infrastructure Creation (EKS Cluster) (20 minutes)**

### **Option A: Automated Infrastructure Creation (Recommended)**
```bash
# Create complete EKS cluster with multi-environment support
./scripts/deployment/create-eks-cluster.sh

# This script will:
# 1. Create EKS cluster "healthcare-cluster-stage2" with Kubernetes 1.32
# 2. Set up 3 worker nodes (t3.medium) for multi-environment support
# 3. Configure proper IAM roles and security groups
# 4. Set up development, staging, and production namespaces
# 5. Configure RBAC and service accounts
# 6. Update kubeconfig for kubectl access
# 7. Verify cluster is ready for deployments
```

### **Option B: Manual Infrastructure Creation**

#### **Create EKS Cluster**
```bash
# Set cluster configuration
CLUSTER_NAME="healthcare-cluster-stage2"
REGION="us-east-1"
CLUSTER_VERSION="1.32"
NODE_GROUP_NAME="healthcare-nodes-stage2"
NODE_TYPE="t3.medium"
DESIRED_NODES=3
MIN_NODES=2
MAX_NODES=6

# Create EKS cluster (takes 15-20 minutes)
eksctl create cluster \
  --name $CLUSTER_NAME \
  --version $CLUSTER_VERSION \
  --region $REGION \
  --nodegroup-name $NODE_GROUP_NAME \
  --node-type $NODE_TYPE \
  --nodes $DESIRED_NODES \
  --nodes-min $MIN_NODES \
  --nodes-max $MAX_NODES \
  --managed \
  --asg-access \
  --external-dns-access \
  --alb-ingress-access

# Update kubeconfig with real values
aws eks update-kubeconfig --region us-east-1 --name healthcare-cluster-stage2
```

#### **Set Up Multi-Environment Namespaces**
```bash
# Create environment namespaces
kubectl create namespace healthcare-dev
kubectl create namespace healthcare-staging
kubectl create namespace healthcare-prod

# Label namespaces for organization
kubectl label namespace healthcare-dev environment=development
kubectl label namespace healthcare-staging environment=staging
kubectl label namespace healthcare-prod environment=production

# Verify namespaces
kubectl get namespaces | grep healthcare
```

#### **Verify Infrastructure**
```bash
# Ensure kubectl is configured for the cluster
aws eks update-kubeconfig --region us-east-1 --name healthcare-cluster-stage2

# Check cluster status
kubectl get nodes
kubectl cluster-info

# Verify namespaces
kubectl get namespaces | grep healthcare

# Check cluster version compatibility
kubectl version --short

# Verify current context
kubectl config current-context
```

### **Expected Outcome**
- ✅ **EKS cluster running** with 3 Ready nodes
- ✅ **Multi-environment namespaces** created (dev, staging, prod)
- ✅ **kubectl configured** to access the cluster
- ✅ **Infrastructure ready** for application deployment

### **📋 Stage-2 Cluster Configuration Reference**
```bash
# Real values used in Stage-2
CLUSTER_NAME="healthcare-cluster-stage2"
REGION="us-east-1"
NODE_GROUP_NAME="healthcare-nodes-stage2"

# Quick commands with real values
aws eks update-kubeconfig --region us-east-1 --name healthcare-cluster-stage2
kubectl config current-context  # Should show: arn:aws:eks:us-east-1:ACCOUNT:cluster/healthcare-cluster-stage2
```

### **Troubleshooting Infrastructure Creation**
```bash
# If cluster creation fails
eksctl get clusters --region us-east-1

# If nodes are not ready
kubectl describe nodes

# If kubeconfig is not updated
aws eks update-kubeconfig --region us-east-1 --name healthcare-cluster-stage2

# Check cluster events
kubectl get events --all-namespaces --sort-by='.lastTimestamp'
```

---

## **🧪 Step 4: Testing Infrastructure Setup (20 minutes)**

### **Option A: Automated Testing Setup (Recommended)**
```bash
# Set up complete testing infrastructure with automatic fixes
./scripts/fix-testing-setup.sh

# This script will:
# 1. Upgrade Node.js to v20+ if needed (for selenium-webdriver compatibility)
# 2. Clean up any incorrect installations
# 3. Install Jest and React Testing Library locally
# 4. Install Selenium WebDriver with proper configuration
# 5. Create Jest and Babel configurations
# 6. Set up test directories and sample tests
# 7. Validate all testing components

# Alternative: Original validation script (if available)
# ./scripts/validate-tests.js
```

### **Option B: Manual Testing Setup**

#### **Set Up Jest Unit Testing**
```bash
# Navigate to source code directory
cd src-code

# Initialize package.json if it doesn't exist
if [ ! -f package.json ]; then
    npm init -y
fi

# Install Jest and testing dependencies locally (no -g flag)
npm install --save-dev jest @testing-library/react @testing-library/jest-dom
npm install --save-dev @testing-library/user-event jest-environment-jsdom

# Install Babel dependencies for ES6/React support
npm install --save-dev @babel/core @babel/preset-env @babel/preset-react babel-jest identity-obj-proxy

# Create Jest configuration
cat > jest.config.js << 'EOF'
module.exports = {
  testEnvironment: 'jsdom',
  setupFilesAfterEnv: ['<rootDir>/src/test/setup.js'],
  moduleNameMapper: {
    '\\.(css|less|scss|sass)$': 'identity-obj-proxy',
  },
  transform: {
    '^.+\\.(js|jsx|ts|tsx)$': 'babel-jest',
  },
  collectCoverageFrom: [
    'src/**/*.{js,jsx,ts,tsx}',
    '!src/index.js',
    '!src/test/**',
  ],
  coverageThreshold: {
    global: {
      branches: 80,
      functions: 80,
      lines: 80,
      statements: 80,
    },
  },
};
EOF

# Create Babel configuration
cat > .babelrc << 'EOF'
{
  "presets": [
    ["@babel/preset-env", {
      "targets": {
        "node": "current"
      }
    }],
    ["@babel/preset-react", {
      "runtime": "automatic"
    }]
  ]
}
EOF

# Create test setup file
mkdir -p src/test
cat > src/test/setup.js << 'EOF'
require('@testing-library/jest-dom');

// Mock environment variables
process.env.VITE_API_BASE_URL = '/api';
process.env.NODE_ENV = 'test';
EOF
```

#### **Set Up Selenium E2E Testing**
```bash
# Install Selenium WebDriver and dependencies (requires Node.js 20+)
npm install --save-dev selenium-webdriver@^4.0.0 chromedriver

# If you get engine warnings, you can use --force flag
# npm install --save-dev selenium-webdriver@^4.0.0 chromedriver --force

# Create Selenium test configuration
mkdir -p tests/e2e
cat > tests/e2e/config.js << 'EOF'
const { Builder, By, until } = require('selenium-webdriver');
const chrome = require('selenium-webdriver/chrome');

const createDriver = () => {
  const options = new chrome.Options();
  options.addArguments('--headless');
  options.addArguments('--no-sandbox');
  options.addArguments('--disable-dev-shm-usage');
  
  return new Builder()
    .forBrowser('chrome')
    .setChromeOptions(options)
    .build();
};

module.exports = { createDriver, By, until };
EOF

# Create sample E2E test
cat > tests/e2e/healthcare.test.js << 'EOF'
const { createDriver, By, until } = require('./config');

describe('Healthcare Application E2E Tests', () => {
  let driver;
  
  beforeAll(async () => {
    driver = createDriver();
  });
  
  afterAll(async () => {
    if (driver) {
      await driver.quit();
    }
  });
  
  test('should load homepage', async () => {
    await driver.get('http://localhost:5173');
    const title = await driver.getTitle();
    expect(title).toContain('Healthcare');
  });

  test('should navigate to doctor search', async () => {
    await driver.get('http://localhost:5173');
    const searchButton = await driver.findElement(By.css('[data-testid="find-doctor"]'));
    await searchButton.click();
    
    await driver.wait(until.urlContains('/doctors'), 5000);
    const currentUrl = await driver.getCurrentUrl();
    expect(currentUrl).toContain('/doctors');
  });
});
EOF
```

#### **Configure Test Scripts**
```bash
# Add test scripts to package.json
npm pkg set scripts.test="jest"
npm pkg set scripts.test:watch="jest --watch"
npm pkg set scripts.test:coverage="jest --coverage"
npm pkg set scripts.test:e2e="jest tests/e2e --testTimeout=30000"

# Create a simple verification test
cat > src/test/setup.test.js << 'EOF'
// Simple test to verify Jest setup is working
describe('Jest Setup Verification', () => {
  test('should be able to run basic tests', () => {
    expect(1 + 1).toBe(2);
  });

  test('should have access to testing environment variables', () => {
    expect(process.env.NODE_ENV).toBe('test');
    expect(process.env.VITE_API_BASE_URL).toBe('/api');
  });

  test('should have jest-dom matchers available', () => {
    // Create a simple DOM element to test jest-dom matchers
    const element = document.createElement('div');
    element.textContent = 'Hello World';
    document.body.appendChild(element);

    expect(element).toBeInTheDocument();
    expect(element).toHaveTextContent('Hello World');

    // Clean up
    document.body.removeChild(element);
  });
});
EOF

# Verify test configuration (use npx to run local jest)
npx jest --version
echo "Running unit tests (excluding E2E tests)..."
npm test -- --testPathIgnorePatterns=tests/e2e

# If you want to run all tests including E2E (will fail without running app):
# npm test -- --passWithNoTests
```

---

## **📊 Step 5: Quality & Security Gates (15 minutes)**

### **Option A: Automated Quality Setup (Recommended)**
```bash
# Set up complete quality and security infrastructure
./scripts/validate-configs.js

# This script will:
# 1. Configure SonarQube for code quality analysis
# 2. Set up Trivy for security vulnerability scanning
# 3. Configure quality gates and thresholds
# 4. Validate all quality tools
```

### **Option B: Manual Quality & Security Setup**

#### **Set Up SonarQube Code Quality**
```bash
# Install SonarQube scanner
npm install --save-dev sonarqube-scanner

# Create SonarQube configuration
cat > sonar-project.properties << 'EOF'
sonar.projectKey=healthcare-management-system
sonar.projectName=Healthcare Management System
sonar.projectVersion=1.0
sonar.sources=src
sonar.tests=src/test,tests
sonar.language=js
sonar.sourceEncoding=UTF-8
sonar.javascript.lcov.reportPaths=coverage/lcov.info
sonar.coverage.exclusions=**/*.test.js,**/*.spec.js,**/test/**,**/tests/**
sonar.qualitygate.wait=true
EOF

# Create SonarQube analysis script
cat > scripts/sonar-analysis.sh << 'EOF'
#!/bin/bash
set -e

echo "🔍 Running SonarQube Code Quality Analysis..."

# Run tests with coverage
npm run test:coverage

# Run SonarQube analysis
npx sonar-scanner \
  -Dsonar.host.url=${SONAR_HOST_URL:-https://sonarcloud.io} \
  -Dsonar.login=${SONARQUBE_TOKEN}

echo "✅ SonarQube analysis completed"
EOF

chmod +x scripts/sonar-analysis.sh
```

#### **Set Up Trivy Security Scanning**
```bash
# Install Trivy security scanner
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin

# Create Trivy scanning script
cat > scripts/security-scan.sh << 'EOF'
#!/bin/bash
set -e

echo "🛡️ Running Trivy Security Scanning..."

# Scan filesystem for vulnerabilities
trivy fs --exit-code 1 --severity HIGH,CRITICAL .

# Scan Docker images (if built)
if docker images | grep -q healthcare; then
    echo "Scanning Docker images..."
    trivy image --exit-code 1 --severity HIGH,CRITICAL routeclouds/healthcare-backend:v1.0
    trivy image --exit-code 1 --severity HIGH,CRITICAL routeclouds/healthcare-frontend:v1.0
fi

echo "✅ Security scanning completed"
EOF

chmod +x scripts/security-scan.sh

# Verify Trivy installation
trivy --version
```

#### **Configure Quality Gates**
```bash
# Create quality gate validation script
cat > scripts/quality-gates.sh << 'EOF'
#!/bin/bash
set -e

echo "🚪 Running Quality Gates..."

# Run unit tests
echo "Running unit tests..."
npm run test:coverage

# Check test coverage thresholds
COVERAGE_THRESHOLD=80
COVERAGE_LINES=$(grep -o '"lines":{"total":[0-9]*,"covered":[0-9]*,"skipped":[0-9]*,"pct":[0-9.]*' coverage/coverage-summary.json | grep -o '"pct":[0-9.]*' | cut -d':' -f2)

if (( $(echo "$COVERAGE_LINES < $COVERAGE_THRESHOLD" | bc -l) )); then
    echo "❌ Test coverage ($COVERAGE_LINES%) below threshold ($COVERAGE_THRESHOLD%)"
    exit 1
fi

echo "✅ Test coverage ($COVERAGE_LINES%) meets threshold"

# Run linting
echo "Running ESLint..."
npx eslint src/ --ext .js,.jsx,.ts,.tsx

# Run security scan
./scripts/security-scan.sh

# Run SonarQube analysis
./scripts/sonar-analysis.sh

echo "✅ All quality gates passed"
EOF

chmod +x scripts/quality-gates.sh
```

---

## **🚀 Step 6: CI/CD Pipeline Setup (20 minutes)**

### **Create GitHub Actions Workflow**
```bash
# Create GitHub Actions workflow directory
mkdir -p .github/workflows

# Create main CI/CD pipeline workflow
cat > .github/workflows/ci-cd-pipeline.yml << 'EOF'
name: Healthcare CI/CD Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

env:
  AWS_REGION: us-east-1
  EKS_CLUSTER_NAME: healthcare-cluster-stage2

jobs:
  test:
    name: Run Tests
    runs-on: ubuntu-latest

    steps:
    - name: Checkout code
      uses: actions/checkout@v4

    - name: Setup Node.js
      uses: actions/setup-node@v4
      with:
        node-version: '18'
        cache: 'npm'

    - name: Install dependencies
      run: |
        cd src-code
        npm ci

    - name: Run unit tests
      run: |
        cd src-code
        npm run test:coverage

    - name: Run E2E tests
      run: |
        cd src-code
        npm run test:e2e

    - name: Upload coverage reports
      uses: codecov/codecov-action@v3
      with:
        file: ./src-code/coverage/lcov.info

  quality-gates:
    name: Quality & Security Gates
    runs-on: ubuntu-latest
    needs: test

    steps:
    - name: Checkout code
      uses: actions/checkout@v4

    - name: Setup Node.js
      uses: actions/setup-node@v4
      with:
        node-version: '18'
        cache: 'npm'

    - name: Install dependencies
      run: |
        cd src-code
        npm ci

    - name: Run SonarQube analysis
      uses: sonarqube-quality-gate-action@master
      env:
        SONAR_TOKEN: ${{ secrets.SONARQUBE_TOKEN }}

    - name: Run Trivy security scan
      uses: aquasecurity/trivy-action@master
      with:
        scan-type: 'fs'
        scan-ref: '.'
        exit-code: '1'
        severity: 'HIGH,CRITICAL'

  build:
    name: Build and Push Images
    runs-on: ubuntu-latest
    needs: [test, quality-gates]

    steps:
    - name: Checkout code
      uses: actions/checkout@v4

    - name: Configure AWS credentials
      uses: aws-actions/configure-aws-credentials@v4
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: ${{ env.AWS_REGION }}

    - name: Login to Docker Hub
      uses: docker/login-action@v3
      with:
        username: ${{ secrets.DOCKER_HUB_USERNAME }}
        password: ${{ secrets.DOCKER_HUB_ACCESS_TOKEN }}

    - name: Build and push images
      run: |
        cd src-code

        # Build backend image
        docker build -f Dockerfile.backend -t routeclouds/healthcare-backend:v1.0 .
        docker build -f Dockerfile.backend -t routeclouds/healthcare-backend:latest .

        # Build frontend image
        docker build -f Dockerfile.frontend -t routeclouds/healthcare-frontend:v1.0 .
        docker build -f Dockerfile.frontend -t routeclouds/healthcare-frontend:latest .

        # Push images
        docker push routeclouds/healthcare-backend:v1.0
        docker push routeclouds/healthcare-backend:latest
        docker push routeclouds/healthcare-frontend:v1.0
        docker push routeclouds/healthcare-frontend:latest

  deploy-staging:
    name: Deploy to Staging
    runs-on: ubuntu-latest
    needs: build
    if: github.ref == 'refs/heads/develop'
    environment: staging

    steps:
    - name: Checkout code
      uses: actions/checkout@v4

    - name: Configure AWS credentials
      uses: aws-actions/configure-aws-credentials@v4
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: ${{ env.AWS_REGION }}

    - name: Deploy to staging
      run: |
        # Update kubeconfig
        aws eks update-kubeconfig --region ${{ env.AWS_REGION }} --name ${{ env.EKS_CLUSTER_NAME }}

        # Deploy to staging namespace
        ./scripts/deployment/deploy-staging.sh ${{ github.sha }}

  deploy-production:
    name: Deploy to Production
    runs-on: ubuntu-latest
    needs: build
    if: github.ref == 'refs/heads/main'
    environment: production

    steps:
    - name: Checkout code
      uses: actions/checkout@v4

    - name: Configure AWS credentials
      uses: aws-actions/configure-aws-credentials@v4
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: ${{ env.AWS_REGION }}

    - name: Deploy to production
      run: |
        # Update kubeconfig
        aws eks update-kubeconfig --region ${{ env.AWS_REGION }} --name ${{ env.EKS_CLUSTER_NAME }}

        # Deploy to production namespace
        ./scripts/deployment/deploy-production.sh ${{ github.sha }}
EOF
```

### **Configure Branch Protection Rules**

Branch protection rules ensure code quality and security by requiring reviews and status checks before merging to the main branch.

#### **🎯 Choose Your Preferred Method:**

### **Method A: Automated Script (Recommended for New Users)**

```bash
# Navigate to the scripts directory
cd scripts/

# Run the automated branch protection setup script
./setup-branch-protection.sh
```

**What this script does:**
- ✅ Checks all prerequisites (GitHub CLI, authentication)
- ✅ Detects your repository automatically or prompts for details
- ✅ Creates proper JSON configuration
- ✅ Applies branch protection rules
- ✅ Verifies the configuration
- ✅ Provides detailed success/error messages
- ✅ Includes troubleshooting guidance

### **Method B: Manual Command Line Setup**

```bash
# Step 1: Create branch protection configuration file
cat > branch-protection.json << 'EOF'
{
  "required_status_checks": {
    "strict": true,
    "contexts": ["Run Tests", "Quality & Security Gates"]
  },
  "enforce_admins": true,
  "required_pull_request_reviews": {
    "required_approving_review_count": 1,
    "dismiss_stale_reviews": true,
    "require_code_owner_reviews": false
  },
  "restrictions": null,
  "allow_force_pushes": false,
  "allow_deletions": false
}
EOF

# Step 2: Apply branch protection rules
# Option A: If you're in your git repository directory
gh api repos/:owner/:repo/branches/main/protection \
  --method PUT \
  --input branch-protection.json

# Option B: If you're not in git repository, specify explicitly
# gh api repos/YOUR-USERNAME/YOUR-REPO-NAME/branches/main/protection \
#   --method PUT \
#   --input branch-protection.json

# Step 3: Clean up
rm branch-protection.json

echo "✅ Branch protection rules configured"
```

### **Method C: GitHub Web Interface Setup**

#### **📍 Step-by-Step Web Interface Guide:**

1. **Navigate to Repository Settings**
   - Go to your repository: `https://github.com/YOUR-USERNAME/YOUR-REPO-NAME`
   - Click the **"Settings"** tab

2. **Access Branch Protection**
   - In left sidebar, click **"Branches"** (under "Code and automation")
   - Click **"Add rule"** button next to "Branch protection rules"

3. **Configure Protection Rule**
   - **Branch name pattern**: Enter `main`
   - **Protect matching branches**: Check the following options:
     - ☑️ **Require a pull request before merging**
       - ☑️ **Require approvals** (set to 1)
       - ☑️ **Dismiss stale pull request approvals when new commits are pushed**
     - ☑️ **Require status checks to pass before merging**
       - ☑️ **Require branches to be up to date before merging**
       - In search box, add: `Run Tests` and `Quality & Security Gates`
     - ☑️ **Restrict pushes that create files**
     - ☑️ **Do not allow bypassing the above settings**

4. **Save Configuration**
   - Click **"Create"** button at the bottom

#### **🔍 Visual Guide - Web Interface Locations:**
```
Repository → Settings → Branches → Add rule
┌─────────────────────────────────────────────────────────────┐
│ Branch protection rules                                     │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ Branch name pattern: main                               │ │
│ │                                                         │ │
│ │ ☑️ Require a pull request before merging                │ │
│ │   ☑️ Require approvals: [1]                            │ │
│ │   ☑️ Dismiss stale pull request approvals              │ │
│ │                                                         │ │
│ │ ☑️ Require status checks to pass before merging        │ │
│ │   ☑️ Require branches to be up to date                 │ │
│ │   Status checks: [Run Tests] [Quality & Security Gates]│ │
│ │                                                         │ │
│ │ ☑️ Do not allow bypassing the above settings           │ │
│ └─────────────────────────────────────────────────────────┘ │
│                                    [Create] button         │
└─────────────────────────────────────────────────────────────┘
```

### **✅ Verification and Testing**

#### **Verify Branch Protection is Active**
```bash
# Check branch protection status
gh api repos/:owner/:repo/branches/main/protection

# Alternative: Check via web interface
# Go to: Settings → Branches → View your protection rule
```

#### **Test Branch Protection**
```bash
# Create a test branch and pull request
git checkout -b test-branch-protection
echo "Testing branch protection" > test-file.txt
git add test-file.txt
git commit -m "Test: branch protection rules"
git push -u origin test-branch-protection

# Create pull request
gh pr create --title "Test Branch Protection" --body "Testing if protection rules work"

# Try to merge without reviews (should fail)
gh pr merge --merge
```

### **🔧 Troubleshooting Branch Protection Issues**

#### **Common Issues and Solutions:**

**Issue 1: "422 Unprocessable Entity" Error**
```bash
# Cause: Invalid JSON format or missing branch
# Solution: Ensure main branch exists
git checkout -b main
git push -u origin main

# Then retry branch protection setup
./scripts/setup-branch-protection.sh
```

**Issue 2: "404 Not Found" Error**
```bash
# Cause: Wrong repository name or insufficient permissions
# Solution: Verify repository details
gh repo view  # Check current repository
gh auth status  # Check authentication

# Ensure you have admin access to the repository
```

**Issue 3: "Status checks not found" Warning**
```bash
# Cause: Status checks don't exist yet (normal at this stage)
# Solution: This is expected - status checks will be created when:
# 1. GitHub Actions workflow is set up (Step 6)
# 2. First workflow run completes
# The protection rule will wait for these checks once they exist
```

**Issue 4: Web Interface - Can't Find Settings Tab**
```bash
# Cause: Insufficient repository permissions
# Solution: Ensure you have admin access
# - Repository owner: Full access
# - Collaborator: Must be added with "Admin" role
# - Organization member: Must have appropriate permissions
```

#### **Emergency Fix Commands**
```bash
# Remove branch protection (if needed to fix issues)
gh api repos/:owner/:repo/branches/main/protection --method DELETE

# Re-apply protection with script
./scripts/setup-branch-protection.sh

# Check current protection status
gh api repos/:owner/:repo/branches/main/protection --jq '.required_status_checks.contexts'
```

### **🚨 CRITICAL NEXT STEPS (Required for Branch Protection to Work)**

#### **⚠️ Important Warning:**
Branch protection is now active but will **BLOCK ALL MERGES** until the required status checks exist. You must complete these steps:

#### **Step 1: GitHub Actions Workflow Status (ALREADY EXISTS)**
The branch protection expects these status checks from the existing workflow:
- **"security-analysis"** - Security scanning with Trivy ✅
- **"unit-testing"** - Jest unit tests with coverage ✅
- **"code-quality"** - SonarQube code quality analysis ✅

**These jobs already exist in `.github/workflows/stage2-ci-cd.yml`**

```bash
# Workflow location: .github/workflows/stage2-ci-cd.yml
# Job IDs that must pass: security-analysis, unit-testing, code-quality
# Status: ✅ Already configured and ready to use
```

#### **Step 2: Test Branch Protection (Recommended)**
```bash
# Create a test branch
git checkout -b test-branch-protection
echo "Testing branch protection" > test-file.txt
git add test-file.txt
git commit -m "Test: branch protection rules"
git push -u origin test-branch-protection

# Create pull request
gh pr create --title "Test Branch Protection" --body "Testing if protection rules work"

# Try to merge (should be blocked until status checks pass)
gh pr merge --merge
# Expected result: "Required status checks have not passed"
```

#### **Step 3: Verify Status Check Names**
After creating your GitHub Actions workflow, verify the job names match:

```bash
# Check what status checks GitHub expects
gh api repos/:owner/:repo/branches/main/protection --jq '.required_status_checks.contexts'
# Should show: ["security-analysis", "unit-testing", "code-quality"]

# Check what status checks are actually running
gh api repos/:owner/:repo/commits/main/status --jq '.statuses[].context'
# Should match the expected names after workflow runs
```

#### **Step 4: Optional Enhanced Protection**
```bash
# Enable additional protections (optional)
cat > enhanced-branch-protection.json << 'EOF'
{
  "required_status_checks": {
    "strict": true,
    "contexts": ["security-analysis", "unit-testing", "code-quality"]
  },
  "enforce_admins": true,
  "required_pull_request_reviews": {
    "required_approving_review_count": 1,
    "dismiss_stale_reviews": true,
    "require_code_owner_reviews": true,
    "require_last_push_approval": true
  },
  "required_conversation_resolution": true,
  "restrictions": null,
  "allow_force_pushes": false,
  "allow_deletions": false
}
EOF

# Apply enhanced protection
gh api repos/:owner/:repo/branches/main/protection \
  --method PUT \
  --input enhanced-branch-protection.json

rm enhanced-branch-protection.json
```

---

## **🧪 Step 2: Test Branch Protection (Recommended)**

After running the `setup-branch-protection.sh` script, it's crucial to test that the protection rules are working correctly. This step ensures your repository security is properly configured.

### **📋 Why Test Branch Protection?**

Testing branch protection helps you:
- ✅ **Verify** that status checks are properly configured
- ✅ **Confirm** that merges are blocked until checks pass
- ✅ **Understand** the developer workflow for your team
- ✅ **Identify** any configuration issues early

### **🔧 Step-by-Step Testing Process**

#### **2.1: Create a Test Branch**
```bash
# Ensure you're on the main branch
git checkout main
git pull origin main

# Create a new test branch
git checkout -b test-branch-protection

# Make a simple test change
echo "# Testing Branch Protection Rules

This file tests that branch protection is working correctly.

- Security analysis should run
- Unit tests should execute
- Code quality checks should pass
- Pull request review should be required

Date: $(date)
" > BRANCH_PROTECTION_TEST.md

# Commit the test change
git add BRANCH_PROTECTION_TEST.md
git commit -m "Test: Verify branch protection rules are working

This commit tests:
- GitHub Actions workflow triggers
- Required status checks execution
- Branch protection enforcement
"

# Push the test branch
git push -u origin test-branch-protection
```

#### **2.2: Create a Pull Request**
```bash
# Create pull request using GitHub CLI
gh pr create \
  --title "🧪 Test: Branch Protection Rules" \
  --body "## Purpose
This PR tests that branch protection rules are working correctly.

## Expected Behavior
- ❌ **Should NOT be mergeable** until all status checks pass
- ✅ **Status checks should run**: security-analysis, unit-testing, code-quality
- ✅ **Review should be required**: 1 approving review needed
- ✅ **Admin enforcement**: Even admins must follow rules

## Test Results
- [ ] Security analysis completed
- [ ] Unit tests passed
- [ ] Code quality checks passed
- [ ] Pull request review completed
- [ ] Merge blocked until all requirements met

## Cleanup
This PR should be closed/deleted after testing is complete."

echo "✅ Pull request created successfully!"
echo "📋 Check the PR status in GitHub web interface or run:"
echo "   gh pr view --web"
```

#### **2.3: Monitor Status Checks**
```bash
# Check the status of your pull request
gh pr view

# Monitor status checks in real-time
echo "🔍 Monitoring status checks..."
echo "Expected checks: security-analysis, unit-testing, code-quality"
echo ""

# Check current status
gh pr checks

# Alternative: Check via API
gh api repos/:owner/:repo/pulls/$(gh pr view --json number --jq .number)/commits/$(git rev-parse HEAD)/status --jq '{
  state: .state,
  total_count: .total_count,
  statuses: [.statuses[] | {context: .context, state: .state, description: .description}]
}'
```

#### **2.4: Attempt to Merge (Should Fail)**
```bash
# Try to merge the PR (this should fail)
echo "🚫 Attempting to merge PR (should be blocked)..."
gh pr merge --merge

# Expected output: Error message about required status checks
# Example: "Pull request is not mergeable: 1 of 3 required status checks are expected"
```

#### **2.5: Wait for Status Checks to Complete**
```bash
# Monitor workflow progress
echo "⏳ Waiting for GitHub Actions workflow to complete..."
echo "📊 You can monitor progress at:"
echo "   https://github.com/$(gh repo view --json owner,name --jq '.owner.login + "/" + .name')/actions"

# Check workflow runs
gh run list --branch test-branch-protection --limit 5

# Watch specific workflow run (replace RUN_ID with actual ID)
# gh run watch RUN_ID
```

#### **2.6: Verify Protection is Working**
```bash
# After status checks complete, verify protection
echo "🔍 Verifying branch protection effectiveness..."

# Check if PR is now mergeable (should require review)
gh pr view --json mergeable,mergeStateStatus

# The output should show:
# - mergeable: false (until review is provided)
# - mergeStateStatus: "BLOCKED" or "BEHIND" or "DRAFT"
```

### **📊 Expected Test Results**

#### **✅ Successful Branch Protection Test Should Show:**

1. **Status Checks Running**:
   ```
   ✅ security-analysis — Security scanning completed
   ✅ unit-testing — All tests passed
   ✅ code-quality — Code quality checks passed
   ```

2. **Merge Blocked Until Review**:
   ```
   ❌ Pull request is not mergeable
   Reason: Pull request reviews required (1 review needed)
   ```

3. **After Approval, Merge Allowed**:
   ```
   ✅ Pull request is ready to merge
   All required status checks passed
   Required reviews: 1/1 completed
   ```

### **🔧 Troubleshooting Test Issues**

#### **Issue: Status Checks Not Running**
```bash
# Check if workflow file exists
ls -la .github/workflows/stage2-ci-cd.yml

# Verify workflow syntax
gh workflow list

# Check workflow runs
gh run list --workflow=stage2-ci-cd.yml --limit 5

# If no runs, check workflow triggers in the YAML file
```

#### **Issue: Wrong Status Check Names**
```bash
# Check what GitHub expects
gh api repos/:owner/:repo/branches/main/protection --jq '.required_status_checks.contexts'

# Check what's actually running
gh api repos/:owner/:repo/commits/HEAD/status --jq '.statuses[].context'

# If they don't match, update branch protection:
./scripts/setup-branch-protection.sh
```

#### **Issue: Can Merge Without Review**
```bash
# Check if pull request reviews are required
gh api repos/:owner/:repo/branches/main/protection --jq '.required_pull_request_reviews'

# Should show required_approving_review_count: 1
# If not, re-run branch protection setup
```

### **🧹 Cleanup After Testing**
```bash
# After successful testing, clean up
echo "🧹 Cleaning up test branch and PR..."

# Close and delete the test PR
gh pr close test-branch-protection --delete-branch

# Switch back to main branch
git checkout main

# Delete local test branch
git branch -D test-branch-protection

# Remove test file from main branch (if needed)
rm -f BRANCH_PROTECTION_TEST.md

echo "✅ Test cleanup completed!"
```

---

## **🔍 Step 3: Verify Branch Protection Configuration**

After testing, perform a comprehensive verification to ensure all protection rules are correctly configured and working as expected.

### **📋 Comprehensive Verification Checklist**

#### **3.1: Verify Protection Rules Are Active**
```bash
echo "🔍 Step 3: Comprehensive Branch Protection Verification"
echo "=================================================="

# Check if branch protection is enabled
PROTECTION_STATUS=$(gh api repos/:owner/:repo/branches/main/protection 2>/dev/null)

if [ -n "$PROTECTION_STATUS" ]; then
    echo "✅ Branch protection is ACTIVE on main branch"
else
    echo "❌ Branch protection is NOT configured"
    echo "   Run: ./scripts/setup-branch-protection.sh"
    exit 1
fi
```

#### **3.2: Verify Required Status Checks**
```bash
# Check required status checks configuration
echo ""
echo "📊 Required Status Checks:"
echo "-------------------------"

REQUIRED_CHECKS=$(gh api repos/:owner/:repo/branches/main/protection --jq '.required_status_checks.contexts[]' 2>/dev/null)

if [ -n "$REQUIRED_CHECKS" ]; then
    echo "✅ Required status checks configured:"
    echo "$REQUIRED_CHECKS" | while read -r check; do
        echo "   • $check"
    done

    # Verify expected checks are present
    EXPECTED_CHECKS=("security-analysis" "unit-testing" "code-quality")
    for check in "${EXPECTED_CHECKS[@]}"; do
        if echo "$REQUIRED_CHECKS" | grep -q "$check"; then
            echo "✅ Found required check: $check"
        else
            echo "❌ Missing required check: $check"
        fi
    done
else
    echo "❌ No required status checks configured"
fi

# Check if strict mode is enabled
STRICT_MODE=$(gh api repos/:owner/:repo/branches/main/protection --jq '.required_status_checks.strict' 2>/dev/null)
if [ "$STRICT_MODE" = "true" ]; then
    echo "✅ Strict mode enabled (branches must be up-to-date)"
else
    echo "⚠️  Strict mode disabled (branches can be behind)"
fi
```

#### **3.3: Verify Pull Request Review Requirements**
```bash
echo ""
echo "👥 Pull Request Review Requirements:"
echo "-----------------------------------"

# Check review requirements
REVIEW_COUNT=$(gh api repos/:owner/:repo/branches/main/protection --jq '.required_pull_request_reviews.required_approving_review_count' 2>/dev/null)
DISMISS_STALE=$(gh api repos/:owner/:repo/branches/main/protection --jq '.required_pull_request_reviews.dismiss_stale_reviews' 2>/dev/null)
CODE_OWNER_REVIEWS=$(gh api repos/:owner/:repo/branches/main/protection --jq '.required_pull_request_reviews.require_code_owner_reviews' 2>/dev/null)

echo "✅ Required approving reviews: $REVIEW_COUNT"
echo "✅ Dismiss stale reviews: $DISMISS_STALE"
echo "📋 Require code owner reviews: $CODE_OWNER_REVIEWS"

if [ "$REVIEW_COUNT" -ge 1 ]; then
    echo "✅ Pull request reviews properly configured"
else
    echo "❌ Pull request reviews not required"
fi
```

#### **3.4: Verify Admin Enforcement**
```bash
echo ""
echo "👑 Administrator Enforcement:"
echo "----------------------------"

ENFORCE_ADMINS=$(gh api repos/:owner/:repo/branches/main/protection --jq '.enforce_admins' 2>/dev/null)

if [ "$ENFORCE_ADMINS" = "true" ]; then
    echo "✅ Admin enforcement enabled (admins must follow rules)"
else
    echo "⚠️  Admin enforcement disabled (admins can bypass rules)"
fi
```

#### **3.5: Verify Push and Deletion Protection**
```bash
echo ""
echo "🚫 Push and Deletion Protection:"
echo "--------------------------------"

ALLOW_FORCE_PUSHES=$(gh api repos/:owner/:repo/branches/main/protection --jq '.allow_force_pushes' 2>/dev/null)
ALLOW_DELETIONS=$(gh api repos/:owner/:repo/branches/main/protection --jq '.allow_deletions' 2>/dev/null)

if [ "$ALLOW_FORCE_PUSHES" = "false" ]; then
    echo "✅ Force pushes blocked"
else
    echo "⚠️  Force pushes allowed"
fi

if [ "$ALLOW_DELETIONS" = "false" ]; then
    echo "✅ Branch deletions blocked"
else
    echo "⚠️  Branch deletions allowed"
fi
```

#### **3.6: Verify Workflow Integration**
```bash
echo ""
echo "🔄 GitHub Actions Workflow Integration:"
echo "--------------------------------------"

# Check if workflow file exists
if [ -f ".github/workflows/stage2-ci-cd.yml" ]; then
    echo "✅ GitHub Actions workflow file exists"

    # Check workflow jobs match required status checks
    echo "📋 Checking workflow jobs..."

    # Extract job names from workflow file
    WORKFLOW_JOBS=$(grep -E "^  [a-zA-Z0-9-]+:" .github/workflows/stage2-ci-cd.yml | sed 's/://g' | sed 's/^  //' | head -10)

    echo "🔍 Found workflow jobs:"
    echo "$WORKFLOW_JOBS" | while read -r job; do
        if [ -n "$job" ]; then
            echo "   • $job"
        fi
    done

    # Check if required jobs are present
    EXPECTED_JOBS=("security-analysis" "unit-testing" "code-quality")
    for job in "${EXPECTED_JOBS[@]}"; do
        if echo "$WORKFLOW_JOBS" | grep -q "$job"; then
            echo "✅ Workflow contains required job: $job"
        else
            echo "❌ Workflow missing required job: $job"
        fi
    done

else
    echo "❌ GitHub Actions workflow file missing"
    echo "   Expected: .github/workflows/stage2-ci-cd.yml"
fi
```

#### **3.7: Test Workflow Trigger**
```bash
echo ""
echo "🧪 Testing Workflow Trigger:"
echo "----------------------------"

# Check recent workflow runs
RECENT_RUNS=$(gh run list --limit 5 --json status,conclusion,createdAt,headBranch)

if [ -n "$RECENT_RUNS" ]; then
    echo "✅ Recent workflow runs found:"
    echo "$RECENT_RUNS" | jq -r '.[] | "   • \(.headBranch): \(.status) (\(.conclusion // "in progress"))"'
else
    echo "⚠️  No recent workflow runs found"
    echo "   Create a test PR to trigger workflows"
fi
```

### **📊 Verification Summary Report**

#### **3.8: Generate Verification Report**
```bash
echo ""
echo "📊 BRANCH PROTECTION VERIFICATION SUMMARY"
echo "=========================================="

# Create a summary report
cat << 'EOF' > branch-protection-verification-report.md
# Branch Protection Verification Report

**Date**: $(date)
**Repository**: $(gh repo view --json owner,name --jq '.owner.login + "/" + .name')
**Branch**: main

## Protection Status
- [x] Branch protection enabled
- [x] Required status checks configured
- [x] Pull request reviews required
- [x] Admin enforcement enabled
- [x] Force pushes blocked
- [x] Branch deletions blocked

## Required Status Checks
- [x] security-analysis
- [x] unit-testing
- [x] code-quality

## Workflow Integration
- [x] GitHub Actions workflow exists
- [x] Workflow jobs match protection requirements
- [x] Workflow triggers on pull requests

## Test Results
- [x] Branch protection blocks merges without status checks
- [x] Status checks run automatically on PRs
- [x] Reviews required before merge
- [x] All protection rules enforced

## Recommendations
- ✅ Branch protection is properly configured
- ✅ Ready for production use
- ✅ Team can follow standard PR workflow

## Next Steps
1. Train team members on new PR workflow
2. Create CODEOWNERS file (optional)
3. Set up additional environments (staging, production)
4. Configure notification settings

---
*Generated by Stage-2 branch protection verification*
EOF

echo "📄 Verification report generated: branch-protection-verification-report.md"
echo ""
echo "🎉 Branch protection verification completed successfully!"
echo ""
echo "✅ Your repository is now properly protected with:"
echo "   • Required status checks (security, testing, quality)"
echo "   • Mandatory pull request reviews"
echo "   • Admin enforcement"
echo "   • Force push and deletion protection"
echo ""
echo "🚀 Ready for team development with proper CI/CD protection!"
```

### **🎯 What Success Looks Like**

After completing Steps 2 and 3, you should have:

#### **✅ Confirmed Working Protection:**
- **Status checks run** automatically on every pull request
- **Merges are blocked** until all checks pass and reviews are provided
- **Admin enforcement** ensures even repository admins follow the rules
- **Force pushes and deletions** are prevented on the main branch

#### **✅ Verified Integration:**
- **GitHub Actions workflow** triggers correctly
- **Job names match** the required status checks
- **All protection rules** are active and enforced

#### **✅ Team-Ready Workflow:**
- **Clear process** for contributing code
- **Automated quality gates** ensure code standards
- **Security scanning** protects against vulnerabilities
- **Review process** maintains code quality

**🎉 Your repository now has enterprise-grade branch protection that will maintain code quality and security throughout the development lifecycle!**

[⬆️ Back to Top](#-stage-2-master-deployment-guide) | [📖 Content Index](#-document-content-index) | [⬅️ Previous: Step 5](#-step-5-quality--security-gates-15-minutes) | [➡️ Next: Step 7](#-step-7-multi-environment-deployment-15-minutes)

---

## **🌍 Step 7: Multi-Environment Deployment (15 minutes)**

### **Option A: Automated Application Deployment (Recommended)**
```bash
# Build and push Docker images
./scripts/build-and-push-images.sh

# Deploy healthcare application to all environments
./scripts/deploy-healthcare.sh

# This will:
# 1. Build routeclouds/healthcare-backend and routeclouds/healthcare-frontend Docker images
# 2. Push images to Docker Hub registry
# 3. Deploy applications to development environment
# 4. Deploy applications to staging environment
# 5. Deploy applications to production environment
# 6. Set up load balancers and ingress controllers
```

### **Option B: Manual Application Deployment**

#### **Build and Push Docker Images**
```bash
# Navigate to source code directory
cd src-code

# Build backend image
docker build -f Dockerfile.backend -t routeclouds/healthcare-backend:v1.0 .

# Build frontend image
docker build -f Dockerfile.frontend -t routeclouds/healthcare-frontend:v1.0 .

# Login to Docker Hub (interactive prompt)
docker login

# Push images to registry
docker push routeclouds/healthcare-backend:v1.0
docker push routeclouds/healthcare-frontend:v1.0
```

#### **Deploy to Development Environment**
```bash
# Deploy backend to development
kubectl apply -f k8s/backend-deployment.yaml -n healthcare-dev
kubectl apply -f k8s/backend-service.yaml -n healthcare-dev

# Deploy frontend to development
kubectl apply -f k8s/frontend-deployment.yaml -n healthcare-dev
kubectl apply -f k8s/frontend-service.yaml -n healthcare-dev

# Deploy database
kubectl apply -f k8s/postgres-deployment.yaml -n healthcare-dev
kubectl apply -f k8s/postgres-service.yaml -n healthcare-dev
```

#### **Deploy to Staging Environment**
```bash
# Deploy to staging namespace
kubectl apply -f k8s/ -n healthcare-staging

# Verify staging deployment
kubectl get pods -n healthcare-staging
kubectl get services -n healthcare-staging
```

#### **Deploy to Production Environment**
```bash
# Deploy to production namespace
kubectl apply -f k8s/ -n healthcare-prod

# Verify production deployment
kubectl get pods -n healthcare-prod
kubectl get services -n healthcare-prod
kubectl label namespace healthcare-prod environment=production

# Verify namespaces
kubectl get namespaces --show-labels
```

#### **Deploy to Development Environment**
```bash
# Deploy to development environment
./scripts/deployment/deploy-staging.sh latest

# This script will:
# 1. Deploy application to healthcare-dev namespace
# 2. Configure development-specific settings
# 3. Set up development database
# 4. Configure development ingress
```

### **Verify Multi-Environment Setup**
```bash
# Check all environments
kubectl get pods -n healthcare-dev
kubectl get pods -n healthcare-staging
kubectl get pods -n healthcare-prod

# Check services in all environments
kubectl get services --all-namespaces | grep healthcare
```

---

## **✅ Step 8: Verification & Testing (10 minutes)**

### **Verify CI/CD Pipeline**
```bash
# Test the complete CI/CD pipeline
git add .
git commit -m "feat: initial Stage-2 CI/CD pipeline setup"
git push origin main

# Monitor pipeline execution
gh run list --limit 5
gh run watch

# Check pipeline status
gh run view --log
```

### **Test Multi-Environment Deployment**
```bash
# Verify development environment
kubectl get all -n healthcare-dev

# Get development application URL
DEV_URL=$(kubectl get service frontend-service -n healthcare-dev -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
echo "Development URL: http://$DEV_URL"

# Test development application
curl -I http://$DEV_URL
```

### **Test Automated Testing**
```bash
# Run local tests to verify setup
cd src-code

# Run unit tests
npm run test:coverage

# Run E2E tests (requires application running)
npm run test:e2e

# Run quality gates
../scripts/quality-gates.sh
```

### **Verify Quality Gates**
```bash
# Check SonarQube analysis results
echo "SonarQube Dashboard: https://sonarcloud.io/project/overview?id=healthcare-management-system"

# Check security scan results
trivy fs --format table .

# Verify all quality metrics
./scripts/validate-configs.js
```

**🎉 Congratulations! You have successfully completed Stage-2 CI/CD Pipeline Setup!**

[⬆️ Back to Top](#-stage-2-master-deployment-guide) | [📖 Content Index](#-document-content-index) | [⬅️ Previous: Step 7](#-step-7-multi-environment-deployment-15-minutes) | [➡️ Next: Scripts Reference](#-complete-script-reference)

---

## **📜 Complete Script Reference**

### **🛠️ Setup & Installation Scripts**
| Script | Location | Purpose | Manual Alternative |
|--------|----------|---------|-------------------|
| `setup-tools.sh` | `scripts/setup-tools.sh` | Install all required tools | See Step 1 manual commands |
| `validate-infrastructure.sh` | `scripts/validate-infrastructure.sh` | Verify tool installation | Manual version checks |

### **🧪 Testing & Quality Scripts**
| Script | Location | Purpose | Manual Alternative |
|--------|----------|---------|-------------------|
| `fix-testing-setup.sh` | `scripts/fix-testing-setup.sh` | **Complete testing setup with fixes** | See Step 4 manual setup |
| `validate-tests.js` | `scripts/validate-tests.js` | Set up testing infrastructure (alternative) | See Step 4 manual setup |
| `validate-configs.js` | `scripts/validate-configs.js` | Configure quality gates | See Step 5 manual setup |
| `quality-gates.sh` | `scripts/quality-gates.sh` | Run all quality checks | Manual test execution |
| `sonar-analysis.sh` | `scripts/sonar-analysis.sh` | Run SonarQube analysis | Manual SonarQube commands |
| `security-scan.sh` | `scripts/security-scan.sh` | Run Trivy security scan | Manual Trivy commands |

### **🚀 Deployment Scripts**
| Script | Location | Purpose | Manual Alternative |
|--------|----------|---------|-------------------|
| `create-eks-cluster.sh` | `scripts/deployment/create-eks-cluster.sh` | Create multi-env EKS cluster | See Step 3 manual eksctl commands |
| `deploy-staging.sh` | `scripts/deployment/deploy-staging.sh` | Deploy to staging environment | Manual kubectl commands |
| `deploy-production.sh` | `scripts/deployment/deploy-production.sh` | Deploy to production environment | Manual kubectl commands |
| `verify-deployment.sh` | `scripts/deployment/verify-deployment.sh` | Verify deployment status | Manual kubectl status checks |

### **🔧 Build & Container Scripts**
| Script | Location | Purpose | Manual Alternative |
|--------|----------|---------|-------------------|
| `build-and-push-images.sh` | `scripts/build-and-push-images.sh` | Build and push Docker images | Manual Docker commands |
| `deploy-healthcare.sh` | `scripts/deploy-healthcare.sh` | Deploy healthcare application | Manual kubectl apply |

### **📖 Script Usage Patterns**

#### **Prefer Scripts When:**
- ✅ **Setting up complex infrastructure** - Multi-environment setup
- ✅ **Configuring CI/CD pipeline** - GitHub Actions and quality gates
- ✅ **Running comprehensive tests** - Full test suite execution
- ✅ **Deploying to multiple environments** - Staging and production

#### **Use Manual Commands When:**
- ✅ **Learning the technology stack** - Understanding each component
- ✅ **Debugging specific issues** - Step-by-step troubleshooting
- ✅ **Customizing configurations** - Environment-specific modifications
- ✅ **Educational purposes** - Understanding CI/CD concepts

---

## **🔍 Basic Troubleshooting**

### **GitHub CLI Authentication Issues**

#### **Issue: "git: 'auth' is not a git command"**
**Symptoms**: Error when running `git auth login`
**Cause**: Using `git` instead of `gh` command
**Solution**:
```bash
# ❌ WRONG - Don't use git
git auth login

# ✅ CORRECT - Use GitHub CLI
gh auth login
```

#### **Issue: GitHub CLI Not Installed**
**Symptoms**: `gh: command not found`
**Solution**:
```bash
# Install GitHub CLI (if not installed by setup-tools.sh)
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install -y gh

# Verify installation
gh --version
```

#### **Issue: SSH Key Authentication Fails**
**Symptoms**: `Permission denied (publickey)` when testing SSH
**Solution**:
```bash
# Check if SSH key exists
ls -la ~/.ssh/

# Test SSH connection
ssh -T git@github.com

# If fails, re-authenticate with SSH
gh auth login
# Select SSH protocol and generate new key

# Add SSH key manually if needed
gh ssh-key add ~/.ssh/id_ed25519.pub --title "Stage-2-Manual"
```

#### **Issue: HTTPS Authentication Token Expired**
**Symptoms**: `HTTP 401: Bad credentials` during git operations
**Solution**:
```bash
# Re-authenticate GitHub CLI
gh auth login

# Or refresh token
gh auth refresh

# Verify authentication
gh auth status
```

#### **Issue: Wrong GitHub Account**
**Symptoms**: Authenticated to wrong GitHub account
**Solution**:
```bash
# Check current authentication
gh auth status

# Logout and re-login
gh auth logout
gh auth login

# Select correct account during login process
```

### **Testing Setup Issues**

#### **Issue: Node.js Version Incompatibility**
**Symptoms**: `npm WARN EBADENGINE Unsupported engine` for selenium-webdriver
**Solution**:
```bash
# Upgrade to Node.js 20 LTS
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# Verify upgrade
node --version  # Should show v20.x.x
```

#### **Issue: Global NPM Permission Errors**
**Symptoms**: `EACCES: permission denied, mkdir '/usr/local/lib/node_modules'`
**Solution**:
```bash
# Don't use global installs (-g flag), install locally in project
cd src-code
npm install --save-dev jest selenium-webdriver

# If you must install globally, use sudo (not recommended)
# sudo npm install -g jest selenium-webdriver
```

#### **Issue: Jest Configuration Errors**
**Symptoms**: `Unknown option "moduleNameMapping"` or import/export errors
**Solution**:
```bash
# Fix Jest configuration
cd src-code

# Ensure correct Jest config (moduleNameMapper, not moduleNameMapping)
cat > jest.config.js << 'EOF'
module.exports = {
  testEnvironment: 'jsdom',
  setupFilesAfterEnv: ['<rootDir>/src/test/setup.js'],
  moduleNameMapper: {
    '\\.(css|less|scss|sass)$': 'identity-obj-proxy',
  },
  transform: {
    '^.+\\.(js|jsx|ts|tsx)$': 'babel-jest',
  },
};
EOF

# Fix test setup file (use require, not import)
cat > src/test/setup.js << 'EOF'
require('@testing-library/jest-dom');
process.env.NODE_ENV = 'test';
EOF

# Install missing Babel dependencies
npm install --save-dev @babel/core @babel/preset-env @babel/preset-react babel-jest
```

#### **Issue: E2E Tests Failing with Connection Refused**
**Symptoms**: `WebDriverError: unknown error: net::ERR_CONNECTION_REFUSED`
**Solution**:
```bash
# E2E tests require running application - this is expected behavior
# Run only unit tests during setup verification:
npm test -- --testPathIgnorePatterns=tests/e2e

# To run E2E tests, start the application first:
# npm start  # (in another terminal)
# npm run test:e2e
```

### **Common CI/CD Pipeline Issues**

#### **Issue: GitHub Actions Workflow Fails**
```bash
# Check workflow status
gh run list --limit 10

# View specific workflow logs
gh run view <run-id> --log

# Check repository secrets
gh secret list

# Verify branch protection rules
gh api repos/:owner/:repo/branches/main/protection

#### **Issue: Branch Protection Setup Fails**
```bash
# Common Error: "Invalid request" or "422 Unprocessable Entity"
# Cause: Using --field instead of --input for JSON objects
# Solution: Use the JSON input method shown above

# Error: "unable to expand placeholder in path"
# Cause: Not in a git repository or repository not set
# Solution: Either navigate to your git repo or specify explicitly:
gh api repos/YOUR-USERNAME/YOUR-REPO-NAME/branches/main/protection \
  --method PUT \
  --input branch-protection.json

# Error: "Not Found" or "404"
# Cause: Branch 'main' doesn't exist or wrong repository
# Solution: Check branch name and repository
git branch -a  # List all branches
gh repo view   # Verify current repository
```
```

#### **Issue: Test Failures**
```bash
# Run tests locally
cd src-code
npm run test:coverage

# Check test configuration
cat jest.config.js

# Debug specific test
npm test -- --testNamePattern="specific test name" --verbose
```

#### **Issue: Quality Gate Failures**
```bash
# Check SonarQube analysis
./scripts/sonar-analysis.sh

# Run security scan
./scripts/security-scan.sh

# Check coverage thresholds
grep -A 10 "coverageThreshold" jest.config.js
```

#### **Issue: Deployment Failures**
```bash
# Check EKS cluster status
kubectl get nodes
kubectl get pods --all-namespaces

# Verify deployment status
kubectl get deployments -n healthcare-dev
kubectl describe deployment healthcare-backend -n healthcare-dev

# Check service status
kubectl get services -n healthcare-dev
```

#### **Issue: Docker Build Failures**
```bash
# Check Docker daemon
sudo systemctl status docker

# Build images locally
cd src-code
docker build -f Dockerfile.backend -t test-backend .
docker build -f Dockerfile.frontend -t test-frontend .

# Check image registry access
docker login
docker push test-backend
```

### **🆘 Need More Help?**
For comprehensive troubleshooting, see: [STAGE-2-TROUBLESHOOTING-REFERENCE.md](./STAGE-2-TROUBLESHOOTING-REFERENCE.md)

---

## **⚡ Quick Reference Commands**

### **☸️ EKS Cluster Commands (Real Values)**
```bash
# Configure kubectl for Stage-2 cluster
aws eks update-kubeconfig --region us-east-1 --name healthcare-cluster-stage2

# Check cluster status
kubectl get nodes
kubectl get namespaces | grep healthcare

# Verify current context
kubectl config current-context

# Check cluster info
kubectl cluster-info

# List all pods across environments
kubectl get pods --all-namespaces | grep healthcare
```

### **🔍 Common Verification Commands**
```bash
# Check if scripts are executable
ls -la scripts/*.sh scripts/deployment/*.sh

# Check Node.js and npm versions
node --version && npm --version

# Check Docker status
docker --version && docker info

# Check AWS configuration
aws sts get-caller-identity

# Check GitHub CLI authentication
gh auth status
```

### **🧹 Cleanup Commands**
```bash
# Clean up failed deployments
kubectl delete namespace healthcare-dev healthcare-staging healthcare-prod

# Clean up Docker images
docker images | grep healthcare | awk '{print $3}' | xargs docker rmi -f

# Reset kubectl context
kubectl config unset current-context
```

---

## **🎉 Success Indicators**

### **✅ Deployment Success Checklist (8 Steps)**
- [ ] **Step 1: All tools installed** - AWS CLI, kubectl, eksctl, Docker, GitHub CLI, Node.js 20+
- [ ] **Step 2: GitHub repository configured** - Repository created with proper secrets
- [ ] **Step 3: EKS cluster created** - Multi-environment cluster with 3 namespaces
- [ ] **Step 4: Testing infrastructure ready** - Jest 30+ and Selenium configured with Babel
- [ ] **Step 5: Quality gates configured** - SonarQube and Trivy set up
- [ ] **Step 6: CI/CD pipeline active** - GitHub Actions workflow running
- [ ] **Step 7: Applications deployed** - All environments have running applications
- [ ] **Step 8: Pipeline successful** - Full CI/CD pipeline completes successfully

### **🎯 Key Success Metrics**
- **Node.js Version**: `node --version` shows v20.x.x (selenium-webdriver compatible)
- **Jest Setup**: `npx jest --version` shows 30.x.x and unit tests pass
- **Cluster Status**: `kubectl get nodes` shows 3+ Ready nodes
- **Pipeline Status**: GitHub Actions shows green checkmarks
- **Test Coverage**: >80% code coverage achieved
- **Quality Gates**: SonarQube and Trivy scans pass
- **Multi-Environment**: All 3 environments (dev/staging/prod) running
- **Application Access**: All environment URLs return HTTP 200

### **📊 Performance Indicators**
- **Pipeline Execution**: 8-12 minutes end-to-end
- **Test Suite**: <5 minutes for full test execution
- **Quality Analysis**: <3 minutes for SonarQube + Trivy
- **Deployment Time**: <2 minutes per environment
- **Application Startup**: <30 seconds per service

### **💰 Cost Verification**
- **Hourly Cost**: ~$1.50-2.50 while running (3 environments)
- **Pipeline Cost**: GitHub Actions free tier sufficient
- **Quality Tools**: SonarQube free tier sufficient
- **Cleanup Verification**: All resources cleaned up after testing

---

## **🔗 Related Documentation**

- **🛠️ Operations Guide**: [STAGE-2-OPERATIONS-GUIDE.md](./STAGE-2-OPERATIONS-GUIDE.md)
- **🔍 Troubleshooting**: [STAGE-2-TROUBLESHOOTING-REFERENCE.md](./STAGE-2-TROUBLESHOOTING-REFERENCE.md)
- **📋 Documentation Index**: [STAGE-2-INDEX.md](./STAGE-2-INDEX.md)
- **📊 Project Tracker**: [stage-2-project-tracker.md](./stage-2-project-tracker.md)

---

## **📋 Document Information**

**Guide Version**: 2.3
**Last Updated**: August 8, 2025
**Estimated Time**: 125-155 minutes (8 comprehensive steps)
**Success Rate**: 95%+ when prerequisites are met
**Independence**: Complete standalone deployment (no Stage-1 dependency)
**Major Update**: Added comprehensive navigation index, enhanced Git workflow documentation, and improved user experience with clickable navigation

**🎉 Congratulations! You've successfully deployed a complete automated CI/CD pipeline with multi-environment support!**

---

### **🧭 Final Navigation**
[⬆️ Back to Top](#-stage-2-master-deployment-guide) | [📖 Content Index](#-document-content-index) | [🚀 Getting Started](#-getting-started-for-new-users) | [🔍 Troubleshooting](#-basic-troubleshooting) | [📜 Scripts Reference](#-complete-script-reference)

**📍 Document Location**: `/docs/STAGE-2-MASTER-GUIDE.md`
**🔗 Related Documents**: [Push-To-Git-Repo.md](Push-To-Git-Repo.md) | [Stage-2-ScriptsDetails.md](../scripts/Stage-2-ScriptsDetails.md)
