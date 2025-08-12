# 🚀 How to Setup Source Code Project - Complete Guide

## 📋 Overview

This guide provides step-by-step instructions for setting up the Healthcare Management System source code environment. This is essential for DevOps students to understand the complete setup process and avoid common issues.

## 🎯 Prerequisites

### System Requirements
- **Node.js**: Version 18.x or 20.x
- **npm**: Version 8.x or higher
- **Docker**: Latest version
- **Git**: Latest version
- **Operating System**: Linux/macOS/Windows with WSL2

### Verify Prerequisites
```bash
# Check Node.js version
node --version
# Expected: v18.x.x or v20.x.x

# Check npm version
npm --version
# Expected: 8.x.x or higher

# Check Docker version
docker --version
# Expected: Docker version 20.x.x or higher

# Check Git version
git --version
# Expected: git version 2.x.x or higher
```

## 📁 Project Structure Understanding

```
src-code/
├── package.json              # Root workspace configuration
├── package-lock.json         # Root dependencies lock file
├── frontend/                 # React frontend workspace
│   ├── package.json         # Frontend dependencies
│   ├── package-lock.json    # Frontend lock file (CRITICAL)
│   └── src/                 # Frontend source code
├── backend/                  # Node.js backend workspace
│   ├── package.json         # Backend dependencies
│   ├── package-lock.json    # Backend lock file
│   └── src/                 # Backend source code
└── docker-compose.yml        # Local development setup
```

## 🔧 Setup Methods

### Method 1: Automated Setup (Recommended for Students)

```bash
# Clone the repository
git clone <your-repo-url>
cd Health_Care_Management_System/Project-Stages/Project-Stage-2-Automated-CI-CD-Pipeline/src-code

# Run the automated setup script
./setup-environment.sh

# Expected output:
# 🏥 Healthcare Management System - Automated Setup
# =================================================
#
# 🔍 Checking Prerequisites...
# ✅ Node.js version: v18.x.x
# ✅ npm version: 8.x.x
#
# 📁 Verifying Project Structure...
# ✅ Found package.json - in correct directory
# ✅ Frontend and backend directories found
#
# 🔧 Installing Dependencies...
# ✅ Root dependencies installed
# ✅ Frontend dependencies installed
# ✅ Backend dependencies installed
#
# 🔒 Verifying Package Lock Files...
# ✅ package-lock.json exists
# ✅ frontend/package-lock.json exists
# ✅ backend/package-lock.json exists
#
# 🏗️ Testing Build Processes...
# ✅ Frontend build successful
# ✅ Backend build successful
#
# 🎉 Setup Complete!
```

**✅ This method prevents all common setup issues automatically!**

### Method 2: Manual Step-by-Step Setup

If you prefer to understand each step or the automated script fails:

#### Step 1: Clone and Navigate
```bash
# Clone the repository
git clone <your-repo-url>
cd Health_Care_Management_System/Project-Stages/Project-Stage-2-Automated-CI-CD-Pipeline/src-code
```

### Step 2: Install Root Dependencies
```bash
# Install root workspace dependencies
npm install

# Expected output:
# added X packages, and audited Y packages in Zs
# X packages are looking for funding
```

**⚠️ Important**: This creates the root `package-lock.json` file and installs shared dependencies.

### Step 3: Install Frontend Dependencies
```bash
# Navigate to frontend directory
cd frontend

# Install frontend dependencies
npm install

# Expected output:
# added X packages, and audited Y packages in Zs
# X packages are looking for funding

# Verify package-lock.json was created
ls -la package-lock.json
# Expected: -rw-rw-r-- 1 user user XXXXX date package-lock.json
```

**🔑 Critical**: The frontend `package-lock.json` file is REQUIRED for Docker builds.

### Step 4: Install Backend Dependencies
```bash
# Navigate to backend directory
cd ../backend

# Install backend dependencies
npm install

# Expected output:
# added X packages, and audited Y packages in Zs
# found 0 vulnerabilities

# Verify package-lock.json exists
ls -la package-lock.json
# Expected: -rw-rw-r-- 1 user user XXXXX date package-lock.json
```

