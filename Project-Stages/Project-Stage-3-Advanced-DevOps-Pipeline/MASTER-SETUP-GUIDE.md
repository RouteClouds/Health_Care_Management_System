# Stage-3 Master Setup Guide

## 🎯 **Overview**

This guide provides **complete step-by-step instructions** for deploying the Healthcare Management System Stage-3 Advanced DevOps Pipeline. This guide is designed for **new users** who may not have implemented Stage-2 and want to deploy Stage-3 from scratch.

**What You'll Deploy:**
- Enterprise-grade Kubernetes cluster (AWS EKS)
- Infrastructure as Code (Terraform)
- GitOps deployment pipeline (ArgoCD)
- Comprehensive monitoring (Prometheus/Grafana)
- Centralized logging (ELK Stack)
- Auto-scaling and high availability

**Estimated Total Time:** 4-6 hours
**Skill Level:** Intermediate to Advanced
**Prerequisites:** AWS Account, GitHub Account, Basic DevOps Knowledge

## 📋 Table of Contents

1. [Prerequisites Verification](#prerequisites-verification)
2. [Environment Preparation](#environment-preparation)
3. [AWS Backend Setup](#aws-backend-setup)
4. [ECR Repository Setup](#ecr-repository-setup)
5. [AWS Account ID Replacement](#aws-account-id-replacement)
6. [GitHub Configuration](#github-configuration)
7. [Infrastructure Deployment](#infrastructure-deployment)
8. [Application Deployment](#application-deployment)
9. [Monitoring Setup](#monitoring-setup)
10. [Validation & Testing](#validation--testing)
11. [Troubleshooting](#troubleshooting)

---

## 🔍 Prerequisites Verification

### **Required Tools Installation**

**Choose your preferred installation method:**

#### **🚀 Option 1: Automated Installation (Recommended)**

**Use our automated installation script that installs all required tools:**

```bash
# Run the automated tool installation script
./scripts/setup/install-tools.sh

# This script will install:
# - AWS CLI v2 (latest)
# - Terraform v1.6.0
# - kubectl (latest stable)
# - Helm v3 (latest)
# - Docker (optional, with confirmation)
```

**What the script does:**
- **Detects your OS**: Supports Ubuntu/Debian, CentOS/RHEL, and macOS
- **Checks existing installations**: Skips tools already installed
- **Handles dependencies**: Installs required packages automatically
- **Verifies installations**: Confirms all tools work correctly
- **Provides next steps**: Guides you to the next phase

**Expected output:**
```
🚀 Stage-3 Automated Tool Installation
======================================
[SUCCESS] ✅ AWS CLI installed successfully
[SUCCESS] ✅ Terraform installed successfully
[SUCCESS] ✅ kubectl installed successfully
[SUCCESS] ✅ Helm installed successfully
[SUCCESS] 🎉 All required tools installed successfully!

Next steps:
1. Configure AWS credentials: aws configure
2. Run prerequisites test: ./scripts/validation/test-phase-deployment.sh prerequisites
```

#### **📋 Option 2: Manual Installation (Alternative)**

**If you prefer manual installation or the script doesn't work on your system:**

<details>
<summary>Click to expand manual installation commands</summary>

##### **1. AWS CLI Installation**
```bash
# Install AWS CLI v2 (Linux/macOS)
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Verify installation
aws --version
# Expected: aws-cli/2.x.x or higher
```

##### **2. Terraform Installation**
```bash
# Install Terraform (Linux)
wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip
unzip terraform_1.6.0_linux_amd64.zip
sudo mv terraform /usr/local/bin/

# Verify installation
terraform version
# Expected: Terraform v1.6.0 or higher
```

##### **3. kubectl Installation**
```bash
# Install kubectl (Linux)
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

# Verify installation
kubectl version --client
# Expected: Client Version v1.28.0 or higher
```

##### **4. Helm Installation**
```bash
# Install Helm (Linux)
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Verify installation
helm version
# Expected: version.BuildInfo{Version:"v3.x.x"}
```

##### **5. Docker Installation (Optional - for local testing)**
```bash
# Install Docker (Ubuntu/Debian)
sudo apt-get update
sudo apt-get install docker.io
sudo systemctl start docker
sudo systemctl enable docker

# Verify installation
docker --version
# Expected: Docker version 20.x.x or higher
```

</details>

### **System Requirements Check**
```bash
# Run our automated prerequisites check
./scripts/validation/test-phase-deployment.sh prerequisites

# This script will verify:
# - All required tools are installed
# - AWS credentials are configured
# - Correct AWS account access
# - Tool versions compatibility
```

### **AWS Account Setup**

#### **Step 1: Configure AWS Credentials**
```bash
# Configure AWS CLI with your credentials
aws configure

# You'll be prompted for:
# AWS Access Key ID: [Your Access Key]
# AWS Secret Access Key: [Your Secret Key]
# Default region name: us-east-1
# Default output format: json
```

**What these credentials do:**
- **Access Key ID**: Identifies your AWS account
- **Secret Access Key**: Authenticates your requests
- **Region**: Where your resources will be created (us-east-1 = N. Virginia)

#### **Step 2: Verify AWS Configuration**
```bash
# Verify AWS credentials and permissions
aws sts get-caller-identity

# Expected output:
# {
#     "UserId": "AIDACKCEVSQ6C2EXAMPLE",
#     "Account": "867344452513",
#     "Arn": "arn:aws:iam::867344452513:user/your-username"
# }

# Verify you have the correct account ID (867344452513)
```

#### **Step 3: Test AWS Permissions**
```bash
# Test EKS permissions
aws eks list-clusters --region us-east-1

# Test ECR permissions
aws ecr describe-repositories --region us-east-1 || echo "No repositories yet - this is expected"

# Test S3 permissions
aws s3 ls || echo "No buckets yet - this is expected"
```

**Note:** If you get permission errors, ensure your AWS user has the following policies:
- `AmazonEKSClusterPolicy`
- `AmazonEKSWorkerNodePolicy`
- `AmazonEKS_CNI_Policy`
- `AmazonEC2ContainerRegistryPowerUser`
- `AmazonS3FullAccess`
- `AmazonDynamoDBFullAccess`

**⏱️ Estimated Time: 30 minutes**

---

## 🛠️ Environment Preparation

### **Create Stage-3 Directory Structure**
```bash
# Navigate to project root
cd /home/ubuntu/Projects/Health_Care_Management_System/Project-Stages/Project-Stage-3-Advanced-DevOps-Pipeline

# Create essential directories
mkdir -p {scripts/{setup,migration,validation,operations,cleanup},terraform/{modules,environments,examples}}
mkdir -p {k8s/{base,overlays,monitoring},gitops/{applications,projects,environments}}
mkdir -p {monitoring/{prometheus,grafana,alertmanager,exporters},logging/{elasticsearch,logstash,kibana,filebeat}}
mkdir -p {src-code,helm-charts,configs/{environments,secrets,policies},tests/{unit,integration,e2e,performance}}
mkdir -p {docs,examples/{development,staging,production}}

echo "✅ Directory structure created successfully"
```

### **Set Environment Variables**
```bash
# Set Stage-3 environment variables
export STAGE3_PROJECT_ROOT="/home/ubuntu/Projects/Health_Care_Management_System/Project-Stages/Project-Stage-3-Advanced-DevOps-Pipeline"
export AWS_REGION="us-east-1"
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
export STAGE3_CLUSTER_NAME="healthcare-eks-stage3-dev"
export STAGE3_ECR_REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

# Save environment variables
cat >> ~/.bashrc << EOF
# Stage-3 Environment Variables
export STAGE3_PROJECT_ROOT="${STAGE3_PROJECT_ROOT}"
export AWS_REGION="${AWS_REGION}"
export AWS_ACCOUNT_ID="${AWS_ACCOUNT_ID}"
export STAGE3_CLUSTER_NAME="${STAGE3_CLUSTER_NAME}"
export STAGE3_ECR_REGISTRY="${STAGE3_ECR_REGISTRY}"
EOF

source ~/.bashrc
echo "✅ Environment variables configured"
```

**⏱️ Estimated Time: 15 minutes**

---

## 🏗️ AWS Backend Setup

**CRITICAL STEP:** Before deploying infrastructure, you must create AWS backend resources for Terraform state management.

### **What is Terraform Backend?**
Terraform backend stores the state of your infrastructure in a remote location (S3) with locking (DynamoDB) to prevent conflicts when multiple people work on the same infrastructure.

**Why do we need this?**
- **State Management**: Keeps track of what resources exist
- **Team Collaboration**: Multiple people can work on same infrastructure
- **State Locking**: Prevents conflicts during concurrent operations
- **State History**: Maintains versions of infrastructure changes

### **Step 1: Create AWS Backend Resources**
```bash
# Run the automated backend setup script
./scripts/setup/create-aws-backend.sh

# This script will create:
# - S3 bucket: healthcare-terraform-state-stage3-867344452513
# - DynamoDB table: healthcare-terraform-locks-stage3
# - Enable versioning and encryption on S3 bucket
```

**What this script does:**
1. **Checks AWS credentials** - Ensures you're authenticated with correct account
2. **Creates S3 bucket** - Stores Terraform state files securely
3. **Enables versioning** - Keeps history of state changes for rollback
4. **Enables encryption** - Secures state files with AES256 encryption
5. **Creates DynamoDB table** - Prevents concurrent Terraform runs
6. **Verifies resources** - Confirms everything was created correctly

### **Step 2: Verify Backend Resources**
```bash
# Verify S3 bucket was created
aws s3 ls | grep healthcare-terraform-state-stage3
# Expected: healthcare-terraform-state-stage3-867344452513

# Verify DynamoDB table was created
aws dynamodb describe-table --table-name healthcare-terraform-locks-stage3 --region us-east-1
# Expected: Table status should be "ACTIVE"

# Test S3 bucket access
aws s3 ls s3://healthcare-terraform-state-stage3-867344452513
# Expected: Empty bucket (no error)
```

### **Step 3: Test Prerequisites**
```bash
# Run comprehensive prerequisites test
./scripts/validation/test-phase-deployment.sh prerequisites

# This will verify:
# ✅ AWS CLI installed and configured
# ✅ Terraform installed with correct version
# ✅ kubectl installed and working
# ✅ Helm installed and working
# ✅ AWS credentials working
# ✅ Correct AWS account (867344452513)
# ✅ Backend resources created and accessible
```

**⏱️ Estimated Time: 10 minutes**

---

## 🐳 ECR Repository Setup

**CRITICAL STEP:** Before running the CI/CD pipeline, you must create ECR repositories for Docker images.

### **What are ECR Repositories?**
Amazon Elastic Container Registry (ECR) repositories store Docker images that will be built and deployed by the CI/CD pipeline. The pipeline will fail if these repositories don't exist.

### **🚀 Option 1: Automated ECR Setup (Recommended)**

**Use our automated script to create ECR repositories:**

```bash
# Navigate to project directory
cd Project-Stages/Project-Stage-3-Advanced-DevOps-Pipeline

# Run ECR repository creation script
./scripts/setup/create-ecr-repositories.sh
```

**Expected Output:**
```
🏗️ ECR Repository Setup for Stage-3
====================================
✅ Created repository: healthcare-frontend-stage3
✅ Created repository: healthcare-backend-stage3
🎉 All ECR repositories created successfully!
```

### **🔧 Option 2: Manual ECR Setup**

**If you prefer manual setup:**

```bash
# Create frontend repository
aws ecr create-repository \
    --repository-name healthcare-frontend-stage3 \
    --region us-east-1 \
    --image-scanning-configuration scanOnPush=true

# Create backend repository
aws ecr create-repository \
    --repository-name healthcare-backend-stage3 \
    --region us-east-1 \
    --image-scanning-configuration scanOnPush=true
```

### **Verification**

**Verify repositories were created:**
```bash
# List ECR repositories
aws ecr describe-repositories --region us-east-1 | grep healthcare

# Expected output:
# "repositoryName": "healthcare-frontend-stage3"
# "repositoryName": "healthcare-backend-stage3"
```

**⏱️ Estimated Time: 5 minutes**

---

## 🔄 AWS Account ID Replacement

**IMPORTANT:** The project contains hardcoded AWS Account ID `867344452513` that must be replaced with your AWS Account ID.

### **Step 1: Get Your AWS Account ID**

```bash
# Get your AWS Account ID
aws sts get-caller-identity --query Account --output text

# Example output: 123456789012
```

### **Step 2: Replace AWS Account ID in Configuration Files**

**Files that need AWS Account ID replacement:**

1. **Terraform Variables** (`terraform/environments/dev/terraform.tfvars`)
2. **S3 Bucket Names** (various configuration files)
3. **ECR Registry URLs** (Kubernetes manifests)

**🚀 Option 1: Automated Replacement (Recommended)**

```bash
# Replace AWS Account ID automatically
# Replace 867344452513 with your actual AWS Account ID
export YOUR_AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# Run replacement in terraform files
find terraform/ -name "*.tf" -o -name "*.tfvars" | xargs sed -i "s/867344452513/$YOUR_AWS_ACCOUNT_ID/g"

# Run replacement in Kubernetes manifests
find k8s/ -name "*.yaml" -o -name "*.yml" | xargs sed -i "s/867344452513/$YOUR_AWS_ACCOUNT_ID/g"

# Run replacement in scripts
find scripts/ -name "*.sh" | xargs sed -i "s/867344452513/$YOUR_AWS_ACCOUNT_ID/g"

echo "✅ AWS Account ID replacement completed for: $YOUR_AWS_ACCOUNT_ID"
```

**🔧 Option 2: Manual Replacement**

**Search and replace `867344452513` with your AWS Account ID in these files:**

- `terraform/environments/dev/terraform.tfvars`
- `k8s/applications/frontend/deployment.yaml`
- `k8s/applications/backend/deployment.yaml`
- `scripts/setup/create-ecr-repositories.sh`

### **Step 3: Verification**

**Verify replacement was successful:**
```bash
# Check if old AWS Account ID still exists
grep -r "867344452513" terraform/ k8s/ scripts/ || echo "✅ All AWS Account IDs replaced successfully"

# Verify your AWS Account ID is present
grep -r "$YOUR_AWS_ACCOUNT_ID" terraform/environments/dev/terraform.tfvars
```

**⏱️ Estimated Time: 5 minutes**

---

## 🔧 GitHub Configuration

### **Step 1: Fork the Repository (If Not Already Done)**
```bash
# If you haven't forked the repository yet:
# 1. Go to: https://github.com/RouteClouds/Health_Care_Management_System
# 2. Click "Fork" button
# 3. Clone your fork:

git clone https://github.com/YOUR_USERNAME/Health_Care_Management_System.git
cd Health_Care_Management_System
```

### **Step 2: Initialize Git for Stage-3 Directory**
```bash
# Navigate to Stage-3 directory
cd Project-Stages/Project-Stage-3-Advanced-DevOps-Pipeline

# Initialize git if not already done (usually already initialized from clone)
git status
# If you see "fatal: not a git repository", run:
# git init

# Configure git user (if not already configured globally)
git config user.name "Your Name"
git config user.email "your.email@example.com"

# Check current branch and remote
git branch -a
git remote -v

# Ensure you're on the main branch
git checkout main

# Pull latest changes to ensure you're up to date
git pull origin main
```

**What this does:**
- **Verifies Git setup**: Ensures the directory is properly tracked
- **Configures user info**: Sets up commit author information
- **Checks branch status**: Confirms you're on the correct branch
- **Syncs with remote**: Gets latest changes from GitHub
- **Prepares for commits**: Sets up for pipeline triggering

### **Step 3: Configure GitHub Secrets**
**Navigate to your GitHub repository → Settings → Secrets and variables → Actions**

**Required Secrets:**
```
AWS_ACCESS_KEY_ID = [Your AWS Access Key ID]
AWS_SECRET_ACCESS_KEY = [Your AWS Secret Access Key]
ECR_REGISTRY = 867344452513.dkr.ecr.us-east-1.amazonaws.com
```

**How to get AWS credentials:**
```bash
# If you don't have programmatic access keys:
# 1. Go to AWS Console → IAM → Users → Your User
# 2. Click "Security credentials" tab
# 3. Click "Create access key"
# 4. Choose "Command Line Interface (CLI)"
# 5. Copy the Access Key ID and Secret Access Key
```

### **Step 4: Test GitHub Actions Pipeline**

**Important**: The Stage-3 pipeline is triggered by changes in the Stage-3 directory, specifically in the `src-code/` folder.

#### **4.1: Trigger Pipeline with Source Code Change**
```bash
# Navigate to Stage-3 source code directory
cd src-code

# Make a meaningful change to trigger the pipeline
# Option 1: Update package.json version (recommended)
echo "Updating package.json to trigger pipeline..."
sed -i 's/"version": ".*"/"version": "1.0.1"/' package.json

# Option 2: Add a comment to a source file
echo "// Pipeline trigger test - $(date)" >> frontend/src/App.js

# Option 3: Update README in src-code
echo "# Pipeline Test - $(date)" >> README.md

# Verify the changes
git status
git diff
```

#### **4.2: Commit and Push Changes**
```bash
# Add the changes
git add .

# Commit with descriptive message
git commit -m "feat: trigger Stage-3 pipeline - update version to 1.0.1

- Updated package.json version for pipeline testing
- This change should trigger the Stage-3 CI/CD workflow
- Testing infrastructure deployment and container builds"

# Push to trigger the pipeline
git push origin main
```

#### **4.3: Monitor Pipeline Execution**
```bash
# The pipeline will be triggered automatically
# Monitor progress at: https://github.com/YOUR_USERNAME/Health_Care_Management_System/actions

echo "🚀 Pipeline triggered! Monitor at:"
echo "https://github.com/$(git config remote.origin.url | sed 's/.*github.com[:/]\([^/]*\)\/\([^.]*\).*/\1/')/Health_Care_Management_System/actions"
```

### **Step 5: Understanding the Pipeline Process Flow**

**Once you push changes to the Stage-3 directory, here's what happens:**

#### **🔄 Pipeline Trigger Conditions**
The Stage-3 pipeline triggers when:
- **Push to main branch** with changes in `Project-Stages/Project-Stage-3-Advanced-DevOps-Pipeline/**`
- **Pull request** targeting main branch with Stage-3 changes
- **Manual workflow dispatch** from GitHub Actions UI

#### **📋 Pipeline Execution Flow (6 Jobs)**

**Job 1: Terraform Validation (2-3 minutes)**
```
✅ Checkout code
✅ Setup Terraform
✅ Terraform fmt check
✅ Terraform init
✅ Terraform validate
✅ Terraform plan (dry-run)
```

**Job 2: Unit Tests (3-5 minutes)**
```
✅ Checkout code
✅ Setup Node.js
✅ Install dependencies
✅ Run frontend tests
✅ Run backend tests
✅ Generate test reports
```

**Job 3: Security Scanning (2-4 minutes)**
```
✅ Checkout code
✅ Run dependency vulnerability scan
✅ Run code security analysis
✅ Check for secrets in code
✅ Generate security report
```

**Job 4: Build and Push Images (5-8 minutes)**
```
✅ Checkout code
✅ Configure AWS credentials
✅ Login to Amazon ECR
✅ Build frontend Docker image
✅ Build backend Docker image
✅ Tag images with commit SHA
✅ Push images to ECR
```

**Job 5: Infrastructure Deployment (10-15 minutes)**
```
✅ Checkout code
✅ Setup Terraform
✅ Configure AWS credentials
✅ Terraform init with S3 backend
✅ Terraform plan
✅ Terraform apply (if approved)
✅ Update EKS cluster
✅ Verify infrastructure health
```

**Job 6: GitOps Deployment (3-5 minutes)**
```
✅ Checkout code
✅ Update GitOps manifests
✅ Update image tags in manifests
✅ Commit updated manifests
✅ Trigger ArgoCD sync
✅ Verify application deployment
```

#### **📊 Pipeline Success Indicators**
```
🟢 All jobs completed successfully
🟢 Infrastructure deployed/updated
🟢 Applications running in EKS
🟢 Health checks passing
🟢 Monitoring data flowing
```

#### **🔍 Monitoring Pipeline Progress**
```bash
# Watch pipeline in real-time
echo "Monitor pipeline at:"
echo "https://github.com/YOUR_USERNAME/Health_Care_Management_System/actions"

# Check specific workflow run
echo "Click on the latest 'Stage 3 CI (Advanced DevOps)' workflow run"

# Expected total time: 25-40 minutes for complete pipeline
```

#### **⚠️ Common Pipeline Issues**
- **ECR Authentication**: First-time ECR push may fail - repositories created by Terraform
- **Terraform State Lock**: Concurrent runs may conflict - wait for completion
- **Resource Limits**: AWS account limits may cause failures - check quotas
- **Network Issues**: Timeouts during downloads - retry pipeline

**⏱️ Estimated Time: 15 minutes setup + 25-40 minutes pipeline execution**

---

## 🔄 Migration from Stage-2 (Optional)

### **Phase 1: Backup Stage-2 Environment**
```bash
# Create backup of Stage-2 configurations
echo "📦 Creating Stage-2 backup..."

# Backup Kubernetes configurations
kubectl get all -n healthcare -o yaml > stage2-backup-$(date +%Y%m%d).yaml

# Backup GitHub Actions workflows
cp -r ../../.github/workflows/stage2-ci.yml ./backups/

echo "✅ Stage-2 backup completed"
```

### **Phase 2: Copy Stage-2 Assets**
```bash
# Copy source code from Stage-2
echo "📋 Copying Stage-2 assets..."

cp -r ../Project-Stage-2-Automated-CI-CD-Pipeline/src-code ./
cp -r ../Project-Stage-2-Automated-CI-CD-Pipeline/k8s ./k8s-stage2-base
cp -r ../Project-Stage-2-Automated-CI-CD-Pipeline/scripts ./scripts-stage2-base
cp -r ../Project-Stage-2-Automated-CI-CD-Pipeline/helm-charts ./
cp -r ../Project-Stage-2-Automated-CI-CD-Pipeline/configs ./configs-stage2-base

echo "✅ Stage-2 assets copied successfully"
```

### **Phase 3: Execute Automated Migration**
```bash
# Run automated migration script
echo "🚀 Starting automated migration to Stage-3..."

# Create ECR repositories
aws ecr create-repository --repository-name healthcare-frontend-stage3 --region $AWS_REGION || true
aws ecr create-repository --repository-name healthcare-backend-stage3 --region $AWS_REGION || true

# Update Docker registry references
find . -type f -name "*.yaml" -exec sed -i "s|routeclouds/healthcare-|${STAGE3_ECR_REGISTRY}/healthcare-|g" {} \;
find . -type f -name "*.yml" -exec sed -i "s|routeclouds/healthcare-|${STAGE3_ECR_REGISTRY}/healthcare-|g" {} \;

# Update package names
find . -name "package.json" -exec sed -i 's/"name": "healthcare-backend"/"name": "healthcare-backend-stage3"/g' {} \;
find . -name "package.json" -exec sed -i 's/"name": "routeclouds-health"/"name": "routeclouds-health-stage3"/g' {} \;

# Update database references
find . -type f -name "*.sql" -exec sed -i 's/healthcare_db/healthcare_stage3_db/g' {} \;
find . -type f -name "*.yaml" -exec sed -i 's/healthcare_db/healthcare_stage3_db/g' {} \;

# Update service names
find . -type f -name "*.yaml" -exec sed -i 's/-svc/-stage3-svc/g' {} \;

echo "✅ Migration completed successfully"
```

### **Phase 4: Validate Migration**
```bash
# Validate migration results
echo "🔍 Validating migration..."

# Check ECR repositories
aws ecr describe-repositories --repository-names healthcare-frontend-stage3 healthcare-backend-stage3 --region $AWS_REGION

# Validate naming conventions
echo "📝 Checking naming convention updates..."
grep -r "healthcare-stage3" . --include="*.yaml" --include="*.yml" | wc -l

# Check for remaining Stage-2 references
remaining_refs=$(grep -r "routeclouds/healthcare" . --include="*.yaml" --include="*.yml" | wc -l)
if [ $remaining_refs -eq 0 ]; then
    echo "✅ No remaining Stage-2 references found"
else
    echo "⚠️ Found $remaining_refs remaining Stage-2 references - manual review needed"
fi

echo "✅ Migration validation completed"
```

**⏱️ Estimated Time: 2-3 hours**

---

## 🏗️ Infrastructure Deployment

### **Phase 1: Terraform Backend Initialization**

**Note**: If you followed the AWS Backend Setup section, this is already done. Skip to Phase 2.

```bash
# If not already done, create backend resources using our script
./scripts/setup/create-aws-backend.sh

# Navigate to development environment
cd terraform/environments/dev

# Initialize Terraform with backend
terraform init

# Expected output:
# Initializing the backend...
# Successfully configured the backend "s3"!
# Terraform has been successfully initialized!
```

**What this does:**
- **Downloads providers**: AWS, random, TLS providers
- **Configures backend**: Connects to S3 bucket for state storage
- **Initializes modules**: Downloads VPC and EKS modules
- **Sets up locking**: Configures DynamoDB for state locking

### **Phase 2: Infrastructure Planning**
```bash
# Create execution plan
terraform plan -out=tfplan

# Review the plan output carefully
# Expected resources to be created:
# - VPC with public/private subnets
# - EKS cluster with managed node groups
# - RDS PostgreSQL database
# - ECR repositories for frontend/backend
# - S3 bucket for application assets
# - Security groups and IAM roles
```

**What to review in the plan:**
- **Resource Count**: Should show ~40-50 resources to be created
- **VPC Configuration**: 3 public + 3 private subnets across AZs
- **EKS Cluster**: Kubernetes version 1.28
- **RDS Instance**: PostgreSQL 15.4 with encryption
- **ECR Repositories**: healthcare-frontend-stage3, healthcare-backend-stage3

### **Phase 3: Infrastructure Deployment**
```bash
# Apply the infrastructure changes
terraform apply tfplan

# This will take 15-20 minutes to complete
# Monitor the progress and watch for any errors
```

**Deployment Timeline:**
- **VPC Creation**: 2-3 minutes
- **EKS Cluster**: 10-12 minutes
- **Node Groups**: 5-7 minutes
- **RDS Database**: 8-10 minutes
- **ECR & S3**: 1-2 minutes

**Expected Final Output:**
```
Apply complete! Resources: 45 added, 0 changed, 0 destroyed.

Outputs:

cluster_endpoint = "https://ABC123.gr7.us-east-1.eks.amazonaws.com"
cluster_id = "healthcare-eks-stage3-dev"
db_instance_endpoint = "healthcare-eks-stage3-dev-db.cluster-xyz.us-east-1.rds.amazonaws.com:5432"
ecr_repository_frontend_url = "867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-frontend-stage3"
ecr_repository_backend_url = "867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-backend-stage3"
```

### **Phase 4: Kubernetes Configuration**
```bash
# Update kubeconfig to connect to new EKS cluster
aws eks update-kubeconfig --region us-east-1 --name healthcare-eks-stage3-dev

# Verify cluster connectivity
kubectl cluster-info
# Expected: Kubernetes control plane is running at https://...

# Check node status
kubectl get nodes
# Expected: 2 nodes in Ready state

# Create healthcare namespace
kubectl create namespace healthcare-stage3-dev

# Verify namespace creation
kubectl get namespaces | grep healthcare-stage3-dev
```

**What this configures:**
- **kubectl context**: Connects to Stage-3 EKS cluster
- **Cluster access**: Verifies Kubernetes API connectivity
- **Node verification**: Ensures worker nodes are ready
- **Namespace creation**: Prepares for application deployment

### **Phase 5: Infrastructure Validation**
```bash
# Run infrastructure validation tests
cd ../../../
./scripts/validation/test-phase-deployment.sh 3

# Expected output:
# 🔍 Testing Phase 3: Infrastructure Validation
# ✅ Terraform formatting is correct
# ✅ Terraform initialization successful
# ✅ Terraform validation successful
# ✅ Valid manifest: gitops/applications/frontend-stage3.yaml
# ✅ Valid manifest: gitops/applications/backend-stage3.yaml
# 🎉 Phase 3: Infrastructure Validation - PASSED
```
else
    echo "❌ Infrastructure deployment cancelled"
fi

cd $STAGE3_PROJECT_ROOT
```

### **Phase 6: Verify Pipeline Integration**
```bash
# After infrastructure is deployed, test the complete pipeline
cd $STAGE3_PROJECT_ROOT

# Make a change to trigger the pipeline
echo "// Infrastructure deployed - testing pipeline integration - $(date)" >> src-code/frontend/src/App.js

# Commit and push to trigger pipeline
git add .
git commit -m "test: verify pipeline integration with deployed infrastructure

- Infrastructure is now deployed and ready
- Testing complete CI/CD pipeline flow
- Verifying ECR integration and EKS deployment"

git push origin main

# Monitor the pipeline execution
echo "🔍 Monitor pipeline at: https://github.com/$(git config remote.origin.url | sed 's/.*github.com[:/]\([^/]*\)\/\([^.]*\).*/\1/')/Health_Care_Management_System/actions"
echo ""
echo "Expected pipeline flow:"
echo "1. ✅ Terraform Validation (2-3 min) - Should detect no infrastructure changes"
echo "2. ✅ Unit Tests (3-5 min) - Should pass all tests"
echo "3. ✅ Security Scanning (2-4 min) - Should complete security checks"
echo "4. ✅ Build and Push Images (5-8 min) - Should push to deployed ECR"
echo "5. ✅ Infrastructure Deployment (10-15 min) - Should update existing resources"
echo "6. ✅ GitOps Deployment (3-5 min) - Should deploy to EKS cluster"
echo ""
echo "Total expected time: 25-40 minutes"
```

**Pipeline Integration Verification:**
- **✅ Terraform jobs**: Should use existing infrastructure (minimal changes)
- **✅ Build jobs**: Should push images to deployed ECR repositories
- **✅ Deployment jobs**: Should update running applications in EKS
- **✅ GitOps jobs**: Should sync with ArgoCD in deployed cluster

**⏱️ Estimated Time: 45-60 minutes infrastructure + 30 minutes pipeline testing**

---

## 🚀 Application Deployment

### **Phase 1: Configure kubectl for Stage-3**
```bash
# Update kubeconfig for new cluster
aws eks update-kubeconfig --region $AWS_REGION --name $STAGE3_CLUSTER_NAME

# Verify cluster access
kubectl cluster-info
kubectl get nodes

echo "✅ kubectl configured for Stage-3 cluster"
```

### **Phase 2: Deploy Core Applications**
```bash
# Deploy applications using GitOps
echo "🚀 Deploying applications via GitOps..."

# Create namespaces
kubectl create namespace healthcare-stage3-dev
kubectl create namespace argocd
kubectl create namespace monitoring
kubectl create namespace logging

# Deploy ArgoCD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for ArgoCD to be ready
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd

echo "✅ Core applications deployed"
```

**⏱️ Estimated Time: 30-45 minutes**

---

## 📊 Monitoring Setup

### **Phase 1: Deploy Prometheus Stack**
```bash
# Install Prometheus using Helm
echo "📊 Setting up monitoring stack..."

# Add Helm repositories
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Install Prometheus stack
helm install prometheus prometheus-community/kube-prometheus-stack \
    --namespace monitoring \
    --create-namespace \
    --set grafana.adminPassword=admin123 \
    --wait

echo "✅ Monitoring stack deployed"
```

### **Phase 2: Configure Dashboards**
```bash
# Access Grafana dashboard
echo "🎯 Grafana dashboard access:"
echo "URL: http://localhost:3000"
echo "Username: admin"
echo "Password: admin123"

# Port forward to access Grafana
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80 &

echo "✅ Monitoring configured and accessible"
```

**⏱️ Estimated Time: 30 minutes**

---

## ✅ Validation & Testing

### **Comprehensive System Validation**
```bash
# Run complete system validation
echo "🔍 Running comprehensive validation..."

# Check all pods are running
kubectl get pods --all-namespaces

# Verify applications are accessible
kubectl get services -n healthcare-stage3-dev

# Test monitoring endpoints
curl -s http://localhost:9090/api/v1/query?query=up | jq .

# Validate GitOps sync
kubectl get applications -n argocd

echo "✅ System validation completed"
```

**⏱️ Estimated Time: 15 minutes**

---

## 🔧 Troubleshooting

### **Common Issues & Solutions**

#### **ECR Authentication Issues**
```bash
# Re-authenticate with ECR
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $STAGE3_ECR_REGISTRY
```

#### **Terraform State Issues**
```bash
# Unlock Terraform state if locked
terraform force-unlock <lock-id>
```

#### **kubectl Access Issues**
```bash
# Reconfigure kubectl
aws eks update-kubeconfig --region $AWS_REGION --name $STAGE3_CLUSTER_NAME
```

For detailed troubleshooting, see [TROUBLESHOOTING.md](TROUBLESHOOTING.md)

---

## 🎉 Setup Complete!

**Congratulations!** Your Stage-3 Advanced DevOps Pipeline is now operational.

### **Next Steps:**
1. Review [Operations Manual](OPERATIONS.md) for day-to-day procedures
2. Study [Architecture Guide](ARCHITECTURE-guide.md) for system understanding
3. Monitor progress using [Project Tracker](Project-Tracker.md)
4. Explore advanced features and optimizations

**Total Setup Time: 4-6 hours**

---

*This guide provides a complete path from Stage-2 to a fully operational Stage-3 environment with enterprise-grade DevOps practices.*
