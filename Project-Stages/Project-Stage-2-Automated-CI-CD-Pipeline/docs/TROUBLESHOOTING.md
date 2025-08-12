# 🔍 **Troubleshooting Guide - Issue Resolution**

## 🆕 **Recently Fixed Issues (Latest Update)**

### ✅ **Issues Resolved in Latest Version**
All the following issues have been **FIXED** and are documented here for reference:

1. **[Hardcoded Port Values](#hardcoded-port-values-fixed)** - ✅ RESOLVED
2. **[Docker Image Tag Issues](#docker-image-tag-issues-fixed)** - ✅ RESOLVED
3. **[Database Seeding Problems](#database-seeding-problems-fixed)** - ✅ RESOLVED
4. **[GitHub Actions Pipeline Restrictions](#github-actions-restrictions-fixed)** - ✅ RESOLVED

---

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

#### **Issue: Pods Not Updating Despite Successful Pipeline**
**Symptoms**:
- Pipeline shows "deployment unchanged"
- Old pods remain running for hours
- Code changes not reflected in application

**Root Cause**: Kubernetes doesn't detect changes when using static image tags

**Complete Solution**:
```bash
# 1. Check current pod ages (if > 30 minutes, they're likely stuck)
kubectl get pods -n healthcare -o wide

# 2. Check image tags in use
kubectl get pods -n healthcare -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.containers[0].image}{"\n"}{end}'

# 3. Force immediate pod restart (temporary fix)
kubectl rollout restart deployment/healthcare-frontend -n healthcare
kubectl rollout restart deployment/healthcare-backend -n healthcare

# 4. Wait for rollout
kubectl rollout status deployment/healthcare-frontend -n healthcare --timeout=300s
kubectl rollout status deployment/healthcare-backend -n healthcare --timeout=300s

# 5. Verify new pods are running
kubectl get pods -n healthcare -o wide
```

**Permanent Fix Applied**:
- ✅ Kubernetes manifests now use `latest` tag with `imagePullPolicy: Always`
- ✅ CI/CD pipeline adds restart annotations to force pod recreation
- ✅ Automatic rollout restart ensures new images are always pulled
- ✅ No manual intervention required for future deployments

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

## 🔄 **Deployment Update Troubleshooting - Complete Guide**

### **Problem: Pods Not Updating After Code Changes**

This is a common issue where the CI/CD pipeline completes successfully but pods remain unchanged.

#### **Step 1: Identify the Problem**
```bash
# Check pod ages (if > 30 minutes after pipeline, they're stuck)
kubectl get pods -n healthcare -o wide

# Check pipeline status
gh run list --limit 3

# Look for "deployment unchanged" in pipeline logs
gh run view <run-id> --log | grep -i "unchanged\|rollout"
```

#### **Step 2: Immediate Diagnosis**
```bash
# Check what images pods are actually using
kubectl get pods -n healthcare -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.containers[0].image}{"\n"}{end}' | column -t

# Check deployment image configuration
kubectl get deployment healthcare-frontend -n healthcare -o yaml | grep -A 2 "image:"
kubectl get deployment healthcare-backend -n healthcare -o yaml | grep -A 2 "image:"

# Check if imagePullPolicy is set correctly
kubectl get deployment healthcare-frontend -n healthcare -o yaml | grep -A 1 "imagePullPolicy"
```

#### **Step 3: Immediate Fix (Manual)**
```bash
# Force restart all deployments
kubectl rollout restart deployment/healthcare-frontend -n healthcare
kubectl rollout restart deployment/healthcare-backend -n healthcare

# Wait for completion
kubectl rollout status deployment/healthcare-frontend -n healthcare --timeout=300s
kubectl rollout status deployment/healthcare-backend -n healthcare --timeout=300s

# Verify new pods
kubectl get pods -n healthcare -o wide
```

#### **Step 4: Verify Fix Applied**
```bash
# Check pod ages (should be < 5 minutes)
kubectl get pods -n healthcare -o wide

# Test application
FRONTEND_URL=$(kubectl get service frontend-service -n healthcare -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
curl -I http://${FRONTEND_URL}
curl -I http://${FRONTEND_URL}/api/health

# Check logs for any issues
kubectl logs deployment/healthcare-frontend -n healthcare --tail=10
kubectl logs deployment/healthcare-backend -n healthcare --tail=10
```

### **Permanent Solution Implemented**

The following changes ensure this issue never happens again:

#### **1. Kubernetes Manifests Updated**
```yaml
# frontend-deployment.yaml and backend-deployment.yaml now use:
image: routeclouds/healthcare-frontend:latest
imagePullPolicy: Always  # Forces image pull on every deployment
```

#### **2. CI/CD Pipeline Enhanced**
```yaml
# Pipeline now includes automatic restart annotations:
kubectl patch deployment healthcare-frontend -n healthcare -p '{"spec":{"template":{"metadata":{"annotations":{"kubectl.kubernetes.io/restartedAt":"'$(date +%s)'"}}}}}'
```

#### **3. Verification Process**
Every pipeline run now:
- ✅ Builds and pushes images with `latest` tag
- ✅ Applies manifests with `imagePullPolicy: Always`
- ✅ Adds restart annotations to force pod recreation
- ✅ Waits for rollout completion
- ✅ Verifies all pods are running with new images

### **Why This Solution Works**

1. **`latest` Tag**: Always references the most recent image
2. **`imagePullPolicy: Always`**: Forces Kubernetes to pull the image every time
3. **Restart Annotations**: Guarantees pod recreation even with same image tag
4. **Automatic Process**: No manual intervention required

### **Monitoring Deployment Success**

```bash
# Watch deployments in real-time
kubectl get pods -n healthcare -w

# Check deployment history
kubectl rollout history deployment/healthcare-frontend -n healthcare
kubectl rollout history deployment/healthcare-backend -n healthcare

# Verify image pull events
kubectl get events -n healthcare --sort-by='.lastTimestamp' | grep -i "pull"
```

### **Common Deployment Patterns**

```bash
# Pattern 1: Check if deployment is progressing
kubectl get deployment healthcare-frontend -n healthcare -o wide

# Pattern 2: Check replica set status
kubectl get rs -n healthcare

# Pattern 3: Check pod events for issues
kubectl describe pod <pod-name> -n healthcare

# Pattern 4: Force image pull verification
kubectl get pods -n healthcare -o yaml | grep -A 5 "imagePullPolicy"
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

---

## 🆕 **Recently Fixed Issues - Detailed Documentation**

### **Hardcoded Port Values (FIXED)**

#### **Issue Description**
The frontend was hardcoded to use port 5173, causing deployment failures in different environments.

#### **Symptoms**
- Frontend fails to start in Docker containers
- Port conflicts in Kubernetes deployments
- "EADDRINUSE" errors in logs

#### **Root Cause**
Hardcoded port in `vite.config.ts`:
```typescript
// PROBLEMATIC CODE (FIXED)
server: {
  port: 5173,  // Hardcoded port
  host: true
}
```

#### **Solution Applied**
**File:** `Project-Stages/Project-Stage-2-Automated-CI-CD-Pipeline/src-code/frontend/vite.config.ts`
```typescript
// FIXED CODE
export default defineConfig({
  plugins: [react()],
  optimizeDeps: {
    exclude: ['lucide-react'],
  },
  // Removed hardcoded port - now uses environment variable or default
});
```

#### **Verification**
```bash
# Check frontend configuration
cat Project-Stages/Project-Stage-2-Automated-CI-CD-Pipeline/src-code/frontend/vite.config.ts

# Should NOT contain hardcoded port values
```

---

### **Docker Image Tag Issues (FIXED)**

#### **Issue Description**
Kubernetes deployments were using hardcoded version tags (v1.0), preventing automatic updates when new images were built.

#### **Symptoms**
- New pipeline builds don't trigger pod updates
- Pods continue running old code after successful deployments
- Manual pod restarts required after each deployment

#### **Root Cause**
Hardcoded image tags in Kubernetes manifests:
```yaml
# PROBLEMATIC CODE (FIXED)
image: routeclouds/healthcare-backend:v1.0  # Static tag
imagePullPolicy: IfNotPresent  # Doesn't pull latest
```

#### **Solution Applied**
**Files:**
- `Project-Stages/Project-Stage-2-Automated-CI-CD-Pipeline/k8s/backend-deployment.yaml`
- `Project-Stages/Project-Stage-2-Automated-CI-CD-Pipeline/k8s/frontend-deployment.yaml`

```yaml
# FIXED CODE
image: routeclouds/healthcare-backend:latest  # Dynamic latest tag
imagePullPolicy: Always  # Always pull latest image
```

#### **Benefits**
- ✅ Automatic pod updates on new deployments
- ✅ Zero manual intervention required
- ✅ Always runs latest code version
- ✅ Proper CI/CD automation

#### **Verification**
```bash
# Check deployment configurations
grep -r "image.*latest" Project-Stages/Project-Stage-2-Automated-CI-CD-Pipeline/k8s/
grep -r "imagePullPolicy.*Always" Project-Stages/Project-Stage-2-Automated-CI-CD-Pipeline/k8s/

# Verify pods are using latest images
kubectl describe pod -n healthcare | grep -A 2 "Image:"
```

---

### **Database Seeding Problems (FIXED)**

#### **Issue Description**
Database was not being seeded with sample data, causing "Find a Doctor" page to show empty results.

#### **Symptoms**
- Empty doctor listings in frontend
- API returns `"Found 0 doctors"`
- No departments or sample data available
- New users see empty application

#### **Root Cause**
1. Init container script path issues
2. Missing fallback seeding mechanism
3. Script execution failures not handled properly

#### **Solution Applied**
**File:** `Project-Stages/Project-Stage-2-Automated-CI-CD-Pipeline/k8s/backend-deployment.yaml`

Enhanced init container with robust fallback mechanism that:
- ✅ Tries script-based initialization first
- ✅ Falls back to inline seeding if script fails
- ✅ Creates 4 departments and 5 sample doctors
- ✅ Includes proper error handling and logging
- ✅ Prevents duplicate data creation

#### **Sample Data Created**
- **4 Departments**: Cardiology, Pulmonology, Neurology, Orthopedics
- **5 Doctors**: Complete profiles with specializations, qualifications, experience, and fees
- **Proper relationships**: Doctors linked to appropriate departments

#### **Verification**
```bash
# Check if seeding worked
curl -s "http://<load-balancer-url>/api/doctors" | jq '.data.doctors | length'
# Should return: 5

# Check departments
curl -s "http://<load-balancer-url>/api/doctors" | jq '.data.doctors[].department.name' | sort | uniq
# Should return: "Cardiology", "Neurology", "Orthopedics", "Pulmonology"

# Check init container logs
kubectl logs deployment/healthcare-backend -n healthcare -c db-init --tail=20
# Should show: "✅ Database seeded with 4 departments and 5 doctors"
```

---

### **GitHub Actions Restrictions (FIXED)**

#### **Issue Description**
GitHub Actions pipelines were not triggering automatically due to rate limiting and processing delays.

#### **Symptoms**
- Pipelines don't trigger after git push
- Long delays between commit and pipeline start
- Manual intervention required for deployments

#### **Root Cause**
GitHub has several restrictions:
1. **Rate Limiting**: Limits on workflow trigger frequency
2. **Processing Delays**: Push events may have delays
3. **Concurrent Limits**: Free accounts have workflow concurrency limits

#### **Solution Applied**
**Workaround Strategy:**
1. **Manual Trigger Capability**: Added `workflow_dispatch` support
2. **Monitoring Commands**: Comprehensive CLI command documentation
3. **Verification Procedures**: Scripts to check pipeline status

**Commands for Manual Triggering:**
```bash
# Manual trigger when automatic fails
gh workflow run "Stage 2 CI (Quality Gates)"

# Monitor pipeline status
gh run list --limit 3

# Watch real-time progress
gh run watch <pipeline-id>

# Verify commit triggered pipeline
git log --oneline -1
gh run list --limit 1 --json headSha,displayTitle
```

#### **Documentation Created**
**File:** `Project-Stages/Project-Stage-2-Automated-CI-CD-Pipeline/docs/Github-Actions-Commands.md`
- Complete command reference with examples
- Troubleshooting procedures
- Automation scripts and aliases
- Real implementation examples

#### **Verification**
```bash
# Check if manual trigger works
gh workflow run "Stage 2 CI (Quality Gates)"
# Should return: "✓ Created workflow_dispatch event for stage2-ci.yml at main"

# Verify pipeline starts
sleep 10
gh run list --limit 1
# Should show new pipeline with status "*" (running)
```

---

## 🎯 **Prevention Measures**

### **For New Users**
All these issues are now **PREVENTED** by:

1. **✅ Fixed Source Code**: All hardcoded values removed
2. **✅ Proper Configuration**: Environment-based settings
3. **✅ Automated Seeding**: Robust database initialization
4. **✅ Comprehensive Documentation**: Step-by-step guides
5. **✅ Validation Scripts**: Automated problem detection

### **Validation Commands**
```bash
# Verify all fixes are in place
cd Project-Stages/Project-Stage-2-Automated-CI-CD-Pipeline

# Check port configuration
grep -r "port.*5173" src-code/ || echo "✅ No hardcoded ports found"

# Check image tags
grep -r "latest.*Always" k8s/ && echo "✅ Latest tags with Always pull policy"

# Check seeding configuration
grep -A 5 "Database seeded" k8s/backend-deployment.yaml && echo "✅ Seeding configured"

# Test GitHub Actions
gh workflow list && echo "✅ GitHub Actions accessible"
```

### **Quick Health Check**
```bash
# Complete system verification
echo "🔍 Checking all fixes..."

# 1. Port configuration
if ! grep -r "port.*5173" Project-Stages/Project-Stage-2-Automated-CI-CD-Pipeline/src-code/ > /dev/null 2>&1; then
    echo "✅ No hardcoded ports found"
else
    echo "❌ Hardcoded ports still present"
fi

# 2. Image tags
if grep -r "image.*latest" Project-Stages/Project-Stage-2-Automated-CI-CD-Pipeline/k8s/ > /dev/null 2>&1; then
    echo "✅ Using latest image tags"
else
    echo "❌ Not using latest tags"
fi

# 3. Database seeding
if grep "Database seeded" Project-Stages/Project-Stage-2-Automated-CI-CD-Pipeline/k8s/backend-deployment.yaml > /dev/null 2>&1; then
    echo "✅ Database seeding configured"
else
    echo "❌ Database seeding not configured"
fi

# 4. GitHub Actions
if gh workflow list > /dev/null 2>&1; then
    echo "✅ GitHub Actions accessible"
else
    echo "❌ GitHub Actions not accessible"
fi

echo "🎯 Health check complete!"
```

---

## 📋 **Summary of All Fixes**

| Issue | Status | Files Changed | Verification Command |
|-------|--------|---------------|---------------------|
| **Hardcoded Ports** | ✅ FIXED | `frontend/vite.config.ts` | `grep -r "port.*5173" src-code/` |
| **Docker Tags** | ✅ FIXED | `k8s/*-deployment.yaml` | `grep -r "latest.*Always" k8s/` |
| **Database Seeding** | ✅ FIXED | `k8s/backend-deployment.yaml` | `curl -s "<url>/api/doctors" \| jq length` |
| **GitHub Actions** | ✅ FIXED | Documentation + Workarounds | `gh workflow run "Stage 2 CI"` |

### **Commit History of Fixes**
```bash
# View recent fixes
git log --oneline -10 | grep -E "(fix|port|tag|seed|github)"
```

**Expected commits:**
- `fix(frontend): remove hardcoded port configuration`
- `fix(deployment): use latest tags with Always pull policy`
- `fix(database): implement robust inline database seeding`
- `docs(github-actions): comprehensive CLI commands reference guide`

---

*🎉 **All issues have been resolved!** New users cloning this repository should have a smooth setup experience without encountering these problems.*
