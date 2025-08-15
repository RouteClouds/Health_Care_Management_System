# Stage-3 Scripts Documentation

## 📋 **Overview**

This directory contains all automation scripts for the Healthcare Management System Stage-3 Advanced DevOps Pipeline. Each script is designed for specific tasks in the deployment and management lifecycle.

**Script Categories:**
- **Setup Scripts**: Initial environment and infrastructure setup
- **Migration Scripts**: Automated migration and naming convention updates
- **Validation Scripts**: Testing and verification procedures
- **Operations Scripts**: Day-to-day operational tasks
- **Cleanup Scripts**: Environment cleanup and resource removal

---

## 📁 **Directory Structure**

```
scripts/
├── setup/                          # Initial setup and configuration
│   ├── create-aws-backend.sh       # Creates S3 bucket and DynamoDB table for Terraform
│   └── setup-stage3-infrastructure.sh  # Complete infrastructure setup
├── migration/                      # Migration and transformation scripts
│   ├── migrate-to-stage3.sh        # Automated naming convention migration
│   └── update-aws-account-id.sh    # Updates AWS Account ID across all files
├── validation/                     # Testing and validation scripts
│   ├── test-phase-deployment.sh    # Phase-by-phase testing framework
│   └── validate-stage3-migration.sh # Validates migration completeness
├── operations/                     # Operational management scripts
│   ├── stage3-health-check.sh      # System health monitoring
│   └── stage3-backup.sh           # Backup procedures
└── cleanup/                        # Environment cleanup scripts
    └── destroy-stage3-environment.sh # Complete environment destruction
```

---

## 🚀 **Setup Scripts**

### **1. install-tools.sh**

**Purpose**: Automated installation of all required tools for Stage-3 deployment.

**Priority**: **CRITICAL** - Must be run first before any other setup steps.

**What it does:**
- Detects operating system (Ubuntu/Debian, CentOS/RHEL, macOS)
- Installs AWS CLI v2 (latest version)
- Installs Terraform v1.6.0
- Installs kubectl (latest stable)
- Installs Helm v3 (latest)
- Optionally installs Docker for local testing
- Verifies all installations work correctly

**Usage:**
```bash
./scripts/setup/install-tools.sh
```

**Prerequisites:**
- Internet connection for downloading packages
- Sudo privileges for system package installation
- Supported operating system (Linux or macOS)

**Expected Output:**
```
🚀 Stage-3 Automated Tool Installation
======================================
[SUCCESS] ✅ AWS CLI installed successfully
[SUCCESS] ✅ Terraform installed successfully
[SUCCESS] ✅ kubectl installed successfully
[SUCCESS] ✅ Helm installed successfully
[SUCCESS] 🎉 All required tools installed successfully!
```

**Troubleshooting:**
- **Permission Denied**: Ensure you have sudo privileges
- **Network Issues**: Check internet connection and proxy settings
- **Unsupported OS**: Use manual installation commands from MASTER-SETUP-GUIDE.md

---

### **2. create-aws-backend.sh**

**Purpose**: Creates AWS backend resources required for Terraform state management.

**Priority**: **CRITICAL** - Must be run after tool installation and before infrastructure deployment.

**What it does:**
- Creates S3 bucket for Terraform state storage
- Creates DynamoDB table for state locking
- Enables versioning and encryption on S3 bucket
- Verifies all resources are created correctly

**Usage:**
```bash
./scripts/setup/create-aws-backend.sh
```

**Prerequisites:**
- AWS CLI configured with valid credentials
- Permissions to create S3 buckets and DynamoDB tables
- AWS Account ID: 867344452513

**Expected Output:**
```
🚀 AWS Backend Resources Setup for Stage-3
===========================================
S3 Bucket: healthcare-terraform-state-stage3-867344452513
DynamoDB Table: healthcare-terraform-locks-stage3
AWS Region: us-east-1

✅ S3 bucket created: healthcare-terraform-state-stage3-867344452513
✅ Versioning enabled on S3 bucket
✅ Encryption enabled on S3 bucket
✅ DynamoDB table created: healthcare-terraform-locks-stage3
✅ DynamoDB table is active
✅ S3 bucket verified: healthcare-terraform-state-stage3-867344452513
✅ DynamoDB table verified: healthcare-terraform-locks-stage3
🎉 AWS backend resources created successfully!
```

**Troubleshooting:**
- **Permission Denied**: Ensure your AWS user has S3 and DynamoDB permissions
- **Bucket Already Exists**: Script will detect and skip creation
- **Region Issues**: Ensure AWS_REGION is set to us-east-1

---

### **2. setup-stage3-infrastructure.sh** (Future Implementation)

**Purpose**: Complete automated infrastructure setup including EKS, RDS, and monitoring.

**Priority**: **HIGH** - Run after backend setup.

