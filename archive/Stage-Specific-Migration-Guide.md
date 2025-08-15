# 🚀 **Stage-Specific Migration Guide**
## **Healthcare Management System - Modern DevOps Evolution**

### **📋 Document Information**
```yaml
Document: Stage-Specific-Migration-Guide.md
Purpose: Guide for migrating between stage-specific environments
Structure: Stage-specific source code directories
Target Audience: DevOps engineers, developers
Last Updated: August 6, 2025
```

---

## 🎯 **Overview**

This guide covers migration scenarios and common challenges when working with the current stage-specific structure where each stage has its own dedicated source code directory.

### **🏗️ Current Structure**
```bash
Healthcare Management System/
└── Project-Stages/
    ├── Project-Stage-1-Basic-CI-CD-Deploy/
    │   ├── src-code/           # Stage-1 specific source code
    │   ├── scripts/            # Stage-1 deployment scripts
    │   ├── k8s/               # Stage-1 Kubernetes manifests
    │   └── docs/              # Stage-1 documentation
    └── Project-Stage-2-Automated-CI-CD-Pipeline/
        ├── src-code/           # Stage-2 enhanced source code
        ├── scripts/            # Stage-2 automation scripts
        ├── helm-charts/        # Helm charts for deployment
        ├── tests/             # Testing configurations
        └── docs/              # Stage-2 documentation
```

---

## 🔄 **Common Migration Scenarios**

### **Scenario 1: Developer Moving from Stage-1 to Stage-2**

#### **Challenge**: Different Development Workflows
```yaml
Stage-1 Workflow:
  1. cd Project-Stages/Project-Stage-1-Basic-CI-CD-Deploy/src-code
  2. docker compose up -d
  3. Manual testing and deployment

Stage-2 Workflow:
  1. cd Project-Stages/Project-Stage-2-Automated-CI-CD-Pipeline/src-code
  2. npm run test (automated testing)
  3. GitHub Actions handles deployment
```

#### **Solution**: Environment Setup
```bash
# Stage-1 Development
cd Project-Stages/Project-Stage-1-Basic-CI-CD-Deploy/src-code
docker compose up -d
# Simple development environment

# Stage-2 Development  
cd Project-Stages/Project-Stage-2-Automated-CI-CD-Pipeline/src-code
npm install  # Install testing dependencies
npm run test # Run test suite
npm run lint # Code quality checks
```

### **Scenario 2: Code Synchronization Between Stages**

#### **Challenge**: Keeping Core Features in Sync
When you add a new feature to Stage-1, you need to port it to Stage-2.

#### **Solution**: Feature Porting Process
```bash
# 1. Develop feature in Stage-1
cd Project-Stages/Project-Stage-1-Basic-CI-CD-Deploy/src-code
# ... develop feature ...

# 2. Port to Stage-2 with enhancements
cd Project-Stages/Project-Stage-2-Automated-CI-CD-Pipeline/src-code
# Copy core feature code
# Add tests for the feature
# Add any Stage-2 specific enhancements

# 3. Verify with Stage-2 testing
npm run test
npm run test:e2e
```

### **Scenario 3: Docker Image Management**

#### **Challenge**: Different Docker Strategies
```yaml
Stage-1: Simple Docker builds
  - Basic Dockerfiles
  - Manual image building
  - Version v1.0

Stage-2: Advanced Docker builds  
  - Multi-stage builds
  - Automated CI/CD builds
  - Version v2.0+
  - Security scanning
```

#### **Solution**: Stage-Specific Build Scripts
```bash
# Stage-1 Build
cd Project-Stages/Project-Stage-1-Basic-CI-CD-Deploy
./scripts/build-and-push-images.sh

# Stage-2 Build (with testing and security)
cd Project-Stages/Project-Stage-2-Automated-CI-CD-Pipeline  
./scripts/build-and-push-images.sh --version v2.1
```

---

## 🛠️ **Migration Best Practices**

