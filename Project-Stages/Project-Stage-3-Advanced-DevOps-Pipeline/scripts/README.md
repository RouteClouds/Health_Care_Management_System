# 📜 **Stage-3 Scripts Documentation - Complete Automation Suite**

## � **Overview**

This directory contains all automation scripts for the Healthcare Management System Stage-3 Advanced DevOps Pipeline. Each script is designed for specific tasks in the deployment and management lifecycle with full automation support.

**Key Features:**
- ✅ **Fully Automated Database Setup** - No manual intervention required
- ✅ **Comprehensive Error Handling** - Robust failure recovery
- ✅ **Network Resilience** - Handles network issues in CI/CD
- ✅ **GitOps Integration** - Automated image tag updates
- ✅ **Complete Validation** - End-to-end testing capabilities

---

## 📁 **Directory Structure**

```
scripts/
├── 🛠️ setup/                          # Initial setup and configuration
│   ├── create-aws-backend.sh          # S3 bucket and DynamoDB for Terraform
│   ├── create-ecr-repositories.sh     # ECR repositories creation
│   └── install-tools.sh               # Required tools installation
├── 🔄 migration/                       # Migration and transformation
│   ├── migrate-to-stage3.sh           # Automated naming convention migration
│   └── update-aws-account-id.sh       # AWS Account ID updates
├── 🚀 deployment/                      # Infrastructure and application deployment
│   ├── build-and-push-images.sh       # Docker image building and pushing
│   ├── create-eks-cluster.sh          # EKS cluster creation
│   ├── deploy-production.sh           # Production deployment
│   ├── deploy-staging.sh              # Staging deployment
│   └── validate-infrastructure.sh     # Infrastructure validation
├── 🔧 operations/                      # Day-to-day operational tasks
│   └── trigger-pipeline.sh            # Manual pipeline triggering
├── 🧪 validation/                      # Testing and verification
│   ├── test-phase-deployment.sh       # Phase-by-phase testing
│   ├── test-pipeline-isolation.sh     # Pipeline isolation testing
│   └── test-simple.sh                 # Simple validation tests
├── 🗄️ gitops/                         # GitOps automation
│   └── update-image-tags.sh           # Automated image tag updates
├── 🔍 git-scripts/                     # Git automation
│   ├── git-status-check.sh            # Git status validation
│   └── setup-branch-protection.sh     # GitHub branch protection
├── 🧹 cleanup/                         # Environment cleanup
│   └── cleanup-existing-resources.sh  # Resource cleanup automation
└── 📊 Root Level Scripts               # Main automation scripts
    ├── build-with-network-resilience.sh    # Network-resilient Docker builds
    ├── deploy-healthcare.sh                # Complete application deployment
    ├── fix-gitops-sync.sh                  # GitOps synchronization fixes
    ├── test-frontend-backend-connectivity.sh # Connectivity testing
    └── validate-configs.js                 # Configuration validation
```

---

## 🎯 **Quick Start Guide**

### **For New Users (Complete Automated Setup)**
```bash
# 1. Install required tools
./setup/install-tools.sh

# 2. Create AWS backend infrastructure
./setup/create-aws-backend.sh

# 3. Create ECR repositories
./setup/create-ecr-repositories.sh

# 4. Deploy complete infrastructure
./deployment/create-eks-cluster.sh

# 5. Deploy application with automated database setup
./deploy-healthcare.sh

# 6. Validate deployment
./test-frontend-backend-connectivity.sh
```

### **For CI/CD Pipeline (Automated)**
```bash
# Trigger automated pipeline (includes database setup)
./operations/trigger-pipeline.sh

# The pipeline automatically:
# - Builds images with network resilience
# - Updates GitOps manifests
# - Applies database migrations
# - Seeds database with sample data
# - Validates connectivity
```

---

## 🗄️ **DATABASE AUTOMATION SCRIPTS**

### **� Database Seeding Script** (`src-code/backend/scripts/seed-database.js`)

**Purpose**: Automated database seeding with comprehensive sample data for Stage-3 deployment.

**Automation Level**: **FULLY AUTOMATED** - Runs automatically in CI/CD pipeline and Docker containers.

**When it runs:**
- ✅ **Automatically during Docker container startup** (via docker-entrypoint.sh)
- ✅ **During CI/CD pipeline deployment** (via GitHub Actions)
- ✅ **Manual execution** for testing and development

