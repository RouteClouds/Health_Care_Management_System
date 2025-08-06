# 🚀 **Stage 2 Master Deployment Guide**
## **Complete Automated CI/CD Pipeline - From Setup to Production**

### **📖 Document Content Index**
- [🎯 Welcome to Stage 2](#-welcome-to-stage-2)
- [📋 Prerequisites & Requirements](#-prerequisites--requirements)
- [🛠️ Step 1: Tool Installation & Setup](#️-step-1-tool-installation--setup-15-minutes)
- [🔑 Step 2: GitHub Configuration](#-step-2-github-configuration-10-minutes)
- [🧪 Step 3: Testing Infrastructure](#-step-3-testing-infrastructure-setup-20-minutes)
- [📊 Step 4: Quality & Security Gates](#-step-4-quality--security-gates-15-minutes)
- [🚀 Step 5: CI/CD Pipeline Setup](#-step-5-cicd-pipeline-setup-20-minutes)
- [🌍 Step 6: Multi-Environment Deployment](#-step-6-multi-environment-deployment-15-minutes)
- [✅ Step 7: Verification & Testing](#-step-7-verification--testing-10-minutes)
- [📜 Complete Script Reference](#-complete-script-reference)
- [🔍 Basic Troubleshooting](#-basic-troubleshooting)
- [🎉 Success Indicators](#-success-indicators)

**Document Purpose**: Complete end-to-end automated CI/CD pipeline deployment
**Target Audience**: All Stage 2 users (independent of Stage 1)
**Estimated Time**: 105-135 minutes
**Success Rate**: 95%+ when prerequisites are met
**Last Updated**: August 6, 2025

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
# Install Node.js 18 LTS
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install global testing tools
npm install -g jest selenium-webdriver

# Verify installations
node --version
npm --version
jest --version
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
node --version        # Should be v18.x+
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
```bash
# Login to GitHub
gh auth login

# Follow the prompts:
# ? What account do you want to log into? GitHub.com
# ? What is your preferred protocol for Git operations? HTTPS
# ? Authenticate Git with your GitHub credentials? Yes
# ? How would you like to authenticate GitHub CLI? Login with a web browser

# Verify GitHub authentication
gh auth status
```

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
```bash
# Set up required GitHub secrets for CI/CD pipeline
gh secret set AWS_ACCESS_KEY_ID --body "your-aws-access-key-id"
gh secret set AWS_SECRET_ACCESS_KEY --body "your-aws-secret-access-key"
gh secret set DOCKER_USERNAME --body "your-docker-username"
gh secret set DOCKER_PASSWORD --body "your-docker-password"
gh secret set SONARQUBE_TOKEN --body "your-sonarqube-token"

# Verify secrets are set
gh secret list
```

---

## **🧪 Step 3: Testing Infrastructure Setup (20 minutes)**

### **Option A: Automated Testing Setup (Recommended)**
```bash
# Set up complete testing infrastructure
./scripts/validate-tests.js

# This script will:
# 1. Install Jest for unit testing
# 2. Configure Selenium for E2E testing
# 3. Set up test databases and mock services
# 4. Configure test environments
# 5. Validate all testing components
```

### **Option B: Manual Testing Setup**

#### **Set Up Jest Unit Testing**
```bash
# Navigate to source code directory
cd src-code

# Install Jest and testing dependencies
npm install --save-dev jest @testing-library/react @testing-library/jest-dom
npm install --save-dev @testing-library/user-event jest-environment-jsdom

# Create Jest configuration
cat > jest.config.js << 'EOF'
module.exports = {
  testEnvironment: 'jsdom',
  setupFilesAfterEnv: ['<rootDir>/src/test/setup.js'],
  moduleNameMapping: {
    '\\.(css|less|scss|sass)$': 'identity-obj-proxy',
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

# Create test setup file
mkdir -p src/test
cat > src/test/setup.js << 'EOF'
import '@testing-library/jest-dom';

// Mock environment variables
process.env.REACT_APP_API_URL = 'http://localhost:3002/api';
process.env.NODE_ENV = 'test';
EOF
```

#### **Set Up Selenium E2E Testing**
```bash
# Install Selenium WebDriver and dependencies
npm install --save-dev selenium-webdriver chromedriver

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
    await driver.get('http://localhost:3000');
    const title = await driver.getTitle();
    expect(title).toContain('Healthcare');
  });
  
  test('should navigate to doctor search', async () => {
    await driver.get('http://localhost:3000');
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

# Verify test configuration
npm test -- --passWithNoTests
```

---

## **📊 Step 4: Quality & Security Gates (15 minutes)**

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
    trivy image --exit-code 1 --severity HIGH,CRITICAL healthcare-backend:latest
    trivy image --exit-code 1 --severity HIGH,CRITICAL healthcare-frontend:latest
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

## **🚀 Step 5: CI/CD Pipeline Setup (20 minutes)**

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
        username: ${{ secrets.DOCKER_USERNAME }}
        password: ${{ secrets.DOCKER_PASSWORD }}

    - name: Build and push images
      run: |
        cd src-code

        # Build backend image
        docker build -f Dockerfile.backend -t ${{ secrets.DOCKER_USERNAME }}/healthcare-backend:${{ github.sha }} .
        docker build -f Dockerfile.backend -t ${{ secrets.DOCKER_USERNAME }}/healthcare-backend:latest .

        # Build frontend image
        docker build -f Dockerfile.frontend -t ${{ secrets.DOCKER_USERNAME }}/healthcare-frontend:${{ github.sha }} .
        docker build -f Dockerfile.frontend -t ${{ secrets.DOCKER_USERNAME }}/healthcare-frontend:latest .

        # Push images
        docker push ${{ secrets.DOCKER_USERNAME }}/healthcare-backend:${{ github.sha }}
        docker push ${{ secrets.DOCKER_USERNAME }}/healthcare-backend:latest
        docker push ${{ secrets.DOCKER_USERNAME }}/healthcare-frontend:${{ github.sha }}
        docker push ${{ secrets.DOCKER_USERNAME }}/healthcare-frontend:latest

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
```bash
# Set up branch protection for main branch
gh api repos/:owner/:repo/branches/main/protection \
  --method PUT \
  --field required_status_checks='{"strict":true,"contexts":["Run Tests","Quality & Security Gates"]}' \
  --field enforce_admins=true \
  --field required_pull_request_reviews='{"required_approving_review_count":1}' \
  --field restrictions=null

echo "✅ Branch protection rules configured"
```

---

## **🌍 Step 6: Multi-Environment Deployment (15 minutes)**

### **Option A: Automated Multi-Environment Setup (Recommended)**
```bash
# Create EKS cluster for Stage-2
./scripts/deployment/create-eks-cluster.sh

# This script will:
# 1. Create EKS cluster with multi-environment support
# 2. Set up development, staging, and production namespaces
# 3. Configure RBAC and service accounts
# 4. Set up ingress controllers and load balancers
```

### **Option B: Manual Multi-Environment Setup**

#### **Create EKS Cluster**
```bash
# Set cluster configuration
CLUSTER_NAME="healthcare-cluster-stage2"
REGION="us-east-1"
CLUSTER_VERSION="1.32"
NODE_GROUP_NAME="healthcare-nodes-stage2"
NODE_TYPE="t3.medium"
DESIRED_NODES=3
MIN_NODES=1
MAX_NODES=6

# Create EKS cluster
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
  --with-oidc \
  --full-ecr-access \
  --asg-access \
  --external-dns-access \
  --alb-ingress-access

# Update kubeconfig
aws eks update-kubeconfig --region $REGION --name $CLUSTER_NAME
```

#### **Set Up Multi-Environment Namespaces**
```bash
# Create environment namespaces
kubectl create namespace healthcare-dev
kubectl create namespace healthcare-staging
kubectl create namespace healthcare-prod

# Label namespaces
kubectl label namespace healthcare-dev environment=development
kubectl label namespace healthcare-staging environment=staging
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

## **✅ Step 7: Verification & Testing (10 minutes)**

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
| `validate-tests.js` | `scripts/validate-tests.js` | Set up testing infrastructure | See Step 3 manual setup |
| `validate-configs.js` | `scripts/validate-configs.js` | Configure quality gates | See Step 4 manual setup |
| `quality-gates.sh` | `scripts/quality-gates.sh` | Run all quality checks | Manual test execution |
| `sonar-analysis.sh` | `scripts/sonar-analysis.sh` | Run SonarQube analysis | Manual SonarQube commands |
| `security-scan.sh` | `scripts/security-scan.sh` | Run Trivy security scan | Manual Trivy commands |

### **🚀 Deployment Scripts**
| Script | Location | Purpose | Manual Alternative |
|--------|----------|---------|-------------------|
| `create-eks-cluster.sh` | `scripts/deployment/create-eks-cluster.sh` | Create multi-env EKS cluster | See Step 6 manual eksctl commands |
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

## **🎉 Success Indicators**

### **✅ Deployment Success Checklist**
- [ ] **All tools installed** - AWS CLI, kubectl, eksctl, Docker, GitHub CLI, Node.js
- [ ] **GitHub repository configured** - Repository created with proper secrets
- [ ] **Testing infrastructure ready** - Jest and Selenium configured
- [ ] **Quality gates configured** - SonarQube and Trivy set up
- [ ] **CI/CD pipeline active** - GitHub Actions workflow running
- [ ] **EKS cluster created** - Multi-environment cluster with 3 namespaces
- [ ] **Applications deployed** - All environments have running applications
- [ ] **Pipeline successful** - Full CI/CD pipeline completes successfully

### **🎯 Key Success Metrics**
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

**Guide Version**: 2.0
**Last Updated**: August 6, 2025
**Estimated Time**: 105-135 minutes
**Success Rate**: 95%+ when prerequisites are met
**Independence**: Complete standalone deployment (no Stage-1 dependency)

**🎉 Congratulations! You've successfully deployed a complete automated CI/CD pipeline with multi-environment support!**