**Status**: Planned for Phase 4 implementation.

---

## 🔄 **Migration Scripts**

### **1. migrate-to-stage3.sh**

**Purpose**: Automated migration from Stage-2 naming conventions to Stage-3.

**Priority**: **HIGH** - Essential for proper Stage-3 operation.

**What it does:**
- Updates package.json files with Stage-3 naming
- Converts Docker Hub references to ECR
- Updates database names and user references
- Modifies Helm chart configurations
- Updates application branding

**Usage:**
```bash
./scripts/migration/migrate-to-stage3.sh
```

**Prerequisites:**
- Stage-2 assets copied to Stage-3 directory
- Backup created automatically by script

**Files Modified:**
- `src-code/package.json` (3 files)
- `k8s/*.yaml` (4 files)
- `helm-charts/healthcare-system/values/*.yaml` (2 files)
- `scripts/deployment/*.sh` (3 files)
- Application source code (3 files)

**Expected Output:**
```
🚀 Stage-3 Automated Migration Script
======================================
✅ Backup created at: /path/to/backup
✅ Updated: Root package name
✅ Updated: Backend package name
✅ Updated: Frontend package name
✅ Updated: Frontend deployment image
✅ Updated: Backend deployment image
✅ Updated: Database name references
✅ Updated: Database user references
🎉 Stage-3 migration completed successfully!
```

---

### **2. update-aws-account-id.sh**

**Purpose**: Updates AWS Account ID across all configuration files.

**Priority**: **MEDIUM** - Run when changing AWS accounts.

**What it does:**
- Updates ECR registry URLs
- Modifies Terraform configurations
- Updates documentation examples
- Validates all changes

**Usage:**
```bash
./scripts/migration/update-aws-account-id.sh
```

**Configuration:**
```bash
OLD_ACCOUNT_ID="123456789012"
NEW_ACCOUNT_ID="867344452513"
```

---

## ✅ **Validation Scripts**

### **1. test-phase-deployment.sh**

**Purpose**: Comprehensive testing framework for phase-by-phase validation.

**Priority**: **CRITICAL** - Run before each deployment phase.

**What it tests:**
- **Prerequisites**: AWS CLI, Terraform, kubectl, Helm installation
- **Phase 1**: Repository structure and file existence
- **Phase 2**: GitHub Actions workflow and naming conventions
- **Phase 3**: Terraform syntax and GitOps manifests

**Usage:**
```bash
# Test all phases
./scripts/validation/test-phase-deployment.sh all

# Test specific phase
./scripts/validation/test-phase-deployment.sh 1
./scripts/validation/test-phase-deployment.sh 2
./scripts/validation/test-phase-deployment.sh 3

# Test prerequisites only
./scripts/validation/test-phase-deployment.sh prerequisites
```

**Test Categories:**

#### **Prerequisites Test**
```bash
./scripts/validation/test-phase-deployment.sh prerequisites
```
**Validates:**
- ✅ AWS CLI installed and configured
- ✅ Terraform installed (v1.6+)
- ✅ kubectl installed (v1.28+)
- ✅ Helm installed (v3.x)
- ✅ AWS credentials working
- ✅ Correct AWS Account ID (867344452513)

#### **Phase 1 Test (Repository Structure)**
```bash
./scripts/validation/test-phase-deployment.sh 1
```
**Validates:**
- ✅ Terraform modules directory exists
- ✅ GitOps applications directory exists
- ✅ Required files present (backend.tf, main.tf, etc.)

#### **Phase 2 Test (GitHub Actions)**
```bash
./scripts/validation/test-phase-deployment.sh 2
```
**Validates:**
- ✅ GitHub Actions workflow exists
- ✅ Workflow paths are correct
- ✅ Stage-3 naming convention applied
- ✅ AWS Account ID correctly configured

#### **Phase 3 Test (Infrastructure)**
```bash
./scripts/validation/test-phase-deployment.sh 3
```
**Validates:**
- ✅ Terraform syntax and formatting
- ✅ Terraform initialization successful
- ✅ Terraform validation passes
- ✅ GitOps manifests syntax valid

**Expected Output:**
```
🚀 Stage-3 Phase-by-Phase Testing
==================================
Testing Phase: all

🔍 Testing AWS Prerequisites
✅ AWS CLI installed
✅ AWS credentials configured for correct account (867344452513)
✅ terraform installed
✅ kubectl installed
✅ helm installed
🎉 AWS Prerequisites - PASSED

🔍 Testing Phase 1: Repository Structure
✅ Terraform modules directory exists
✅ GitOps applications directory exists
✅ Required file exists: terraform/backend.tf
✅ Required file exists: terraform/environments/dev/main.tf
🎉 Phase 1: Repository Structure - PASSED

📊 Test Results Summary
=======================
Total Tests: 5
Passed: 5
Failed: 0
🎉 ALL TESTS PASSED - Ready for deployment!
```