**What it creates:**
```
📊 Sample Data Created:
├── 🏥 5 Departments
│   ├── Cardiology (CARD)
│   ├── Pediatrics (PEDI)
│   ├── Orthopedics (ORTH)
│   ├── Emergency Medicine (EMER)
│   └── Internal Medicine (INTE)
├── 👥 2 Sample Users
│   ├── john.patient (PATIENT role)
│   └── admin.user (ADMIN role)
└── 👨‍⚕️ 5 Doctors
    ├── Dr. John Smith (Cardiology)
    ├── Dr. Sarah Johnson (Pediatrics)
    ├── Dr. Michael Brown (Orthopedics)
    ├── Dr. Emily Davis (Emergency)
    └── Dr. Robert Wilson (Internal Medicine)
```

**Usage:**
```bash
# Automatic (recommended)
# - Runs automatically during deployment
# - No manual intervention required

# Manual execution (for testing)
cd src-code/backend
node scripts/seed-database.js

# Via npm scripts
npm run db:seed
npm run db:setup  # Includes migrations + seeding

# Via Prisma
npx prisma db seed
```

**Expected Output:**
```
🌱 Starting database seeding for Healthcare Management System Stage-3...
================================================================================
✅ Database connection successful
🏥 Seeding departments...
✅ Created 5 departments
👥 Seeding users...
✅ Created 2 users
👨‍⚕️ Seeding doctors...
✅ Created 5 doctors

🎉 Database seeding completed successfully!
================================================================================
📊 Summary:
   - Departments: 5
   - Users: 2
   - Doctors: 5

🔗 You can now test the API endpoints:
   - GET /api/health (health check)
   - GET /api/doctors (list doctors)
   - GET /api/departments (list departments)
```

**Error Handling:**
- ✅ **Graceful duplicate handling** with `skipDuplicates: true`
- ✅ **Database connection validation** before seeding
- ✅ **Comprehensive error logging** with specific error messages
- ✅ **Automatic retry logic** in Docker entrypoint
- ✅ **Non-blocking failures** - application starts even if seeding has warnings

---

## 🛠️ **SETUP SCRIPTS**

### **1. install-tools.sh** (`setup/install-tools.sh`)

**Purpose**: Automated installation of all required tools for Stage-3 deployment.

**Priority**: **CRITICAL** - Must be run first before any other setup steps.

**What it installs:**
- ✅ AWS CLI v2 (latest version)
- ✅ Terraform v1.6.0
- ✅ kubectl (latest stable)
- ✅ Docker (if not present)
- ✅ jq (JSON processor)
- ✅ curl and wget
- ✅ Git (if not present)

**Usage:**
```bash
./setup/install-tools.sh

# Expected output:
# 🛠️ Installing required tools for Stage-3...
# ✅ AWS CLI v2 installed successfully
# ✅ Terraform v1.6.0 installed successfully
# ✅ kubectl installed successfully
# ✅ All tools installed successfully!
```

### **2. create-aws-backend.sh** (`setup/create-aws-backend.sh`)

**Purpose**: Creates S3 bucket and DynamoDB table for Terraform state management.

**What it creates:**
- ✅ S3 bucket for Terraform state storage
- ✅ DynamoDB table for state locking
- ✅ Proper IAM permissions
- ✅ Versioning and encryption enabled

**Usage:**
```bash
./setup/create-aws-backend.sh

# Creates:
# - S3 bucket: healthcare-terraform-state-{account-id}
# - DynamoDB table: healthcare-terraform-locks
```

### **3. create-ecr-repositories.sh** (`setup/create-ecr-repositories.sh`)

**Purpose**: Creates ECR repositories for Docker images.

**What it creates:**
- ✅ healthcare-frontend-stage3 repository
- ✅ healthcare-backend-stage3 repository
- ✅ Proper lifecycle policies
- ✅ Image scanning enabled

---

## 🚀 **DEPLOYMENT SCRIPTS**

### **1. deploy-healthcare.sh** (Root Level)

**Purpose**: Complete application deployment with automated database setup.

**Automation Level**: **FULLY AUTOMATED** - Includes database migrations and seeding.

**What it does:**
- ✅ Builds and pushes Docker images
- ✅ Updates GitOps manifests with new image tags
- ✅ Applies Kubernetes deployments
- ✅ **Automatically applies database migrations**
- ✅ **Automatically seeds database with sample data**
- ✅ Validates deployment health
- ✅ Tests frontend-backend connectivity

**Usage:**
```bash
./deploy-healthcare.sh

# Expected flow:
# 🏗️ Building Docker images...
# 📤 Pushing to ECR...
# 🔄 Updating GitOps manifests...
# 🚀 Deploying to Kubernetes...
# 🗄️ Setting up database...
# ✅ Deployment completed successfully!
```

### **2. build-with-network-resilience.sh** (Root Level)

**Purpose**: Network-resilient Docker image building for CI/CD pipelines.

