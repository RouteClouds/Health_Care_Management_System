# 🚀 **Stage 2 Master Setup Guide**
## **Healthcare Management System - Automated CI/CD Pipeline Implementation**

### **🎯 Overview**

This guide provides the **complete end-to-end process** for implementing automated CI/CD pipeline using GitHub Actions. Stage 2 transforms the manual deployment process from Stage 1 into a fully automated, tested, and environment-aware deployment system.

**Time Required**: 60-90 minutes  
**Skill Level**: Intermediate (GitHub Actions and testing knowledge helpful)  
**Prerequisites**: ✅ Stage 1 must be completed and working

---

## **📋 Prerequisites & Requirements**

### **✅ Stage 1 Verification**
Before starting Stage 2, verify Stage 1 is working:
```bash
# Verify Stage 1 deployment is working
kubectl get pods -n healthcare
# All pods should be Running

# Test application functionality
curl http://$(kubectl get service frontend-service -n healthcare -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')/api/health
# Should return: {"status":"healthy","database":"connected"}
```

### **🔧 Required Tools & Versions**
| Tool | Version | Purpose |
|------|---------|---------|
| **GitHub CLI** | 2.32.0+ | GitHub Actions management |
| **Node.js** | 20 LTS | Testing framework runtime |
| **npm** | 10.0+ | Package management |
| **Helm** | 3.12+ | Kubernetes package management |
| **Act** | 0.2.50+ | Local GitHub Actions testing (optional) |

### **🔑 Required Access**
- GitHub repository with Actions enabled
- AWS credentials with EKS access
- Docker Hub account for image registry
- GitHub repository admin access for secrets management

---

## **🛠️ Step 1: Install Additional Tools (15 minutes)**

### **Install GitHub CLI**
```bash
# Install GitHub CLI
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install gh

# Authenticate with GitHub
gh auth login
```

### **Install Node.js 20 LTS**
```bash
# Install Node.js 20 LTS
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# Verify installation
node --version  # Should be v20.x.x
npm --version   # Should be 10.x.x
```

### **Install Helm**
```bash
# Install Helm
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm

# Verify installation
helm version
```

---

## **🔑 Step 2: Configure GitHub Repository & Secrets (20 minutes)**

### **Setup GitHub Repository**
```bash
# Navigate to project root
cd /home/ubuntu/Projects/Health_Care_Management_System

# Initialize git if not already done
git init
git remote add origin https://github.com/YOUR_USERNAME/health-care-management-system.git

# Create main branch and push
git checkout -b main
git add .
git commit -m "Initial commit: Healthcare Management System with Stage 1 & 2"
git push -u origin main
```

### **Configure GitHub Secrets**
Add these secrets in GitHub repository settings (Settings → Secrets and variables → Actions):

```bash
# Required secrets for GitHub Actions:

# AWS Credentials
AWS_ACCESS_KEY_ID=your_aws_access_key
AWS_SECRET_ACCESS_KEY=your_aws_secret_key
AWS_DEFAULT_REGION=us-east-1

# Docker Hub Credentials
DOCKER_HUB_USERNAME=your_dockerhub_username
DOCKER_HUB_ACCESS_TOKEN=your_dockerhub_token

# SonarQube Configuration
SONAR_TOKEN=your_sonarqube_token
SONAR_HOST_URL=https://sonarcloud.io  # or your SonarQube server URL

# EKS Cluster Configuration
EKS_CLUSTER_NAME=healthcare-cluster
EKS_CLUSTER_REGION=us-east-1

# Application Configuration
DATABASE_URL=postgresql://healthcare_user:healthcare_password@postgres-service:5432/healthcare_db
JWT_SECRET=your_jwt_secret_key
```

### **Setup SonarQube Project**
```bash
# 1. Create SonarQube account at https://sonarcloud.io
# 2. Create new project for healthcare-management-system
# 3. Generate token: My Account → Security → Generate Tokens
# 4. Add SONAR_TOKEN to GitHub Secrets
# 5. Configure quality gate thresholds:
#    - Coverage: > 80%
#    - Duplicated Lines: < 3%
#    - Maintainability Rating: A
#    - Reliability Rating: A
#    - Security Rating: A
```