### Step 5: Return to Root Directory
```bash
# Return to src-code root
cd ..

# Verify all package-lock.json files exist
find . -name "package-lock.json" -type f
# Expected output:
# ./package-lock.json
# ./frontend/package-lock.json
# ./backend/package-lock.json
```

## ✅ Verification Steps

### Test Frontend Build
```bash
cd frontend
npm run build

# Expected output:
# > routeclouds-health@1.0.0 build
# > vite build
# 
# vite v5.x.x building for production...
# ✓ XX modules transformed.
# dist/index.html                   X.XX kB │ gzip: X.XX kB
# dist/assets/index-XXXXXXXX.css    X.XX kB │ gzip: X.XX kB
# dist/assets/index-XXXXXXXX.js   XXX.XX kB │ gzip: XX.XX kB
# ✓ built in XXXXms
```

### Test Backend Build
```bash
cd ../backend
npm run build

# Expected output:
# > healthcare-backend@1.0.0 build
# > tsc
# 
# (No output means successful compilation)

# Verify dist directory was created
ls -la dist/
# Expected: Directory with compiled JavaScript files
```

### Test Docker Build (Optional)
```bash
cd ..
docker build -f Dockerfile.frontend.k8s -t test-frontend .

# Expected: Successful build without errors
```

## 🛡️ Issue Prevention Strategies

### Automated Prevention Tools

We've created automated tools to prevent common setup issues:

#### 1. Setup Environment Script
```bash
# Run this after cloning the repository
./setup-environment.sh

# This script:
# ✅ Validates prerequisites
# ✅ Installs all dependencies correctly
# ✅ Generates all required package-lock.json files
# ✅ Tests build processes
# ✅ Prevents Docker build failures
```

#### 2. Setup Validation Script
```bash
# Run this anytime to check your environment
./validate-setup.sh

# This script checks:
# ✅ Node.js and npm versions
# ✅ All package-lock.json files exist
# ✅ Dependencies are installed
# ✅ Build processes work
# ✅ Environment is ready for CI/CD
```

#### 3. Port Configuration Validation
```bash
# Validate port configurations (prevents frontend-backend communication issues)
./validate-port-config.sh

# This script checks:
# ✅ Frontend API configuration (/api base URL)
# ✅ Backend port settings (3002)
# ✅ Nginx proxy configuration
# ✅ Kubernetes service ports
# ✅ No hardcoded localhost:3000 references
# ✅ Docker Compose port mappings
```

#### 4. Pre-Commit Validation
```bash
# Before committing code, always run:
./validate-setup.sh && ./validate-port-config.sh

# This ensures:
# ✅ No missing package-lock.json files
# ✅ All builds work
# ✅ Port configurations are correct
# ✅ Frontend-backend communication will work
# ✅ CI/CD pipeline will succeed
```

### Why These Issues Occurred

1. **Missing package-lock.json**: npm workspaces don't always generate individual lock files
2. **Docker build failures**: Using `--only=production` excludes dev dependencies needed for builds
3. **Environment inconsistencies**: Different Node.js/npm versions across systems

### How We Fixed Them

1. **Generated all required lock files** and committed them to git
2. **Fixed Dockerfile** to include dev dependencies for build stage
3. **Created validation scripts** to catch issues before they cause problems
4. **Added automated setup** to ensure consistent environments

## 🚨 Common Issues & Troubleshooting

### Issue 1: Missing package-lock.json Files

**Symptoms:**
```
ERROR: failed to solve: process "/bin/sh -c npm ci --only=production" 
did not complete successfully: exit code: 1

npm error The `npm ci` command can only install with an existing package-lock.json
```

**Root Cause**: Missing `package-lock.json` files in frontend/backend directories.