**Features:**
- ✅ **Automatic retry logic** for network failures
- ✅ **Registry mirror fallbacks** for reliability
- ✅ **Enhanced timeout handling** for slow networks
- ✅ **Comprehensive error logging** for debugging
- ✅ **Build cache optimization** for faster builds

**Usage:**
```bash
./build-with-network-resilience.sh

# Automatically handles:
# - Network timeouts
# - Registry connectivity issues
# - Build failures with retries
# - Cache optimization
```

---

## 🧪 **TESTING AND VALIDATION SCRIPTS**

### **1. test-frontend-backend-connectivity.sh** (Root Level)

**Purpose**: Comprehensive connectivity testing between frontend and backend with database validation.

**What it tests:**
- ✅ **Frontend accessibility** via LoadBalancer
- ✅ **Backend API health** and responsiveness
- ✅ **CORS configuration** for cross-origin requests
- ✅ **Database connectivity** and data availability
- ✅ **API endpoint functionality** with real data
- ✅ **Pod health status** in Kubernetes

**Usage:**
```bash
./test-frontend-backend-connectivity.sh

# Expected output:
# 🔍 Frontend-Backend Connectivity Test
# =====================================
# 1. Testing Frontend Loading...
# ✅ Frontend: 200 OK
# 2. Testing Backend API...
# ✅ Backend API: 200 OK
# 3. Testing CORS Configuration...
# ✅ CORS: Correctly configured
# 4. Testing API Endpoints...
# ✅ API Endpoints: Responding with data
# 5. Testing Pod Status...
# ✅ All Pods: Running successfully
#
# 🎉 Frontend-Backend Connectivity: OPERATIONAL
```

### **2. validate-configs.js** (Root Level)

**Purpose**: Configuration validation for all Stage-3 components.

**What it validates:**
- ✅ **Kubernetes manifests** syntax and structure
- ✅ **Environment variables** completeness
- ✅ **Docker configurations** validity
- ✅ **Terraform configurations** syntax
- ✅ **Database connection strings** format

**Usage:**
```bash
node validate-configs.js

# Validates all configuration files
# Reports any issues or inconsistencies
```

### **3. test-phase-deployment.sh** (`validation/test-phase-deployment.sh`)

**Purpose**: Phase-by-phase deployment testing framework.

**Testing Phases:**
- ✅ **Phase 1**: Infrastructure validation
- ✅ **Phase 2**: Application deployment
- ✅ **Phase 3**: Database setup and seeding
- ✅ **Phase 4**: Connectivity and functionality
- ✅ **Phase 5**: Performance and load testing

---

## 🔧 **OPERATIONS SCRIPTS**

### **1. trigger-pipeline.sh** (`operations/trigger-pipeline.sh`)

**Purpose**: Manual pipeline triggering for testing and emergency deployments.

**What it does:**
- ✅ **Triggers GitHub Actions workflow** manually
- ✅ **Monitors pipeline progress** with real-time updates
- ✅ **Provides pipeline status** and logs
- ✅ **Handles pipeline failures** with retry options

**Usage:**
```bash
./operations/trigger-pipeline.sh

# Triggers the complete CI/CD pipeline
# Includes automated database setup
```

### **2. fix-gitops-sync.sh** (Root Level)

**Purpose**: GitOps synchronization fixes for image tag mismatches.

**When to use:**
- ❌ **GitOps manifests using old image tags**
- ❌ **Manual intervention needed for deployment**
- ❌ **Pipeline built new images but GitOps not updated**

**What it fixes:**
- ✅ **Updates GitOps manifests** with latest commit SHA
- ✅ **Applies updated configurations** to Kubernetes
- ✅ **Monitors deployment rollout** status
- ✅ **Validates new pods** are using correct images

**Usage:**
```bash
./fix-gitops-sync.sh

# Expected output:
# 🔄 GitOps Sync Fix Script
# ========================
# Latest commit SHA: a4ad4a894c88cdc5670144ebe1694d0bda6aec1f
# 🔄 Updating GitOps manifests...
# ✅ Frontend image updated
# ✅ Backend image updated
# 🚀 Applying updates to Kubernetes...
# ✅ GitOps sync fix completed!
```

---

## 🔄 **MIGRATION SCRIPTS**

### **1. migrate-to-stage3.sh** (`migration/migrate-to-stage3.sh`)

**Purpose**: Automated migration from Stage-2 to Stage-3 with naming convention updates.

**What it migrates:**
- ✅ **Service names** (adds -stage3 suffix)
- ✅ **Database references** (healthcare_db → healthcare_stage3_db)
- ✅ **Package names** in package.json files
- ✅ **Docker image tags** and repository names
- ✅ **Kubernetes manifests** with new naming