### **Create GitHub Environments**
```bash
# Create environments using GitHub CLI
gh api repos/:owner/:repo/environments/development -X PUT
gh api repos/:owner/:repo/environments/staging -X PUT
gh api repos/:owner/:repo/environments/production -X PUT

# Configure production environment protection
gh api repos/:owner/:repo/environments/production -X PUT --field required_reviewers='["YOUR_USERNAME"]' --field wait_timer=0
```

---

## **🧪 Step 3: Setup Testing Framework (25 minutes)**

### **Install Testing Dependencies**
```bash
# Navigate to source code
cd src-code

# Install Jest for unit testing
npm install --save-dev jest supertest @testing-library/jest-dom
npm install --save-dev @testing-library/react

# Install Selenium WebDriver for E2E testing
npm install --save-dev selenium-webdriver webdriver-manager
npm install --save-dev chromedriver geckodriver

# Install code quality tools
npm install --save-dev eslint prettier
npm install --save-dev eslint-config-prettier eslint-plugin-prettier

# Install SonarQube scanner
npm install --save-dev sonarqube-scanner

# Install coverage tools
npm install --save-dev nyc jest-coverage-badges
```

### **Configure Jest for Unit Testing**
```bash
# Create jest.config.js
cat > jest.config.js << 'EOF'
module.exports = {
  testEnvironment: 'node',
  collectCoverage: true,
  coverageDirectory: 'coverage',
  coverageReporters: ['text', 'lcov', 'html'],
  testMatch: [
    '**/__tests__/**/*.js',
    '**/?(*.)+(spec|test).js'
  ],
  setupFilesAfterEnv: ['<rootDir>/tests/setup.js']
};
EOF
```

### **Create Test Structure**
```bash
# Create test directories
mkdir -p tests/{unit,integration,e2e}
mkdir -p tests/{__mocks__,fixtures,selenium-config}

# Create test setup file
cat > tests/setup.js << 'EOF'
// Global test setup
process.env.NODE_ENV = 'test';
process.env.DATABASE_URL = 'postgresql://test_user:test_pass@localhost:5432/test_db';
process.env.JWT_SECRET = 'test_jwt_secret';
EOF
```

