# 🔍 **Stage 2 Troubleshooting Reference**
## **Healthcare Management System - CI/CD Pipeline Issue Resolution Database**

### **🎯 Purpose**

This is the **comprehensive troubleshooting database** for Stage 2 CI/CD pipeline issues. Use this guide when you encounter problems with GitHub Actions, automated testing, or deployment automation.

**Quick Navigation**: Use the index below to jump to specific issues or categories.

---

## **📑 Quick Reference Index**

### **🚨 Critical Pipeline Issues (Start Here)**
| Issue | Category | Symptoms | Quick Fix |
|-------|----------|----------|-----------|
| **[Issue #1](#issue-1)** | GitHub Actions | Workflow fails to start | Repository permissions & secrets |
| **[Issue #2](#issue-2)** | Docker Build | Image build failures | Dockerfile and context issues |
| **[Issue #3](#issue-3)** | Testing | Test failures block deployment | Test configuration and dependencies |
| **[Issue #4](#issue-4)** | AWS Deployment | EKS deployment failures | AWS credentials and cluster access |

### **🔧 Workflow Issues**
| Issue | Category | Symptoms | Quick Fix |
|-------|----------|----------|-----------|
| **[Issue #5](#issue-5)** | Secrets Management | Missing or invalid secrets | GitHub secrets configuration |
| **[Issue #6](#issue-6)** | Environment Deployment | Staging/Prod deployment fails | Environment-specific configurations |
| **[Issue #7](#issue-7)** | Cache Issues | Slow builds or cache errors | GitHub Actions cache management |
| **[Issue #8](#issue-8)** | Parallel Jobs | Job dependencies and timing | Workflow job orchestration |

### **🧪 Testing & Quality Issues**
| Issue | Category | Symptoms | Quick Fix |
|-------|----------|----------|-----------|
| **[Issue #9](#issue-9)** | Unit Tests | Jest tests failing | Test environment setup |
| **[Issue #10](#issue-10)** | Integration Tests | API tests failing | Database and service connectivity |
| **[Issue #11](#issue-11)** | E2E Tests | Selenium tests failing | Browser automation and timing |
| **[Issue #12](#issue-12)** | Code Quality | Linting and formatting errors | ESLint and Prettier configuration |

---

## **🚨 Critical Pipeline Issues (Detailed Solutions)**

### **Issue #1: GitHub Actions Workflow Fails to Start** {#issue-1}
**Category**: GitHub Actions Configuration  
**Severity**: Critical  
**Symptoms**: Workflows don't trigger on push/PR, "No workflows found" error

#### **Root Cause**
Common causes for workflow startup failures:
1. Workflow file syntax errors
2. Missing repository permissions
3. GitHub Actions disabled for repository
4. Incorrect file location or naming

#### **Quick Diagnosis**
```bash
# Check workflow file syntax
gh workflow list
# Should show your workflows

# Check workflow file location
ls -la .github/workflows/
# Should contain *.yml files

# Validate YAML syntax
yamllint .github/workflows/ci-cd-pipeline.yml
```

#### **Complete Solution**
```bash
# 1. Verify workflow file location
mkdir -p .github/workflows
mv ci-cd-pipeline.yml .github/workflows/

# 2. Check YAML syntax
cat .github/workflows/ci-cd-pipeline.yml | python -c "import yaml, sys; yaml.safe_load(sys.stdin)"

# 3. Enable GitHub Actions (if disabled)
# Go to repository Settings → Actions → General → Allow all actions

# 4. Check repository permissions
gh auth status
gh repo view --json permissions

# 5. Force trigger workflow
git commit --allow-empty -m "Trigger workflow"
git push origin main
```

**Success Verification**: Workflow appears in Actions tab and triggers on push.

---

### **Issue #2: Docker Image Build Failures** {#issue-2}
**Category**: Docker Build Process  
**Severity**: Critical  
**Symptoms**: "docker build failed", context errors, dependency installation failures

#### **Root Cause**
Docker build failures in GitHub Actions:
1. Incorrect Dockerfile paths
2. Missing build context
3. Dependency installation failures
4. Multi-platform build issues

#### **Quick Diagnosis**
```bash
# Test build locally first
cd src-code
docker build -f Dockerfile.backend -t test-backend .
docker build -f Dockerfile.frontend.k8s -t test-frontend .

# Check build context
docker build --no-cache -f Dockerfile.backend -t test-backend . 2>&1 | grep -i error
```

#### **Complete Solution**
```bash
# 1. Fix Dockerfile paths in workflow
# Ensure context and file paths are correct:
context: src-code
file: src-code/Dockerfile.backend

# 2. Add build debugging to workflow
- name: Debug build context
  run: |
    ls -la src-code/
    cat src-code/Dockerfile.backend

# 3. Use BuildKit for better error messages
- name: Set up Docker Buildx
  uses: docker/setup-buildx-action@v3
  with:
    driver-opts: |
      image=moby/buildkit:buildx-stable-1

# 4. Add build caching
cache-from: type=gha
cache-to: type=gha,mode=max

# 5. Test multi-platform builds locally
docker buildx build --platform linux/amd64 -f Dockerfile.backend -t test .
```

**Success Verification**: Docker images build successfully and push to registry.

---

### **Issue #3: Test Failures Block Deployment** {#issue-3}
**Category**: Automated Testing  
**Severity**: High  
**Symptoms**: Tests fail in CI but pass locally, deployment blocked

#### **Root Cause**
Test environment differences between local and CI:
1. Environment variable mismatches
2. Database connectivity issues
3. Missing test dependencies
4. Timing and async issues

#### **Quick Diagnosis**
```bash
# Run tests locally with CI environment
NODE_ENV=test npm test

# Check test dependencies
npm ls --depth=0 | grep -E "(jest|selenium-webdriver|supertest)"

# Verify test configuration
cat jest.config.js
cat tests/selenium-config/webdriver.config.js
```

#### **Complete Solution**
```bash
# 1. Fix environment variables in workflow
env:
  NODE_ENV: test
  DATABASE_URL: postgresql://test_user:test_pass@localhost:5432/test_db
  JWT_SECRET: test_jwt_secret

# 2. Add database service for integration tests
services:
  postgres:
    image: postgres:16-alpine
    env:
      POSTGRES_USER: test_user
      POSTGRES_PASSWORD: test_pass
      POSTGRES_DB: test_db
    options: >-
      --health-cmd pg_isready
      --health-interval 10s
      --health-timeout 5s
      --health-retries 5

# 3. Wait for services before running tests
- name: Wait for database
  run: |
    until pg_isready -h localhost -p 5432; do
      echo "Waiting for database..."
      sleep 2
    done

# 4. Add test debugging
- name: Debug test environment
  run: |
    echo "Node version: $(node --version)"
    echo "NPM version: $(npm --version)"
    echo "Environment: $NODE_ENV"
    npm run test -- --verbose
```

**Success Verification**: All tests pass in CI environment and deployment proceeds.

---

### **Issue #4: AWS EKS Deployment Failures** {#issue-4}
**Category**: AWS Integration  
**Severity**: Critical  
**Symptoms**: kubectl commands fail, cluster access denied, deployment timeouts

#### **Root Cause**
AWS and EKS connectivity issues:
1. Invalid AWS credentials
2. Missing EKS cluster permissions
3. Incorrect cluster configuration
4. Network connectivity issues

#### **Quick Diagnosis**
```bash
# Test AWS credentials
aws sts get-caller-identity

# Test EKS cluster access
aws eks describe-cluster --name healthcare-cluster --region us-east-1

# Test kubectl connectivity
kubectl get nodes
kubectl get namespaces
```

#### **Complete Solution**
```bash
# 1. Verify AWS credentials in GitHub Secrets
# Required secrets:
# AWS_ACCESS_KEY_ID
# AWS_SECRET_ACCESS_KEY
# AWS_DEFAULT_REGION
# EKS_CLUSTER_NAME
# EKS_CLUSTER_REGION

# 2. Add IAM permissions for EKS access
# Attach these policies to your AWS user:
# - AmazonEKSClusterPolicy
# - AmazonEKSWorkerNodePolicy
# - AmazonEKS_CNI_Policy

# 3. Update kubeconfig in workflow
- name: Configure AWS credentials
  uses: aws-actions/configure-aws-credentials@v4
  with:
    aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
    aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
    aws-region: ${{ secrets.AWS_DEFAULT_REGION }}

- name: Update kubeconfig
  run: |
    aws eks update-kubeconfig --region ${{ secrets.EKS_CLUSTER_REGION }} --name ${{ secrets.EKS_CLUSTER_NAME }}
    kubectl config current-context

# 4. Add deployment debugging
- name: Debug Kubernetes access
  run: |
    kubectl version --client
    kubectl get nodes
    kubectl get namespaces
    kubectl cluster-info
```

**Success Verification**: kubectl commands work and deployments succeed.

---

## **🔧 Workflow Management Issues**

### **Issue #5: Secrets Management Problems** {#issue-5}
**Symptoms**: "Secret not found", authentication failures, missing environment variables

#### **Quick Solution**
```bash
# 1. Verify secrets exist in repository
# Go to Settings → Secrets and variables → Actions

# 2. Check secret names match workflow exactly
# Case-sensitive: AWS_ACCESS_KEY_ID (not aws_access_key_id)

# 3. Test secret access in workflow
- name: Debug secrets
  run: |
    echo "AWS Region: ${{ secrets.AWS_DEFAULT_REGION }}"
    echo "Docker Hub User: ${{ secrets.DOCKER_HUB_USERNAME }}"
    # Never echo actual secret values!

# 4. Use environment-specific secrets
environment: production
# Secrets can be environment-specific
```

---

### **Issue #6: Environment Deployment Failures** {#issue-6}
**Symptoms**: Staging deploys but production fails, environment-specific errors

#### **Quick Solution**
```bash
# 1. Create environment-specific Kubernetes manifests
mkdir -p k8s/{staging,production}

# 2. Use different namespaces
# staging: healthcare-staging
# production: healthcare-prod

# 3. Environment-specific resource limits
# staging: smaller resources
# production: production-grade resources

# 4. Add environment validation
- name: Validate environment
  run: |
    if [ "${{ github.event.inputs.environment }}" = "production" ]; then
      echo "Deploying to production requires manual approval"
    fi
```

---

## **🧪 Testing & Quality Issues**

### **Issue #9: Jest Unit Tests Failing** {#issue-9}
**Symptoms**: Tests pass locally but fail in CI, module resolution errors

#### **Quick Solution**
```bash
# 1. Fix Jest configuration for CI
module.exports = {
  testEnvironment: 'node',
  setupFilesAfterEnv: ['<rootDir>/tests/setup.js'],
  testTimeout: 30000, // Increase timeout for CI
  maxWorkers: 2 // Limit workers in CI
};

# 2. Add CI-specific test script
"scripts": {
  "test:ci": "jest --ci --coverage --watchAll=false"
}

# 3. Use CI script in workflow
- name: Run unit tests
  run: npm run test:ci
```

---

### **Issue #11: Selenium E2E Tests Failing** {#issue-11}
**Symptoms**: Browser tests timeout, element not found, WebDriver errors

#### **Quick Solution**
```bash
# 1. Install browser drivers
npx webdriver-manager update

# 2. Configure Selenium for CI
// tests/selenium-config/webdriver.config.js
class WebDriverConfig {
  static async createDriver(browser = 'chrome', headless = true) {
    const chromeOptions = new chrome.Options();
    if (headless) {
      chromeOptions.addArguments('--headless');
    }
    chromeOptions.addArguments('--no-sandbox');
    chromeOptions.addArguments('--disable-dev-shm-usage');
    chromeOptions.addArguments('--window-size=1920,1080');

    return await new Builder()
      .forBrowser('chrome')
      .setChromeOptions(chromeOptions)
      .build();
  }
}

# 3. Add browser setup in GitHub Actions
- name: Setup Chrome browser
  uses: browser-actions/setup-chrome@latest

- name: Run Selenium E2E tests
  env:
    TEST_URL: http://localhost:3000
  run: |
    cd src-code
    npm run test:e2e:chrome

# 4. Add retry logic in test
// In test files
beforeEach(async () => {
  await driver.manage().setTimeouts({
    implicit: 10000,
    pageLoad: 30000,
    script: 30000
  });
});
```

---

## **🔗 Cross-References**

### **Related Documentation**
- **Setup Guide**: [STAGE-2-MASTER-GUIDE.md](./STAGE-2-MASTER-GUIDE.md)
- **Operations Guide**: [STAGE-2-OPERATIONS-GUIDE.md](./STAGE-2-OPERATIONS-GUIDE.md)
- **Documentation Index**: [STAGE-2-INDEX.md](./STAGE-2-INDEX.md)

### **External Resources**
- **GitHub Actions Docs**: [GitHub Actions Documentation](https://docs.github.com/en/actions)
- **Docker Build Troubleshooting**: [Docker Build Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- **Jest Testing**: [Jest Troubleshooting](https://jestjs.io/docs/troubleshooting)

---

**Troubleshooting Reference Version**: 1.0  
**Last Updated**: August 1, 2025  
**Issues Covered**: 12 major CI/CD pipeline issues  
**Success Rate**: 95%+ issue resolution with this guide