### **1. Environment Isolation**
```yaml
Principle: Each stage is completely self-contained
Benefits:
  ✅ No dependency conflicts between stages
  ✅ Clear separation of concerns
  ✅ Independent testing and deployment
  ✅ Easier troubleshooting
```

### **2. Feature Development Workflow**
```bash
# Recommended workflow for new features:

# Step 1: Develop in Stage-1 (simple environment)
cd Project-Stages/Project-Stage-1-Basic-CI-CD-Deploy/src-code
# Develop and test basic functionality

# Step 2: Port to Stage-2 (add testing and automation)
cd Project-Stages/Project-Stage-2-Automated-CI-CD-Pipeline/src-code
# Copy feature code
# Add comprehensive tests
# Integrate with CI/CD pipeline

# Step 3: Deploy through proper stage
# Stage-1: Manual deployment
# Stage-2: Automated deployment via GitHub Actions
```

### **3. Configuration Management**
```yaml
Stage-1 Configuration:
  - Simple environment variables
  - Basic Docker Compose setup
  - Manual configuration management

Stage-2 Configuration:
  - Environment-specific configs
  - Helm values for different environments
  - Automated configuration deployment
```

---

## 🚨 **Common Issues and Solutions**

### **Issue 1: Wrong Stage Directory**
```bash
# Symptom: Commands fail with "file not found"
# Cause: Running commands from wrong stage directory

# Solution: Always verify your location
pwd
# Should show: .../Project-Stage-X-...

# Navigate to correct stage
cd Project-Stages/Project-Stage-1-Basic-CI-CD-Deploy  # For Stage-1
cd Project-Stages/Project-Stage-2-Automated-CI-CD-Pipeline  # For Stage-2
```

### **Issue 2: Docker Build Context Errors**
```bash
# Symptom: Docker build fails with "COPY failed"
# Cause: Wrong build context or Dockerfile path

# Solution: Always build from src-code directory
cd Project-Stages/Project-Stage-X/src-code
docker build -f Dockerfile.backend -t backend:latest .
```

### **Issue 3: Script Path Errors**
```bash
# Symptom: "./scripts/script-name.sh: No such file or directory"
# Cause: Running script from wrong directory

# Solution: Run scripts from stage root
cd Project-Stages/Project-Stage-X  # Stage root
./scripts/script-name.sh
```

---

## 📚 **Quick Reference**

### **Stage-1 Quick Commands**
```bash
# Navigate to Stage-1
cd Project-Stages/Project-Stage-1-Basic-CI-CD-Deploy

# Local development
cd src-code && docker compose up -d

# Build images
./scripts/build-and-push-images.sh

# Deploy to EKS
./scripts/deploy-to-eks.sh
```

### **Stage-2 Quick Commands**
```bash
# Navigate to Stage-2
cd Project-Stages/Project-Stage-2-Automated-CI-CD-Pipeline

# Local development with testing
cd src-code && npm install && npm test

# Build with testing and security
./scripts/build-and-push-images.sh

# Deploy with Helm
./scripts/deploy-healthcare.sh
```

---

## 🎓 **Training Recommendations**

### **For New Developers**
1. **Start with Stage-1** - Learn basic concepts
2. **Master Stage-1 workflow** - Manual deployment understanding
3. **Progress to Stage-2** - Advanced automation concepts
4. **Practice migration** - Port features between stages

### **For DevOps Engineers**
1. **Understand both stages** - Different deployment strategies
2. **Master automation tools** - GitHub Actions, Helm, testing
3. **Focus on Stage-2** - Production-ready practices
4. **Create custom stages** - Extend the pattern for specific needs

---

## 🔗 **Related Documentation**

- **Stage-1**: `Project-Stages/Project-Stage-1-Basic-CI-CD-Deploy/README.md`
- **Stage-2**: `Project-Stages/Project-Stage-2-Automated-CI-CD-Pipeline/README.md`
- **Troubleshooting**: `Stage-1-2-Docker-Troubleshooting.md`
- **Version Guide**: `Source-Code-Version-Guide.md`

---

**Last Updated**: August 6, 2025
**Status**: ✅ Current with stage-specific structure