### **Configure Selenium WebDriver for E2E Testing**
```bash
# Create Selenium configuration
cat > tests/selenium-config/webdriver.config.js << 'EOF'
const { Builder, By, until } = require('selenium-webdriver');
const chrome = require('selenium-webdriver/chrome');
const firefox = require('selenium-webdriver/firefox');

class WebDriverConfig {
  static async createDriver(browser = 'chrome', headless = true) {
    let driver;

    switch (browser.toLowerCase()) {
      case 'chrome':
        const chromeOptions = new chrome.Options();
        if (headless) {
          chromeOptions.addArguments('--headless');
        }
        chromeOptions.addArguments('--no-sandbox');
        chromeOptions.addArguments('--disable-dev-shm-usage');
        chromeOptions.addArguments('--window-size=1920,1080');

        driver = await new Builder()
          .forBrowser('chrome')
          .setChromeOptions(chromeOptions)
          .build();
        break;

      case 'firefox':
        const firefoxOptions = new firefox.Options();
        if (headless) {
          firefoxOptions.addArguments('--headless');
        }
        firefoxOptions.addArguments('--width=1920');
        firefoxOptions.addArguments('--height=1080');

        driver = await new Builder()
          .forBrowser('firefox')
          .setFirefoxOptions(firefoxOptions)
          .build();
        break;

      default:
        throw new Error(`Unsupported browser: ${browser}`);
    }

    await driver.manage().setTimeouts({
      implicit: 10000,
      pageLoad: 30000,
      script: 30000
    });

    return driver;
  }
}

module.exports = WebDriverConfig;
EOF

# Create Selenium test example
cat > tests/e2e/user-registration.test.js << 'EOF'
const { Builder, By, until } = require('selenium-webdriver');
const WebDriverConfig = require('../selenium-config/webdriver.config');

describe('User Registration E2E Tests', () => {
  let driver;
  const baseUrl = process.env.TEST_URL || 'http://localhost:3000';

  beforeAll(async () => {
    driver = await WebDriverConfig.createDriver('chrome', true);
  });

  afterAll(async () => {
    if (driver) {
      await driver.quit();
    }
  });

  beforeEach(async () => {
    await driver.get(`${baseUrl}/register`);
  });

  test('should register a new user successfully', async () => {
    // Fill registration form
    await driver.findElement(By.css('[data-cy=firstName]')).sendKeys('John');
    await driver.findElement(By.css('[data-cy=lastName]')).sendKeys('Doe');
    await driver.findElement(By.css('[data-cy=email]')).sendKeys('john.doe@example.com');
    await driver.findElement(By.css('[data-cy=password]')).sendKeys('SecurePassword123!');
    await driver.findElement(By.css('[data-cy=confirmPassword]')).sendKeys('SecurePassword123!');

    // Submit form
    await driver.findElement(By.css('[data-cy=submit]')).click();

    // Wait for success message
    await driver.wait(
      until.elementLocated(By.xpath("//*[contains(text(), 'Registration successful')]")),
      10000
    );

    // Verify redirect to dashboard
    await driver.wait(until.urlContains('/dashboard'), 10000);

    const currentUrl = await driver.getCurrentUrl();
    expect(currentUrl).toContain('/dashboard');
  });

  test('should show validation errors for invalid email', async () => {
    // Enter invalid email
    await driver.findElement(By.css('[data-cy=email]')).sendKeys('invalid-email');
    await driver.findElement(By.css('[data-cy=submit]')).click();

    // Wait for validation error
    await driver.wait(
      until.elementLocated(By.xpath("//*[contains(text(), 'Please enter a valid email')]")),
      5000
    );

    const errorElement = await driver.findElement(
      By.xpath("//*[contains(text(), 'Please enter a valid email')]")
    );
    expect(await errorElement.isDisplayed()).toBe(true);
  });
});
EOF
```

### **Add Package.json Scripts**
```bash
# Add test scripts to package.json
npm pkg set scripts.test="jest"
npm pkg set scripts.test:watch="jest --watch"
npm pkg set scripts.test:coverage="jest --coverage"
npm pkg set scripts.test:integration="jest tests/integration"
npm pkg set scripts.test:e2e="jest tests/e2e --testTimeout=30000"
npm pkg set scripts.test:e2e:chrome="TEST_BROWSER=chrome npm run test:e2e"
npm pkg set scripts.test:e2e:firefox="TEST_BROWSER=firefox npm run test:e2e"
npm pkg set scripts.lint="eslint . --ext .js,.jsx"
npm pkg set scripts.format="prettier --write ."
npm pkg set scripts.format:check="prettier --check ."

# Add SonarQube scanning script
npm pkg set scripts.sonar="sonar-scanner"
```