### **2. update-aws-account-id.sh** (`migration/update-aws-account-id.sh`)

**Purpose**: Updates AWS Account ID across all configuration files.

**Usage:**
```bash
./migration/update-aws-account-id.sh NEW_ACCOUNT_ID

# Updates all references to AWS Account ID
# Includes ECR URLs, IAM roles, and resource ARNs
```

---

## 🧹 **CLEANUP SCRIPTS**

### **1. cleanup-existing-resources.sh** (`cleanup/cleanup-existing-resources.sh`)

**Purpose**: Complete environment cleanup and resource removal.

**What it cleans:**
- ✅ **Kubernetes resources** (pods, services, deployments)
- ✅ **AWS resources** (EKS cluster, RDS, LoadBalancers)
- ✅ **ECR images** and repositories
- ✅ **S3 buckets** and DynamoDB tables
- ✅ **CloudFormation stacks** if applicable

---

## 🤖 **AUTOMATION FEATURES**

### **🔄 Fully Automated Database Setup**

**The Stage-3 pipeline now includes ZERO-INTERVENTION database setup:**

1. **Automatic Migration Application**:
   ```bash
   # Runs automatically in Docker containers
   npx prisma migrate deploy
   ```

2. **Automatic Database Seeding**:
   ```bash
   # Runs automatically after migrations
   node scripts/seed-database.js
   ```

3. **Health Validation**:
   ```bash
   # Automatic validation of database connectivity and data
   curl /api/health | jq '.database'  # Should return "connected"
   curl /api/doctors | jq '.data.doctors | length'  # Should return > 0
   ```

### **🚀 CI/CD Pipeline Integration**

**The automated pipeline flow:**

```yaml
# GitHub Actions Workflow (Automated)
1. Code Push → Trigger Pipeline
2. Build Images → Network-Resilient Build Process
3. Push to ECR → Automated Registry Push
4. Update GitOps → Automatic Manifest Updates
5. Deploy to K8s → Kubernetes Deployment
6. Database Setup → Automatic Migrations + Seeding
7. Validation → Connectivity and Health Checks
8. Notification → Success/Failure Alerts
```

### **🛡️ Error Handling and Recovery**

**Comprehensive error handling across all scripts:**

- ✅ **Network Resilience**: Automatic retries for network failures
- ✅ **Database Recovery**: Graceful handling of connection issues
- ✅ **GitOps Sync**: Automatic detection and fixing of image tag mismatches
- ✅ **Rollback Capability**: Automatic rollback on deployment failures
- ✅ **Monitoring Integration**: Real-time status monitoring and alerting

---

## 📋 **SCRIPT EXECUTION ORDER**

### **For Complete New Setup:**
```bash
1. ./setup/install-tools.sh                    # Install required tools
2. ./setup/create-aws-backend.sh               # Create Terraform backend
3. ./setup/create-ecr-repositories.sh          # Create ECR repos
4. ./deployment/create-eks-cluster.sh          # Create infrastructure
5. ./deploy-healthcare.sh                      # Deploy application (includes DB setup)
6. ./test-frontend-backend-connectivity.sh     # Validate deployment
```

### **For Regular Deployments:**
```bash
# Automated via CI/CD pipeline
git push origin main  # Triggers automated pipeline with database setup

# Manual deployment
./deploy-healthcare.sh  # Includes automated database setup
```

### **For Troubleshooting:**
```bash
1. ./test-frontend-backend-connectivity.sh     # Check connectivity
2. ./fix-gitops-sync.sh                        # Fix GitOps issues
3. ./validate-configs.js                       # Validate configurations
```

---

## 🎯 **KEY BENEFITS**

### **For New Users:**
- ✅ **Zero Manual Database Setup** - Fully automated migrations and seeding
- ✅ **One-Command Deployment** - Complete setup with single script execution
- ✅ **Comprehensive Validation** - Automatic testing and health checks
- ✅ **Error Recovery** - Automatic detection and fixing of common issues

### **For DevOps Teams:**
- ✅ **CI/CD Integration** - Seamless pipeline automation
- ✅ **GitOps Workflow** - Automatic manifest updates and synchronization
- ✅ **Monitoring Ready** - Built-in health checks and status validation
- ✅ **Production Ready** - Enterprise-level error handling and recovery

### **For Development Teams:**
- ✅ **Consistent Environments** - Identical setup across all deployments
- ✅ **Sample Data Ready** - Pre-populated database for immediate testing
- ✅ **API Testing Ready** - Functional endpoints with real data
- ✅ **Documentation Complete** - Comprehensive guides and troubleshooting

---

*This comprehensive script suite ensures Stage-3 deployments are fully automated, reliable, and production-ready with zero manual database intervention required.*
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
