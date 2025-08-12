# 🔍 **Troubleshooting Guide - Issue Resolution**

## 📖 **Issue Index**

### 🚨 **Critical Issues**
- [Pipeline Failures](#pipeline-failures) - GitHub Actions workflow issues
- [Frontend-Backend Communication](#frontend-backend-communication) - API connection problems
- [Docker Build Errors](#docker-build-errors) - Container build failures
- [EKS Deployment Issues](#eks-deployment-issues) - Kubernetes deployment problems

### 🧪 **Testing Issues**
- [Unit Test Failures](#unit-test-failures) - Jest and testing framework issues
- [E2E Test Problems](#e2e-test-problems) - Selenium and browser automation
- [Port Configuration](#port-configuration) - Frontend-backend communication

### 🔧 **Setup Issues**
- [Tool Installation](#tool-installation-issues) - Prerequisites and dependencies
- [GitHub Configuration](#github-configuration-issues) - Authentication and secrets
- [Environment Problems](#environment-problems) - Node.js, npm, Docker issues

### 🛠️ **Quick Fixes**
- [Common Commands](#common-commands) - Essential troubleshooting commands
- [Validation Scripts](#validation-scripts) - Automated problem detection
- [Reset Procedures](#reset-procedures) - Clean slate solutions

---

## 🚨 **Critical Issues**

### **Pipeline Failures**

#### **Issue: GitHub Actions Workflow Not Triggering**
**Symptoms**: No workflow runs appear after pushing code
**Solution**:
```bash
# 1. Check workflow file location
ls -la .github/workflows/

# 2. Validate YAML syntax
cat .github/workflows/stage2-ci.yml | python -c "import yaml, sys; yaml.safe_load(sys.stdin)"

# 3. Check repository permissions
gh repo view --json permissions

# 4. Manually trigger workflow
gh workflow run stage2-ci.yml
```

#### **Issue: Pipeline Fails at Docker Build**
**Symptoms**: "failed to solve: process did not complete successfully"
**Solution**:
```bash
# 1. Check Dockerfile syntax
docker build -f Dockerfile.frontend.k8s -t test-frontend . --no-cache

# 2. Verify package-lock.json files exist
find . -name "package-lock.json" -type f

# 3. Fix missing dependencies
cd src-code && ./setup-environment.sh

# 4. Test build locally
cd src-code/frontend && npm run build
cd ../backend && npm run build
```

#### **Issue: Tests Failing in CI but Passing Locally**
**Symptoms**: Tests pass on local machine but fail in GitHub Actions
**Solution**:
```bash
# 1. Check Node.js version consistency
node --version  # Should match CI version (18.x or 20.x)

# 2. Run tests with CI environment
NODE_ENV=test npm test

# 3. Check for missing environment variables
./validate-port-config.sh

# 4. Increase test timeouts for CI
# In jest.config.js: testTimeout: 30000
```

---

### **Frontend-Backend Communication**

#### **Issue: API Calls Failing with ERR_CONNECTION_REFUSED**
**Symptoms**: Frontend loads but API calls fail
**Root Cause**: Incorrect port configurations or hardcoded URLs
**Solution**:
```bash
# 1. Run port configuration validation
cd src-code && ./validate-port-config.sh

# 2. Check frontend environment configuration
cat frontend/.env.k8s
# Should contain: VITE_API_BASE_URL=/api

# 3. Verify nginx proxy configuration
grep "proxy_pass" nginx/nginx.k8s.conf
# Should show: proxy_pass http://backend;

# 4. Check Kubernetes service configurations
kubectl get services -n healthcare-dev
# frontend-service should expose port 80
# backend-service should expose port 3002

# 5. Test API connectivity from frontend pod
kubectl exec -it <frontend-pod> -n healthcare-dev -- curl http://backend-service:3002/health
```

#### **Issue: Hardcoded localhost URLs**
**Symptoms**: Application works locally but fails in Kubernetes
**Solution**:
```bash
# 1. Search for hardcoded URLs
grep -r "localhost:3000\|localhost:3002" src-code/ --exclude-dir=node_modules

# 2. Fix environment variables
# Frontend: Use VITE_API_BASE_URL=/api
# Backend: Use relative service names

# 3. Update test configurations
# Replace localhost:3000 with localhost:5173
# Replace localhost:3002 with /api for relative URLs

# 4. Validate fixes
./validate-port-config.sh
```

---

### **Docker Build Errors**

#### **Issue: npm ci Fails with Missing package-lock.json**
**Symptoms**: "npm ci can only install with an existing package-lock.json"
**Solution**:
```bash
# 1. Generate missing lock files
cd src-code/frontend && npm install
cd ../backend && npm install

# 2. Verify lock files exist
ls -la frontend/package-lock.json backend/package-lock.json

# 3. Commit lock files
git add frontend/package-lock.json backend/package-lock.json
git commit -m "fix: add missing package-lock.json files"
```

#### **Issue: Build Fails with "command not found"**
**Symptoms**: npm run build fails with exit code 127
**Solution**:
```bash
# 1. Check if dev dependencies are installed
# Dockerfile should use: RUN npm ci (not --only=production)

# 2. Verify build scripts exist
cat frontend/package.json | grep -A 5 '"scripts"'

# 3. Test build locally
cd frontend && npm install && npm run build
```

---

### **EKS Deployment Issues**

#### **Issue: Pods Stuck in Pending State**
**Symptoms**: kubectl get pods shows Pending status
**Solution**:
```bash
# 1. Check node capacity
kubectl describe nodes

# 2. Check pod events
kubectl describe pod <pod-name> -n healthcare-dev

# 3. Check resource requests
kubectl get pods -n healthcare-dev -o yaml | grep -A 5 resources

# 4. Scale cluster if needed
eksctl scale nodegroup --cluster healthcare-cluster-stage2 --name ng-1 --nodes 4
```

#### **Issue: ImagePullBackOff Errors**
**Symptoms**: Pods fail to pull Docker images
**Solution**:
```bash
# 1. Check image names and tags
kubectl describe pod <pod-name> -n healthcare-dev

# 2. Verify images exist in Docker Hub
docker pull routeclouds/healthcare-frontend:v1.0
docker pull routeclouds/healthcare-backend:v1.0

# 3. Check image pull secrets
kubectl get secrets -n healthcare-dev

# 4. Rebuild and push images
./scripts/build-and-push-images.sh
```

---

## 🧪 **Testing Issues**

### **Unit Test Failures**

#### **Issue: Jest Configuration Errors**
**Symptoms**: "Unknown option" or import/export errors
**Solution**:
```bash
# 1. Fix Jest configuration
cd src-code
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

# 2. Install missing dependencies
npm install --save-dev @babel/core @babel/preset-env @babel/preset-react babel-jest

# 3. Test configuration
npm test -- --testPathIgnorePatterns=tests/e2e
```

#### **Issue: Module Resolution Errors**
**Symptoms**: "Cannot resolve module" errors
**Solution**:
```bash
# 1. Check package.json dependencies
cat package.json | grep -A 10 '"dependencies"'

# 2. Reinstall dependencies
rm -rf node_modules package-lock.json
npm install

# 3. Check import paths
# Use relative imports: import './component'
# Not absolute: import 'src/component'
```

---

### **E2E Test Problems**

#### **Issue: WebDriver Connection Refused**
**Symptoms**: "net::ERR_CONNECTION_REFUSED" in E2E tests
**Solution**:
```bash
# 1. This is expected if application isn't running
# E2E tests require running application

# 2. Start application for testing
npm run dev  # In another terminal

# 3. Update test URLs to correct ports
# Use localhost:5173 for frontend (not localhost:3000)

# 4. Run E2E tests
npm run test:e2e
```

#### **Issue: Browser Automation Fails**
**Symptoms**: Selenium WebDriver errors
**Solution**:
```bash
# 1. Install Chrome browser
sudo apt-get update
sudo apt-get install -y google-chrome-stable

# 2. Update ChromeDriver
npm install --save-dev chromedriver

# 3. Use headless mode in CI
# In test config: options.addArguments('--headless')
```

---

### **Port Configuration**

#### **Issue: Frontend-Backend Communication Fails**
**Symptoms**: API calls return 404 or connection errors
**Solution**:
```bash
# 1. Run comprehensive port validation
./validate-port-config.sh

# 2. Check nginx configuration
cat nginx/nginx.k8s.conf | grep proxy_pass

# 3. Verify service configurations
kubectl get services -n healthcare-dev

# 4. Test service connectivity
kubectl exec -it <frontend-pod> -n healthcare-dev -- curl http://backend-service:3002/health
```

---

## 🔧 **Setup Issues**

### **Tool Installation Issues**

#### **Issue: Node.js Version Incompatibility**
**Symptoms**: "npm WARN EBADENGINE Unsupported engine"
**Solution**:
```bash
# 1. Install Node.js 20 LTS
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# 2. Verify version
node --version  # Should show v20.x.x

# 3. Clear npm cache
npm cache clean --force
```

#### **Issue: Docker Permission Denied**
**Symptoms**: "permission denied while trying to connect to Docker daemon"
**Solution**:
```bash
# 1. Add user to docker group
sudo usermod -aG docker $USER

# 2. Restart session
newgrp docker

# 3. Test Docker access
docker run hello-world
```

---

### **GitHub Configuration Issues**

#### **Issue: GitHub CLI Authentication Fails**
**Symptoms**: "authentication required" errors
**Solution**:
```bash
# 1. Login to GitHub CLI
gh auth login

# 2. Select correct options:
# - GitHub.com
# - HTTPS
# - Yes (authenticate Git)
# - Login with web browser

# 3. Verify authentication
gh auth status
```

#### **Issue: Branch Protection Setup Fails**
**Symptoms**: "422 Unprocessable Entity" errors
**Solution**:
```bash
# 1. Ensure main branch exists
git checkout -b main
git push -u origin main

# 2. Check repository permissions
gh api repos/:owner/:repo --jq '.permissions'

# 3. Retry branch protection setup
./scripts/setup-branch-protection.sh
```

---

## 🛠️ **Quick Fixes**

### **Common Commands**

#### **Reset Everything**
```bash
# Complete environment reset
cd src-code
rm -rf node_modules frontend/node_modules backend/node_modules
rm -rf package-lock.json frontend/package-lock.json backend/package-lock.json
./setup-environment.sh
```

#### **Restart Services**
```bash
# Restart all pods
kubectl rollout restart deployment/frontend-deployment -n healthcare-dev
kubectl rollout restart deployment/backend-deployment -n healthcare-dev

# Check status
kubectl rollout status deployment/frontend-deployment -n healthcare-dev
```

#### **Check Pipeline Status**
```bash
# Monitor current run
gh run watch

# List recent runs
gh run list --limit 5

# View specific run
gh run view <run-id>
```

---

### **Validation Scripts**

#### **Run All Validations**
```bash
# Complete system validation
./scripts/validate-stage2-setup.sh

# Source code validation
cd src-code
./validate-setup.sh
./validate-port-config.sh

# Infrastructure validation
kubectl get nodes
kubectl get pods --all-namespaces
```

#### **Specific Validations**
```bash
# Test validation
npm test -- --testPathIgnorePatterns=tests/e2e

# Build validation
npm run build

# Configuration validation
./scripts/validate-configs.js
```

---

### **Reset Procedures**

#### **Clean Slate Reset**
```bash
# 1. Reset source code
cd src-code
rm -rf node_modules frontend/node_modules backend/node_modules
./setup-environment.sh

# 2. Reset EKS cluster
eksctl delete cluster --name healthcare-cluster-stage2 --region us-east-1
./scripts/deployment/create-eks-cluster.sh

# 3. Reset GitHub configuration
./scripts/setup-branch-protection.sh

# 4. Validate everything
./scripts/validate-stage2-setup.sh
```

---

## 📞 **Getting Help**

### **Escalation Path**
1. **First**: Run validation scripts to identify issues
2. **Second**: Check this troubleshooting guide
3. **Third**: Review [Master Setup Guide](MASTER-SETUP-GUIDE.md)
4. **Fourth**: Check [Operations Guide](OPERATIONS.md)

### **Diagnostic Information to Collect**
```bash
# System information
uname -a
node --version
npm --version
docker --version

# Project status
./scripts/validate-stage2-setup.sh
kubectl get pods --all-namespaces
gh run list --limit 3

# Error logs
kubectl logs -f deployment/frontend-deployment -n healthcare-dev
kubectl logs -f deployment/backend-deployment -n healthcare-dev
```

---

**🎯 Most issues can be resolved by running the validation scripts and following the specific solutions above.**

**📞 Support**: For complex issues, collect diagnostic information and review the [Master Setup Guide](MASTER-SETUP-GUIDE.md).