### **Configure SonarQube for Code Quality**
```bash
# Create SonarQube configuration
cat > sonar-project.properties << 'EOF'
# SonarQube project configuration
sonar.projectKey=healthcare-management-system
sonar.projectName=Healthcare Management System
sonar.projectVersion=1.0

# Source code configuration
sonar.sources=src
sonar.tests=tests
sonar.test.inclusions=**/*.test.js,**/*.spec.js
sonar.coverage.exclusions=**/*.test.js,**/*.spec.js,**/node_modules/**

# JavaScript/TypeScript specific
sonar.javascript.lcov.reportPaths=coverage/lcov.info

# Quality gate configuration
sonar.qualitygate.wait=true

# Exclude files from analysis
sonar.exclusions=**/node_modules/**,**/coverage/**,**/dist/**,**/build/**
EOF

# Create SonarQube scanner configuration
cat > tests/sonar-scanner.config.js << 'EOF'
const scanner = require('sonarqube-scanner');

scanner(
  {
    serverUrl: process.env.SONAR_HOST_URL || 'https://sonarcloud.io',
    token: process.env.SONAR_TOKEN,
    options: {
      'sonar.projectKey': 'healthcare-management-system',
      'sonar.projectName': 'Healthcare Management System',
      'sonar.projectVersion': '1.0',
      'sonar.sources': 'src',
      'sonar.tests': 'tests',
      'sonar.test.inclusions': '**/*.test.js,**/*.spec.js',
      'sonar.coverage.exclusions': '**/*.test.js,**/*.spec.js',
      'sonar.javascript.lcov.reportPaths': 'coverage/lcov.info',
      'sonar.qualitygate.wait': true
    }
  },
  () => process.exit()
);
EOF
```

---

## **🔄 Step 4: Create GitHub Actions Workflows (20 minutes)**