---

### **2. validate-stage3-migration.sh** (Future Implementation)

**Purpose**: Validates completeness of Stage-2 to Stage-3 migration.

**Status**: Planned for Phase 4 implementation.

---

## 🔧 **Operations Scripts**

### **1. trigger-pipeline.sh**

**Purpose**: Interactive helper script to trigger the Stage-3 GitHub Actions pipeline.

**Priority**: **HIGH** - Essential for testing and deployment workflows.

**What it does:**
- Provides multiple trigger options (version bump, feature test, docs update, custom)
- Validates git repository status and branch
- Creates meaningful commits that trigger the pipeline
- Shows pipeline monitoring information and expected execution flow
- Handles git operations safely with validation

**Usage:**
```bash
./scripts/operations/trigger-pipeline.sh
```

**Prerequisites:**
- Git repository properly configured
- No uncommitted changes
- Access to push to main branch

**Trigger Options:**
1. **Version bump** - Updates package.json version (recommended for releases)
2. **Feature development** - Adds test comment to source code
3. **Documentation update** - Updates README with timestamp
4. **Custom change** - User-specified file modification

**Expected Output:**
```
🚀 Stage-3 Pipeline Trigger Helper
==================================
[SUCCESS] ✅ Changes pushed successfully!
🔍 Monitor your pipeline at: https://github.com/username/repo/actions
Expected pipeline jobs:
1. ✅ Terraform Validation (2-3 minutes)
2. ✅ Unit Tests (3-5 minutes)
3. ✅ Security Scanning (2-4 minutes)
4. ✅ Build and Push Images (5-8 minutes)
5. ✅ Infrastructure Deployment (10-15 minutes)
6. ✅ GitOps Deployment (3-5 minutes)
🎉 Pipeline triggered successfully!
```

---

### **2. stage3-health-check.sh** (Future Implementation)

**Purpose**: Automated health monitoring for Stage-3 environment.

**Priority**: **MEDIUM** - For ongoing operations.

**Planned Features:**
- EKS cluster health check
- Application pod status
- Database connectivity
- Monitoring stack status

---

### **3. stage3-backup.sh** (Future Implementation)

**Purpose**: Automated backup procedures for Stage-3 environment.

**Priority**: **MEDIUM** - For data protection.

**Planned Features:**
- Database backup to S3
- Kubernetes configuration backup
- Application data backup

---

## 🧹 **Cleanup Scripts**

### **1. destroy-stage3-environment.sh** (Future Implementation)

**Purpose**: Complete environment destruction and cleanup.

**Priority**: **LOW** - For environment teardown.

**Planned Features:**
- Terraform destroy
- AWS resource cleanup
- Local configuration cleanup

---

## 📊 **Script Execution Priority**

### **Phase 1: Initial Setup**
1. **install-tools.sh** (CRITICAL)
2. **create-aws-backend.sh** (CRITICAL)
3. **test-phase-deployment.sh prerequisites** (CRITICAL)

### **Phase 2: Migration & Validation**
3. **migrate-to-stage3.sh** (HIGH)
4. **update-aws-account-id.sh** (MEDIUM)
5. **test-phase-deployment.sh all** (HIGH)

### **Phase 3: Deployment**
6. **Terraform deployment** (Manual)
7. **test-phase-deployment.sh 3** (HIGH)

### **Phase 4: Operations**
8. **trigger-pipeline.sh** (HIGH)
9. **stage3-health-check.sh** (MEDIUM)
10. **stage3-backup.sh** (MEDIUM)

---

## 🛠️ **Script Development Guidelines**

### **Coding Standards**
- **Error Handling**: All scripts use `set -e` for immediate exit on error
- **Logging**: Colored output with INFO, SUCCESS, WARNING, ERROR levels
- **Validation**: Input validation and prerequisite checks
- **Documentation**: Comprehensive comments and usage instructions

### **Common Functions**
```bash
# Logging functions used across all scripts
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
```

### **Error Handling Pattern**
```bash
# Standard error handling pattern
if command_that_might_fail; then
    log_success "✅ Operation successful"
else
    log_error "❌ Operation failed"
    exit 1
fi
```

---

## 🔍 **Troubleshooting Scripts**

### **Common Issues**

#### **Permission Errors**
```bash
# Fix script permissions
chmod +x scripts/**/*.sh
```

#### **AWS Credential Issues**
```bash
# Verify AWS configuration
aws sts get-caller-identity
aws configure list
```

#### **Path Issues**
```bash
# Ensure you're in the correct directory
cd /home/ubuntu/Projects/Health_Care_Management_System/Project-Stages/Project-Stage-3-Advanced-DevOps-Pipeline
```

---

**For detailed usage of each script, refer to the individual script files which contain comprehensive documentation and examples.**