**Solution:**
```bash
# For frontend
cd frontend
rm -rf node_modules
npm install
ls -la package-lock.json  # Verify file exists

# For backend
cd ../backend
rm -rf node_modules
npm install
ls -la package-lock.json  # Verify file exists
```

### Issue 2: npm ci Build Failures

**Symptoms:**
```
ERROR: failed to solve: process "/bin/sh -c npm run build" 
did not complete successfully: exit code: 127
```

**Root Cause**: Using `npm ci --only=production` excludes dev dependencies needed for build.

**Solution**: Dockerfile should use `npm ci` (without --only=production) for build stage.

### Issue 3: Workspace Configuration Issues

**Symptoms:**
```
npm error code EUSAGE
npm error This command does not support workspaces.
```

**Root Cause**: Running workspace commands from wrong directory.

**Solution:**
```bash
# Always run workspace commands from root
cd Project-Stages/Project-Stage-2-Automated-CI-CD-Pipeline/src-code

# Install all workspace dependencies
npm install

# Install specific workspace
npm install --workspace=frontend
npm install --workspace=backend
```

### Issue 4: Frontend-Backend Communication Failure

**Symptoms:**
```
# Frontend loads but API calls fail
Network Error: ERR_CONNECTION_REFUSED
API calls to localhost:3000 or localhost:3002 fail in Kubernetes
```

**Root Cause**: Hardcoded localhost URLs or incorrect port configurations.

**Solution:**
```bash
# 1. Validate port configurations
./validate-port-config.sh

# 2. Check frontend environment configuration
cat frontend/.env.k8s
# Should contain: VITE_API_BASE_URL=/api

# 3. Verify nginx proxy configuration
grep "proxy_pass" nginx/nginx.k8s.conf
# Should show: proxy_pass http://backend-service:3002;

# 4. Check Kubernetes service configurations
kubectl get services -n healthcare
# frontend-service should expose port 80
# backend-service should expose port 3002

# 5. Test API connectivity from frontend pod
kubectl exec -it <frontend-pod> -n healthcare -- curl http://backend-service:3002/health
```

### Issue 5: Node Version Compatibility

**Symptoms:**
```
npm error engine Unsupported engine
npm error Required: {"node":">=18.0.0"}
```

**Solution:**
```bash
# Check current version
node --version

# Install Node 18 or 20 using nvm
nvm install 18
nvm use 18

# Or install Node 20
nvm install 20
nvm use 20
```

## 📊 Expected File Structure After Setup

```
src-code/
├── package-lock.json         ✅ (Root workspace lock)
├── node_modules/             ✅ (Root dependencies)
├── frontend/
│   ├── package-lock.json     ✅ (CRITICAL for Docker)
│   ├── node_modules/         ✅ (Frontend dependencies)
│   └── dist/                 ✅ (After npm run build)
├── backend/
│   ├── package-lock.json     ✅ (Backend lock file)
│   ├── node_modules/         ✅ (Backend dependencies)
│   └── dist/                 ✅ (After npm run build)
```

## 🎓 Learning Objectives

By completing this setup, students will understand:

1. **npm Workspaces**: How monorepo structures work
2. **Dependency Management**: Difference between dependencies and devDependencies
3. **Lock Files**: Why package-lock.json is critical for reproducible builds
4. **Docker Builds**: How Docker uses npm ci for consistent builds
5. **Build Processes**: Frontend (Vite) vs Backend (TypeScript) compilation

## 📞 Support

If you encounter issues not covered here:

1. **Check Prerequisites**: Ensure all required tools are installed
2. **Clean Install**: Delete node_modules and package-lock.json, then reinstall
3. **Docker Reset**: `docker system prune -f` to clean Docker cache
4. **Version Check**: Ensure Node.js and npm versions match requirements

## 🔄 Quick Reset Commands

```bash
# Complete reset (if everything breaks)
cd Project-Stages/Project-Stage-2-Automated-CI-CD-Pipeline/src-code

# Clean all dependencies
rm -rf node_modules package-lock.json
rm -rf frontend/node_modules frontend/package-lock.json
rm -rf backend/node_modules backend/package-lock.json

# Reinstall everything
npm install
cd frontend && npm install && cd ..
cd backend && npm install && cd ..

# Verify setup
find . -name "package-lock.json" -type f
```