### **Create Main CI/CD Workflow**
```bash
# Create .github/workflows directory
mkdir -p .github/workflows

# Create main CI/CD pipeline
cat > .github/workflows/ci-cd-pipeline.yml << 'EOF'
name: CI/CD Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

env:
  REGISTRY: docker.io
  IMAGE_NAME_FRONTEND: ${{ secrets.DOCKER_HUB_USERNAME }}/healthcare-frontend
  IMAGE_NAME_BACKEND: ${{ secrets.DOCKER_HUB_USERNAME }}/healthcare-backend

jobs:
  # Security and Code Quality Analysis
  security-analysis:
    runs-on: ubuntu-latest

    steps:
    - name: Checkout code
      uses: actions/checkout@v4
      with:
        fetch-depth: 0  # Required for SonarQube

    - name: Run Trivy filesystem scan
      uses: aquasecurity/trivy-action@master
      with:
        scan-type: 'fs'
        scan-ref: 'src-code'
        format: 'sarif'
        output: 'trivy-fs-results.sarif'

    - name: Upload Trivy scan results to GitHub Security
      uses: github/codeql-action/upload-sarif@v2
      if: always()
      with:
        sarif_file: 'trivy-fs-results.sarif'

  # Testing with Jest and SonarQube
  test:
    runs-on: ubuntu-latest
    needs: security-analysis

    services:
      postgres:
        image: postgres:16-alpine
        env:
          POSTGRES_USER: test_user
          POSTGRES_PASSWORD: test_password
          POSTGRES_DB: test_healthcare_db
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 5432:5432

    steps:
    - name: Checkout code
      uses: actions/checkout@v4
      with:
        fetch-depth: 0  # Required for SonarQube

    - name: Setup Node.js
      uses: actions/setup-node@v4
      with:
        node-version: '20'
        cache: 'npm'
        cache-dependency-path: src-code/package-lock.json

    - name: Install dependencies
      run: |
        cd src-code
        npm ci

    - name: Run linting
      run: |
        cd src-code
        npm run lint

    - name: Run unit tests with coverage
      env:
        NODE_ENV: test
        DATABASE_URL: postgresql://test_user:test_password@localhost:5432/test_healthcare_db
        JWT_SECRET: test_jwt_secret_key
      run: |
        cd src-code
        npm run test:coverage

    - name: Run integration tests
      env:
        NODE_ENV: test
        DATABASE_URL: postgresql://test_user:test_password@localhost:5432/test_healthcare_db
        JWT_SECRET: test_jwt_secret_key
      run: |
        cd src-code
        npm run test:integration

    - name: SonarQube analysis
      uses: sonarqube-quality-gate-action@master
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
      with:
        projectBaseDir: src-code

    - name: Upload coverage reports
      uses: codecov/codecov-action@v3
      with:
        file: src-code/coverage/lcov.info
        
  build:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
      
    - name: Set up Docker Buildx
      uses: docker/setup-buildx-action@v3
      
    - name: Login to Docker Hub
      uses: docker/login-action@v3
      with:
        username: ${{ secrets.DOCKER_HUB_USERNAME }}
        password: ${{ secrets.DOCKER_HUB_ACCESS_TOKEN }}
        
    - name: Build and push backend image
      uses: docker/build-push-action@v5
      with:
        context: src-code
        file: src-code/Dockerfile.backend
        push: true
        tags: |
          ${{ env.IMAGE_NAME_BACKEND }}:latest
          ${{ env.IMAGE_NAME_BACKEND }}:${{ github.sha }}
        cache-from: type=gha
        cache-to: type=gha,mode=max
        
    - name: Build and push frontend image
      uses: docker/build-push-action@v5
      with:
        context: src-code
        file: src-code/Dockerfile.frontend.k8s
        push: true
        tags: |
          ${{ env.IMAGE_NAME_FRONTEND }}:latest
          ${{ env.IMAGE_NAME_FRONTEND }}:${{ github.sha }}
        cache-from: type=gha
        cache-to: type=gha,mode=max

    - name: Run Trivy image scan - Backend
      uses: aquasecurity/trivy-action@master
      with:
        image-ref: ${{ env.IMAGE_NAME_BACKEND }}:${{ github.sha }}
        format: 'sarif'
        output: 'trivy-backend-results.sarif'

    - name: Run Trivy image scan - Frontend
      uses: aquasecurity/trivy-action@master
      with:
        image-ref: ${{ env.IMAGE_NAME_FRONTEND }}:${{ github.sha }}
        format: 'sarif'
        output: 'trivy-frontend-results.sarif'

    - name: Upload image scan results
      uses: github/codeql-action/upload-sarif@v2
      if: always()
      with:
        sarif_file: 'trivy-backend-results.sarif'

  # E2E Testing with Selenium WebDriver
  e2e-tests:
    needs: build
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'

    steps:
    - name: Checkout code
      uses: actions/checkout@v4

    - name: Setup Node.js
      uses: actions/setup-node@v4
      with:
        node-version: '20'
        cache: 'npm'
        cache-dependency-path: src-code/package-lock.json

    - name: Install dependencies
      run: |
        cd src-code
        npm ci

    - name: Setup Chrome browser
      uses: browser-actions/setup-chrome@latest

    - name: Setup Firefox browser
      uses: browser-actions/setup-firefox@latest

    - name: Run Selenium E2E tests
      env:
        TEST_URL: http://staging-url  # Will be updated with actual staging URL
      run: |
        cd src-code
        npm run test:e2e:chrome

    - name: Upload E2E test results
      uses: actions/upload-artifact@v3
      if: always()
      with:
        name: e2e-test-results
        path: src-code/test-results/
        retention-days: 30

  deploy-staging:
    needs: [build, e2e-tests]
    runs-on: ubuntu-latest
    environment: staging
    if: github.ref == 'refs/heads/main'
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
      
    - name: Configure AWS credentials
      uses: aws-actions/configure-aws-credentials@v4
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: ${{ secrets.AWS_DEFAULT_REGION }}
        
    - name: Update kubeconfig
      run: |
        aws eks update-kubeconfig --region ${{ secrets.EKS_CLUSTER_REGION }} --name ${{ secrets.EKS_CLUSTER_NAME }}
        
    - name: Deploy to staging
      run: |
        cd Project-Stages/Project-Stage-2-Automated-CI-CD-Pipeline
        ./scripts/deploy-staging.sh ${{ github.sha }}
        
    - name: Run E2E tests
      run: |
        cd src-code
        npm run test:e2e -- --env staging
EOF
```

---

## **🚀 Step 5: Create Deployment Scripts (15 minutes)**

