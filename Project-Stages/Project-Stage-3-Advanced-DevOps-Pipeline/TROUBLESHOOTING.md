# Stage-3 Troubleshooting Guide

## 📋 Table of Contents

1. [Quick Diagnostic Commands](#quick-diagnostic-commands)
2. [Git & Repository Issues](#git--repository-issues)
3. [GitHub Actions Pipeline Issues](#github-actions-pipeline-issues)
4. [ECR & Container Issues](#ecr--container-issues)
5. [Terraform Infrastructure Issues](#terraform-infrastructure-issues)
6. [GitOps & ArgoCD Issues](#gitops--argocd-issues)
7. [Monitoring & Observability Issues](#monitoring--observability-issues)
8. [Application-Specific Issues](#application-specific-issues)
9. [Network & Connectivity Issues](#network--connectivity-issues)
10. [Performance Issues](#performance-issues)
11. [Security Issues](#security-issues)
12. [Emergency Procedures](#emergency-procedures)

---

## 📁 Git & Repository Issues

### **Issue: Large Files Blocking Git Push**

**Problem**: Git push fails with errors about large files exceeding GitHub's limits.

**Error Messages**:
```
remote: error: File Project-Stages/Project-Stage-3-Advanced-DevOps-Pipeline/terraform/environments/dev/.terraform/providers/registry.terraform.io/hashicorp/aws/5.100.0/linux_amd64/terraform-provider-aws_v5.100.0_x5 is 674.20 MB; this exceeds GitHub's file size limit of 100.00 MB
remote: error: GH001: Large files detected. You may want to try Git Large File Storage - https://git-lfs.github.com.
```

**Root Cause**: Terraform provider files and `.terraform` directories were accidentally committed to the repository.

**Solution Steps**:

1. **Check for large files**:
```bash
# Find large files in repository
find . -type f -size +50M -exec ls -lh {} \;

# Check git status for large files
git status --porcelain | grep -E "\.terraform|terraform-provider"
```

2. **Create proper .gitignore files**:
```bash
# Root .gitignore
cat > .gitignore << 'EOF'
# Terraform files
**/.terraform/
**/.terraform.lock.hcl
**/terraform.tfstate
**/terraform.tfstate.backup
**/terraform.tfvars
**/terraform.tfvars.json
**/*.tfplan
**/*.tfstate
**/.terraform.tfstate.lock.info

# AWS credentials
**/.aws/
**/aws-credentials

# IDE files
.vscode/
.idea/
*.swp
*.swo
*~

# OS files
.DS_Store
Thumbs.db

# Logs
*.log
logs/

# Node modules
**/node_modules/
**/npm-debug.log*
**/yarn-debug.log*
**/yarn-error.log*

# Docker
**/.dockerignore

# Kubernetes
**/kubeconfig
**/.kube/

# Backup files
**/backup/
**/migration-backup*/

# Temporary files
**/tmp/
**/temp/
**/.tmp/

# Environment files
**/.env
**/.env.local
**/.env.production

# Build outputs
**/dist/
**/build/
**/target/

# Coverage reports
**/coverage/
**/.nyc_output/

# Package files
**/*.tgz
**/*.tar.gz
EOF

# Terraform-specific .gitignore
cat > Project-Stages/Project-Stage-3-Advanced-DevOps-Pipeline/terraform/.gitignore << 'EOF'
# Local .terraform directories
**/.terraform/*

# .tfstate files
*.tfstate
*.tfstate.*

# Crash log files
crash.log
crash.*.log

# Exclude all .tfvars files, which are likely to contain sensitive data
*.tfvars
*.tfvars.json

# Ignore override files as they are usually used to override resources locally
override.tf
override.tf.json
*_override.tf
*_override.tf.json

# Include override files you do wish to add to version control using negated pattern
# !example_override.tf

# Include tfplan files to ignore the plan output of command: terraform plan -out=tfplan
*tfplan*

# Ignore CLI configuration files
.terraformrc
terraform.rc

# Terraform lock file (optional - some teams commit this)
.terraform.lock.hcl
EOF
```

3. **Remove large files from git tracking**:
```bash
# Remove .terraform directories from git cache
git rm -r --cached "Project-Stages/Project-Stage-3-Advanced-DevOps-Pipeline/terraform/environments/dev/.terraform" 2>/dev/null || echo "Terraform directory not in cache"

# Clean up any remaining terraform state files
find . -name "*.tfstate*" -delete 2>/dev/null || echo "Cleaned up tfstate files"
```

4. **Use git filter-branch to remove from history**:
```bash
# Remove large files from entire git history
git filter-branch --force --index-filter 'git rm --cached --ignore-unmatch -r "Project-Stages/Project-Stage-3-Advanced-DevOps-Pipeline/terraform/environments/dev/.terraform"' --prune-empty --tag-name-filter cat -- --all
```

5. **Commit the fixes**:
```bash
# Add .gitignore files
git add .gitignore Project-Stages/Project-Stage-3-Advanced-DevOps-Pipeline/terraform/.gitignore

# Commit the fix
git commit -m "fix: remove large Terraform provider files and add proper .gitignore

- Added comprehensive .gitignore files to prevent large file commits
- Removed .terraform directories from git tracking
- Added Terraform-specific .gitignore in terraform directory
- Prevents future issues with large provider files (674MB AWS provider)
- Ensures only source code and configuration files are tracked"
```

6. **Force push to update remote repository**:
```bash
# Force push to update remote (WARNING: This rewrites history)
git push --force origin main
```

**Prevention**:
- Always add `.gitignore` files before running `terraform init`
- Never commit `.terraform/` directories
- Use `git status` before committing to check for large files
- Set up pre-commit hooks to prevent large file commits

---

## 🔄 GitHub Actions Pipeline Issues

### **Issue: Multiple Pipelines Triggering Simultaneously**

**Problem**: Both Stage-2 and Stage-3 pipelines trigger when making changes to Stage-3 source code.

**Symptoms**:
- Both "Stage 2 CI (Quality Gates)" and "Stage 3 CI (Advanced DevOps)" workflows run simultaneously
- Resource conflicts in AWS (Terraform state locks)
- Unexpected pipeline executions
- Confusion about which pipeline should be running

**Root Cause**: Overlapping or incorrect path patterns in GitHub Actions workflow trigger conditions.

**Diagnosis Steps**:

1. **Check current workflow trigger patterns**:
```bash
# Check Stage-2 pipeline triggers
grep -A 20 "paths:" .github/workflows/stage2-ci.yml

# Check Stage-3 pipeline triggers
grep -A 20 "paths:" .github/workflows/stage3-ci.yml
```

2. **Analyze recent commits and their triggers**:
```bash
# Check what files were changed in recent commits
git log --oneline -5
git show --name-only HEAD
git show --name-only HEAD~1
```

3. **Test pipeline isolation**:
```bash
# Run the pipeline isolation test script
./scripts/validation/test-pipeline-isolation.sh
```

**Solution Steps**:

1. **Fix Stage-2 pipeline triggers** (make them specific):
```yaml
# .github/workflows/stage2-ci.yml
on:
  push:
    branches: [ main, develop ]
    paths:
      - 'Project-Stages/Project-Stage-2-Automated-CI-CD-Pipeline/src-code/**'
      - 'Project-Stages/Project-Stage-2-Automated-CI-CD-Pipeline/k8s/**'
      - 'Project-Stages/Project-Stage-2-Automated-CI-CD-Pipeline/helm-charts/**'
      - 'Project-Stages/Project-Stage-2-Automated-CI-CD-Pipeline/scripts/**'
      - 'Project-Stages/Project-Stage-2-Automated-CI-CD-Pipeline/docs/**'
      - 'Project-Stages/Project-Stage-2-Automated-CI-CD-Pipeline/*.md'
      - '.github/workflows/stage2-ci.yml'
```

2. **Fix Stage-3 pipeline triggers** (comprehensive paths):
```yaml
# .github/workflows/stage3-ci.yml
on:
  push:
    branches: [ main, develop ]
    paths:
      - 'Project-Stages/Project-Stage-3-Advanced-DevOps-Pipeline/src-code/**'
      - 'Project-Stages/Project-Stage-3-Advanced-DevOps-Pipeline/terraform/**'
      - 'Project-Stages/Project-Stage-3-Advanced-DevOps-Pipeline/gitops/**'
      - 'Project-Stages/Project-Stage-3-Advanced-DevOps-Pipeline/k8s/**'
      - 'Project-Stages/Project-Stage-3-Advanced-DevOps-Pipeline/helm-charts/**'
      - 'Project-Stages/Project-Stage-3-Advanced-DevOps-Pipeline/scripts/**'
      - 'Project-Stages/Project-Stage-3-Advanced-DevOps-Pipeline/monitoring/**'
      - 'Project-Stages/Project-Stage-3-Advanced-DevOps-Pipeline/logging/**'
      - 'Project-Stages/Project-Stage-3-Advanced-DevOps-Pipeline/*.md'
      - '.github/workflows/stage3-ci.yml'
```

3. **Commit the pipeline isolation fixes**:
```bash
git add .github/workflows/stage2-ci.yml .github/workflows/stage3-ci.yml
git commit -m "fix: implement proper pipeline isolation between Stage-2 and Stage-3

- Updated Stage-2 pipeline to use specific directory paths instead of wildcards
- Updated Stage-3 pipeline with comprehensive path specifications
- Removed problematic path exclusion patterns that don't work reliably
- Added pipeline isolation testing script for validation
- Ensures Stage-2 and Stage-3 pipelines trigger independently
- Prevents simultaneous pipeline execution conflicts"

git push origin main
```

4. **Test the isolation**:
```bash
# Make a Stage-3 specific change to test
echo "// Stage-3 pipeline isolation test - $(date)" >> src-code/frontend/src/App.js
git add src-code/frontend/src/App.js
git commit -m "test: verify Stage-3 pipeline isolation

- Added test comment to Stage-3 frontend App.js
- This change should trigger ONLY Stage-3 pipeline
- Testing pipeline isolation after workflow path fixes"
git push origin main
```

**Verification**:
1. Visit GitHub Actions: https://github.com/USERNAME/Health_Care_Management_System/actions
2. Verify only the expected pipeline runs for each commit
3. Check that workflow file changes trigger their respective pipelines (expected behavior)

**Expected Behavior**:
- **Stage-3 src-code changes** → Only Stage-3 pipeline triggers
- **Stage-2 src-code changes** → Only Stage-2 pipeline triggers
- **Workflow file changes** → Respective pipeline triggers (correct behavior)
- **No simultaneous execution** conflicts

**Pipeline Isolation Test Results**:
```bash
# Expected output from test-pipeline-isolation.sh
🔍 Pipeline Isolation Testing
=============================

[SUCCESS] ✅ Stage-2 pipeline properly isolated from Stage-3
[SUCCESS] ✅ Stage-3 pipeline properly isolated from Stage-2
[SUCCESS] ✅ No overlapping paths found between pipelines
[SUCCESS] 🎉 All pipeline isolation tests PASSED!
```

**Common Mistakes to Avoid**:
- Using `paths-ignore` with `paths` (not supported together)
- Using overly broad wildcard patterns like `**`
- Forgetting that workflow file changes trigger their respective pipelines
- Not testing pipeline isolation after making changes

### **Pipeline Monitoring & Validation**

**Monitor Pipeline Execution**:
```bash
# Check recent commits and their expected triggers
git log --oneline -5

# Analyze what files changed in a specific commit
git show --name-only COMMIT_HASH

# Check if a commit should trigger Stage-2 or Stage-3
echo "Checking commit: $(git rev-parse HEAD)"
echo "Files changed:"
git show --name-only HEAD | grep -E "(Stage-2|Stage-3)"
```

**Validate Pipeline Behavior**:
```bash
# Test scenarios for pipeline triggers
echo "📋 Pipeline Trigger Test Scenarios:"
echo "=================================="
echo ""
echo "1. Stage-2 src-code change:"
echo "   File: Project-Stages/Project-Stage-2-Automated-CI-CD-Pipeline/src-code/app.js"
echo "   Expected: ✅ Stage-2 triggers, ❌ Stage-3 does NOT trigger"
echo ""
echo "2. Stage-3 src-code change:"
echo "   File: Project-Stages/Project-Stage-3-Advanced-DevOps-Pipeline/src-code/README.md"
echo "   Expected: ❌ Stage-2 does NOT trigger, ✅ Stage-3 triggers"
echo ""
echo "3. Stage-3 terraform change:"
echo "   File: Project-Stages/Project-Stage-3-Advanced-DevOps-Pipeline/terraform/main.tf"
echo "   Expected: ❌ Stage-2 does NOT trigger, ✅ Stage-3 triggers"
```

**GitHub Actions Monitoring Commands**:
```bash
# Quick check of GitHub Actions status (requires gh CLI)
gh workflow list
gh run list --limit 5

# Check specific workflow runs
gh run view --log  # View latest run logs
gh run list --workflow="Stage 3 CI (Advanced DevOps)" --limit 3
```

**Warning Signs of Pipeline Issues**:
- Both pipelines running simultaneously for the same commit
- Unexpected pipeline triggers (Stage-2 triggering on Stage-3 changes)
- Resource conflicts in AWS (Terraform state locks)
- Failed deployments due to concurrent infrastructure changes

### **Issue: Unit Tests Failing in GitHub Actions Pipeline**

**Problem**: GitHub Actions pipeline fails at "Unit Tests (Node 20.x)" job with React component import errors.

**Error Messages**:
```
Error: Element type is invalid: expected a string (for built-in components) or a class/function (for composite components) but got: undefined. You likely forgot to export your component from the file it's defined in, or you might have mixed up default and named imports.

FAIL  src/App.spec.tsx > App Component > renders the app successfully
FAIL  src/App.spec.tsx > App Component > displays navigation elements
FAIL  src/App.spec.tsx > App Component > shows authentication buttons
```

**Root Cause Analysis**:
1. **Frontend Issue**: Conflicting `App.js` and `App.tsx` files where test imports from wrong file
2. **Backend Issue**: Test expects different package name than actual package.json

**Solution Steps**:

1. **Fix Frontend Import Conflict**:
```bash
# Check for conflicting App files
ls -la src-code/frontend/src/App.*

# Remove incomplete App.js if it exists
rm src-code/frontend/src/App.js

# Verify App.tsx exists and is complete
cat src-code/frontend/src/App.tsx | head -20
```

2. **Fix Backend Package Name Test**:
```bash
# Check actual package name
grep '"name"' src-code/backend/package.json

# Update test to match actual package name
# Edit src-code/backend/src/app.test.ts
# Change: expect(packageJson.name).toBe('healthcare-backend');
# To: expect(packageJson.name).toBe('healthcare-backend-stage3');
```

3. **Test Locally Before Pushing**:
```bash
# Test frontend
cd src-code && npm run test:unit:frontend

# Test backend
npm run test:unit:backend

# Test complete suite
npm run test:unit
```

**Expected Test Results**:
```
✅ Frontend Tests:
 ✓ src/App.spec.tsx (3)
   ✓ App Component (3)
     ✓ renders the app successfully
     ✓ displays navigation elements
     ✓ shows authentication buttons

✅ Backend Tests:
 ✓ src/app.test.ts (3)
   ✓ Healthcare Backend - Basic Tests (3)
     ✓ should pass basic math test
     ✓ should validate environment setup
     ✓ should have correct package name

Total: 6/6 tests passed
```

4. **Commit and Push Fix**:
```bash
git add .
git commit -m "fix: resolve unit test failures in Stage-3 pipeline

Frontend Fix:
- Removed incomplete App.js file conflicting with App.tsx
- App.spec.tsx now correctly imports from App.tsx component

Backend Fix:
- Updated app.test.ts to expect correct package name
- Fixed package name assertion to match actual package.json

Test Results: ✅ 6/6 tests passed"

git push origin main
```

**Prevention**:
- Always test locally before pushing: `npm run test:unit`
- Avoid creating duplicate component files (App.js vs App.tsx)
- Keep test assertions in sync with actual package.json values
- Use consistent naming conventions across environments

### **Issue: Build and Push Images Stage Failure**

**Problem**: GitHub Actions pipeline fails at "Build and Push Images" job with exit code 1.

**Error Messages**:
```
Error: Process completed with exit code 1.
```

**Common Root Causes**:
1. **ECR repositories don't exist** (most common)
2. **AWS credentials issues**
3. **ECR authentication failure**
4. **Docker build failures**
5. **Missing Dockerfile files**

**Diagnosis Steps**:

1. **Check if ECR repositories exist**:
```bash
# Check if repositories exist
aws ecr describe-repositories --repository-names healthcare-frontend-stage3 --region us-east-1
aws ecr describe-repositories --repository-names healthcare-backend-stage3 --region us-east-1

# If repositories don't exist, you'll get:
# RepositoryNotFoundException: The repository with name 'healthcare-frontend-stage3' does not exist
```

2. **Test Docker builds locally**:
```bash
# Test frontend build
cd src-code
docker build -f Dockerfile.frontend -t test-frontend .

# Test backend build
docker build -f Dockerfile.backend -t test-backend .
```

3. **Check AWS credentials in GitHub Secrets**:
```bash
# Verify AWS credentials work locally
aws sts get-caller-identity
aws ecr get-login-token --region us-east-1
```

**Solution Steps**:

1. **Create ECR Repositories** (Most Common Fix):
```bash
# Use the automated script
./scripts/setup/create-ecr-repositories.sh

# Or create manually
aws ecr create-repository --repository-name healthcare-frontend-stage3 --region us-east-1
aws ecr create-repository --repository-name healthcare-backend-stage3 --region us-east-1
```

2. **Verify Repository Creation**:
```bash
# Check repositories exist
aws ecr describe-repositories --region us-east-1 | grep healthcare

# Expected output:
# "repositoryName": "healthcare-frontend-stage3"
# "repositoryName": "healthcare-backend-stage3"
```

3. **Test ECR Authentication**:
```bash
# Test ECR login
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <account-id>.dkr.ecr.us-east-1.amazonaws.com

# Should show: Login Succeeded
```

4. **Verify GitHub Secrets Configuration**:
Required secrets in GitHub repository settings:
```
AWS_ACCESS_KEY_ID=<your-access-key>
AWS_SECRET_ACCESS_KEY=<your-secret-key>
```

**Prevention**:
- Create ECR repositories before running pipeline
- Test Docker builds locally before pushing
- Verify AWS credentials and permissions
- Use ECR repository creation script for consistent setup

### **Issue: Infrastructure Deployment Stage Failure**

**Problem**: Terraform apply fails during infrastructure deployment with multiple errors.

**Common Error Messages**:
```
Error: Have got the following error while validating the existence of the ConfigMap "aws-auth":
Get "http://localhost/api/v1/namespaces/kube-system/configmaps/aws-auth": dial tcp [::1]:80: connect: connection refused

Error: creating RDS DB Instance: Cannot find version 15.4 for postgres

Error: creating ECR Repository: RepositoryAlreadyExistsException: The repository with name 'healthcare-frontend-stage3' already exists
```

**Root Causes**:
1. **Kubernetes provider dependency cycle** - Can't connect to EKS cluster during creation
2. **PostgreSQL version not supported** - Version 15.4 not available in AWS RDS
3. **ECR repositories already exist** - Terraform tries to create existing repositories
4. **AWS auth ConfigMap issues** - EKS module tries to manage ConfigMap before cluster is ready

**Diagnosis Steps**:

1. **Check PostgreSQL version availability**:
```bash
# Check available PostgreSQL versions
aws rds describe-db-engine-versions --engine postgres --query 'DBEngineVersions[?starts_with(EngineVersion, `15`)].EngineVersion' --output table --region us-east-1
```

2. **Verify ECR repositories exist**:
```bash
# Check if ECR repositories exist
aws ecr describe-repositories --repository-names healthcare-frontend-stage3 --region us-east-1
aws ecr describe-repositories --repository-names healthcare-backend-stage3 --region us-east-1
```

3. **Test Terraform plan**:
```bash
cd terraform/environments/dev
terraform plan
```

**Solution Steps**:

1. **Fix PostgreSQL Version**:
```bash
# Update postgres_version in variables.tf from 15.4 to 15.8
# File: terraform/modules/healthcare-platform/variables.tf
variable "postgres_version" {
  description = "PostgreSQL version"
  type        = string
  default     = "15.8"  # Changed from 15.4
}
```

2. **Fix ECR Repository Conflicts**:
```bash
# Convert ECR resources to data sources in main.tf
# File: terraform/modules/healthcare-platform/main.tf

# Replace resource blocks with data sources:
data "aws_ecr_repository" "frontend" {
  name = "healthcare-frontend-stage3"
}

data "aws_ecr_repository" "backend" {
  name = "healthcare-backend-stage3"
}
```

3. **Fix Kubernetes Provider Configuration**:
```bash
# Create providers.tf with minimal Kubernetes provider config
# File: terraform/environments/dev/providers.tf

provider "kubernetes" {
  # Use empty configuration during initial deployment
  # This will be properly configured after EKS cluster is created
}
```

4. **Disable AWS Auth ConfigMap Management**:
```bash
# Update EKS module configuration in main.tf
# File: terraform/modules/healthcare-platform/main.tf

module "eks" {
  # ... other configuration ...

  # Disable aws-auth ConfigMap management to avoid connection issues
  manage_aws_auth_configmap = false
  create_aws_auth_configmap = false
}
```

5. **Update ECR Outputs**:
```bash
# Update outputs.tf to reference data sources
# File: terraform/modules/healthcare-platform/outputs.tf

output "ecr_repository_frontend_url" {
  description = "URL of the frontend ECR repository"
  value       = data.aws_ecr_repository.frontend.repository_url  # Changed from aws_ecr_repository
}
```

**Verification**:

1. **Test Terraform Plan**:
```bash
cd terraform/environments/dev
terraform init -reconfigure
terraform plan

# Should show: Plan: 72 to add, 0 to change, 0 to destroy.
```

2. **Verify PostgreSQL Version**:
```bash
# Check that plan shows postgres version 15.8
terraform plan | grep engine_version
# Should show: engine_version = "15.8"
```

3. **Verify ECR Data Sources**:
```bash
# Check that ECR repositories are read as data sources
terraform plan | grep "data.aws_ecr_repository"
# Should show data sources being read, not resources being created
```

**Expected Success Output**:
```bash
# Terraform plan success
Plan: 72 to add, 0 to change, 0 to destroy.

# No dependency cycle errors
# No PostgreSQL version errors
# No ECR repository conflicts
# No Kubernetes provider connection errors
```

**Troubleshooting Specific Errors**:

1. **"Cannot find version 15.4 for postgres"**:
   - Update postgres_version variable to "15.8"
   - Check available versions with AWS CLI command above

2. **"RepositoryAlreadyExistsException"**:
   - Convert ECR resources to data sources
   - Update outputs to reference data sources

3. **"dial tcp [::1]:80: connect: connection refused"**:
   - Disable aws-auth ConfigMap management
   - Use minimal Kubernetes provider configuration

4. **"Dependency cycle" errors**:
   - Ensure Kubernetes provider doesn't reference EKS module outputs
   - Use empty provider configuration during initial deployment

**Prevention**:
- Always test Terraform plan before apply
- Use supported AWS service versions
- Handle existing resources with data sources or import
- Avoid circular dependencies between providers and resources

### **Issue: Infrastructure Deployment Resource Conflicts (Complete Analysis)**

**Problem**: Terraform apply fails due to existing AWS resources from previous deployment attempts, including hidden EKS infrastructure.

**Common Error Messages**:
```
Error: creating CloudWatch Logs Log Group (/aws/eks/healthcare-eks-stage3-dev/cluster):
ResourceAlreadyExistsException: The specified log group already exists

Error: creating KMS Alias (alias/eks/healthcare-eks-stage3-dev):
AlreadyExistsException: An alias with the name already exists

Error: creating RDS DB Subnet Group:
DBSubnetGroupAlreadyExists: The DB subnet group already exists

Error: creating S3 Bucket: BucketAlreadyExists

Error: Cannot delete the subnet group because at least one database instance is still using it
```

**Root Cause Analysis**:

**Primary Issue**: Hidden EKS infrastructure from previous deployment attempts
- Complete EKS cluster still running with active node groups
- RDS database instances using DB subnet groups
- CloudWatch log groups auto-created by EKS cluster
- KMS keys and aliases in use by existing resources
- S3 buckets from previous deployments

**Secondary Issues**:
- Terraform state inconsistency (resources exist but not tracked)
- Dependency conflicts (cannot delete subnet groups while DB instances exist)
- Resource recreation by AWS services (EKS auto-creates log groups)
- Partial cleanup leaving orphaned resources

**Why Simple Resource Deletion Fails**:
1. **Dependency Order**: Resources have dependencies that must be deleted in correct order
2. **Hidden Dependencies**: EKS cluster creates resources not visible in Terraform plan
3. **Auto-Recreation**: Some resources are automatically recreated by AWS services
4. **State Drift**: Terraform state doesn't reflect actual AWS resource state

**Comprehensive Diagnosis Steps**:

1. **Check for Hidden EKS Infrastructure**:
```bash
# Check if EKS cluster exists
aws eks describe-cluster --name healthcare-eks-stage3-dev --region us-east-1

# Check EKS node groups
aws eks list-nodegroups --cluster-name healthcare-eks-stage3-dev --region us-east-1

# Check cluster status and health issues
aws eks describe-cluster --name healthcare-eks-stage3-dev --query 'cluster.health.issues' --region us-east-1
```

2. **Check RDS Dependencies**:
```bash
# Check for RDS database instances
aws rds describe-db-instances --db-instance-identifier healthcare-eks-stage3-dev-db --region us-east-1

# Check DB subnet group usage
aws rds describe-db-subnet-groups --db-subnet-group-name healthcare-eks-stage3-dev-db-subnet-group --region us-east-1
```

3. **Check Individual Resources**:
```bash
# Check KMS alias and key status
aws kms list-aliases --query 'Aliases[?AliasName==`alias/eks/healthcare-eks-stage3-dev`]' --output table
aws kms describe-key --key-id alias/eks/healthcare-eks-stage3-dev --region us-east-1

# Check CloudWatch log group
aws logs describe-log-groups --log-group-name-prefix "/aws/eks/healthcare-eks-stage3-dev" --region us-east-1

# Check S3 bucket
aws s3 ls | grep healthcare-assets-stage3-dev
aws s3api head-bucket --bucket healthcare-assets-stage3-dev-867344452513 2>/dev/null && echo "Bucket exists" || echo "Bucket not found"
```

4. **Verify Terraform State vs Reality**:
```bash
cd terraform/environments/dev
terraform state list | grep -E "(eks|rds|s3|kms|cloudwatch)"
terraform plan | grep -E "(create|destroy|change)"
```

**Solution 1: Automated Cleanup Script (Recommended)**

**The Enhanced Cleanup Script handles complete infrastructure cleanup:**

```bash
# Run the comprehensive cleanup script
./scripts/cleanup/cleanup-existing-resources.sh
```

**Script Features**:
- ✅ **EKS Infrastructure**: Detects and removes complete EKS clusters with node groups
- ✅ **RDS Dependencies**: Handles database instances before subnet groups
- ✅ **Proper Order**: Deletes resources in correct dependency order
- ✅ **Wait Mechanisms**: Waits for long-running deletions (EKS: 10-15 min, Nodes: 5-10 min)
- ✅ **Error Handling**: Comprehensive error reporting and recovery
- ✅ **Progress Tracking**: Real-time status updates with time tracking
- ✅ **Verification**: Confirms successful deletion of all resources

**Expected Output**:
```
🧹 Cleanup Existing Resources for Stage-3
==========================================
[INFO] Using AWS Account: 867344452513
[INFO] Using AWS Region: us-east-1

[SUCCESS] ✅ Deleted S3 bucket: healthcare-assets-stage3-dev-867344452513
[SUCCESS] ✅ Deleted RDS database: healthcare-eks-stage3-dev-db
[SUCCESS] ✅ Deleted DB subnet group: healthcare-eks-stage3-dev-db-subnet-group
[SUCCESS] ✅ Deleted EKS node group: healthcare-nodes-20250815134807061900000016
[SUCCESS] ✅ Deleted EKS cluster: healthcare-eks-stage3-dev
[SUCCESS] ✅ Deleted CloudWatch log group: /aws/eks/healthcare-eks-stage3-dev/cluster
[SUCCESS] ✅ Deleted KMS alias: alias/eks/healthcare-eks-stage3-dev

🎉 All conflicting resources cleaned up successfully!
```

**Script Adaptability for Other Projects**:

The cleanup script can be easily adapted for other projects by modifying the configuration section:

```bash
# Configuration (modify for your project)
AWS_REGION="${AWS_REGION:-us-east-1}"
CLUSTER_NAME="your-cluster-name"
KMS_ALIAS="alias/eks/your-cluster-name"
LOG_GROUP="/aws/eks/your-cluster-name/cluster"
DB_SUBNET_GROUP="your-db-subnet-group-name"
S3_BUCKET="your-s3-bucket-name"
```

**Advantages of This Cleanup Approach**:
- ✅ **Reusable**: Easy to adapt for different projects and environments
- ✅ **Comprehensive**: Handles complex AWS infrastructure dependencies
- ✅ **Safe**: Proper error handling and confirmation before deletion
- ✅ **Efficient**: Parallel deletion where possible, sequential where required
- ✅ **Informative**: Detailed logging and progress reporting
- ✅ **Robust**: Handles timeouts and edge cases gracefully

**Solution 2: Step-by-Step Manual Resolution (Detailed Process)**

**This documents the exact process used to solve the infrastructure conflicts:**

**Step 1: Initial Error Analysis**
```bash
# Original Terraform error
Error: creating CloudWatch Logs Log Group (/aws/eks/healthcare-eks-stage3-dev/cluster):
operation error CloudWatch Logs: CreateLogGroup,
ResourceAlreadyExistsException: The specified log group already exists
```

**Step 2: Discover Hidden EKS Infrastructure**
```bash
# Check for existing EKS cluster
aws eks describe-cluster --name healthcare-eks-stage3-dev --region us-east-1

# Output revealed active cluster:
{
    "cluster": {
        "name": "healthcare-eks-stage3-dev",
        "status": "ACTIVE",
        "health": {
            "issues": [
                {
                    "code": "KmsKeyMarkedForDeletion",
                    "message": "Internal failure encountered when trying to validate resources"
                }
            ]
        }
    }
}
```

**Step 3: Identify All Dependent Resources**
```bash
# Check node groups
aws eks list-nodegroups --cluster-name healthcare-eks-stage3-dev --region us-east-1
# Output: "nodegroups": ["healthcare-nodes-20250815134807061900000016"]

# Check RDS database
aws rds describe-db-instances --db-instance-identifier healthcare-eks-stage3-dev-db --region us-east-1
# Output: "DBInstanceStatus": "available"

# Check S3 bucket
aws s3 ls | grep healthcare-assets-stage3-dev
# Output: 2025-08-15 13:37:13 healthcare-assets-stage3-dev-867344452513
```

**Step 4: Execute Proper Deletion Order**

**4a. Delete S3 Bucket First**
```bash
# Empty and delete S3 bucket
aws s3 rm s3://healthcare-assets-stage3-dev-867344452513 --recursive
aws s3 rb s3://healthcare-assets-stage3-dev-867344452513
# Output: remove_bucket: healthcare-assets-stage3-dev-867344452513
```

**4b. Delete RDS Database Instance**
```bash
# Delete RDS database (required before subnet group)
aws rds delete-db-instance --db-instance-identifier healthcare-eks-stage3-dev-db --skip-final-snapshot --region us-east-1

# Wait for deletion (2-5 minutes)
aws rds describe-db-instances --db-instance-identifier healthcare-eks-stage3-dev-db --region us-east-1 2>/dev/null || echo "RDS deleted"
# Output: RDS database deleted successfully
```

**4c. Delete DB Subnet Group**
```bash
# Now safe to delete subnet group
aws rds delete-db-subnet-group --db-subnet-group-name healthcare-eks-stage3-dev-db-subnet-group --region us-east-1
# Output: (no output = success)
```

**4d. Delete EKS Node Groups**
```bash
# Delete node groups first (EKS dependency)
aws eks delete-nodegroup --cluster-name healthcare-eks-stage3-dev --nodegroup-name healthcare-nodes-20250815134807061900000016 --region us-east-1

# Wait for node group deletion (5-10 minutes)
# Monitor status:
aws eks describe-nodegroup --cluster-name healthcare-eks-stage3-dev --nodegroup-name healthcare-nodes-20250815134807061900000016 --region us-east-1
# Output: Eventually returns "not found" error when deleted
```

**4e. Delete EKS Cluster**
```bash
# Delete the main EKS cluster
aws eks delete-cluster --name healthcare-eks-stage3-dev --region us-east-1

# Wait for cluster deletion (10-15 minutes)
# Monitor status:
aws eks describe-cluster --name healthcare-eks-stage3-dev --region us-east-1
# Output: Eventually returns "not found" error when deleted
```

**4f. Clean Up Remaining Resources**
```bash
# Delete CloudWatch log group (now safe after EKS deletion)
aws logs delete-log-group --log-group-name /aws/eks/healthcare-eks-stage3-dev/cluster --region us-east-1
# Output: (no output = success)

# Delete KMS alias and schedule key deletion
aws kms delete-alias --alias-name alias/eks/healthcare-eks-stage3-dev --region us-east-1
KEY_ID=$(aws kms list-aliases --query "Aliases[?AliasName=='alias/eks/healthcare-eks-stage3-dev'].TargetKeyId" --output text --region us-east-1)
aws kms schedule-key-deletion --key-id $KEY_ID --pending-window-in-days 7 --region us-east-1
# Output: Key scheduled for deletion
```

**Step 5: Verification of Complete Cleanup**
```bash
# Verify all resources are deleted
echo "=== VERIFICATION OF CLEANUP ==="

# Check EKS cluster
aws eks describe-cluster --name healthcare-eks-stage3-dev --region us-east-1 2>/dev/null || echo "✅ EKS cluster deleted"

# Check RDS database
aws rds describe-db-instances --db-instance-identifier healthcare-eks-stage3-dev-db --region us-east-1 2>/dev/null || echo "✅ RDS database deleted"

# Check DB subnet group
aws rds describe-db-subnet-groups --db-subnet-group-name healthcare-eks-stage3-dev-db-subnet-group --region us-east-1 2>/dev/null || echo "✅ DB subnet group deleted"

# Check CloudWatch log group
aws logs describe-log-groups --log-group-name-prefix "/aws/eks/healthcare-eks-stage3-dev" --region us-east-1 --query 'logGroups[0]' 2>/dev/null || echo "✅ CloudWatch log group deleted"

# Check S3 bucket
aws s3 ls | grep healthcare-assets-stage3-dev || echo "✅ S3 bucket deleted"

# Check KMS alias
aws kms describe-key --key-id alias/eks/healthcare-eks-stage3-dev --region us-east-1 2>/dev/null || echo "✅ KMS alias deleted"

# Expected output: All resources show as deleted
```

**Step 6: Terraform Validation**
```bash
# Test Terraform plan after cleanup
cd terraform/environments/dev
terraform plan

# Expected successful output:
# Plan: 16 to add, 1 to change, 0 to destroy.
# No resource conflicts detected
```

**Key Lessons Learned from This Issue**:

1. **Hidden Dependencies**: EKS clusters create resources not visible in Terraform plan
2. **Auto-Recreation**: AWS services automatically recreate certain resources (CloudWatch logs)
3. **Dependency Order**: Critical to delete resources in proper dependency order
4. **State Drift**: Terraform state may not reflect actual AWS resource state
5. **Comprehensive Discovery**: Must check for all related infrastructure, not just obvious resources

**Why This Issue Was Complex**:
- **Multiple Failure Points**: Each resource had different dependency requirements
- **Hidden Infrastructure**: EKS cluster was running but not immediately obvious
- **Auto-Recreation**: CloudWatch log group was being recreated by EKS cluster
- **Circular Dependencies**: RDS database prevented DB subnet group deletion
- **Time-Sensitive**: EKS deletions take 10-15 minutes, requiring proper waiting

**Critical Success Factors**:
1. **Complete Discovery**: Found the hidden EKS cluster causing issues
2. **Proper Order**: Deleted resources in correct dependency sequence
3. **Patience**: Waited for long-running deletions to complete
4. **Verification**: Confirmed each step before proceeding
5. **Automation**: Created reusable script for future occurrences

**Manual Cleanup (if script fails)**:

1. **Clean up S3 bucket**:
```bash
# Empty and delete S3 bucket
aws s3 rm s3://healthcare-assets-stage3-dev-867344452513 --recursive
aws s3 rb s3://healthcare-assets-stage3-dev-867344452513
```

2. **Clean up RDS DB subnet group**:
```bash
# Delete DB subnet group
aws rds delete-db-subnet-group --db-subnet-group-name healthcare-eks-stage3-dev-db-subnet-group
```

3. **Clean up CloudWatch log group**:
```bash
# Delete log group
aws logs delete-log-group --log-group-name /aws/eks/healthcare-eks-stage3-dev/cluster
```

4. **Clean up KMS alias and key**:
```bash
# Delete KMS alias
aws kms delete-alias --alias-name alias/eks/healthcare-eks-stage3-dev

# Get key ID and schedule deletion
KEY_ID=$(aws kms list-aliases --query "Aliases[?AliasName=='alias/eks/healthcare-eks-stage3-dev'].TargetKeyId" --output text)
aws kms schedule-key-deletion --key-id $KEY_ID --pending-window-in-days 7
```

**Verification**:

1. **Test Terraform plan after cleanup**:
```bash
cd terraform/environments/dev
terraform plan
# Should show: Plan: 15 to add, 0 to change, 0 to destroy.
```

2. **Verify no conflicts**:
```bash
# Should return empty or not found
aws kms describe-key --key-id alias/eks/healthcare-eks-stage3-dev 2>/dev/null || echo "KMS alias cleaned up"
aws logs describe-log-groups --log-group-name-prefix "/aws/eks/healthcare-eks-stage3-dev" --query 'logGroups[0]' 2>/dev/null || echo "Log group cleaned up"
aws s3 ls | grep healthcare-assets-stage3-dev || echo "S3 bucket cleaned up"
```

**Expected Success Output**:
```bash
# Cleanup script success
🎉 All conflicting resources cleaned up successfully!

# Terraform plan success
Plan: 15 to add, 0 to change, 0 to destroy.
```

**Alternative: Import Existing Resources (Advanced)**

If you want to keep existing resources and import them into Terraform state:

```bash
# Import existing resources (complex, use cleanup instead)
terraform import module.healthcare_infrastructure.aws_s3_bucket.healthcare_assets healthcare-assets-stage3-dev-867344452513
terraform import module.healthcare_infrastructure.aws_db_subnet_group.healthcare healthcare-eks-stage3-dev-db-subnet-group
# Note: Importing nested module resources is complex and error-prone
```

**Enhanced Prevention Strategies**:

1. **Pre-Deployment Checks**:
```bash
# Always check for existing resources before deployment
./scripts/cleanup/cleanup-existing-resources.sh --dry-run  # (if implemented)
terraform plan | grep -E "(create|destroy|change)"
```

2. **Proper Cleanup Procedures**:
```bash
# Always run complete cleanup before redeployment
terraform destroy -auto-approve  # If Terraform state is consistent
./scripts/cleanup/cleanup-existing-resources.sh  # If state is inconsistent
```

3. **State Management**:
```bash
# Regularly verify state consistency
terraform plan -detailed-exitcode
terraform state list | wc -l  # Count tracked resources
```

4. **Infrastructure Monitoring**:
```bash
# Monitor for orphaned resources
aws eks list-clusters --region us-east-1
aws rds describe-db-instances --region us-east-1
aws s3 ls | grep your-project-prefix
```

5. **CI/CD Pipeline Improvements**:
- Implement pre-deployment resource checks
- Add automatic cleanup on pipeline failure
- Use Terraform workspaces for environment isolation
- Implement proper state locking and backup

### **Summary: Complete Terraform Infrastructure Issues Resolution**

**This section documents the resolution of two major Terraform infrastructure deployment issues:**

#### **Issue 1: Initial Infrastructure Configuration Problems**
- **PostgreSQL Version Incompatibility**: Version 15.4 → 15.8 (AWS supported)
- **ECR Repository Conflicts**: Resources → Data sources for existing repositories
- **Kubernetes Provider Dependency Cycles**: Simplified provider configuration
- **AWS Auth ConfigMap Issues**: Disabled management during initial deployment

**Resolution**: Configuration fixes in Terraform modules and provider setup
**Result**: Terraform plan successful with 72 resources to create

#### **Issue 2: Hidden Infrastructure Resource Conflicts**
- **Root Cause**: Complete EKS cluster from previous deployment still running
- **Hidden Dependencies**: EKS cluster auto-creating CloudWatch log groups
- **Resource Chain**: EKS → Node Groups → RDS Database → DB Subnet Group → S3 → KMS
- **Complexity**: 15+ minute EKS deletion + dependency management

**Resolution**: Comprehensive cleanup script with proper dependency order
**Result**: Terraform plan successful with 16 resources to create

#### **Key Technical Insights**:

1. **AWS Service Behavior**:
   - EKS clusters automatically create CloudWatch log groups
   - RDS databases prevent DB subnet group deletion
   - KMS keys used by services cannot be immediately deleted
   - Resource dependencies are not always obvious

2. **Terraform State Management**:
   - State can become inconsistent with actual AWS resources
   - Manual resource deletion outside Terraform causes state drift
   - Import operations are complex for nested module resources

3. **Cleanup Strategy**:
   - Always check for complete infrastructure, not just obvious resources
   - Delete resources in proper dependency order
   - Wait for long-running deletions to complete
   - Verify each step before proceeding

#### **Reusable Solutions Created**:

1. **Enhanced Cleanup Script** (`scripts/cleanup/cleanup-existing-resources.sh`):
   - Handles complete EKS infrastructure cleanup
   - Proper dependency order management
   - Comprehensive error handling and progress reporting
   - Easily adaptable for other projects

2. **Terraform Configuration Fixes**:
   - PostgreSQL version compatibility
   - ECR data source patterns
   - Kubernetes provider configuration
   - AWS auth ConfigMap management

3. **Comprehensive Documentation**:
   - Step-by-step resolution process
   - Command examples with expected outputs
   - Prevention strategies and best practices
   - Troubleshooting methodology

**Total Resolution Time**: ~45 minutes (including EKS deletion wait times)
**Resources Cleaned**: 7 major AWS services with 15+ individual resources
**Automation Level**: Fully automated cleanup script + manual verification

### **Issue: GitOps Repository Permission Denied**

**Problem**: GitHub Actions workflow fails at GitOps deployment stage when trying to push updated image tags back to the repository.

**Error Message**:
```
remote: Permission to RouteClouds/Health_Care_Management_System.git denied to github-actions[bot].
fatal: unable to access 'https://github.com/RouteClouds/Health_Care_Management_System/': The requested URL returned error: 403
Error: Process completed with exit code 128.
```

**Root Cause**:
- GitHub Actions workflow lacks `contents: write` permission
- Default `GITHUB_TOKEN` has limited permissions for security
- GitOps step tries to push changes but is denied access
- Improper git configuration for automated commits

**Solution Applied**:

1. **Added Workflow Permissions**:
```yaml
permissions:
  contents: write          # Required to push changes back to repository
  pull-requests: read      # Required to read PR information
  actions: read           # Required to read workflow information
  security-events: write  # Required for security scanning results
```

2. **Fixed Checkout Step**:
```yaml
- name: Checkout
  uses: actions/checkout@v4
  with:
    token: ${{ secrets.GITHUB_TOKEN }}
    fetch-depth: 0
```

3. **Enhanced Git Configuration**:
```yaml
- name: Commit and push changes
  env:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
  run: |
    git config --local user.email "41898282+github-actions[bot]@users.noreply.github.com"
    git config --local user.name "github-actions[bot]"

    if git diff --quiet && git diff --staged --quiet; then
      echo "No changes to commit"
      exit 0
    fi

    git add Project-Stages/Project-Stage-3-Advanced-DevOps-Pipeline/gitops/
    git commit -m "Update Stage-3 image tags to ${{ github.sha }}"
    git push https://x-access-token:${GITHUB_TOKEN}@github.com/${{ github.repository }}.git HEAD:main
```

**Expected Success**: GitOps stage will now successfully update image tags and push changes to repository.

### **Issue: Persistent GitOps Permission Denied (Advanced Solution)**

**Problem**: Even after adding workflow permissions, GitOps deployment continues to fail with 403 errors.

**Advanced Solutions Applied**:

1. **Dedicated Git Action (Recommended)**:
```yaml
- name: Commit and push changes
  uses: stefanzweifel/git-auto-commit-action@v5
  with:
    commit_message: "Update Stage-3 image tags to ${{ github.sha }}"
    file_pattern: "Project-Stages/Project-Stage-3-Advanced-DevOps-Pipeline/gitops/"
    commit_user_name: "github-actions[bot]"
    commit_user_email: "41898282+github-actions[bot]@users.noreply.github.com"
    commit_author: "github-actions[bot] <41898282+github-actions[bot]@users.noreply.github.com>"
```

2. **Job-Level Permissions**:
```yaml
update-gitops:
  permissions:
    contents: write
    actions: read
```

3. **Enhanced Checkout Configuration**:
```yaml
- name: Checkout
  uses: actions/checkout@v4
  with:
    token: ${{ github.token }}
    persist-credentials: true
```

**Manual Fallback Solution**:

If GitHub Actions continues to fail, use the manual script:

```bash
# Update image tags manually
./scripts/gitops/update-image-tags.sh c1bc0c062492e0496faf56b5cd466a70184f1874

# Show current tags
./scripts/gitops/update-image-tags.sh show

# Get help
./scripts/gitops/update-image-tags.sh help
```

**Script Features**:
- ✅ **Automated Updates**: Updates both frontend and backend image tags
- ✅ **Verification**: Confirms changes were applied correctly
- ✅ **Git Integration**: Handles commit and push operations
- ✅ **Error Handling**: Comprehensive error checking and reporting
- ✅ **Flexible Usage**: Can be used in CI/CD or manually

**Why git-auto-commit-action Works Better**:
- **Built-in Authentication**: Handles GitHub token authentication automatically
- **Proven Solution**: Widely used in GitHub Actions workflows
- **Error Handling**: Built-in handling of no-changes scenarios
- **Maintenance**: Actively maintained and updated
- **Compatibility**: Works with various GitHub repository configurations

### **Quick Reference Commands**

**Git Repository Cleanup**:
```bash
# Emergency cleanup for large files
git filter-branch --force --index-filter 'git rm --cached --ignore-unmatch -r "**/.terraform"' --prune-empty --tag-name-filter cat -- --all
git push --force origin main

# Check repository size
du -sh .git/
git count-objects -vH
```

**Pipeline Trigger Testing**:
```bash
# Test Stage-3 pipeline trigger
echo "// Pipeline test - $(date)" >> src-code/frontend/src/App.js
git add src-code/frontend/src/App.js
git commit -m "test: Stage-3 pipeline trigger test"
git push origin main

# Validate pipeline isolation
./scripts/validation/test-pipeline-isolation.sh
```

**GitHub Actions Quick Check**:
```bash
# Check workflow files
grep -A 10 "paths:" .github/workflows/stage2-ci.yml
grep -A 10 "paths:" .github/workflows/stage3-ci.yml

# Monitor at: https://github.com/USERNAME/Health_Care_Management_System/actions
```

---

## 🔍 Quick Diagnostic Commands

### **System Health Check**
```bash
# Quick system overview
echo "🔍 System Health Check"
echo "====================="

# Cluster status
kubectl cluster-info
kubectl get nodes

# Pod status across all namespaces
kubectl get pods --all-namespaces | grep -v Running | grep -v Completed

# Critical services status
kubectl get pods -n healthcare-stage3-dev
kubectl get pods -n monitoring
kubectl get pods -n argocd

# Recent events
kubectl get events --sort-by='.lastTimestamp' | tail -10
```

### **Application Status Check**
```bash
# Application-specific diagnostics
kubectl describe deployment healthcare-frontend-stage3 -n healthcare-stage3-dev
kubectl describe deployment healthcare-backend-stage3 -n healthcare-stage3-dev

# Service endpoints
kubectl get services -n healthcare-stage3-dev
kubectl get ingress -n healthcare-stage3-dev

# Application logs (last 50 lines)
kubectl logs deployment/healthcare-frontend-stage3 -n healthcare-stage3-dev --tail=50
kubectl logs deployment/healthcare-backend-stage3 -n healthcare-stage3-dev --tail=50
```

---

## 📦 ECR & Container Issues

### **Issue 1: ECR Authentication Failures**

#### **Symptoms**
```
Error: Cannot perform an interactive login from a non TTY device
Error: no basic auth credentials
```

#### **Diagnosis**
```bash
# Check AWS credentials
aws sts get-caller-identity

# Check ECR permissions
aws ecr describe-repositories --region us-east-1

# Test ECR login
aws ecr get-login-password --region us-east-1
```

#### **Solutions**
```bash
# Solution 1: Re-authenticate with ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 867344452513.dkr.ecr.us-east-1.amazonaws.com

# Solution 2: Update GitHub Actions secrets
# Add/update these secrets in GitHub repository:
# - AWS_ACCESS_KEY_ID
# - AWS_SECRET_ACCESS_KEY
# - ECR_REGISTRY

# Solution 3: Fix IAM permissions
aws iam attach-role-policy --role-name GitHubActionsRole --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser
```

### **Issue 2: Image Pull Errors**

#### **Symptoms**
```
Error: ErrImagePull
Error: ImagePullBackOff
```

#### **Diagnosis**
```bash
# Check pod events
kubectl describe pod <pod-name> -n healthcare-stage3-dev

# Verify image exists in ECR
aws ecr describe-images --repository-name healthcare-frontend-stage3 --region us-east-1

# Check image tags
aws ecr list-images --repository-name healthcare-frontend-stage3 --region us-east-1
```

#### **Solutions**
```bash
# Solution 1: Verify image tag exists
kubectl get deployment healthcare-frontend-stage3 -n healthcare-stage3-dev -o yaml | grep image:

# Solution 2: Update deployment with correct image
kubectl set image deployment/healthcare-frontend-stage3 frontend=867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-frontend-stage3:latest -n healthcare-stage3-dev

# Solution 3: Check node ECR permissions
kubectl describe node <node-name> | grep -A 10 "System Info"
```

### **Issue 3: Repository Does Not Exist**

#### **Symptoms**
```
Error: repository does not exist or may require 'docker login'
```

#### **Solutions**
```bash
# Create missing ECR repository
aws ecr create-repository --repository-name healthcare-frontend-stage3 --region us-east-1
aws ecr create-repository --repository-name healthcare-backend-stage3 --region us-east-1

# Verify repository creation
aws ecr describe-repositories --repository-names healthcare-frontend-stage3 healthcare-backend-stage3 --region us-east-1
```

---

## 🏗️ Terraform Infrastructure Issues

### **Issue 1: State File Locked**

#### **Symptoms**
```
Error: Error acquiring the state lock
Error: state file is locked
```

#### **Diagnosis**
```bash
# Check DynamoDB lock table
aws dynamodb scan --table-name healthcare-terraform-locks-stage3 --region us-east-1

# Check who has the lock
terraform show
```

#### **Solutions**
```bash
# Solution 1: Wait for lock to release (if someone else is running terraform)
# Wait 10-15 minutes and try again

# Solution 2: Force unlock (use with caution)
terraform force-unlock <lock-id>

# Solution 3: Check for stuck processes
ps aux | grep terraform
kill -9 <terraform-process-id>
```

### **Issue 2: Resource Already Exists**

#### **Symptoms**
```
Error: resource already exists
Error: AlreadyExistsException
```

#### **Solutions**
```bash
# Solution 1: Import existing resource
terraform import aws_eks_cluster.healthcare healthcare-eks-stage3-dev

# Solution 2: Use data source instead of resource
# Replace resource block with data block in Terraform configuration

# Solution 3: Remove resource from state (if safe)
terraform state rm aws_eks_cluster.healthcare
```

### **Issue 3: Insufficient Permissions**

#### **Symptoms**
```
Error: AccessDenied
Error: UnauthorizedOperation
```

#### **Solutions**
```bash
# Check current IAM permissions
aws sts get-caller-identity
aws iam list-attached-role-policies --role-name <role-name>

# Add required permissions
aws iam attach-role-policy --role-name <role-name> --policy-arn arn:aws:iam::aws:policy/AmazonEKSClusterPolicy
```

---

## 🔄 GitOps & ArgoCD Issues

### **Issue 1: ArgoCD Application Out of Sync**

#### **Symptoms**
```
Status: OutOfSync
Health: Degraded
```

#### **Diagnosis**
```bash
# Check application status
argocd app get healthcare-frontend-stage3

# View differences
argocd app diff healthcare-frontend-stage3

# Check sync history
argocd app history healthcare-frontend-stage3
```

#### **Solutions**
```bash
# Solution 1: Manual sync
argocd app sync healthcare-frontend-stage3

# Solution 2: Force sync (ignores differences)
argocd app sync healthcare-frontend-stage3 --force

# Solution 3: Refresh application
argocd app refresh healthcare-frontend-stage3

# Solution 4: Hard refresh (re-read Git repository)
argocd app refresh healthcare-frontend-stage3 --hard
```

### **Issue 2: ArgoCD Server Not Accessible**

#### **Symptoms**
```
Error: connection refused
Error: server not found
```

#### **Solutions**
```bash
# Check ArgoCD pods
kubectl get pods -n argocd

# Restart ArgoCD server
kubectl rollout restart deployment/argocd-server -n argocd

# Port forward to ArgoCD
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Get ArgoCD admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

### **Issue 3: Git Repository Access Issues**

#### **Symptoms**
```
Error: authentication failed
Error: repository not found
```

#### **Solutions**
```bash
# Check repository configuration
argocd repo list

# Add repository with credentials
argocd repo add https://github.com/RouteClouds/Health_Care_Management_System.git --username <username> --password <token>

# Test repository connection
argocd repo get https://github.com/RouteClouds/Health_Care_Management_System.git
```

---

## 📊 Monitoring & Observability Issues

### **Issue 1: Prometheus Not Scraping Targets**

#### **Symptoms**
```
Status: DOWN in Prometheus targets
No metrics available
```

#### **Diagnosis**
```bash
# Check Prometheus targets
kubectl port-forward -n monitoring svc/prometheus-server 9090:80 &
curl http://localhost:9090/api/v1/targets

# Check service discovery
kubectl get servicemonitor -n monitoring
kubectl get endpoints -n healthcare-stage3-dev
```

#### **Solutions**
```bash
# Solution 1: Check service labels
kubectl get services -n healthcare-stage3-dev --show-labels

# Solution 2: Add Prometheus annotations
kubectl annotate service backend-stage3-svc prometheus.io/scrape=true -n healthcare-stage3-dev
kubectl annotate service backend-stage3-svc prometheus.io/port=3001 -n healthcare-stage3-dev

# Solution 3: Restart Prometheus
kubectl rollout restart deployment/prometheus-server -n monitoring
```

### **Issue 2: Grafana Dashboard Empty**

#### **Symptoms**
```
Error: No data
Error: Query returned empty result
```

#### **Solutions**
```bash
# Check Grafana data source
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80 &

# Verify Prometheus data source URL
# Should be: http://prometheus-server.monitoring.svc.cluster.local

# Test Prometheus connectivity from Grafana pod
kubectl exec -n monitoring deployment/prometheus-grafana -- curl http://prometheus-server.monitoring.svc.cluster.local/api/v1/query?query=up
```

### **Issue 3: Logs Not Appearing in Kibana**

#### **Symptoms**
```
No logs in Kibana
Elasticsearch indices empty
```

#### **Solutions**
```bash
# Check Filebeat status
kubectl get pods -n logging | grep filebeat

# Check Elasticsearch indices
kubectl exec -n logging deployment/elasticsearch -- curl localhost:9200/_cat/indices

# Restart log pipeline
kubectl rollout restart daemonset/filebeat -n logging
kubectl rollout restart deployment/logstash -n logging
```

---

## 🚀 Application-Specific Issues

### **Issue 1: Frontend Not Loading**

#### **Diagnosis**
```bash
# Check frontend pod status
kubectl get pods -n healthcare-stage3-dev | grep frontend

# Check frontend logs
kubectl logs deployment/healthcare-frontend-stage3 -n healthcare-stage3-dev

# Check service and ingress
kubectl get service frontend-stage3-svc -n healthcare-stage3-dev
kubectl get ingress -n healthcare-stage3-dev
```

#### **Solutions**
```bash
# Solution 1: Restart frontend deployment
kubectl rollout restart deployment/healthcare-frontend-stage3 -n healthcare-stage3-dev

# Solution 2: Check environment variables
kubectl describe deployment healthcare-frontend-stage3 -n healthcare-stage3-dev | grep -A 10 Environment

# Solution 3: Port forward for direct access
kubectl port-forward deployment/healthcare-frontend-stage3 3000:80 -n healthcare-stage3-dev
```

### **Issue 2: Backend API Errors**

#### **Diagnosis**
```bash
# Check backend logs for errors
kubectl logs deployment/healthcare-backend-stage3 -n healthcare-stage3-dev | grep -i error

# Test backend health endpoint
kubectl exec -n healthcare-stage3-dev deployment/healthcare-backend-stage3 -- curl localhost:3001/health

# Check database connectivity
kubectl exec -n healthcare-stage3-dev deployment/healthcare-backend-stage3 -- npm run db:check
```

#### **Solutions**
```bash
# Solution 1: Check database connection
kubectl get secret database-credentials-stage3 -n healthcare-stage3-dev -o yaml

# Solution 2: Restart backend with debug logging
kubectl set env deployment/healthcare-backend-stage3 LOG_LEVEL=debug -n healthcare-stage3-dev

# Solution 3: Scale backend pods
kubectl scale deployment healthcare-backend-stage3 --replicas=3 -n healthcare-stage3-dev
```

### **Issue 3: Database Connection Issues**

#### **Diagnosis**
```bash
# Check RDS instance status
aws rds describe-db-instances --db-instance-identifier healthcare-stage3-db

# Test database connectivity from backend pod
kubectl exec -n healthcare-stage3-dev deployment/healthcare-backend-stage3 -- pg_isready -h $DB_HOST -p 5432
```

#### **Solutions**
```bash
# Solution 1: Check security groups
aws ec2 describe-security-groups --group-ids <rds-security-group-id>

# Solution 2: Verify database credentials
kubectl get secret database-credentials-stage3 -n healthcare-stage3-dev -o jsonpath='{.data.password}' | base64 -d

# Solution 3: Check VPC connectivity
kubectl exec -n healthcare-stage3-dev deployment/healthcare-backend-stage3 -- nslookup $DB_HOST
```

---

## 🌐 Network & Connectivity Issues

### **Issue 1: Service Not Accessible**

#### **Diagnosis**
```bash
# Check service configuration
kubectl get service frontend-stage3-svc -n healthcare-stage3-dev -o yaml

# Check endpoints
kubectl get endpoints frontend-stage3-svc -n healthcare-stage3-dev

# Test internal connectivity
kubectl run test-pod --image=busybox --rm -it -- wget -qO- http://frontend-stage3-svc.healthcare-stage3-dev.svc.cluster.local
```

#### **Solutions**
```bash
# Solution 1: Check selector labels
kubectl get pods -n healthcare-stage3-dev --show-labels
kubectl get service frontend-stage3-svc -n healthcare-stage3-dev -o yaml | grep selector

# Solution 2: Recreate service
kubectl delete service frontend-stage3-svc -n healthcare-stage3-dev
kubectl apply -f k8s/services/frontend-service.yaml
```

### **Issue 2: Ingress Not Working**

#### **Solutions**
```bash
# Check ingress controller
kubectl get pods -n ingress-nginx

# Check ingress configuration
kubectl describe ingress healthcare-ingress-stage3 -n healthcare-stage3-dev

# Check DNS resolution
nslookup stage3.healthcare.example.com
```

---

## ⚡ Performance Issues

### **Issue 1: High Response Times**

#### **Diagnosis**
```bash
# Check resource utilization
kubectl top pods -n healthcare-stage3-dev
kubectl top nodes

# Check HPA status
kubectl get hpa -n healthcare-stage3-dev

# Review performance metrics
kubectl exec -n monitoring deployment/prometheus-server -- promtool query instant 'rate(http_request_duration_seconds[5m])'
```

#### **Solutions**
```bash
# Solution 1: Scale application
kubectl scale deployment healthcare-backend-stage3 --replicas=5 -n healthcare-stage3-dev

# Solution 2: Increase resource limits
kubectl patch deployment healthcare-backend-stage3 -n healthcare-stage3-dev -p '{"spec":{"template":{"spec":{"containers":[{"name":"backend","resources":{"limits":{"memory":"1Gi","cpu":"500m"}}}]}}}}'

# Solution 3: Enable caching
kubectl apply -f configs/redis-cache.yaml
```

---

## 🚨 Emergency Procedures

### **Complete System Recovery**

#### **Step 1: Assess Damage**
```bash
# Check what's working
kubectl get nodes
kubectl get pods --all-namespaces
kubectl get services --all-namespaces
```

#### **Step 2: Emergency Rollback**
```bash
# Rollback to last known good state
argocd app rollback healthcare-frontend-stage3 --revision <last-good-revision>
argocd app rollback healthcare-backend-stage3 --revision <last-good-revision>
```

#### **Step 3: Infrastructure Recovery**
```bash
# If infrastructure is damaged, restore from Terraform
cd terraform/environments/dev
terraform plan
terraform apply
```

#### **Step 4: Data Recovery**
```bash
# Restore database from backup
kubectl exec -n healthcare-stage3-dev deployment/healthcare-backend-stage3 -- psql -h $DB_HOST -U $DB_USER -d healthcare_stage3_db < /backups/latest-backup.sql
```

### **Emergency Contacts**
- **On-call Engineer**: [Phone/Slack]
- **DevOps Lead**: [Phone/Slack]
- **Platform Team**: [Phone/Slack]
- **Security Team**: [Phone/Slack]

---

## 📞 Escalation Procedures

### **Escalation Matrix**
1. **Level 1**: Self-service using this guide (0-30 minutes)
2. **Level 2**: Team lead assistance (30-60 minutes)
3. **Level 3**: Senior engineer involvement (1-2 hours)
4. **Level 4**: Management and vendor support (2+ hours)

### **When to Escalate**
- Issue not resolved within time limits
- Security incident detected
- Data loss suspected
- Multiple system failures
- Customer-facing impact

---

## 🚀 **ARGOCD DEPLOYMENT AND APPLICATION TROUBLESHOOTING**

### **Index: ArgoCD Issues**
1. [ArgoCD Installation Issues](#argocd-installation-issues)
2. [ArgoCD Application Sync Problems](#argocd-application-sync-problems)
3. [Healthcare Application CrashLoopBackOff](#healthcare-application-crashloopbackoff)
4. [Nginx Configuration Issues](#nginx-configuration-issues)
5. [Namespace and RBAC Issues](#namespace-and-rbac-issues)
6. [LoadBalancer and Service Issues](#loadbalancer-and-service-issues)

---

### **ArgoCD Installation Issues**

#### **Issue: ArgoCD Pods Not Starting**

**Problem**: ArgoCD pods stuck in `Pending` or `CrashLoopBackOff` state.

**Diagnosis Commands**:
```bash
# Check pod status
kubectl get pods -n argocd

# Check pod events
kubectl describe pods -n argocd

# Check node resources
kubectl top nodes

# Check persistent volume claims
kubectl get pvc -n argocd
```

**Common Causes & Solutions**:

1. **Insufficient Resources**:
```bash
# Check node capacity
kubectl describe nodes

# Solution: Scale up EKS node group
aws eks update-nodegroup-config \
  --cluster-name healthcare-eks-stage3-dev \
  --nodegroup-name healthcare-eks-stage3-dev-node-group \
  --scaling-config minSize=2,maxSize=6,desiredSize=3
```

2. **Storage Issues**:
```bash
# Check storage classes
kubectl get storageclass

# If no default storage class, set one
kubectl patch storageclass gp2 -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
```

#### **Issue: ArgoCD Server Not Accessible**

**Problem**: Cannot access ArgoCD UI via port-forward or LoadBalancer.

**Diagnosis Commands**:
```bash
# Check ArgoCD server status
kubectl get svc argocd-server -n argocd
kubectl get endpoints argocd-server -n argocd

# Check server logs
kubectl logs deployment/argocd-server -n argocd

# Test port-forward
kubectl port-forward svc/argocd-server -n argocd 8080:443 &
curl -k https://localhost:8080
```

**Solutions**:

1. **Port-Forward Issues**:
```bash
# Kill existing port-forwards
pkill -f "kubectl port-forward"

# Create new port-forward
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Test access
curl -k -I https://localhost:8080
```

2. **LoadBalancer Configuration**:
```bash
# Convert to LoadBalancer
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'

# Wait for external IP
kubectl get svc argocd-server -n argocd -w

# Check AWS Load Balancer
aws elbv2 describe-load-balancers --query 'LoadBalancers[?contains(LoadBalancerName, `argocd`)]'
```

---

### **ArgoCD Application Sync Problems**

#### **Issue: Applications Not Syncing**

**Problem**: ArgoCD applications show `Unknown` or `OutOfSync` status.

**Diagnosis Commands**:
```bash
# Check application status
kubectl get applications -n argocd

# Get detailed application info
kubectl describe application healthcare-frontend-stage3 -n argocd
kubectl describe application healthcare-backend-stage3 -n argocd

# Check ArgoCD application controller logs
kubectl logs statefulset/argocd-application-controller -n argocd
```

**Expected Healthy Output**:
```bash
kubectl get applications -n argocd
```
```
NAME                         SYNC STATUS   HEALTH STATUS
healthcare-backend-stage3    Synced        Healthy
healthcare-frontend-stage3   Synced        Healthy
```

**Solutions**:

1. **Manual Sync**:
```bash
# Force sync applications
kubectl patch application healthcare-frontend-stage3 -n argocd --type merge --patch '{"operation":{"sync":{"revision":"HEAD"}}}'
kubectl patch application healthcare-backend-stage3 -n argocd --type merge --patch '{"operation":{"sync":{"revision":"HEAD"}}}'
```

2. **Repository Access Issues**:
```bash
# Check if ArgoCD can access the repository
kubectl exec -it deployment/argocd-repo-server -n argocd -- sh
# Inside container:
git ls-remote https://github.com/RouteClouds/Health_Care_Management_System.git
```

3. **Path Issues**:
```bash
# Verify the GitOps path exists
ls -la Project-Stages/Project-Stage-3-Advanced-DevOps-Pipeline/gitops/environments/dev/

# Check manifest syntax
kubectl apply --dry-run=client -f gitops/environments/dev/
```

---

### **Healthcare Application CrashLoopBackOff**

#### **Issue: Frontend Pods in CrashLoopBackOff**

**Problem**: Frontend pods continuously restart due to configuration issues.

**Real-World Example from Our Deployment**:

**Diagnosis Commands**:
```bash
# Check pod status
kubectl get pods -n healthcare-stage3-dev
```

**Problematic Output**:
```
NAME                                          READY   STATUS             RESTARTS      AGE
healthcare-backend-stage3-656fb478f8-k879k    1/1     Running            0             6m
healthcare-backend-stage3-656fb478f8-ljsv2    1/1     Running            0             6m
healthcare-frontend-stage3-5db7f6d9b9-56kg4   0/1     CrashLoopBackOff   6 (64s ago)   6m
healthcare-frontend-stage3-5db7f6d9b9-7sc6j   0/1     CrashLoopBackOff   6 (43s ago)   6m
```

**Get Detailed Error Information**:
```bash
# Check pod logs
kubectl logs healthcare-frontend-stage3-5db7f6d9b9-56kg4 -n healthcare-stage3-dev

# Check pod events
kubectl describe pod healthcare-frontend-stage3-5db7f6d9b9-56kg4 -n healthcare-stage3-dev
```

**Actual Error Output**:
```
/docker-entrypoint.sh: /docker-entrypoint.d/ is not empty, will attempt to perform configuration
/docker-entrypoint.sh: Looking for shell scripts in /docker-entrypoint.d/
/docker-entrypoint.sh: Launching /docker-entrypoint.d/10-listen-on-ipv6-by-default.sh
10-listen-on-ipv6-by-default.sh: info: Getting the checksum of /etc/nginx/conf.d/default.conf
10-listen-on-ipv6-by-default.sh: info: Enabled listen on IPv6 in /etc/nginx/conf.d/default.conf
/docker-entrypoint.sh: Sourcing /docker-entrypoint.d/15-local-resolvers.envsh
/docker-entrypoint.sh: Launching /docker-entrypoint.d/20-envsubst-on-templates.sh
/docker-entrypoint.sh: Launching /docker-entrypoint.d/30-tune-worker-processes.sh
/docker-entrypoint.sh: Configuration complete; ready for start up
2025/08/15 19:34:11 [emerg] 1#1: host not found in upstream "backend-service" in /etc/nginx/nginx.conf:82
nginx: [emerg] host not found in upstream "backend-service" in /etc/nginx/nginx.conf:82
```

**Root Cause Analysis**:
The error shows nginx cannot resolve `backend-service` hostname. Let's check what services actually exist:

```bash
# Check actual service names
kubectl get services -n healthcare-stage3-dev
```

**Actual Services Output**:
```
NAME                  TYPE           CLUSTER-IP      EXTERNAL-IP                                                              PORT(S)        AGE
backend-stage3-svc    ClusterIP      172.20.171.59   <none>                                                                   3001/TCP       8m
frontend-stage3-svc   LoadBalancer   172.20.253.61   a46a32210135848f797d5b74ea975657-537872179.us-east-1.elb.amazonaws.com   80:31679/TCP   8m
```

**Problem Identified**:
- Nginx config references: `backend-service:3002`
- Actual service name: `backend-stage3-svc:3001`
- Port mismatch: 3002 vs 3001

---

### **Nginx Configuration Issues**

#### **Issue: Service Name and Port Mismatch**

**Step-by-Step Fix Process**:

**Step 1: Identify the Configuration File**
```bash
# Find nginx configuration
find . -name "nginx.conf" -type f
```

**Output**:
```
./Project-Stages/Project-Stage-3-Advanced-DevOps-Pipeline/src-code/nginx/nginx.conf
```

**Step 2: Check Current Configuration**
```bash
# Check current nginx upstream configuration
grep -A 5 -B 5 "backend-service" Project-Stages/Project-Stage-3-Advanced-DevOps-Pipeline/src-code/nginx/nginx.conf
```

**Problematic Configuration**:
```nginx
# Upstream backend servers (Docker Compose uses 'backend', Kubernetes uses 'backend-service')
upstream backend {
    server backend-service:3002 max_fails=3 fail_timeout=30s;
    keepalive 32;
}
```

**Step 3: Fix the Configuration**
```bash
# Edit the nginx configuration file
nano Project-Stages/Project-Stage-3-Advanced-DevOps-Pipeline/src-code/nginx/nginx.conf
```

**Corrected Configuration**:
```nginx
# Upstream backend servers (Stage-3 uses 'backend-stage3-svc')
upstream backend {
    server backend-stage3-svc:3001 max_fails=3 fail_timeout=30s;
    keepalive 32;
}
```

**Step 4: Commit and Push Changes**
```bash
# Add changes to git
git add Project-Stages/Project-Stage-3-Advanced-DevOps-Pipeline/src-code/nginx/nginx.conf

# Commit with descriptive message
git commit -m "fix: update nginx configuration for Stage-3 backend service

## Frontend Configuration Fix
- Updated nginx upstream configuration to use correct backend service name
- Changed from 'backend-service:3002' to 'backend-stage3-svc:3001'
- Matches the actual Kubernetes service name and port in Stage-3 deployment
- Resolves frontend CrashLoopBackOff due to upstream host not found error"

# Push to trigger pipeline
git push origin main
```

**Step 5: Monitor Pipeline and Deployment**
```bash
# Monitor GitHub Actions pipeline
# Go to: https://github.com/RouteClouds/Health_Care_Management_System/actions

# Wait for pipeline to complete (15-20 minutes)
# Pipeline will rebuild frontend image with fixed nginx config

# Monitor ArgoCD for automatic sync
kubectl get applications -n argocd -w

# Monitor pod updates
kubectl get pods -n healthcare-stage3-dev -w
```

**Step 6: Verify Fix**
```bash
# After pipeline completes, check pod status
kubectl get pods -n healthcare-stage3-dev

# Expected healthy output:
# NAME                                          READY   STATUS    RESTARTS   AGE
# healthcare-backend-stage3-xxx-xxx             1/1     Running   0          5m
# healthcare-frontend-stage3-xxx-xxx            1/1     Running   0          3m

# Check frontend logs for successful startup
kubectl logs deployment/healthcare-frontend-stage3 -n healthcare-stage3-dev

# Test application access
FRONTEND_URL=$(kubectl get svc frontend-stage3-svc -n healthcare-stage3-dev -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
curl -I http://$FRONTEND_URL
```

**Expected Healthy Log Output**:
```
/docker-entrypoint.sh: Configuration complete; ready for start up
2025/08/15 20:15:00 [notice] 1#1: using the "epoll" event method
2025/08/15 20:15:00 [notice] 1#1: nginx/1.21.6
2025/08/15 20:15:00 [notice] 1#1: built by gcc 10.2.1 20210110 (Debian 10.2.1-6)
2025/08/15 20:15:00 [notice] 1#1: OS: Linux 5.4.0-1043-aws
2025/08/15 20:15:00 [notice] 1#1: getrlimit(RLIMIT_NOFILE): 1048576:1048576
2025/08/15 20:15:00 [notice] 1#1: start worker processes
```

---

### **Namespace and RBAC Issues**

#### **Issue: Namespace Not Found Error**

**Problem**: Applications fail to deploy due to missing namespace.

**Error Example**:
```bash
kubectl apply -f gitops/environments/dev/
```

**Error Output**:
```
Error from server (NotFound): error when creating "gitops/environments/dev/backend.yaml": namespaces "healthcare-stage3-dev" not found
Error from server (NotFound): error when creating "gitops/environments/dev/frontend.yaml": namespaces "healthcare-stage3-dev" not found
```

**Solution**:
```bash
# Create the required namespace
kubectl create namespace healthcare-stage3-dev

# Verify namespace creation
kubectl get namespaces | grep healthcare

# Re-apply the manifests
kubectl apply -f gitops/environments/dev/

# Verify successful deployment
kubectl get pods -n healthcare-stage3-dev
```

**Prevention**: Update ArgoCD applications to auto-create namespaces:
```yaml
# In argocd/applications/*.yaml
spec:
  syncPolicy:
    syncOptions:
    - CreateNamespace=true
```

---

### **LoadBalancer and Service Issues**

#### **Issue: LoadBalancer Stuck in Pending**

**Problem**: Frontend service LoadBalancer shows `<pending>` for external IP.

**Diagnosis**:
```bash
# Check service status
kubectl get svc frontend-stage3-svc -n healthcare-stage3-dev

# Check AWS Load Balancer Controller
kubectl get pods -n kube-system | grep aws-load-balancer

# Check service events
kubectl describe svc frontend-stage3-svc -n healthcare-stage3-dev
```

**Solutions**:

1. **Install AWS Load Balancer Controller** (if missing):
```bash
# Download IAM policy
curl -o iam_policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.4.4/docs/install/iam_policy.json

# Create IAM policy
aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://iam_policy.json

# Install via Helm
helm repo add eks https://aws.github.io/eks-charts
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=healthcare-eks-stage3-dev
```

2. **Check Security Groups**:
```bash
# Get cluster security group
aws eks describe-cluster --name healthcare-eks-stage3-dev --query 'cluster.resourcesVpcConfig.clusterSecurityGroupId'

# Verify security group rules allow HTTP/HTTPS
aws ec2 describe-security-groups --group-ids sg-xxxxxxxxx
```

#### **Issue: Service Not Accessible Externally**

**Problem**: LoadBalancer has external IP but application not accessible.

**Diagnosis and Fix**:
```bash
# Test from within cluster
kubectl run test-pod --image=busybox --rm -it -- sh
# Inside pod:
wget -qO- http://frontend-stage3-svc.healthcare-stage3-dev.svc.cluster.local

# Test external access
FRONTEND_URL=$(kubectl get svc frontend-stage3-svc -n healthcare-stage3-dev -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
curl -v http://$FRONTEND_URL

# Check target group health
aws elbv2 describe-target-health --target-group-arn $(aws elbv2 describe-load-balancers --query 'LoadBalancers[?contains(LoadBalancerName, `frontend`)].[LoadBalancerArn]' --output text)
```

---

### **Quick Reference Commands**

#### **Health Check Commands**
```bash
# Overall system health
kubectl get pods --all-namespaces | grep -E "(Error|CrashLoop|Pending)"

# ArgoCD health
kubectl get applications -n argocd
kubectl get pods -n argocd

# Healthcare applications health
kubectl get pods,svc,hpa -n healthcare-stage3-dev

# Check logs for issues
kubectl logs -l app=healthcare-frontend -n healthcare-stage3-dev --tail=50
kubectl logs -l app=healthcare-backend -n healthcare-stage3-dev --tail=50
```

#### **Emergency Recovery Commands**
```bash
# Restart ArgoCD components
kubectl rollout restart deployment/argocd-server -n argocd
kubectl rollout restart statefulset/argocd-application-controller -n argocd

# Force application sync
kubectl patch application healthcare-frontend-stage3 -n argocd --type merge --patch '{"operation":{"sync":{"revision":"HEAD"}}}'

# Restart healthcare applications
kubectl rollout restart deployment/healthcare-frontend-stage3 -n healthcare-stage3-dev
kubectl rollout restart deployment/healthcare-backend-stage3 -n healthcare-stage3-dev

# Clean and redeploy
kubectl delete -f gitops/environments/dev/
kubectl apply -f gitops/environments/dev/
```

---

## 🚨 **LOADBALANCER TARGET HEALTH AND FRONTEND CRASHLOOPBACKOFF ISSUES**

### **Index: Critical Production Issues**
1. [LoadBalancer Target Nodes Unhealthy](#loadbalancer-target-nodes-unhealthy)
2. [Frontend Pods CrashLoopBackOff Persistent Issue](#frontend-pods-crashloopbackoff-persistent-issue)
3. [Image Update and Deployment Sync Issues](#image-update-and-deployment-sync-issues)
4. [AWS Load Balancer Target Group Health](#aws-load-balancer-target-group-health)
5. [Complete Fix Process with Verification](#complete-fix-process-with-verification)

---

### **LoadBalancer Target Nodes Unhealthy**

#### **Issue: AWS Load Balancer Target Group Shows Unhealthy Targets**

**Problem**: LoadBalancer has external IP but targets are unhealthy, causing 503/504 errors.

**Diagnosis Commands**:
```bash
# Check service and endpoints
kubectl get svc frontend-stage3-svc -n healthcare-stage3-dev
kubectl get endpoints frontend-stage3-svc -n healthcare-stage3-dev

# Check pod status
kubectl get pods -n healthcare-stage3-dev -o wide

# Check AWS target group health
FRONTEND_URL=$(kubectl get svc frontend-stage3-svc -n healthcare-stage3-dev -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
echo "Frontend URL: http://$FRONTEND_URL"

# Test external access
curl -I http://$FRONTEND_URL
```

**Current Problematic Output**:
```bash
kubectl get pods -n healthcare-stage3-dev
```
```
NAME                                          READY   STATUS             RESTARTS          AGE
healthcare-backend-stage3-656fb478f8-k879k    1/1     Running            0                 8h
healthcare-backend-stage3-656fb478f8-ljsv2    1/1     Running            0                 8h
healthcare-frontend-stage3-5db7f6d9b9-56kg4   0/1     CrashLoopBackOff   109 (2m43s ago)   8h
healthcare-frontend-stage3-5db7f6d9b9-7sc6j   0/1     CrashLoopBackOff   109 (3m21s ago)   8h
```

**Check Endpoints**:
```bash
kubectl get endpoints frontend-stage3-svc -n healthcare-stage3-dev
```

**Problematic Output (No Ready Endpoints)**:
```
NAME                  ENDPOINTS   AGE
frontend-stage3-svc   <none>      8h
```

**Root Cause**: Frontend pods are not running (CrashLoopBackOff), so no healthy endpoints exist for the LoadBalancer to route traffic to.

#### **AWS Load Balancer Target Group Analysis**

**Check Target Group Health via AWS CLI**:
```bash
# Get load balancer ARN
LB_ARN=$(aws elbv2 describe-load-balancers --query 'LoadBalancers[?contains(DNSName, `a46a32210135848f797d5b74ea975657-537872179.us-east-1.elb.amazonaws.com`)].LoadBalancerArn' --output text)

# Get target groups
aws elbv2 describe-target-groups --load-balancer-arn $LB_ARN

# Check target health
TG_ARN=$(aws elbv2 describe-target-groups --load-balancer-arn $LB_ARN --query 'TargetGroups[0].TargetGroupArn' --output text)
aws elbv2 describe-target-health --target-group-arn $TG_ARN
```

**Expected Unhealthy Output**:
```json
{
    "TargetHealthDescriptions": [
        {
            "Target": {
                "Id": "i-0123456789abcdef0",
                "Port": 31679
            },
            "TargetHealth": {
                "State": "unhealthy",
                "Reason": "Target.FailedHealthChecks",
                "Description": "Health checks failed"
            }
        }
    ]
}
```

---

### **Frontend Pods CrashLoopBackOff Persistent Issue**

#### **Issue: Frontend Pods Still Using Old Image with Wrong Configuration**

**Problem**: Despite nginx configuration fix, pods are still using old image with incorrect backend service name.

**Detailed Diagnosis Process**:

**Step 1: Check Current Pod Logs**
```bash
# Get current pod logs
kubectl logs healthcare-frontend-stage3-5db7f6d9b9-56kg4 -n healthcare-stage3-dev --tail=20
```

**Current Error Output**:
```
/docker-entrypoint.sh: Configuration complete; ready for start up
2025/08/16 04:27:23 [emerg] 1#1: host not found in upstream "backend-service" in /etc/nginx/nginx.conf:82
nginx: [emerg] host not found in upstream "backend-service" in /etc/nginx/nginx.conf:82
```

**Step 2: Check Current Image Being Used**
```bash
# Check deployment image
kubectl describe deployment healthcare-frontend-stage3 -n healthcare-stage3-dev | grep Image
```

**Current Output**:
```
Image: 867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-frontend-stage3:7b7660cd3cf1d09635c7d268aa91030f05e9b8a6
```

**Step 3: Check Latest Commit SHA**
```bash
# Get latest commit SHA
git log --oneline -1
```

**Expected Output**:
```
6e17bacd docs: comprehensive ArgoCD deployment and troubleshooting documentation
```

**Problem Identified**:
- Current image uses commit SHA: `7b7660cd` (old)
- Latest commit SHA: `6e17bacd` (new with nginx fix)
- **Issue**: Deployment is not using the latest image with the nginx fix

**Step 4: Check GitOps Manifest Current State**
```bash
# Check current GitOps manifest
grep "image:" gitops/environments/dev/frontend.yaml
```

**Current Output**:
```
image: 867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-frontend-stage3:7b7660cd3cf1d09635c7d268aa91030f05e9b8a6
```

**Step 5: Check if Pipeline Updated the Manifest**
```bash
# Check git log for GitOps updates
git log --oneline --grep="Update Stage-3 image tags" -5
```

---

### **Image Update and Deployment Sync Issues**

#### **Issue: GitOps Manifest Not Updated with Latest Image**

**Problem**: Pipeline may not have updated GitOps manifests with the new image containing the nginx fix.

**Diagnosis and Fix Process**:

**Step 1: Check Pipeline Status**
```bash
# Check if pipeline ran successfully
# Go to: https://github.com/RouteClouds/Health_Care_Management_System/actions

# Or check locally if GitOps job updated manifests
git log --oneline -10 | grep "Update Stage-3 image tags"
```

**Step 2: Manual GitOps Update (If Pipeline Failed)**
```bash
# Get latest commit SHA
LATEST_SHA=$(git rev-parse HEAD)
echo "Latest commit SHA: $LATEST_SHA"

# Update frontend manifest manually
sed -i "s|image: .*healthcare-frontend-stage3:.*|image: 867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-frontend-stage3:$LATEST_SHA|g" gitops/environments/dev/frontend.yaml

# Verify the change
grep "image:" gitops/environments/dev/frontend.yaml
```

**Expected Output After Update**:
```
image: 867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-frontend-stage3:6e17bacd
```

**Step 3: Commit GitOps Update**
```bash
# Add and commit the GitOps update
git add gitops/environments/dev/frontend.yaml
git commit -m "fix: update frontend image to latest commit with nginx configuration fix

- Updated frontend image tag from 7b7660cd to 6e17bacd
- New image contains nginx upstream fix: backend-stage3-svc:3001
- Resolves frontend CrashLoopBackOff and LoadBalancer target health issues"

# Push the update
git push origin main
```

**Step 4: Force ArgoCD Sync**
```bash
# Force ArgoCD to sync the new manifest
kubectl patch application healthcare-frontend-stage3 -n argocd --type merge --patch '{"operation":{"sync":{"revision":"HEAD"}}}'

# Alternative: Delete and recreate pods to pull new image
kubectl rollout restart deployment/healthcare-frontend-stage3 -n healthcare-stage3-dev

# Monitor the rollout
kubectl rollout status deployment/healthcare-frontend-stage3 -n healthcare-stage3-dev
```

**Step 5: Verify Image Update**
```bash
# Check if deployment is using new image
kubectl describe deployment healthcare-frontend-stage3 -n healthcare-stage3-dev | grep Image

# Expected output with new SHA:
# Image: 867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-frontend-stage3:6e17bacd
```

---

### **Complete Fix Process with Verification**

#### **Full Resolution Workflow**

**Phase 1: Immediate Fix - Update Image Manually**

```bash
# 1. Get current status
kubectl get pods -n healthcare-stage3-dev
kubectl get svc frontend-stage3-svc -n healthcare-stage3-dev

# 2. Update GitOps manifest with latest image
LATEST_SHA=$(git rev-parse HEAD)
sed -i "s|image: .*healthcare-frontend-stage3:.*|image: 867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-frontend-stage3:$LATEST_SHA|g" gitops/environments/dev/frontend.yaml

# 3. Verify the update
grep "image:" gitops/environments/dev/frontend.yaml

# 4. Apply the updated manifest
kubectl apply -f gitops/environments/dev/frontend.yaml

# 5. Monitor pod restart
kubectl get pods -n healthcare-stage3-dev -w
```

**Phase 2: Verify Fix Success**

```bash
# 1. Wait for pods to be running (may take 2-3 minutes)
kubectl wait --for=condition=ready pod -l app=healthcare-frontend -n healthcare-stage3-dev --timeout=300s

# 2. Check pod status
kubectl get pods -n healthcare-stage3-dev
```

**Expected Healthy Output**:
```
NAME                                          READY   STATUS    RESTARTS   AGE
healthcare-backend-stage3-656fb478f8-k879k    1/1     Running   0          8h
healthcare-backend-stage3-656fb478f8-ljsv2    1/1     Running   0          8h
healthcare-frontend-stage3-7c8d9f6b5a-abc12   1/1     Running   0          2m
healthcare-frontend-stage3-7c8d9f6b5a-def34   1/1     Running   0          2m
```

**Phase 3: Verify LoadBalancer Health**

```bash
# 1. Check endpoints are now available
kubectl get endpoints frontend-stage3-svc -n healthcare-stage3-dev
```

**Expected Healthy Output**:
```
NAME                  ENDPOINTS                     AGE
frontend-stage3-svc   10.0.1.100:80,10.0.2.200:80   8h
```

```bash
# 2. Test application access
FRONTEND_URL=$(kubectl get svc frontend-stage3-svc -n healthcare-stage3-dev -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
curl -I http://$FRONTEND_URL
```

**Expected Healthy Response**:
```
HTTP/1.1 200 OK
Server: nginx/1.21.6
Date: Fri, 16 Aug 2025 04:45:00 GMT
Content-Type: text/html
Content-Length: 1234
Connection: keep-alive
```

**Phase 4: Verify AWS Target Group Health**

```bash
# Check AWS target group health
LB_ARN=$(aws elbv2 describe-load-balancers --query 'LoadBalancers[?contains(DNSName, `a46a32210135848f797d5b74ea975657-537872179.us-east-1.elb.amazonaws.com`)].LoadBalancerArn' --output text)
TG_ARN=$(aws elbv2 describe-target-groups --load-balancer-arn $LB_ARN --query 'TargetGroups[0].TargetGroupArn' --output text)
aws elbv2 describe-target-health --target-group-arn $TG_ARN
```

**Expected Healthy Output**:
```json
{
    "TargetHealthDescriptions": [
        {
            "Target": {
                "Id": "i-0123456789abcdef0",
                "Port": 31679
            },
            "TargetHealth": {
                "State": "healthy",
                "Description": "Target is healthy"
            }
        }
    ]
}
```

---

### **Prevention and Monitoring**

#### **Automated Health Checks**

```bash
# Create health check script
cat > health-check.sh << 'EOF'
#!/bin/bash
echo "🏥 Healthcare System Health Check"
echo "================================"

# Check pod health
echo "📦 Pod Status:"
kubectl get pods -n healthcare-stage3-dev

# Check service endpoints
echo -e "\n🌐 Service Endpoints:"
kubectl get endpoints -n healthcare-stage3-dev

# Check external access
echo -e "\n🔗 External Access Test:"
FRONTEND_URL=$(kubectl get svc frontend-stage3-svc -n healthcare-stage3-dev -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
curl -s -I http://$FRONTEND_URL | head -1

# Check ArgoCD sync status
echo -e "\n🔄 ArgoCD Sync Status:"
kubectl get applications -n argocd

echo -e "\n✅ Health check completed"
EOF

chmod +x health-check.sh
```

#### **Monitoring Commands**

```bash
# Continuous monitoring
watch -n 30 'kubectl get pods -n healthcare-stage3-dev'

# Log monitoring
kubectl logs -f deployment/healthcare-frontend-stage3 -n healthcare-stage3-dev

# Event monitoring
kubectl get events -n healthcare-stage3-dev --sort-by='.lastTimestamp'
```

---

## 🔗 **STAGE-3 FRONTEND-BACKEND CONNECTIVITY COMPREHENSIVE SOLUTION**

### **Learning from Stage-1 & Stage-2 Issues**

Based on the connectivity problems encountered in previous stages, Stage-3 implements comprehensive solutions to prevent frontend-backend communication failures.

#### **Previous Stage Issues Identified**:
1. **Service Name Mismatches**: `backend-service:3002` vs actual service names
2. **Port Configuration Problems**: Frontend expecting wrong backend ports
3. **Nginx Proxy Misconfigurations**: Incorrect upstream server definitions
4. **Hardcoded URLs**: localhost references failing in Kubernetes
5. **Environment Variable Issues**: Missing or incorrect API base URLs

---

### **Stage-3 Connectivity Architecture**

#### **Service Naming Convention**
```
Stage-3 Service Names:
├── Frontend Service: frontend-stage3-svc (Port 80)
├── Backend Service: backend-stage3-svc (Port 3001)
├── Database Service: RDS PostgreSQL (Port 5432)
└── LoadBalancer: AWS ELB (Port 80 → frontend-stage3-svc:80)
```

#### **Network Flow Diagram**
```
Internet → AWS LoadBalancer → frontend-stage3-svc:80 → Frontend Pods
                                        ↓
                              nginx proxy_pass → backend-stage3-svc:3001 → Backend Pods
                                                                    ↓
                                                          RDS PostgreSQL:5432
```

---

### **Complete Connectivity Validation Process**

#### **Step 1: Verify Service Configurations**

```bash
# Check all services in healthcare namespace
kubectl get services -n healthcare-stage3-dev

# Expected output:
# NAME                  TYPE           CLUSTER-IP      EXTERNAL-IP                     PORT(S)        AGE
# backend-stage3-svc    ClusterIP      172.20.171.59   <none>                         3001/TCP       8h
# frontend-stage3-svc   LoadBalancer   172.20.253.61   a46a32...elb.amazonaws.com     80:31679/TCP   8h

# Verify service endpoints
kubectl get endpoints -n healthcare-stage3-dev

# Expected output:
# NAME                  ENDPOINTS                     AGE
# backend-stage3-svc    10.0.1.100:3001,10.0.2.200:3001   8h
# frontend-stage3-svc   10.0.1.101:80,10.0.2.201:80       8h
```

#### **Step 2: Validate Nginx Configuration**

```bash
# Check nginx configuration in frontend image
kubectl exec -it deployment/healthcare-frontend-stage3 -n healthcare-stage3-dev -- cat /etc/nginx/nginx.conf | grep -A 5 "upstream backend"

# Expected correct configuration:
# upstream backend {
#     server backend-stage3-svc:3001 max_fails=3 fail_timeout=30s;
#     keepalive 32;
# }

# Check proxy_pass configuration
kubectl exec -it deployment/healthcare-frontend-stage3 -n healthcare-stage3-dev -- cat /etc/nginx/nginx.conf | grep proxy_pass

# Expected output:
# proxy_pass http://backend;
```

#### **Step 3: Test Internal Service Connectivity**

```bash
# Test backend service from frontend pod
kubectl exec -it deployment/healthcare-frontend-stage3 -n healthcare-stage3-dev -- curl -I http://backend-stage3-svc:3001/health

# Expected healthy response:
# HTTP/1.1 200 OK
# Content-Type: application/json

# Test backend service DNS resolution
kubectl exec -it deployment/healthcare-frontend-stage3 -n healthcare-stage3-dev -- nslookup backend-stage3-svc

# Expected output:
# Name:    backend-stage3-svc.healthcare-stage3-dev.svc.cluster.local
# Address: 172.20.171.59
```

#### **Step 4: Validate External Access**

```bash
# Get LoadBalancer URL
FRONTEND_URL=$(kubectl get svc frontend-stage3-svc -n healthcare-stage3-dev -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
echo "Frontend URL: http://$FRONTEND_URL"

# Test frontend access
curl -I http://$FRONTEND_URL

# Test API proxy through frontend
curl -I http://$FRONTEND_URL/api/health

# Expected responses:
# Frontend: HTTP/1.1 200 OK (nginx serving React app)
# API: HTTP/1.1 200 OK (nginx proxying to backend)
```

---

### **Common Connectivity Issues and Solutions**

#### **Issue 1: Service Name Resolution Failures**

**Problem**: Frontend cannot resolve backend service name
**Symptoms**:
```
nginx: [emerg] host not found in upstream "backend-service" in /etc/nginx/nginx.conf:82
```

**Root Cause Analysis**:
```bash
# Check what services actually exist
kubectl get services -n healthcare-stage3-dev

# Check nginx configuration
kubectl exec -it deployment/healthcare-frontend-stage3 -n healthcare-stage3-dev -- cat /etc/nginx/nginx.conf | grep "server.*backend"
```

**Solution**:
```bash
# 1. Update nginx configuration to use correct service name
# Edit src-code/nginx/nginx.conf
sed -i 's/backend-service:3002/backend-stage3-svc:3001/g' src-code/nginx/nginx.conf

# 2. Rebuild and deploy frontend image
git add src-code/nginx/nginx.conf
git commit -m "fix: update nginx upstream to use correct Stage-3 service name"
git push origin main

# 3. Wait for pipeline to rebuild image and update GitOps manifests
# 4. Verify fix
kubectl logs deployment/healthcare-frontend-stage3 -n healthcare-stage3-dev --tail=10
```

#### **Issue 2: Port Mismatch Problems**

**Problem**: Frontend trying to connect to wrong backend port
**Symptoms**: Connection refused or 404 errors on API calls

**Diagnosis**:
```bash
# Check backend service port
kubectl get svc backend-stage3-svc -n healthcare-stage3-dev -o yaml | grep port

# Check nginx upstream configuration
kubectl exec -it deployment/healthcare-frontend-stage3 -n healthcare-stage3-dev -- cat /etc/nginx/nginx.conf | grep "server.*backend"

# Test connectivity with correct port
kubectl exec -it deployment/healthcare-frontend-stage3 -n healthcare-stage3-dev -- curl http://backend-stage3-svc:3001/health
```

**Solution**:
```bash
# Update nginx configuration with correct port
sed -i 's/:3002/:3001/g' src-code/nginx/nginx.conf

# Verify backend deployment port
kubectl get deployment healthcare-backend-stage3 -n healthcare-stage3-dev -o yaml | grep containerPort
# Should show: containerPort: 3001
```

#### **Issue 3: Environment Variable Misconfigurations**

**Problem**: Frontend using hardcoded URLs instead of relative paths
**Symptoms**: API calls work locally but fail in Kubernetes

**Diagnosis**:
```bash
# Check for hardcoded URLs in frontend code
grep -r "localhost:3000\|localhost:3002\|http://.*:300" src-code/frontend/ --exclude-dir=node_modules

# Check environment variables in frontend pod
kubectl exec -it deployment/healthcare-frontend-stage3 -n healthcare-stage3-dev -- env | grep API
```

**Solution**:
```bash
# 1. Update frontend to use relative API URLs
# In frontend code, use: /api/endpoint instead of http://localhost:3002/endpoint

# 2. Ensure nginx proxy configuration handles /api routes
grep -A 10 "location /api" src-code/nginx/nginx.conf

# Expected configuration:
# location /api/ {
#     proxy_pass http://backend/;
#     proxy_set_header Host $host;
#     proxy_set_header X-Real-IP $remote_addr;
# }
```

---

### **Stage-3 Connectivity Best Practices**

#### **1. Service Discovery Pattern**
```yaml
# Use Kubernetes DNS for service discovery
# Format: <service-name>.<namespace>.svc.cluster.local
# Short form: <service-name> (within same namespace)

# Example nginx upstream:
upstream backend {
    server backend-stage3-svc:3001;  # Short DNS name
    # OR
    server backend-stage3-svc.healthcare-stage3-dev.svc.cluster.local:3001;  # Full DNS name
}
```

#### **2. Port Standardization**
```
Frontend Service: 80 (HTTP)
Backend Service: 3001 (API)
Database: 5432 (PostgreSQL)
LoadBalancer: 80 → 80 (frontend)
```

#### **3. Environment-Specific Configurations**
```bash
# Development
VITE_API_BASE_URL=/api

# Production
VITE_API_BASE_URL=/api

# Local Development
VITE_API_BASE_URL=http://localhost:3001
```

#### **4. Health Check Endpoints**
```bash
# Frontend health check
curl http://frontend-stage3-svc/health

# Backend health check
curl http://backend-stage3-svc:3001/health

# End-to-end connectivity check
curl http://frontend-stage3-svc/api/health
```

---

### **Automated Connectivity Testing Script**

```bash
# Create comprehensive connectivity test
cat > test-connectivity.sh << 'EOF'
#!/bin/bash

echo "🔗 Stage-3 Connectivity Test"
echo "============================"

# Test 1: Service Discovery
echo "1. Testing Service Discovery..."
kubectl get services -n healthcare-stage3-dev

# Test 2: DNS Resolution
echo -e "\n2. Testing DNS Resolution..."
kubectl exec -it deployment/healthcare-frontend-stage3 -n healthcare-stage3-dev -- nslookup backend-stage3-svc

# Test 3: Internal Connectivity
echo -e "\n3. Testing Internal Connectivity..."
kubectl exec -it deployment/healthcare-frontend-stage3 -n healthcare-stage3-dev -- curl -s -I http://backend-stage3-svc:3001/health

# Test 4: External Access
echo -e "\n4. Testing External Access..."
FRONTEND_URL=$(kubectl get svc frontend-stage3-svc -n healthcare-stage3-dev -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
curl -s -I http://$FRONTEND_URL

# Test 5: API Proxy
echo -e "\n5. Testing API Proxy..."
curl -s -I http://$FRONTEND_URL/api/health

echo -e "\n✅ Connectivity test completed"
EOF

chmod +x test-connectivity.sh
```

---

### **Prevention Strategies**

#### **1. Configuration Validation**
```bash
# Pre-deployment validation script
cat > validate-stage3-config.sh << 'EOF'
#!/bin/bash

echo "🔍 Stage-3 Configuration Validation"
echo "==================================="

# Check nginx configuration
echo "1. Validating nginx configuration..."
grep "backend-stage3-svc:3001" src-code/nginx/nginx.conf || echo "❌ Nginx upstream incorrect"

# Check service manifests
echo "2. Validating service manifests..."
grep "port: 3001" gitops/environments/dev/backend.yaml || echo "❌ Backend port incorrect"
grep "port: 80" gitops/environments/dev/frontend.yaml || echo "❌ Frontend port incorrect"

# Check for hardcoded URLs
echo "3. Checking for hardcoded URLs..."
grep -r "localhost:300" src-code/ --exclude-dir=node_modules && echo "❌ Hardcoded URLs found"

echo "✅ Configuration validation completed"
EOF

chmod +x validate-stage3-config.sh
```

#### **2. Continuous Monitoring**
```bash
# Health monitoring script
cat > monitor-health.sh << 'EOF'
#!/bin/bash

while true; do
    echo "$(date): Checking connectivity..."

    # Check pod health
    kubectl get pods -n healthcare-stage3-dev | grep -E "(Error|CrashLoop|Pending)"

    # Check service endpoints
    kubectl get endpoints -n healthcare-stage3-dev | grep "<none>" && echo "❌ No endpoints available"

    # Test external access
    FRONTEND_URL=$(kubectl get svc frontend-stage3-svc -n healthcare-stage3-dev -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
    curl -s -f http://$FRONTEND_URL > /dev/null || echo "❌ Frontend not accessible"

    sleep 60
done
EOF

chmod +x monitor-health.sh
```

---

*This comprehensive connectivity solution addresses all frontend-backend communication issues identified in Stage-1 and Stage-2, providing robust service discovery, proper port configurations, and automated testing procedures for Stage-3.*

---

## 🔄 **GITOPS IMAGE UPDATE AUTOMATION AND MANUAL RECOVERY**

### **Critical Issue: Manual GitOps Updates Required**

**Problem**: Pipeline builds new images but GitOps manifests don't get updated automatically, requiring manual intervention every time there's a configuration fix.

**Impact**:
- Production deployments stuck with old images
- Manual intervention required for every fix
- Increased deployment time and human error risk
- Not sustainable for production environments

---

### **Immediate Manual Fix Process**

#### **Step 1: Identify Image Mismatch**

```bash
# Check current deployment image
kubectl describe deployment healthcare-frontend-stage3 -n healthcare-stage3-dev | grep Image

# Check latest commit SHA
LATEST_SHA=$(git rev-parse HEAD)
echo "Latest commit SHA: $LATEST_SHA"

# Check current GitOps manifest
grep "image:" gitops/environments/dev/frontend.yaml

# Compare and identify mismatch
echo "Deployment using: [old-sha]"
echo "Latest commit: $LATEST_SHA"
echo "GitOps manifest: [check output above]"
```

**Example Output Showing Mismatch**:
```
Deployment using: 6e17bacd4c284cebe1a6ec130929238ac134d9f7
Latest commit: d6cf0a1f8b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e
GitOps manifest: image: 867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-frontend-stage3:6e17bacd4c284cebe1a6ec130929238ac134d9f7
```

#### **Step 2: Manual GitOps Update**

```bash
# Update GitOps manifest with latest commit SHA
LATEST_SHA=$(git rev-parse HEAD)
sed -i "s|image: .*healthcare-frontend-stage3:.*|image: 867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-frontend-stage3:$LATEST_SHA|g" gitops/environments/dev/frontend.yaml

# Verify the update
grep "image:" gitops/environments/dev/frontend.yaml

# Apply the updated manifest
kubectl apply -f gitops/environments/dev/frontend.yaml

# Monitor pod restart
kubectl get pods -n healthcare-stage3-dev -w
```

#### **Step 3: Verify Fix Success**

```bash
# Wait for new pods to start
kubectl wait --for=condition=ready pod -l app=healthcare-frontend -n healthcare-stage3-dev --timeout=300s

# Check pod logs for successful startup
kubectl logs deployment/healthcare-frontend-stage3 -n healthcare-stage3-dev --tail=10

# Expected healthy output:
# 2025/08/16 05:15:00 [notice] 1#1: start worker processes
# (No nginx errors about backend-service)

# Test connectivity
FRONTEND_URL=$(kubectl get svc frontend-stage3-svc -n healthcare-stage3-dev -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
curl -I http://$FRONTEND_URL
```

---

### **Automated Solutions for Production**

#### **Solution 1: Enhanced GitOps Pipeline Job**

**Problem**: Current GitOps job in pipeline may not be working correctly.

**Fix**: Update `.github/workflows/stage3-ci.yml` with robust GitOps automation:

```yaml
  update-gitops:
    name: Update GitOps Repository
    runs-on: ubuntu-latest
    needs: [deploy-infrastructure]
    if: github.ref == 'refs/heads/main'
    permissions:
      contents: write
      actions: read
    steps:
      - name: Checkout
        uses: actions/checkout@v4
        with:
          token: ${{ github.token }}
          fetch-depth: 0

      - name: Update GitOps manifests
        working-directory: Project-Stages/Project-Stage-3-Advanced-DevOps-Pipeline/gitops
        env:
          IMAGE_TAG: ${{ github.sha }}
          ECR_REGISTRY: ${{ secrets.ECR_REGISTRY }}
        run: |
          echo "Updating GitOps manifests with image tag: $IMAGE_TAG"

          # Update frontend image tag
          sed -i "s|image: .*healthcare-frontend-stage3:.*|image: $ECR_REGISTRY/healthcare-frontend-stage3:$IMAGE_TAG|g" environments/dev/frontend.yaml

          # Update backend image tag
          sed -i "s|image: .*healthcare-backend-stage3:.*|image: $ECR_REGISTRY/healthcare-backend-stage3:$IMAGE_TAG|g" environments/dev/backend.yaml

          # Verify changes
          echo "=== GitOps Manifest Updates ==="
          echo "Frontend image updated:"
          grep "image:" environments/dev/frontend.yaml
          echo "Backend image updated:"
          grep "image:" environments/dev/backend.yaml

      - name: Commit and push changes
        uses: stefanzweifel/git-auto-commit-action@v5
        with:
          commit_message: "Update Stage-3 image tags to ${{ github.sha }}"
          file_pattern: "Project-Stages/Project-Stage-3-Advanced-DevOps-Pipeline/gitops/"
          commit_user_name: "github-actions[bot]"
          commit_user_email: "41898282+github-actions[bot]@users.noreply.github.com"
          commit_author: "github-actions[bot] <41898282+github-actions[bot]@users.noreply.github.com>"

      - name: Trigger ArgoCD Sync
        run: |
          echo "GitOps manifests updated. ArgoCD will sync automatically."
          echo "Manual sync command if needed:"
          echo "kubectl patch application healthcare-frontend-stage3 -n argocd --type merge --patch '{\"operation\":{\"sync\":{\"revision\":\"HEAD\"}}}'"
```

#### **Solution 2: ArgoCD Image Updater**

**Install ArgoCD Image Updater for automatic image updates**:

```bash
# Install ArgoCD Image Updater
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj-labs/argocd-image-updater/stable/manifests/install.yaml

# Configure image updater for healthcare applications
cat > argocd-image-updater-config.yaml << 'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-image-updater-config
  namespace: argocd
data:
  registries.conf: |
    registries:
    - name: ECR
      api_url: https://867344452513.dkr.ecr.us-east-1.amazonaws.com
      prefix: 867344452513.dkr.ecr.us-east-1.amazonaws.com
      ping: yes
      credentials: ext:/scripts/auth1.sh
      credsexpire: 10h
EOF

kubectl apply -f argocd-image-updater-config.yaml
```

**Update ArgoCD applications with image updater annotations**:

```yaml
# Add to argocd/applications/healthcare-frontend-app.yaml
metadata:
  annotations:
    argocd-image-updater.argoproj.io/image-list: frontend=867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-frontend-stage3
    argocd-image-updater.argoproj.io/frontend.update-strategy: latest
    argocd-image-updater.argoproj.io/write-back-method: git
```

#### **Solution 3: Automated Recovery Script**

**Create automated recovery script for immediate use**:

```bash
cat > fix-gitops-sync.sh << 'EOF'
#!/bin/bash

echo "🔄 GitOps Sync Fix Script"
echo "========================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Configuration
ECR_REGISTRY="867344452513.dkr.ecr.us-east-1.amazonaws.com"
NAMESPACE="healthcare-stage3-dev"
GITOPS_DIR="gitops/environments/dev"

# Step 1: Check current state
log_info "Checking current deployment state..."
kubectl get pods -n $NAMESPACE

# Step 2: Get latest commit SHA
LATEST_SHA=$(git rev-parse HEAD)
log_info "Latest commit SHA: $LATEST_SHA"

# Step 3: Check current GitOps manifest
log_info "Current GitOps manifest:"
grep "image:" $GITOPS_DIR/frontend.yaml

# Step 4: Update GitOps manifests
log_info "Updating GitOps manifests..."
sed -i "s|image: .*healthcare-frontend-stage3:.*|image: $ECR_REGISTRY/healthcare-frontend-stage3:$LATEST_SHA|g" $GITOPS_DIR/frontend.yaml
sed -i "s|image: .*healthcare-backend-stage3:.*|image: $ECR_REGISTRY/healthcare-backend-stage3:$LATEST_SHA|g" $GITOPS_DIR/backend.yaml

# Step 5: Verify updates
log_info "Updated manifests:"
echo "Frontend:" && grep "image:" $GITOPS_DIR/frontend.yaml
echo "Backend:" && grep "image:" $GITOPS_DIR/backend.yaml

# Step 6: Apply updates
log_info "Applying updated manifests..."
kubectl apply -f $GITOPS_DIR/

# Step 7: Monitor deployment
log_info "Monitoring deployment..."
kubectl rollout status deployment/healthcare-frontend-stage3 -n $NAMESPACE --timeout=300s
kubectl rollout status deployment/healthcare-backend-stage3 -n $NAMESPACE --timeout=300s

# Step 8: Verify health
log_info "Verifying application health..."
kubectl get pods -n $NAMESPACE

# Step 9: Test connectivity
log_info "Testing connectivity..."
FRONTEND_URL=$(kubectl get svc frontend-stage3-svc -n $NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
if curl -s -I http://$FRONTEND_URL | grep -q "200 OK"; then
    log_success "✅ Frontend accessible: http://$FRONTEND_URL"
else
    log_warning "⚠️ Frontend may still be starting up"
fi

if curl -s -I http://$FRONTEND_URL/api/health | grep -q "200 OK"; then
    log_success "✅ Backend API accessible via frontend proxy"
else
    log_warning "⚠️ Backend API may still be starting up"
fi

log_success "🎉 GitOps sync fix completed!"
echo ""
echo "Next steps:"
echo "1. Monitor pods: kubectl get pods -n $NAMESPACE -w"
echo "2. Check logs: kubectl logs deployment/healthcare-frontend-stage3 -n $NAMESPACE"
echo "3. Test app: curl -I http://$FRONTEND_URL"
EOF

chmod +x fix-gitops-sync.sh
```

#### **Solution 4: Continuous Monitoring and Auto-Fix**

**Create monitoring script that auto-fixes GitOps sync issues**:

```bash
cat > monitor-and-fix.sh << 'EOF'
#!/bin/bash

echo "🔍 Continuous GitOps Monitor and Auto-Fix"
echo "========================================"

NAMESPACE="healthcare-stage3-dev"
CHECK_INTERVAL=60  # Check every 60 seconds

while true; do
    echo "$(date): Checking GitOps sync status..."

    # Check for CrashLoopBackOff pods
    CRASH_PODS=$(kubectl get pods -n $NAMESPACE | grep CrashLoopBackOff | wc -l)

    if [ $CRASH_PODS -gt 0 ]; then
        echo "⚠️ Found $CRASH_PODS pods in CrashLoopBackOff state"
        echo "🔄 Triggering automatic fix..."

        # Run the fix script
        ./fix-gitops-sync.sh

        # Wait for fix to take effect
        sleep 300
    else
        echo "✅ All pods healthy"
    fi

    # Check ArgoCD sync status
    ARGOCD_STATUS=$(kubectl get applications -n argocd -o jsonpath='{.items[*].status.sync.status}')
    if echo "$ARGOCD_STATUS" | grep -q "OutOfSync"; then
        echo "⚠️ ArgoCD applications out of sync"
        echo "🔄 Triggering ArgoCD sync..."

        kubectl patch application healthcare-frontend-stage3 -n argocd --type merge --patch '{"operation":{"sync":{"revision":"HEAD"}}}'
        kubectl patch application healthcare-backend-stage3 -n argocd --type merge --patch '{"operation":{"sync":{"revision":"HEAD"}}}'
    fi

    sleep $CHECK_INTERVAL
done
EOF

chmod +x monitor-and-fix.sh
```

---

### **Production-Ready Automation Strategy**

#### **Recommended Approach for Future**

1. **Enhanced CI/CD Pipeline**:
   - Fix GitOps job in GitHub Actions
   - Add verification steps
   - Implement rollback mechanisms

2. **ArgoCD Image Updater**:
   - Automatic image updates
   - Policy-based updates
   - Integration with ECR

3. **Monitoring and Alerting**:
   - Automated health checks
   - Slack/email notifications
   - Auto-recovery procedures

4. **GitOps Best Practices**:
   - Separate GitOps repository
   - Branch-based environments
   - Automated testing of manifests

#### **Implementation Priority**

1. **Immediate (Today)**: Use manual fix script when needed
2. **Short-term (This Week)**: Fix GitOps pipeline job
3. **Medium-term (Next Sprint)**: Implement ArgoCD Image Updater
4. **Long-term (Next Month)**: Full automation with monitoring

---

### **Emergency Recovery Procedures**

#### **When Manual Intervention is Required**

**Scenario 1: Pipeline Builds but Pods Still Crash**
```bash
# Quick fix
./fix-gitops-sync.sh

# Verify
kubectl get pods -n healthcare-stage3-dev
```

**Scenario 2: ArgoCD Not Syncing**
```bash
# Force sync
kubectl patch application healthcare-frontend-stage3 -n argocd --type merge --patch '{"operation":{"sync":{"revision":"HEAD"}}}'

# Check status
kubectl get applications -n argocd
```

**Scenario 3: Complete GitOps Failure**
```bash
# Direct deployment bypass
kubectl set image deployment/healthcare-frontend-stage3 healthcare-frontend=867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-frontend-stage3:$(git rev-parse HEAD) -n healthcare-stage3-dev

# Monitor rollout
kubectl rollout status deployment/healthcare-frontend-stage3 -n healthcare-stage3-dev
```

---

*This comprehensive guide provides both immediate manual fixes and long-term automation strategies to eliminate the need for manual GitOps interventions in production environments.*