## 🌍 Environment-Specific Configurations

### Development Environment
```bash
# Start development servers
npm run dev

# Expected output:
# Frontend: http://localhost:5173
# Backend: http://localhost:3002
```

### Staging Environment
- Uses Docker builds with production optimizations
- Requires all package-lock.json files
- Automated via GitHub Actions

### Production Environment
- EKS deployment with hardcoded v1.0 tags
- **⚠️ NEVER change version numbers in package.json**
- Uses Kubernetes manifests with fixed image tags

## 🔍 Advanced Troubleshooting

### Debug Docker Build Issues
```bash
# Build with verbose output
docker build -f Dockerfile.frontend.k8s -t debug-frontend . --progress=plain

# Check specific build stage
docker build -f Dockerfile.frontend.k8s --target=builder -t debug-builder .

# Inspect failed container
docker run -it debug-builder /bin/sh
```

### Workspace Dependency Analysis
```bash
# Check workspace configuration
npm ls --workspaces

# Audit security vulnerabilities
npm audit
npm audit fix

# Check for outdated packages
npm outdated --workspaces
```

### Performance Optimization
```bash
# Clean npm cache
npm cache clean --force

# Use npm ci for faster installs
npm ci  # Instead of npm install in CI/CD

# Parallel workspace installs
npm install --workspaces --if-present
```

## 📋 Checklist for Students

### Before Starting Development
- [ ] Node.js 18.x or 20.x installed
- [ ] All package-lock.json files present
- [ ] Frontend builds successfully (`npm run build`)
- [ ] Backend builds successfully (`npm run build`)
- [ ] Docker builds work (optional for local dev)

### Before Committing Code
- [ ] All tests pass (`npm test`)
- [ ] Code lints without errors (`npm run lint`)
- [ ] Build succeeds in all workspaces
- [ ] No new security vulnerabilities (`npm audit`)

### Before Deployment
- [ ] Version numbers unchanged (v1.0 requirement)
- [ ] Docker images build successfully
- [ ] All package-lock.json files committed
- [ ] CI/CD pipeline passes all stages

## 🎯 Success Criteria

Your setup is complete when:

1. ✅ All three package-lock.json files exist
2. ✅ `npm run build` works in frontend directory
3. ✅ `npm run build` works in backend directory
4. ✅ `npm run dev` starts both servers
5. ✅ Docker build completes without errors
6. ✅ GitHub Actions pipeline runs successfully

## 🔧 **Port Configuration Validation**

### **New Validation Tool Added**

We've added a comprehensive port configuration validation script to prevent frontend-backend communication issues:

```bash
# Validate port configurations
./validate-port-config.sh

# This script checks:
# ✅ Frontend API configuration (/api base URL)
# ✅ Backend port settings (3002)
# ✅ Nginx proxy configuration
# ✅ Kubernetes service ports
# ✅ No hardcoded localhost:3000 references
# ✅ Docker Compose port mappings
```

### **Why This Validation is Important**

**Common Issue**: Students often face frontend-backend communication failures in Kubernetes due to:
- Hardcoded localhost URLs in test files
- Incorrect port configurations in manifests
- Missing environment variables

**Our Solution**: Automated validation that catches these issues before deployment.

### **When to Run Port Validation**

```bash
# Before committing code
./validate-setup.sh && ./validate-port-config.sh

# After making configuration changes
./validate-port-config.sh

# When troubleshooting communication issues
./validate-port-config.sh
```

---

**Version**: 1.0
**Last Updated**: August 12, 2025
**Target Audience**: DevOps Students
**Estimated Setup Time**: 15-20 minutes
**Troubleshooting Time**: 5-10 minutes (if issues occur)
**Port Validation**: Added comprehensive frontend-backend communication validation