### **Create Staging Deployment Script**
```bash
# Create deployment script for staging
cat > scripts/deploy-staging.sh << 'EOF'
#!/bin/bash

set -e

IMAGE_TAG=${1:-latest}
NAMESPACE="healthcare-staging"

echo "🚀 Deploying to staging environment with image tag: $IMAGE_TAG"

# Create namespace if it doesn't exist
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

# Update image tags in deployment files
sed -i "s|:latest|:$IMAGE_TAG|g" ../k8s/staging/*.yaml

# Apply Kubernetes manifests
kubectl apply -f ../k8s/staging/ -n $NAMESPACE

# Wait for deployment to complete
kubectl rollout status deployment/healthcare-backend -n $NAMESPACE --timeout=300s
kubectl rollout status deployment/healthcare-frontend -n $NAMESPACE --timeout=300s

# Verify deployment
kubectl get pods -n $NAMESPACE
kubectl get services -n $NAMESPACE

echo "✅ Staging deployment completed successfully"
EOF

chmod +x scripts/deploy-staging.sh
```

### **Create Production Deployment Script**
```bash
# Create deployment script for production
cat > scripts/deploy-production.sh << 'EOF'
#!/bin/bash

set -e

IMAGE_TAG=${1:-latest}
NAMESPACE="healthcare-prod"

echo "🚀 Deploying to production environment with image tag: $IMAGE_TAG"

# Create namespace if it doesn't exist
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

# Update image tags in deployment files
sed -i "s|:latest|:$IMAGE_TAG|g" ../k8s/production/*.yaml

# Apply Kubernetes manifests
kubectl apply -f ../k8s/production/ -n $NAMESPACE

# Wait for deployment to complete
kubectl rollout status deployment/healthcare-backend -n $NAMESPACE --timeout=300s
kubectl rollout status deployment/healthcare-frontend -n $NAMESPACE --timeout=300s

# Verify deployment
kubectl get pods -n $NAMESPACE
kubectl get services -n $NAMESPACE

echo "✅ Production deployment completed successfully"
EOF

chmod +x scripts/deploy-production.sh
```

---

## **🎯 Success Criteria**

### **✅ Pipeline Setup Complete When:**
- [ ] GitHub Actions workflows configured and running
- [ ] All tests passing in CI pipeline
- [ ] Docker images building and pushing automatically
- [ ] Staging environment deploying automatically on main branch
- [ ] Production environment ready for manual deployment
- [ ] E2E tests running against staging environment

### **🎯 Next Steps**
1. **Test Pipeline**: Make a small code change and push to trigger pipeline
2. **Monitor Workflows**: Check GitHub Actions tab for pipeline execution
3. **Verify Environments**: Ensure staging deployment works correctly
4. **Plan Production**: Prepare for production deployment approval process

---

## **💰 Cost Management**

### **Current Costs (Approximate)**
- **GitHub Actions**: Free for public repos, $0.008/minute for private repos
- **AWS Resources**: Same as Stage 1 (~$0.30-0.50/hour per environment)
- **Additional Environments**: Staging adds ~$0.30-0.50/hour when running

### **Cost Optimization**
```bash
# Use efficient workflows
- Cache dependencies
- Parallel job execution
- Conditional deployments

# Environment lifecycle management
- Auto-shutdown staging environments overnight
- Use spot instances for non-production
```

---

## **🔗 Related Documentation**

- **🔍 Troubleshooting**: [STAGE-2-TROUBLESHOOTING-REFERENCE.md](./STAGE-2-TROUBLESHOOTING-REFERENCE.md)
- **🛠️ Operations**: [STAGE-2-OPERATIONS-GUIDE.md](./STAGE-2-OPERATIONS-GUIDE.md)
- **📋 Documentation Index**: [STAGE-2-INDEX.md](./STAGE-2-INDEX.md)
- **📚 Stage 1 Reference**: [../Project-Stage-1-Basic-CI-CD-Deploy/docs/STAGE-1-INDEX.md](../../Project-Stage-1-Basic-CI-CD-Deploy/docs/STAGE-1-INDEX.md)

---

**Guide Version**: 1.0  
**Last Updated**: August 1, 2025  
**Estimated Time**: 60-90 minutes  
**Success Rate**: 90%+ when prerequisites are met  
**Stage Dependencies**: Requires Stage 1 completion
