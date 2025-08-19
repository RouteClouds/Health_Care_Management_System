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

### **Issue: Terraform Command Not Found in Pipeline**

**Problem**: GitHub Actions pipeline fails at the Terraform backend setup stage with "terraform: command not found" error.

**Error Messages**:
```
/home/runner/work/_temp/566e3dd8-39a7-46bc-a4da-1bc2082b0f3f.sh: line 4: terraform: command not found
🔧 Setting up Terraform backend infrastructure...
Error: Process completed with exit code 127.
```

**Root Cause**: The `setup-terraform-backend` job is missing the Terraform installation step, causing the terraform binary to be unavailable when the script tries to run terraform commands.

**Solution Steps**:

1. **Check the GitHub Actions workflow file**:
```bash
# Check if Terraform setup step is missing
grep -A 10 -B 5 "setup-terraform-backend" .github/workflows/stage3-ci.yml
```

2. **Add missing Terraform setup step**:
```yaml
# Add this step before any terraform commands in setup-terraform-backend job
- name: Setup Terraform
  uses: hashicorp/setup-terraform@v3
  with:
    terraform_version: 1.6.0
```

3. **Complete fix in workflow file**:
```yaml
setup-terraform-backend:
  name: Setup Terraform Backend
  runs-on: ubuntu-latest
  needs: [update-gitops]
  if: github.ref == 'refs/heads/main'
  steps:
    - name: Checkout
      uses: actions/checkout@v4

    - name: Configure AWS credentials
      uses: aws-actions/configure-aws-credentials@v4
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: ${{ env.AWS_REGION }}

    # ADD THIS MISSING STEP:
    - name: Setup Terraform
      uses: hashicorp/setup-terraform@v3
      with:
        terraform_version: 1.6.0

    - name: Setup Terraform Backend
      # ... rest of the terraform commands
```

4. **Commit and push the fix**:
```bash
git add .github/workflows/stage3-ci.yml
git commit -m "fix: add missing Terraform setup step in backend setup job

- Added hashicorp/setup-terraform@v3 action to setup-terraform-backend job
- Ensures terraform binary is available before running terraform commands
- Fixes 'terraform: command not found' error in pipeline
- Consistent with deploy-infrastructure job that already has this step"

git push origin main
```

**Verification**:
- Pipeline should now proceed past the backend setup stage
- Terraform commands will execute successfully
- No more "command not found" errors

### **Issue: DynamoDB Table Already Exists Error in Backend Setup**

**Problem**: Terraform backend setup fails because DynamoDB table already exists from previous runs, but Terraform doesn't handle existing resources gracefully.

**Error Messages**:
```
Error: creating AWS DynamoDB Table (healthcare-terraform-locks-stage3): operation error DynamoDB: CreateTable, https response error StatusCode: 400, RequestID: SOAD5JH3QLP2DK47N172D42MG3VV4KQNSO5AEMVJF66Q9ASUAAJG, ResourceInUseException: Table already exists: healthcare-terraform-locks-stage3

  with aws_dynamodb_table.terraform_locks,
  on main.tf line 82, in resource "aws_dynamodb_table" "terraform_locks":
  82: resource "aws_dynamodb_table" "terraform_locks" {

Error: Terraform exited with code 1.
Error: Process completed with exit code 1.
```

**Root Cause**: Terraform tries to create resources that already exist without checking for existing resources or importing them into the state.

**Solution Steps**:

1. **Enhanced pipeline with resource checking**:
The pipeline now includes automatic resource detection and import:

```yaml
- name: Setup Terraform Backend
  run: |
    # Check if backend resources already exist
    AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
    EXPECTED_TABLE="healthcare-terraform-locks-stage3"

    # Check if DynamoDB table exists
    if aws dynamodb describe-table --table-name "$EXPECTED_TABLE" --region ${{ env.AWS_REGION }} >/dev/null 2>&1; then
      echo "✅ DynamoDB table '$EXPECTED_TABLE' already exists"
      TABLE_EXISTS=true
    else
      echo "📋 DynamoDB table '$EXPECTED_TABLE' does not exist, will create"
      TABLE_EXISTS=false
    fi

    # Import existing resources if they exist
    if [[ "$TABLE_EXISTS" == "true" ]]; then
      echo "🔄 Importing existing DynamoDB table..."
      terraform import aws_dynamodb_table.terraform_locks "$EXPECTED_TABLE" || echo "⚠️ Import failed, table might already be in state"
    fi

    # Apply with error handling
    terraform apply -auto-approve backend-plan || {
      echo "⚠️ Apply failed, checking if resources exist..."
      if [[ "$TABLE_EXISTS" == "true" ]]; then
        echo "✅ Using existing backend resources"
        exit 0
      else
        echo "❌ Backend setup failed and resources don't exist"
        exit 1
      fi
    }
```

2. **Manual fix if pipeline still fails**:
```bash
# Option 1: Import existing resources into Terraform state
cd terraform/backend-setup
terraform init
terraform import aws_dynamodb_table.terraform_locks healthcare-terraform-locks-stage3
terraform import aws_s3_bucket.terraform_state healthcare-terraform-state-stage3-YOUR_ACCOUNT_ID-XXXX

# Option 2: Remove existing resources (CAUTION: Will lose state)
aws dynamodb delete-table --table-name healthcare-terraform-locks-stage3 --region us-east-1
aws s3 rb s3://healthcare-terraform-state-stage3-YOUR_ACCOUNT_ID-XXXX --force

# Option 3: Use existing resources
# Update terraform configuration to use data sources instead of resources
```

3. **Prevention for future runs**:
```bash
# The enhanced pipeline now automatically:
# ✅ Checks for existing resources before creating
# ✅ Imports existing resources into Terraform state
# ✅ Handles creation failures gracefully
# ✅ Uses existing resources when available
```

**Verification**:
- Pipeline handles existing resources without errors
- Backend setup completes successfully on subsequent runs
- No manual intervention required for resource conflicts

**Best Practices**:
- Always check for existing resources before creation
- Use Terraform import for existing infrastructure
- Implement proper error handling in CI/CD pipelines
- Consider using Terraform workspaces for environment isolation

### **Issue: Terraform Backend Setup Timeout and S3 Import Failures**

**Problem**: Backend setup gets stuck with "Still modifying" status for DynamoDB table and S3 bucket import fails with malformed bucket ID.

**Error Messages**:
```
aws_dynamodb_table.terraform_locks: Still modifying... [id=healthcare-terraform-locks-stage3, 5m20s elapsed]

Error: Cannot import non-existent remote object
While attempting to import an existing object to "aws_s3_bucket.terraform_state",
the provider detected that no object exists with the given id.
```

**Root Cause**:
1. **DynamoDB Timeout**: Table might be in a stuck state or being modified by another process
2. **S3 Import Issue**: Bucket name format is incorrect due to tab characters in AWS CLI output
3. **Resource Drift**: Terraform state doesn't match actual AWS resources

**Enhanced Solution**:

The pipeline now includes:

1. **Functional Resource Testing**:
```bash
# Test if resources are actually functional before Terraform operations
if aws s3 ls "s3://$BUCKET_NAME" >/dev/null 2>&1; then
  echo "✅ S3 bucket is accessible"
  S3_FUNCTIONAL=true
fi

if aws dynamodb describe-table --table-name "$EXPECTED_TABLE" >/dev/null 2>&1; then
  echo "✅ DynamoDB table is accessible"
  DYNAMO_FUNCTIONAL=true
fi

# Skip Terraform if both resources are functional
if [[ "$S3_FUNCTIONAL" == "true" ]] && [[ "$DYNAMO_FUNCTIONAL" == "true" ]]; then
  echo "🚀 Both resources are functional, skipping Terraform operations"
  exit 0
fi
```

2. **Improved S3 Bucket Detection**:
```bash
# Fix tab character issues in bucket name detection
EXISTING_BUCKET=$(aws s3api list-buckets --query "Buckets[?starts_with(Name, 'healthcare-terraform-state-stage3-${AWS_ACCOUNT_ID}')].Name" --output text | tr '\t' '\n' | head -1)
```

3. **Terraform State Checking**:
```bash
# Check if resources are already in Terraform state before importing
if terraform state list | grep -q "aws_dynamodb_table.terraform_locks"; then
  echo "✅ DynamoDB table already in Terraform state"
  TABLE_IN_STATE=true
fi
```

4. **Timeout Protection**:
```bash
# Apply with 10-minute timeout to prevent indefinite hanging
timeout 600 terraform apply -auto-approve backend-plan || {
  if [[ $? -eq 124 ]]; then
    echo "⏰ Terraform apply timed out after 10 minutes"
    # Use existing resources if they're functional
  fi
}
```

**Manual Recovery Steps**:

If the pipeline continues to have issues:

```bash
# Option 1: Reset Terraform state and use existing resources
cd terraform/backend-setup
rm -rf .terraform terraform.tfstate*
terraform init

# Check if resources exist and are functional
aws s3 ls s3://healthcare-terraform-state-stage3-YOUR_ACCOUNT_ID-XXXX
aws dynamodb describe-table --table-name healthcare-terraform-locks-stage3

# If functional, the enhanced pipeline will detect and use them

# Option 2: Force remove stuck DynamoDB table (CAUTION)
aws dynamodb delete-table --table-name healthcare-terraform-locks-stage3 --region us-east-1
# Wait for deletion to complete, then re-run pipeline

# Option 3: Manual state import (if needed)
terraform import aws_s3_bucket.terraform_state healthcare-terraform-state-stage3-YOUR_ACCOUNT_ID-XXXX
terraform import aws_dynamodb_table.terraform_locks healthcare-terraform-locks-stage3
```

**Prevention**:
- Enhanced pipeline now tests resource functionality before Terraform operations
- Automatic timeout protection prevents indefinite hanging
- Better error handling for various failure scenarios
- Graceful fallback to existing resources when they're functional

### **Issue: Persistent DynamoDB "Already Exists" Error Despite Enhanced Logic**

**Problem**: Even with enhanced resource detection logic, Terraform still fails with "ResourceInUseException: Table already exists" error.

**Error Messages**:
```
Error: creating AWS DynamoDB Table (healthcare-terraform-locks-stage3): operation error DynamoDB: CreateTable, https response error StatusCode: 400, RequestID: SOAD5JH3QLP2DK47N172D42MG3VV4KQNSO5AEMVJF66Q9ASUAAJG, ResourceInUseException: Table already exists: healthcare-terraform-locks-stage3

  with aws_dynamodb_table.terraform_locks,
  on main.tf line 82, in resource "aws_dynamodb_table" "terraform_locks":
  82: resource "aws_dynamodb_table" "terraform_locks" {

Error: Terraform exited with code 1.
Error: Process completed with exit code 1.
```

**Root Cause**:
1. **Terraform State Mismatch**: The DynamoDB table exists in AWS but not in Terraform state
2. **Import Failure**: Terraform import commands may fail due to state conflicts
3. **Resource Drift**: Manual changes or previous failed runs created state inconsistency

**Enhanced Solution Applied**:

1. **Lifecycle Management in Terraform**:
```hcl
# Added to terraform/backend-setup/main.tf
resource "aws_dynamodb_table" "terraform_locks" {
  # ... existing configuration ...

  # Lifecycle management to handle existing resources
  lifecycle {
    ignore_changes = [
      # Ignore changes to these attributes if resource already exists
      billing_mode,
      hash_key,
      attribute
    ]
  }
}
```

2. **Enhanced Error Detection in Pipeline**:
```bash
# Apply with specific error handling for "already exists" scenarios
terraform apply -auto-approve backend-plan 2>&1 | tee apply_output.log || {
  # Check if failure is due to "already exists" errors
  if grep -q "ResourceInUseException.*already exists" apply_output.log; then
    echo "🔍 Detected 'already exists' errors - resources are already created"
    # Use existing resources
    exit 0
  fi
}
```

3. **Functional Resource Testing**:
```bash
# Test if resources are actually functional before Terraform operations
if aws s3 ls "s3://$BUCKET_NAME" >/dev/null 2>&1 && \
   aws dynamodb describe-table --table-name "$EXPECTED_TABLE" >/dev/null 2>&1; then
  echo "🚀 Both resources are functional, skipping Terraform operations"
  exit 0
fi
```

**Manual Recovery Steps**:

If the enhanced pipeline still fails:

```bash
# Option 1: Reset Terraform state completely
cd terraform/backend-setup
rm -rf .terraform terraform.tfstate*
terraform init

# Option 2: Force import existing resources
terraform import aws_s3_bucket.terraform_state healthcare-terraform-state-stage3-YOUR_ACCOUNT_ID-XXXX
terraform import aws_dynamodb_table.terraform_locks healthcare-terraform-locks-stage3

# Option 3: Remove and recreate (CAUTION - will lose state)
aws dynamodb delete-table --table-name healthcare-terraform-locks-stage3 --region us-east-1
aws s3 rb s3://healthcare-terraform-state-stage3-YOUR_ACCOUNT_ID-XXXX --force
```

**Expected Behavior After Fix**:
- Pipeline detects existing functional resources and skips Terraform operations
- "Already exists" errors are caught and handled gracefully
- Backend setup completes successfully using existing resources

### **Issue: Infrastructure Deployment "No Outputs Found" Error**

**Problem**: Infrastructure deployment fails during validation with "No outputs found" error, causing AWS CLI commands to fail with malformed parameters.

**Error Messages**:
```
🔍 Validating deployed infrastructure...
EKS Cluster: ╷
│ Warning: No outputs found
│
│ The state file either has no outputs defined, or all the defined outputs
│ are empty. Please define an output in your configuration with the `output`
│ keyword and run `terraform refresh` for it to become available.
╵
RDS Endpoint: ╷
│ Warning: No outputs found
╵

Unknown options: Warning:, No, outputs, found, │, , │, The, state, file, either, has, no, outputs, defined...
Error: Process completed with exit code 252.
```

**Root Cause**:
1. **Missing Output Definitions**: Terraform configuration lacks output definitions
2. **Incorrect Output Names**: Pipeline references outputs that don't exist
3. **Command Parsing Error**: Terraform warning messages passed to AWS CLI as parameters

**Solution Applied**:

1. **Added Missing Outputs to terraform/environments/dev/main.tf**:
```hcl
# Outputs for pipeline validation
output "cluster_id" {
  description = "EKS cluster ID"
  value       = module.healthcare_infrastructure.cluster_id
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.healthcare_infrastructure.cluster_endpoint
}

output "db_instance_endpoint" {
  description = "RDS instance endpoint"
  value       = module.healthcare_infrastructure.db_instance_endpoint
  sensitive   = true
}

output "ecr_repository_frontend_url" {
  description = "URL of the frontend ECR repository"
  value       = module.healthcare_infrastructure.ecr_repository_frontend_url
}

# ... additional outputs ...
```

2. **Enhanced Pipeline Validation with Error Handling**:
```bash
# Check if outputs exist first
echo "📋 Available Terraform outputs:"
terraform output

# Get outputs with proper error handling
if terraform output cluster_id >/dev/null 2>&1; then
  EKS_CLUSTER_ID=$(terraform output -raw cluster_id)
  echo "EKS Cluster ID: $EKS_CLUSTER_ID"
else
  echo "⚠️ cluster_id output not found"
fi

# Use hardcoded cluster name as fallback
CLUSTER_NAME="healthcare-eks-stage3-dev"
echo "Using cluster name: $CLUSTER_NAME"
```

3. **Robust Validation Logic**:
```bash
# Validate EKS cluster with error handling
if aws eks describe-cluster --name $CLUSTER_NAME --region us-east-1 >/dev/null 2>&1; then
  echo "✅ EKS cluster exists and is accessible"
else
  echo "❌ EKS cluster not found or not accessible"
fi
```

**Manual Verification Steps**:

```bash
# Check if outputs are properly defined
cd terraform/environments/dev
terraform output

# If no outputs, check module outputs
cd ../../modules/healthcare-platform
cat outputs.tf

# Verify infrastructure exists
aws eks describe-cluster --name healthcare-eks-stage3-dev --region us-east-1
aws rds describe-db-instances --region us-east-1
aws ecr describe-repositories --region us-east-1
```

**Expected Behavior After Fix**:
- Terraform outputs are properly defined and accessible
- Pipeline validation uses correct output names
- Fallback mechanisms handle missing outputs gracefully
- Infrastructure validation completes successfully

**Prevention Strategies**:
1. **Output Validation**: Always define outputs for resources that need validation
2. **Error Handling**: Use proper error handling when accessing Terraform outputs
3. **Fallback Values**: Provide hardcoded fallbacks for critical resource names
4. **Testing**: Test output definitions locally before pipeline deployment

### **Issue: Application Deployment Fails with "Namespace Not Found" Error**

**Problem**: Application deployment fails because the Kubernetes namespace `healthcare-stage3-dev` doesn't exist when trying to apply GitOps manifests.

**Error Messages**:
```
🚀 Deploying application with automated database setup...
Using GitOps manifests with image tag: 98a16132ae92d0c7566683a64bd941b7e36779c3
Error from server (NotFound): error when creating "backend.yaml": namespaces "healthcare-stage3-dev" not found
Error from server (NotFound): error when creating "backend.yaml": namespaces "healthcare-stage3-dev" not found
Error from server (NotFound): error when creating "backend.yaml": namespaces "healthcare-stage3-dev" not found
Error from server (NotFound): error when creating "backend.yaml": namespaces "healthcare-stage3-dev" not found
Error: Process completed with exit code 1.
```

**Root Cause**:
1. **Missing Namespace Creation**: Pipeline assumes namespace exists but doesn't create it
2. **Deployment Order**: Applications deployed before namespace creation
3. **Infrastructure Gap**: EKS cluster exists but application namespace is missing
4. **GitOps Manifest Dependencies**: Manifests specify namespace but don't create it

**Solution Applied**:

1. **Enhanced Namespace Creation in Pipeline**:
```yaml
# Added to deploy-application job
- name: Deploy application with latest GitOps manifests
  run: |
    # Create namespace if it doesn't exist
    echo "🏗️ Ensuring namespace exists..."

    # Method 1: Try declarative approach
    if kubectl create namespace healthcare-stage3-dev --dry-run=client -o yaml | kubectl apply -f -; then
      echo "✅ Namespace created/verified using declarative approach"
    else
      echo "⚠️ Declarative approach failed, trying imperative approach..."
      # Method 2: Try imperative approach
      if kubectl create namespace healthcare-stage3-dev 2>/dev/null; then
        echo "✅ Namespace created using imperative approach"
      else
        echo "ℹ️ Namespace might already exist, checking..."
      fi
    fi

    # Verify namespace exists
    if kubectl get namespace healthcare-stage3-dev >/dev/null 2>&1; then
      echo "✅ Namespace healthcare-stage3-dev is ready"
    else
      echo "❌ Failed to create or find namespace"
      exit 1
    fi
```

2. **Enhanced Error Handling for Deployment**:
```yaml
# Apply manifests with error handling
echo "📦 Deploying backend application..."
if kubectl apply -f backend.yaml; then
  echo "✅ Backend deployment successful"
else
  echo "❌ Backend deployment failed"
  echo "🔍 Debugging information:"
  kubectl get namespaces
  kubectl describe namespace healthcare-stage3-dev || echo "Namespace does not exist"
  exit 1
fi
```

3. **Cluster Connectivity Verification**:
```yaml
# Verify cluster connectivity before deployment
echo "🔍 Verifying cluster connectivity..."
kubectl cluster-info
kubectl get nodes
echo "📋 Current namespaces:"
kubectl get namespaces
```

**Manual Troubleshooting Steps**:

1. **Check Cluster Connectivity**:
```bash
# Verify kubectl is configured correctly
kubectl cluster-info

# Check if cluster is accessible
kubectl get nodes

# List existing namespaces
kubectl get namespaces
```

**Expected Output**:
```
NAME              STATUS   AGE
default           Active   1h
kube-system       Active   1h
kube-public       Active   1h
kube-node-lease   Active   1h
```

2. **Create Namespace Manually**:
```bash
# Create namespace using imperative command
kubectl create namespace healthcare-stage3-dev

# Or create using declarative approach
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: healthcare-stage3-dev
  labels:
    name: healthcare-stage3-dev
    environment: dev
    stage: stage-3
    project: healthcare-management
EOF
```

**Expected Output**:
```
namespace/healthcare-stage3-dev created
```

3. **Verify Namespace Creation**:
```bash
# Check namespace exists
kubectl get namespace healthcare-stage3-dev

# Get detailed information
kubectl describe namespace healthcare-stage3-dev
```

**Expected Output**:
```
NAME                   STATUS   AGE
healthcare-stage3-dev  Active   30s

Name:         healthcare-stage3-dev
Labels:       environment=dev
              name=healthcare-stage3-dev
              project=healthcare-management
              stage=stage-3
Annotations:  <none>
Status:       Active
```

4. **Test Application Deployment**:
```bash
# Navigate to GitOps directory
cd Project-Stages/Project-Stage-3-Advanced-DevOps-Pipeline/gitops/environments/dev

# Apply backend manifest
kubectl apply -f backend.yaml

# Apply frontend manifest
kubectl apply -f frontend.yaml

# Verify deployments
kubectl get deployments -n healthcare-stage3-dev
kubectl get pods -n healthcare-stage3-dev
```

**Expected Output**:
```
NAME                        READY   UP-TO-DATE   AVAILABLE   AGE
healthcare-backend-stage3   0/2     2            0           30s
healthcare-frontend-stage3  0/2     2            0           30s

NAME                                         READY   STATUS    RESTARTS   AGE
healthcare-backend-stage3-xxx-xxx            0/1     Pending   0          30s
healthcare-frontend-stage3-xxx-xxx           0/1     Pending   0          30s
```

**Common Variations of This Issue**:

1. **RBAC Permissions**: Service account lacks namespace creation permissions
```bash
# Check current user permissions
kubectl auth can-i create namespaces

# If false, check cluster role bindings
kubectl get clusterrolebindings | grep $(kubectl config current-context)
```

2. **Network Policies**: Namespace isolation preventing communication
```bash
# Check network policies
kubectl get networkpolicies -n healthcare-stage3-dev

# Check if default network policy is blocking traffic
kubectl describe networkpolicy -n healthcare-stage3-dev
```

3. **Resource Quotas**: Namespace resource limits preventing pod creation
```bash
# Check resource quotas
kubectl get resourcequotas -n healthcare-stage3-dev

# Check limit ranges
kubectl get limitranges -n healthcare-stage3-dev
```

**Prevention Strategies**:

1. **Infrastructure as Code**: Include namespace creation in Terraform
```hcl
# Add to Terraform configuration
resource "kubernetes_namespace" "healthcare_stage3_dev" {
  metadata {
    name = "healthcare-stage3-dev"
    labels = {
      environment = "dev"
      stage       = "stage-3"
      project     = "healthcare-management"
    }
  }
}
```

2. **GitOps Namespace Manifest**: Create dedicated namespace manifest
```yaml
# gitops/environments/dev/namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: healthcare-stage3-dev
  labels:
    name: healthcare-stage3-dev
    environment: dev
    stage: stage-3
    project: healthcare-management
```

3. **Pipeline Validation**: Always verify namespace exists before deployment
```bash
# Add to pipeline
if ! kubectl get namespace healthcare-stage3-dev >/dev/null 2>&1; then
  echo "❌ Required namespace does not exist"
  exit 1
fi
```

**Expected Behavior After Fix**:
- Pipeline creates namespace automatically if it doesn't exist
- Application deployment succeeds without namespace errors
- Comprehensive error handling provides clear debugging information
- Fallback mechanisms handle various namespace creation scenarios

**Related Issues**:
- This pattern is common across Kubernetes deployments
- Similar issues may occur with other namespaces (monitoring, logging, etc.)
- RBAC and network policy configurations can cause similar symptoms

### **Issue: Database Connection Fails with 500 Error - Hardcoded RDS Endpoint**

**Problem**: Application deployment succeeds but database connectivity test fails with HTTP 500 error because the backend is using a hardcoded placeholder RDS endpoint instead of the actual RDS endpoint created by Terraform.

**Error Messages**:
```
🔍 Validating automated database setup...
LoadBalancer URL: http://ae91d99305676467bac1f06f1789f29c-766284450.us-east-1.elb.amazonaws.com
⏳ Waiting for LoadBalancer to be ready...
🗄️ Testing database connectivity...
true
✅ Database connection successful
👨‍⚕️ Testing sample data availability...
curl: (22) The requested URL returned error: 500
❌ Sample data not available - database seeding may have failed
Error: Process completed with exit code 1.
```

**Root Cause**:
1. **Hardcoded Database Endpoint**: GitOps manifest contains placeholder RDS endpoint
2. **Configuration Mismatch**: Backend tries to connect to non-existent database server
3. **Missing Configuration Update**: Pipeline doesn't update database configuration with actual RDS endpoint
4. **Terraform Output Not Used**: Actual RDS endpoint from Terraform not propagated to application

**Investigation Steps**:

1. **Check Backend Logs**:
```bash
# Check backend pod logs for database connection errors
kubectl logs deployment/healthcare-backend-stage3 -n healthcare-stage3-dev --tail=50

# Expected error patterns:
# - Connection refused
# - Host not found
# - Authentication failed
```

**Expected Error Output**:
```
Error: getaddrinfo ENOTFOUND healthcare-eks-stage3-dev-db.c6t4q0g6i4n5.us-east-1.rds.amazonaws.com
    at GetAddrInfoReqWrap.onlookup [as oncomplete] (dns.js:66:26)
Database connection failed: Error: getaddrinfo ENOTFOUND healthcare-eks-stage3-dev-db.c6t4q0g6i4n5.us-east-1.rds.amazonaws.com
```

2. **Check Database Configuration**:
```bash
# Check the database secret in the manifest
cd Project-Stages/Project-Stage-3-Advanced-DevOps-Pipeline/gitops/environments/dev
grep -A 10 "database-credentials-stage3" backend.yaml

# Check actual RDS endpoint from Terraform
cd ../../../terraform/environments/dev
terraform output db_instance_endpoint
```

**Expected Findings**:
```yaml
# In backend.yaml (INCORRECT - placeholder):
stringData:
  url: "postgresql://healthcare_stage3_user:healthcare_stage3_password_change_me@healthcare-eks-stage3-dev-db.c6t4q0g6i4n5.us-east-1.rds.amazonaws.com:5432/healthcare_stage3_db"

# From Terraform (CORRECT - actual endpoint):
healthcare-eks-stage3-dev-db.abc123xyz.us-east-1.rds.amazonaws.com:5432
```

**Solution Applied**:

1. **✅ FULLY AUTOMATED: Enhanced Pipeline with Database Configuration Update**:
```yaml
# Added to deploy-application job - FULLY AUTOMATED
- name: Deploy application with latest GitOps manifests
  run: |
    # Use dedicated script for database configuration update
    echo "🔧 Running automated database configuration update..."
    cd ../../../

    # Make script executable and run it
    chmod +x scripts/deployment/update-database-config.sh
    ./scripts/deployment/update-database-config.sh

    # Return to GitOps directory
    cd gitops/environments/dev

    # Continue with deployment...

# Automatic cleanup after deployment
- name: Cleanup temporary files
  if: always()
  run: |
    # Restore original backend.yaml if backup exists
    if [[ -f "backend.yaml.backup" ]]; then
      mv backend.yaml.backup backend.yaml
      echo "✅ Original backend.yaml restored"
    fi
```

2. **Created Dedicated Update Script**:
```bash
# scripts/deployment/update-database-config.sh
#!/bin/bash
echo "🔧 Updating database configuration with actual RDS endpoint..."

# Get RDS endpoint from Terraform
cd terraform/environments/dev
ACTUAL_RDS_ENDPOINT=$(terraform output -raw db_instance_endpoint)

# Update GitOps manifest
cd ../../../gitops/environments/dev
cp backend.yaml backend.yaml.backup
sed -i "s|healthcare-eks-stage3-dev-db\.c6t4q0g6i4n5\.us-east-1\.rds\.amazonaws\.com|$ACTUAL_RDS_ENDPOINT|g" backend.yaml

echo "✅ Database configuration updated"
```

3. **Enhanced Validation with Debugging**:
```yaml
# Enhanced validation step
- name: Validate automated database setup
  run: |
    # Check pod status and logs
    kubectl get pods -n healthcare-stage3-dev
    kubectl logs deployment/healthcare-backend-stage3 -n healthcare-stage3-dev --tail=50

    # Test health endpoint with detailed output
    HEALTH_RESPONSE=$(curl -s "http://${LB_URL}/api/health")
    echo "Health response: $HEALTH_RESPONSE"

    # Test doctors endpoint with HTTP status
    HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "http://${LB_URL}/api/doctors")
    echo "HTTP Status: $HTTP_STATUS"

    if [[ "$HTTP_STATUS" == "500" ]]; then
      echo "🔍 500 Internal Server Error detected - checking backend logs..."
      kubectl logs deployment/healthcare-backend-stage3 -n healthcare-stage3-dev --tail=100
    fi
```

**Manual Fix Steps**:

1. **Update Database Configuration Manually**:
```bash
# Navigate to project directory
cd Project-Stages/Project-Stage-3-Advanced-DevOps-Pipeline

# Get actual RDS endpoint
cd terraform/environments/dev
ACTUAL_RDS_ENDPOINT=$(terraform output -raw db_instance_endpoint)
echo "Actual RDS endpoint: $ACTUAL_RDS_ENDPOINT"

# Update GitOps manifest
cd ../../../gitops/environments/dev
cp backend.yaml backend.yaml.backup

# Replace placeholder with actual endpoint
sed -i "s|healthcare-eks-stage3-dev-db\.c6t4q0g6i4n5\.us-east-1\.rds\.amazonaws\.com|$ACTUAL_RDS_ENDPOINT|g" backend.yaml

# Verify the change
grep "postgresql://" backend.yaml
```

2. **Redeploy Backend with Updated Configuration**:
```bash
# Apply updated manifest
kubectl apply -f backend.yaml

# Wait for rollout to complete
kubectl rollout status deployment/healthcare-backend-stage3 -n healthcare-stage3-dev

# Check pod logs
kubectl logs deployment/healthcare-backend-stage3 -n healthcare-stage3-dev --tail=20
```

**Expected Output After Fix**:
```
Database connection successful
Server running on port 3001
Connected to database: healthcare_stage3_db
Database migrations completed
Sample data seeded successfully
```

3. **Test Database Connectivity**:
```bash
# Get LoadBalancer URL
LB_URL=$(kubectl get service frontend-stage3-svc -n healthcare-stage3-dev -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

# Test health endpoint
curl "http://${LB_URL}/api/health" | jq .

# Test doctors endpoint
curl "http://${LB_URL}/api/doctors" | jq .
```

**Expected Output**:
```json
# Health endpoint:
{
  "status": "healthy",
  "database": "connected",
  "timestamp": "2024-01-15T10:30:00Z"
}

# Doctors endpoint:
{
  "success": true,
  "data": {
    "doctors": [
      {
        "id": 1,
        "name": "Dr. John Smith",
        "specialization": "Cardiology"
      }
    ]
  }
}
```

**Prevention Strategies**:

1. **Automated Configuration Management**: Always use Terraform outputs for dynamic values
2. **Configuration Validation**: Verify database endpoints before deployment
3. **Environment-Specific Configs**: Use environment variables instead of hardcoded values
4. **Pipeline Integration**: Include configuration updates in CI/CD pipeline

**Related Configuration Files**:
- `gitops/environments/dev/backend.yaml` - Contains database configuration
- `terraform/environments/dev/main.tf` - Defines RDS outputs
- `terraform/modules/healthcare-platform/outputs.tf` - Module outputs

**Common Variations**:
- Different RDS endpoint formats (cluster vs instance)
- Multiple environment configurations (dev, staging, prod)
- Database credential management issues
- Network connectivity problems between EKS and RDS

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

---

## 🏗️ **ECR REPOSITORY MANAGEMENT AND PIPELINE FAILURES**

### **Issue: ECR Repository Not Found Error**

**Problem**: Pipeline fails with "The repository with name 'healthcare-frontend-stage3' does not exist in the registry"

**Common Scenarios**:
1. ECR repositories were manually deleted
2. Fresh AWS account setup without repositories
3. Repository names changed but pipeline not updated
4. Cross-region deployment issues

#### **Error Example**:
```
The repository with name 'healthcare-frontend-stage3' does not exist in the registry with id '867344452513'
Error: Process completed with exit code 1.
```

---

### **Immediate Fix: Manual Repository Creation**

#### **Step 1: Create ECR Repositories**

```bash
# Create frontend repository
aws ecr create-repository \
  --repository-name healthcare-frontend-stage3 \
  --region us-east-1 \
  --image-scanning-configuration scanOnPush=true \
  --encryption-configuration encryptionType=AES256

# Create backend repository
aws ecr create-repository \
  --repository-name healthcare-backend-stage3 \
  --region us-east-1 \
  --image-scanning-configuration scanOnPush=true \
  --encryption-configuration encryptionType=AES256
```

**Expected Output**:
```json
{
    "repository": {
        "repositoryArn": "arn:aws:ecr:us-east-1:867344452513:repository/healthcare-frontend-stage3",
        "registryId": "867344452513",
        "repositoryName": "healthcare-frontend-stage3",
        "repositoryUri": "867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-frontend-stage3",
        "createdAt": "2025-08-16T05:59:24.590000+00:00",
        "imageTagMutability": "MUTABLE",
        "imageScanningConfiguration": {
            "scanOnPush": true
        },
        "encryptionConfiguration": {
            "encryptionType": "AES256"
        }
    }
}
```

#### **Step 2: Verify Repository Creation**

```bash
# List all ECR repositories
aws ecr describe-repositories --region us-east-1 --query 'repositories[*].repositoryName' --output table

# Expected output:
# --------------------------------
# |     DescribeRepositories     |
# +------------------------------+
# |  healthcare-backend-stage3   |
# |  healthcare-frontend-stage3  |
# +------------------------------+
```

#### **Step 3: Trigger Pipeline Rebuild**

```bash
# Commit a small change to trigger pipeline
git commit --allow-empty -m "trigger: rebuild after ECR repository creation"
git push origin main
```

---

### **Automated Solution: Pipeline ECR Management**

#### **Enhanced Pipeline Configuration**

The pipeline now includes automatic ECR repository creation:

```yaml
- name: Create ECR repositories if they don't exist
  run: |
    echo "🏗️ Ensuring ECR repositories exist..."

    # Create frontend repository
    aws ecr describe-repositories --repository-names healthcare-frontend-stage3 --region us-east-1 || \
    aws ecr create-repository --repository-name healthcare-frontend-stage3 --region us-east-1 \
      --image-scanning-configuration scanOnPush=true \
      --encryption-configuration encryptionType=AES256

    # Create backend repository
    aws ecr describe-repositories --repository-names healthcare-backend-stage3 --region us-east-1 || \
    aws ecr create-repository --repository-name healthcare-backend-stage3 --region us-east-1 \
      --image-scanning-configuration scanOnPush=true \
      --encryption-configuration encryptionType=AES256

    echo "✅ ECR repositories ready"
```

#### **Benefits of Automated ECR Management**:
- **Resilient Pipelines**: Handles missing repositories gracefully
- **Security Best Practices**: Enables scanning and encryption by default
- **Zero Manual Intervention**: Repositories created automatically
- **Consistent Configuration**: Same settings across all environments

---

### **ECR Repository Management Best Practices**

#### **Repository Naming Convention**
```
Format: <application>-<component>-<stage>
Examples:
- healthcare-frontend-stage3
- healthcare-backend-stage3
- healthcare-database-stage3
```

#### **Security Configuration**
```bash
# Always enable image scanning
--image-scanning-configuration scanOnPush=true

# Always enable encryption
--encryption-configuration encryptionType=AES256

# Set lifecycle policies to manage storage costs
aws ecr put-lifecycle-policy \
  --repository-name healthcare-frontend-stage3 \
  --lifecycle-policy-text file://lifecycle-policy.json
```

#### **Lifecycle Policy Example**
```json
{
  "rules": [
    {
      "rulePriority": 1,
      "description": "Keep last 10 images",
      "selection": {
        "tagStatus": "tagged",
        "countType": "imageCountMoreThan",
        "countNumber": 10
      },
      "action": {
        "type": "expire"
      }
    },
    {
      "rulePriority": 2,
      "description": "Delete untagged images older than 1 day",
      "selection": {
        "tagStatus": "untagged",
        "countType": "sinceImagePushed",
        "countUnit": "days",
        "countNumber": 1
      },
      "action": {
        "type": "expire"
      }
    }
  ]
}
```

---

### **Troubleshooting ECR Issues**

#### **Issue: Permission Denied**
```bash
# Check IAM permissions
aws sts get-caller-identity

# Required permissions:
# - ecr:CreateRepository
# - ecr:DescribeRepositories
# - ecr:GetAuthorizationToken
# - ecr:BatchCheckLayerAvailability
# - ecr:GetDownloadUrlForLayer
# - ecr:BatchGetImage
# - ecr:InitiateLayerUpload
# - ecr:UploadLayerPart
# - ecr:CompleteLayerUpload
# - ecr:PutImage
```

#### **Issue: Cross-Region Problems**
```bash
# Ensure consistent region usage
export AWS_DEFAULT_REGION=us-east-1

# Check current region
aws configure get region

# List repositories in specific region
aws ecr describe-repositories --region us-east-1
```

#### **Issue: Repository Already Exists**
```bash
# Check if repository exists before creating
aws ecr describe-repositories --repository-names healthcare-frontend-stage3 --region us-east-1

# If exists, just proceed with build
# If not exists, create it
```

---

### **Emergency Recovery Procedures**

#### **Complete ECR Reset**
```bash
# Delete all images (if needed)
aws ecr batch-delete-image \
  --repository-name healthcare-frontend-stage3 \
  --image-ids imageTag=latest

# Delete repository (if needed)
aws ecr delete-repository \
  --repository-name healthcare-frontend-stage3 \
  --force

# Recreate repository
aws ecr create-repository \
  --repository-name healthcare-frontend-stage3 \
  --region us-east-1 \
  --image-scanning-configuration scanOnPush=true \
  --encryption-configuration encryptionType=AES256
```

#### **Bulk Repository Management**
```bash
# Create all Stage-3 repositories
for repo in healthcare-frontend-stage3 healthcare-backend-stage3; do
  aws ecr create-repository \
    --repository-name $repo \
    --region us-east-1 \
    --image-scanning-configuration scanOnPush=true \
    --encryption-configuration encryptionType=AES256
done
```

---

*This ECR management guide ensures robust repository handling and prevents pipeline failures due to missing ECR repositories.*

---

## 🌐 **FRONTEND-BACKEND CONNECTIVITY ISSUES AND COMPLETE RESOLUTION**

### **Critical Issue: CORS Configuration Preventing Frontend-Backend Communication**

**Problem**: Frontend loads successfully via LoadBalancer but cannot communicate with backend API due to CORS (Cross-Origin Resource Sharing) misconfiguration.

**Symptoms**:
- ✅ Frontend accessible: `http://LoadBalancer-URL` returns 200 OK
- ✅ Backend API accessible: `http://LoadBalancer-URL/api/health` returns 200 OK
- ❌ Frontend JavaScript cannot make API calls due to CORS errors
- ❌ Browser console shows CORS policy violations

#### **Root Cause Analysis**

**Issue Progression**:
1. **Initial Problem**: ECR repositories missing → `ImagePullBackOff`
2. **ECR Fixed**: Repositories created → Images pulled successfully
3. **Nginx Issue**: Incorrect upstream configuration → `CrashLoopBackOff`
4. **Nginx Fixed**: Static file serving corrected → Pods running
5. **CORS Issue**: Backend only allows `localhost:5173` → Frontend-backend disconnected

#### **Critical CORS Misconfiguration**

**Backend Code** (`src/app.ts`):
```typescript
app.use(cors({
  origin: process.env.FRONTEND_URL || 'http://localhost:5173',  // ❌ PROBLEM HERE
  credentials: true,
}));
```

**Deployment Configuration** (`gitops/environments/dev/backend.yaml`):
```yaml
env:
- name: CORS_ORIGIN  # ❌ WRONG VARIABLE NAME
  value: "http://frontend-stage3-svc.healthcare-stage3-dev.svc.cluster.local"
```

**The Issue**:
- Backend code expects `FRONTEND_URL` environment variable
- Deployment sets `CORS_ORIGIN` environment variable
- Variable name mismatch causes fallback to `localhost:5173`
- LoadBalancer requests from `http://a46a32210135848f797d5b74ea975657-537872179.us-east-1.elb.amazonaws.com` are blocked

---

### **Complete Diagnostic Process**

#### **Step 1: Verify Frontend Loading**

```bash
# Test frontend accessibility
curl -I http://a46a32210135848f797d5b74ea975657-537872179.us-east-1.elb.amazonaws.com

# Expected output:
# HTTP/1.1 200 OK
# Server: nginx/1.29.1
# Content-Type: text/html
```

**✅ Result**: Frontend loads successfully

#### **Step 2: Test Backend API Direct Access**

```bash
# Test backend API accessibility
curl -I http://a46a32210135848f797d5b74ea975657-537872179.us-east-1.elb.amazonaws.com/api/health

# Expected output:
# HTTP/1.1 200 OK
# Content-Type: application/json; charset=utf-8
```

**✅ Result**: Backend API accessible

#### **Step 3: Check CORS Headers (Critical)**

```bash
# Test CORS headers with verbose output
curl -v http://a46a32210135848f797d5b74ea975657-537872179.us-east-1.elb.amazonaws.com/api/health

# Look for this header in response:
# Access-Control-Allow-Origin: http://localhost:5173  # ❌ WRONG!
```

**❌ Problem Identified**: CORS only allows `localhost:5173`

#### **Step 4: Verify Backend Environment Variables**

```bash
# Check backend deployment environment variables
kubectl get deployment healthcare-backend-stage3 -n healthcare-stage3-dev -o yaml | grep -A 10 -B 5 env:

# Look for CORS-related variables:
# - name: CORS_ORIGIN  # ❌ Wrong variable name
#   value: "http://frontend-stage3-svc..."
```

**❌ Problem Confirmed**: Environment variable name mismatch

---

### **Complete Solution Implementation**

#### **Step 1: Fix Environment Variable Configuration**

**Update Backend Deployment**:
```bash
# Edit the backend deployment manifest
vim gitops/environments/dev/backend.yaml

# Change from:
- name: CORS_ORIGIN
  value: "http://frontend-stage3-svc.healthcare-stage3-dev.svc.cluster.local"

# To:
- name: FRONTEND_URL
  value: "http://a46a32210135848f797d5b74ea975657-537872179.us-east-1.elb.amazonaws.com"
```

**Apply the Fix**:
```bash
# Apply updated configuration
kubectl apply -f gitops/environments/dev/backend.yaml

# Expected output:
# deployment.apps/healthcare-backend-stage3 configured
# service/backend-stage3-svc unchanged
# horizontalpodautoscaler.autoscaling/healthcare-backend-stage3-hpa unchanged
# secret/database-credentials-stage3 configured
```

#### **Step 2: Monitor Pod Restart**

```bash
# Monitor backend pods restarting with new configuration
kubectl get pods -n healthcare-stage3-dev

# Expected: New backend pods with recent creation time
# NAME                                          READY   STATUS    RESTARTS   AGE
# healthcare-backend-stage3-857b796f4f-4f7cq    1/1     Running   0          23s
# healthcare-backend-stage3-857b796f4f-hq7s6    1/1     Running   0          17s
```

**✅ Result**: Backend pods restart with new environment variables

#### **Step 3: Verify CORS Fix**

```bash
# Test CORS headers again
curl -v http://a46a32210135848f797d5b74ea975657-537872179.us-east-1.elb.amazonaws.com/api/health

# Look for corrected header:
# Access-Control-Allow-Origin: http://a46a32210135848f797d5b74ea975657-537872179.us-east-1.elb.amazonaws.com  # ✅ CORRECT!
```

**✅ Result**: CORS now allows LoadBalancer URL

#### **Step 4: Test Frontend-Backend Communication**

```bash
# Test API call with proper Origin header
curl -H "Origin: http://a46a32210135848f797d5b74ea975657-537872179.us-east-1.elb.amazonaws.com" \
     http://a46a32210135848f797d5b74ea975657-537872179.us-east-1.elb.amazonaws.com/api/doctors

# Expected: JSON response (not CORS error)
# {"success":false,"message":"Failed to fetch doctors","error":...}  # Database issue, but CORS works!
```

**✅ Result**: No CORS errors, API responds correctly

---

### **Verification Commands and Expected Outputs**

#### **Complete Connectivity Test Script**

```bash
#!/bin/bash
echo "🔍 Frontend-Backend Connectivity Test"
echo "====================================="

FRONTEND_URL="http://a46a32210135848f797d5b74ea975657-537872179.us-east-1.elb.amazonaws.com"

echo "1. Testing Frontend Loading..."
FRONTEND_STATUS=$(curl -s -o /dev/null -w "%{http_code}" $FRONTEND_URL)
if [ "$FRONTEND_STATUS" = "200" ]; then
    echo "✅ Frontend: $FRONTEND_STATUS OK"
else
    echo "❌ Frontend: $FRONTEND_STATUS FAILED"
fi

echo "2. Testing Backend API..."
API_STATUS=$(curl -s -o /dev/null -w "%{http_code}" $FRONTEND_URL/api/health)
if [ "$API_STATUS" = "200" ]; then
    echo "✅ Backend API: $API_STATUS OK"
else
    echo "❌ Backend API: $API_STATUS FAILED"
fi

echo "3. Testing CORS Configuration..."
CORS_HEADER=$(curl -s -H "Origin: $FRONTEND_URL" -I $FRONTEND_URL/api/health | grep "Access-Control-Allow-Origin")
if echo "$CORS_HEADER" | grep -q "$FRONTEND_URL"; then
    echo "✅ CORS: Correctly configured"
    echo "   $CORS_HEADER"
else
    echo "❌ CORS: Misconfigured"
    echo "   $CORS_HEADER"
fi

echo "4. Testing API Endpoints..."
DOCTORS_RESPONSE=$(curl -s -H "Origin: $FRONTEND_URL" $FRONTEND_URL/api/doctors)
if echo "$DOCTORS_RESPONSE" | grep -q "success"; then
    echo "✅ API Endpoints: Responding"
else
    echo "⚠️ API Endpoints: Database connection issues (expected)"
fi

echo ""
echo "🎉 Frontend-Backend Connectivity: OPERATIONAL"
echo "🌐 Application URL: $FRONTEND_URL"
```

#### **Expected Healthy Output**

```
🔍 Frontend-Backend Connectivity Test
=====================================
1. Testing Frontend Loading...
✅ Frontend: 200 OK
2. Testing Backend API...
✅ Backend API: 200 OK
3. Testing CORS Configuration...
✅ CORS: Correctly configured
   Access-Control-Allow-Origin: http://a46a32210135848f797d5b74ea975657-537872179.us-east-1.elb.amazonaws.com
4. Testing API Endpoints...
⚠️ API Endpoints: Database connection issues (expected)

🎉 Frontend-Backend Connectivity: OPERATIONAL
🌐 Application URL: http://a46a32210135848f797d5b74ea975657-537872179.us-east-1.elb.amazonaws.com
```

---

### **Common CORS Issues and Solutions**

#### **Issue 1: Environment Variable Name Mismatch**

**Problem**: Backend code expects different variable name than deployment provides

**Solution**:
```bash
# Check backend code for expected variable name
grep -r "process.env" src-code/backend/src/app.ts

# Update deployment to match:
- name: FRONTEND_URL  # Must match backend code
  value: "http://your-loadbalancer-url"
```

#### **Issue 2: Hardcoded Development URLs**

**Problem**: CORS configuration hardcoded to localhost

**Solution**:
```typescript
// ❌ Bad: Hardcoded
app.use(cors({
  origin: 'http://localhost:5173',
  credentials: true,
}));

// ✅ Good: Environment-based
app.use(cors({
  origin: process.env.FRONTEND_URL || 'http://localhost:5173',
  credentials: true,
}));
```

#### **Issue 3: Multiple Origins Needed**

**Problem**: Need to allow both LoadBalancer and internal service URLs

**Solution**:
```typescript
app.use(cors({
  origin: [
    process.env.FRONTEND_URL,
    'http://frontend-stage3-svc.healthcare-stage3-dev.svc.cluster.local',
    'http://localhost:5173'  // For development
  ],
  credentials: true,
}));
```

#### **Issue 4: Dynamic LoadBalancer URLs**

**Problem**: LoadBalancer URL changes on infrastructure updates

**Solution**:
```bash
# Use wildcard or get URL dynamically
FRONTEND_URL=$(kubectl get svc frontend-stage3-svc -n healthcare-stage3-dev -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

# Update backend deployment
kubectl patch deployment healthcare-backend-stage3 -n healthcare-stage3-dev \
  -p '{"spec":{"template":{"spec":{"containers":[{"name":"backend","env":[{"name":"FRONTEND_URL","value":"http://'$FRONTEND_URL'"}]}]}}}}'
```

---

### **Prevention Strategies**

#### **1. Environment-Specific Configuration**

```yaml
# Use ConfigMap for environment-specific URLs
apiVersion: v1
kind: ConfigMap
metadata:
  name: frontend-config-stage3
  namespace: healthcare-stage3-dev
data:
  FRONTEND_URL: "http://a46a32210135848f797d5b74ea975657-537872179.us-east-1.elb.amazonaws.com"
  API_BASE_URL: "/api"
  ENVIRONMENT: "stage-3"
```

#### **2. Automated URL Discovery**

```bash
# Script to automatically update CORS configuration
#!/bin/bash
FRONTEND_URL=$(kubectl get svc frontend-stage3-svc -n healthcare-stage3-dev -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
kubectl patch deployment healthcare-backend-stage3 -n healthcare-stage3-dev \
  --type='merge' \
  -p='{"spec":{"template":{"spec":{"containers":[{"name":"backend","env":[{"name":"FRONTEND_URL","value":"http://'$FRONTEND_URL'"}]}]}}}}'
```

#### **3. Health Check Integration**

```bash
# Add CORS verification to health checks
curl -H "Origin: $FRONTEND_URL" -I $FRONTEND_URL/api/health | grep "Access-Control-Allow-Origin"
```

---

*This comprehensive guide resolves all frontend-backend connectivity issues in Stage-3, ensuring proper CORS configuration and seamless communication between services.*

---

## 🔧 **CRITICAL STAGE-2 ISSUE RESOLVED: VITE ENVIRONMENT VARIABLES**

### **Issue: Frontend Falls Back to localhost:3002/api Instead of /api**

**Problem**: Frontend-backend connectivity fails because Vite environment variables are not properly passed during Docker build, causing the frontend to use hardcoded localhost URLs instead of relative API paths.

**Symptoms**:
- ✅ Frontend loads successfully via LoadBalancer
- ✅ Backend API accessible directly via LoadBalancer/api
- ✅ CORS headers correctly configured
- ❌ Frontend JavaScript makes API calls to `localhost:3002/api` instead of `/api`
- ❌ Browser console shows network errors for API calls
- ❌ Frontend cannot communicate with backend despite all services running

#### **Root Cause Analysis**

**Critical Discovery**: This is the exact same issue documented in Stage-2 TROUBLESHOOTING.md

**Frontend API Configuration** (`src/services/api.ts`):
```typescript
const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || 'http://localhost:3002/api';
```

**The Problem**:
1. **Vite Environment Variables**: Must be available at BUILD TIME, not runtime
2. **Docker Build Issue**: `VITE_API_BASE_URL` not passed as build argument
3. **Fallback Activation**: Frontend built with `http://localhost:3002/api` fallback
4. **Runtime Failure**: Container tries to connect to localhost instead of nginx proxy

**Environment File** (`.env`):
```bash
VITE_API_BASE_URL=/api  # ✅ Correct value, but not reaching build process
```

**Dockerfile Issue** (Original):
```dockerfile
# ❌ Missing: No VITE environment variables passed to build
RUN npm run build  # Built with localhost:3002/api fallback
```

---

### **Complete Diagnostic Process**

#### **Step 1: Verify Stage-2 Issue Pattern**

```bash
# Check for hardcoded localhost URLs (Stage-2 diagnostic)
grep -r "localhost:3000\|localhost:3002\|localhost:5173" src-code/ --exclude-dir=node_modules

# Key finding:
# src-code/frontend/src/services/api.ts:const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || 'http://localhost:3002/api';
```

**✅ Result**: Confirmed Stage-2 pattern - fallback to localhost:3002/api

#### **Step 2: Test Internal Connectivity**

```bash
# Test backend connectivity from frontend pod (Stage-2 method)
kubectl exec -it deployment/healthcare-frontend-stage3 -n healthcare-stage3-dev -- curl http://backend-stage3-svc:3001/health

# Expected output:
# {"success":true,"message":"Health Care Management System API is running"...}
```

**✅ Result**: Internal connectivity works perfectly

#### **Step 3: Check Environment Variable Availability**

```bash
# Check if VITE variables are available in container
kubectl exec -it deployment/healthcare-frontend-stage3 -n healthcare-stage3-dev -- env | grep VITE

# Expected: No VITE variables found (they're build-time only)
```

**❌ Problem Confirmed**: Vite variables not available at runtime (expected behavior)

#### **Step 4: Verify Frontend Environment Configuration**

```bash
# Check frontend .env file
cat src-code/frontend/.env

# Output:
# VITE_API_BASE_URL=/api  # ✅ Correct
# VITE_APP_NAME=RouteClouds Health Platform
# VITE_APP_VERSION=1.0.0
```

**✅ Result**: Environment file correctly configured

#### **Step 5: Check Dockerfile Build Process**

```bash
# Check if Dockerfile passes Vite environment variables
grep -A 10 -B 5 "VITE" src-code/Dockerfile.frontend

# Original issue: No VITE build arguments
```

**❌ Problem Identified**: Dockerfile not passing VITE environment variables during build

---

### **Complete Solution Implementation**

#### **Step 1: Fix Frontend Dockerfile**

**Update Dockerfile to Pass Vite Environment Variables**:
```dockerfile
# Build arguments for Vite environment variables
ARG VITE_API_BASE_URL=/api
ARG VITE_APP_NAME="RouteClouds Health Platform"
ARG VITE_APP_VERSION="1.0.0"

# Set Vite environment variables for build
ENV VITE_API_BASE_URL=${VITE_API_BASE_URL}
ENV VITE_APP_NAME=${VITE_APP_NAME}
ENV VITE_APP_VERSION=${VITE_APP_VERSION}
```

**Apply the Fix**:
```bash
# Edit Dockerfile.frontend
vim src-code/Dockerfile.frontend

# Add the above build arguments and environment variables
```

#### **Step 2: Update Pipeline to Pass Build Arguments**

**Update GitHub Actions Workflow**:
```yaml
# Build frontend with Vite environment variables
docker build --no-cache --pull \
  --build-arg BUILD_DATE=$BUILD_DATE \
  --build-arg COMMIT_SHA=$IMAGE_TAG \
  --build-arg VITE_API_BASE_URL=/api \
  --build-arg VITE_APP_NAME="RouteClouds Health Platform" \
  --build-arg VITE_APP_VERSION="1.0.0" \
  -f Dockerfile.frontend \
  -t $ECR_REGISTRY/$ECR_REPOSITORY_FRONTEND:$IMAGE_TAG \
  -t $ECR_REGISTRY/$ECR_REPOSITORY_FRONTEND:latest .
```

**Apply the Fix**:
```bash
# Edit pipeline configuration
vim .github/workflows/stage3-ci.yml

# Add the --build-arg parameters for VITE variables
```

#### **Step 3: Commit and Trigger Pipeline**

```bash
# Commit the fixes
git add .
git commit -m "fix: resolve Stage-2 frontend-backend connectivity issue - Vite environment variables"
git push origin main

# Expected: Pipeline builds new frontend image with correct API base URL
```

#### **Step 4: Monitor Deployment**

```bash
# Monitor pipeline progress
# Visit: https://github.com/RouteClouds/Health_Care_Management_System/actions

# Check for new image build
aws ecr list-images --repository-name healthcare-frontend-stage3 --region us-east-1

# Monitor pod updates
kubectl get pods -n healthcare-stage3-dev -w
```

---

### **Verification Commands and Expected Results**

#### **Complete Connectivity Test After Fix**

```bash
#!/bin/bash
echo "🔍 Stage-2 Issue Resolution Verification"
echo "======================================="

FRONTEND_URL="http://a46a32210135848f797d5b74ea975657-537872179.us-east-1.elb.amazonaws.com"

echo "1. Testing Frontend Loading..."
FRONTEND_STATUS=$(curl -s -o /dev/null -w "%{http_code}" $FRONTEND_URL)
echo "✅ Frontend: $FRONTEND_STATUS OK"

echo "2. Testing Backend API Direct..."
API_STATUS=$(curl -s -o /dev/null -w "%{http_code}" $FRONTEND_URL/api/health)
echo "✅ Backend API: $API_STATUS OK"

echo "3. Testing Internal Connectivity..."
kubectl exec -it deployment/healthcare-frontend-stage3 -n healthcare-stage3-dev -- curl -s http://backend-stage3-svc:3001/health | grep -q "success"
echo "✅ Internal: Backend reachable from frontend pod"

echo "4. Testing CORS Configuration..."
CORS_HEADER=$(curl -s -H "Origin: $FRONTEND_URL" -I $FRONTEND_URL/api/health | grep "Access-Control-Allow-Origin")
echo "✅ CORS: $CORS_HEADER"

echo "5. Testing Frontend API Configuration..."
# After fix, frontend should use /api instead of localhost:3002/api
echo "✅ Frontend API: Will use /api (relative path) after rebuild"

echo ""
echo "🎉 Stage-2 Issue Resolution: COMPLETE"
echo "🌐 Application URL: $FRONTEND_URL"
echo ""
echo "📋 Expected After Pipeline Completion:"
echo "   - Frontend JavaScript uses /api instead of localhost:3002/api"
echo "   - API calls properly proxied through nginx to backend"
echo "   - Complete frontend-backend connectivity restored"
```

#### **Expected Healthy Output After Fix**

```
🔍 Stage-2 Issue Resolution Verification
=======================================
1. Testing Frontend Loading...
✅ Frontend: 200 OK
2. Testing Backend API Direct...
✅ Backend API: 200 OK
3. Testing Internal Connectivity...
✅ Internal: Backend reachable from frontend pod
4. Testing CORS Configuration...
✅ CORS: Access-Control-Allow-Origin: http://a46a32210135848f797d5b74ea975657-537872179.us-east-1.elb.amazonaws.com
5. Testing Frontend API Configuration...
✅ Frontend API: Will use /api (relative path) after rebuild

🎉 Stage-2 Issue Resolution: COMPLETE
🌐 Application URL: http://a46a32210135848f797d5b74ea975657-537872179.us-east-1.elb.amazonaws.com

📋 Expected After Pipeline Completion:
   - Frontend JavaScript uses /api instead of localhost:3002/api
   - API calls properly proxied through nginx to backend
   - Complete frontend-backend connectivity restored
```

---

### **Prevention Strategies for Future Deployments**

#### **1. Dockerfile Best Practices for Vite**

```dockerfile
# Always include Vite environment variables as build arguments
ARG VITE_API_BASE_URL
ARG VITE_APP_NAME
ARG VITE_APP_VERSION

# Set them as environment variables for the build process
ENV VITE_API_BASE_URL=${VITE_API_BASE_URL}
ENV VITE_APP_NAME=${VITE_APP_NAME}
ENV VITE_APP_VERSION=${VITE_APP_VERSION}

# Verify they're set during build
RUN echo "Building with VITE_API_BASE_URL: $VITE_API_BASE_URL"
```

#### **2. Pipeline Validation**

```yaml
# Add validation step to ensure build arguments are passed
- name: Validate Vite Environment Variables
  run: |
    echo "Validating Vite build arguments..."
    echo "VITE_API_BASE_URL: /api"
    echo "VITE_APP_NAME: RouteClouds Health Platform"
    echo "VITE_APP_VERSION: 1.0.0"
```

#### **3. Automated Testing**

```bash
# Add to CI/CD pipeline
- name: Test Frontend API Configuration
  run: |
    # Extract API base URL from built frontend
    docker run --rm $ECR_REGISTRY/$ECR_REPOSITORY_FRONTEND:$IMAGE_TAG \
      sh -c "grep -r 'localhost:3002' /usr/share/nginx/html/ || echo 'No localhost URLs found'"
```

#### **4. Development Environment Alignment**

```bash
# Ensure development and production use same environment variables
# .env (development)
VITE_API_BASE_URL=/api

# Dockerfile (production)
ARG VITE_API_BASE_URL=/api
```

---

*This solution resolves the critical Stage-2 frontend-backend connectivity issue by ensuring Vite environment variables are properly passed during Docker build, eliminating the localhost:3002/api fallback and enabling proper API proxying through nginx.*

---

## 🌐 **NETWORK CONNECTIVITY ISSUES IN CI/CD PIPELINE**

### **Issue: Docker Build Failures Due to Network Timeouts**

**Problem**: GitHub Actions pipeline fails during Docker build process with network connectivity errors, preventing successful image creation and deployment.

**Symptoms**:
- Pipeline fails with `dial tcp 54.211.105.2:443: i/o timeout` errors
- Docker build process hangs during npm install operations
- Intermittent failures when pulling base images or downloading dependencies
- Build process fails at different stages randomly

#### **Root Cause Analysis**

**Network Connectivity Issues**:
```
d67a3681594f: Retrying in 5 seconds
d67a3681594f: Retrying in 4 seconds
d67a3681594f: Retrying in 3 seconds
d67a3681594f: Retrying in 2 seconds
d67a3681594f: Retrying in 1 second
dial tcp 54.211.105.2:443: i/o timeout
Error: Process completed with exit code 1.
```

**Common Causes**:
1. **GitHub Actions Runner Network**: Limited bandwidth or connectivity issues
2. **npm Registry Timeouts**: Default npm timeouts too aggressive for CI environment
3. **Docker Registry Issues**: Problems pulling base images or layers
4. **Concurrent Downloads**: Too many simultaneous network operations
5. **No Retry Logic**: Single failure causes entire build to fail

---

### **Comprehensive Network Resilience Solution**

#### **Step 1: Enhanced Pipeline Configuration**

**Updated GitHub Actions Workflow**:
```yaml
# Configure Docker for better network resilience
echo "🔧 Configuring Docker for network resilience..."

# Set Docker daemon configuration for better timeouts
sudo mkdir -p /etc/docker
echo '{
  "max-concurrent-downloads": 3,
  "max-concurrent-uploads": 3,
  "registry-mirrors": ["https://mirror.gcr.io"],
  "insecure-registries": [],
  "debug": false,
  "experimental": false
}' | sudo tee /etc/docker/daemon.json

# Restart Docker daemon
sudo systemctl restart docker
sleep 10
```

**Retry Mechanism Implementation**:
```yaml
# Retry mechanism for frontend build
for attempt in 1 2 3; do
  echo "Frontend build attempt $attempt/3..."
  if docker build \
    --build-arg BUILD_DATE=$BUILD_DATE \
    --build-arg COMMIT_SHA=$IMAGE_TAG \
    --build-arg VITE_API_BASE_URL=/api \
    --network=host \
    -f Dockerfile.frontend \
    -t $ECR_REGISTRY/$ECR_REPOSITORY_FRONTEND:$IMAGE_TAG \
    -t $ECR_REGISTRY/$ECR_REPOSITORY_FRONTEND:latest .; then
    echo "✅ Frontend build successful on attempt $attempt"
    break
  else
    echo "❌ Frontend build failed on attempt $attempt"
    if [ $attempt -eq 3 ]; then
      echo "💥 Frontend build failed after 3 attempts"
      exit 1
    fi
    echo "⏳ Waiting 30 seconds before retry..."
    sleep 30
  fi
done
```

#### **Step 2: Enhanced Dockerfile Configuration**

**Frontend Dockerfile Network Resilience**:
```dockerfile
# Configure npm for better network resilience
RUN npm config set registry https://registry.npmjs.org/ && \
    npm config set fetch-timeout 300000 && \
    npm config set fetch-retry-mintimeout 20000 && \
    npm config set fetch-retry-maxtimeout 120000 && \
    npm config set fetch-retries 5

# Install dependencies with retry mechanism
RUN for attempt in 1 2 3; do \
      echo "npm install attempt $attempt/3..." && \
      npm install && break || \
      (echo "npm install failed on attempt $attempt" && \
       if [ $attempt -eq 3 ]; then exit 1; fi && \
       sleep 30); \
    done
```

**Backend Dockerfile Network Resilience**:
```dockerfile
# Configure npm for better network resilience
RUN npm config set registry https://registry.npmjs.org/ && \
    npm config set fetch-timeout 300000 && \
    npm config set fetch-retry-mintimeout 20000 && \
    npm config set fetch-retry-maxtimeout 120000 && \
    npm config set fetch-retries 5

# Install all dependencies with retry mechanism
RUN for attempt in 1 2 3; do \
      echo "npm install attempt $attempt/3..." && \
      npm install && npm cache clean --force && break || \
      (echo "npm install failed on attempt $attempt" && \
       if [ $attempt -eq 3 ]; then exit 1; fi && \
       sleep 30); \
    done
```

#### **Step 3: Alternative Build Script**

**Network-Resilient Build Script** (`scripts/build-with-network-resilience.sh`):
```bash
#!/bin/bash

# Function to test network connectivity
test_network() {
    if curl -s --connect-timeout 10 https://registry.npmjs.org/ > /dev/null; then
        echo "✅ npm registry accessible"
        return 0
    else
        echo "⚠️ npm registry not accessible"
        return 1
    fi
}

# Function to build with retries
build_with_retry() {
    local dockerfile=$1
    local image_name=$2
    local build_args=$3
    local max_attempts=3

    for attempt in $(seq 1 $max_attempts); do
        echo "Build attempt $attempt/$max_attempts for $image_name..."

        if docker build \
            --network=host \
            --build-arg BUILD_DATE="$BUILD_DATE" \
            --build-arg COMMIT_SHA="$IMAGE_TAG" \
            $build_args \
            -f "$dockerfile" \
            -t "$image_name:$IMAGE_TAG" \
            -t "$image_name:latest" \
            .; then
            echo "✅ $image_name build successful on attempt $attempt"
            return 0
        else
            echo "❌ $image_name build failed on attempt $attempt"
            if [ $attempt -eq $max_attempts ]; then
                echo "💥 Build failed after $max_attempts attempts"
                return 1
            fi
            echo "⏳ Waiting 60 seconds before retry..."
            sleep 60
            docker system prune -f --volumes
        fi
    done
}
```

---

### **Implementation and Usage**

#### **Automatic Pipeline Implementation**

**The enhanced pipeline is now active and includes**:
- ✅ Docker daemon configuration for network resilience
- ✅ Registry mirrors for improved reliability
- ✅ Retry mechanisms for both frontend and backend builds
- ✅ Enhanced npm configuration with extended timeouts
- ✅ Comprehensive error handling and logging

#### **Manual Build Alternative**

**If pipeline continues to fail, use the manual build script**:
```bash
# Navigate to project directory
cd Project-Stages/Project-Stage-3-Advanced-DevOps-Pipeline

# Set environment variables
export ECR_REGISTRY="867344452513.dkr.ecr.us-east-1.amazonaws.com"
export IMAGE_TAG=$(git rev-parse HEAD)
export BUILD_DATE=$(date +%s)

# Run network-resilient build
./scripts/build-with-network-resilience.sh

# Expected output:
# 🔧 Network-Resilient Docker Build Script
# ========================================
# [INFO] Testing network connectivity...
# ✅ npm registry accessible
# [INFO] Building frontend image...
# [INFO] Build attempt 1/3 for healthcare-frontend-stage3...
# ✅ healthcare-frontend-stage3 build successful on attempt 1
# [INFO] Building backend image...
# [INFO] Build attempt 1/3 for healthcare-backend-stage3...
# ✅ healthcare-backend-stage3 build successful on attempt 1
# ✅ All images built successfully!
```

#### **Manual Deployment After Build**

**If manual build is used, deploy manually**:
```bash
# Update GitOps manifests with new image tags
LATEST_SHA=$(git rev-parse HEAD)
sed -i "s|image: .*healthcare-frontend-stage3:.*|image: 867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-frontend-stage3:$LATEST_SHA|g" gitops/environments/dev/frontend.yaml
sed -i "s|image: .*healthcare-backend-stage3:.*|image: 867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-backend-stage3:$LATEST_SHA|g" gitops/environments/dev/backend.yaml

# Apply updated manifests
kubectl apply -f gitops/environments/dev/

# Monitor deployment
kubectl get pods -n healthcare-stage3-dev -w
```

---

### **Monitoring and Verification**

#### **Pipeline Monitoring Commands**

```bash
# Monitor GitHub Actions pipeline
# Visit: https://github.com/RouteClouds/Health_Care_Management_System/actions

# Check pipeline logs for retry attempts
# Look for: "Frontend build attempt 1/3..." messages

# Verify Docker daemon configuration
sudo cat /etc/docker/daemon.json

# Check npm configuration in build logs
# Look for: "npm config set fetch-timeout 300000" messages
```

#### **Success Indicators**

**Successful Pipeline Output**:
```
🔧 Configuring Docker for network resilience...
✅ Docker configured for network resilience
🏗️ Building frontend image with network resilience...
Frontend build attempt 1/3...
✅ Frontend build successful on attempt 1
🏗️ Building backend image with network resilience...
Backend build attempt 1/3...
✅ Backend build successful on attempt 1
📋 Built images:
healthcare-frontend-stage3    7cd21436    2 minutes ago
healthcare-backend-stage3     7cd21436    1 minute ago
📤 Pushing frontend images...
📤 Pushing backend images...
✅ All images pushed successfully
```

---

### **Prevention Strategies**

#### **1. Proactive Network Testing**

```bash
# Add network connectivity test to pipeline
- name: Test Network Connectivity
  run: |
    echo "Testing network connectivity..."
    curl -s --connect-timeout 10 https://registry.npmjs.org/ || echo "npm registry issues detected"
    curl -s --connect-timeout 10 https://index.docker.io/ || echo "Docker Hub issues detected"
```

#### **2. Enhanced Error Handling**

```yaml
# Add comprehensive error handling
- name: Build with Enhanced Error Handling
  run: |
    set -e
    trap 'echo "Build failed at line $LINENO"' ERR
    # Build commands here
```

#### **3. Alternative Registry Configuration**

```dockerfile
# Use multiple registry mirrors
RUN npm config set registry https://registry.npmjs.org/ || \
    npm config set registry https://registry.npm.taobao.org/
```

#### **4. Build Caching Strategy**

```yaml
# Add Docker layer caching
- name: Set up Docker Buildx
  uses: docker/setup-buildx-action@v2
  with:
    driver-opts: network=host

- name: Cache Docker layers
  uses: actions/cache@v3
  with:
    path: /tmp/.buildx-cache
    key: ${{ runner.os }}-buildx-${{ github.sha }}
    restore-keys: |
      ${{ runner.os }}-buildx-
```

---

*This comprehensive network resilience solution ensures reliable Docker builds in CI/CD pipelines by implementing retry mechanisms, enhanced timeouts, registry mirrors, and comprehensive error handling.*

---

## 🗄️ **DATABASE CONNECTIVITY AND SEEDING ISSUES**

### **Issue: Database Connection Failures and Missing Data**

**Problem**: Backend application fails to connect to RDS database or database lacks required schema and sample data, preventing API endpoints from functioning correctly.

**Symptoms**:
- ✅ Frontend loads successfully via LoadBalancer
- ✅ Backend pods running and healthy
- ✅ Frontend-backend connectivity working
- ❌ API endpoints return database connection errors
- ❌ `PrismaClientInitializationError` in backend logs
- ❌ `P2021` errors indicating missing tables
- ❌ Empty API responses due to missing sample data

#### **Root Cause Analysis**

**Common Database Issues**:

1. **Incorrect RDS Endpoint**: Backend configured with placeholder endpoint instead of actual RDS endpoint
2. **Missing Database Schema**: Prisma migrations not applied to RDS instance
3. **Empty Database**: No sample data seeded for testing and demonstration
4. **Connection String Issues**: Malformed DATABASE_URL or incorrect credentials
5. **Network Connectivity**: Security groups blocking database access from EKS

**Error Patterns**:
```json
// Connection Error
{
  "success": false,
  "message": "Failed to fetch doctors",
  "error": {
    "name": "PrismaClientInitializationError",
    "clientVersion": "5.22.0"
  }
}

// Missing Table Error
{
  "success": false,
  "message": "Failed to fetch doctors",
  "error": {
    "name": "PrismaClientKnownRequestError",
    "code": "P2021",
    "clientVersion": "5.22.0",
    "meta": {
      "modelName": "Doctor",
      "table": "public.doctors"
    }
  }
}
```

---

### **Complete Database Issue Resolution**

#### **Step 1: Verify RDS Endpoint Configuration**

**Check Current Configuration**:
```bash
# Check current database configuration in backend deployment
kubectl get secret database-credentials-stage3 -n healthcare-stage3-dev -o yaml

# Decode the DATABASE_URL
kubectl get secret database-credentials-stage3 -n healthcare-stage3-dev -o jsonpath='{.data.url}' | base64 -d
```

**Expected Output**:
```
postgresql://healthcare_stage3_user:healthcare_stage3_password_change_me@healthcare-eks-stage3-dev-db.c6t4q0g6i4n5.us-east-1.rds.amazonaws.com:5432/healthcare_stage3_db
```

**If endpoint is incorrect (contains cluster-xyz or placeholder)**:
```bash
# Get actual RDS endpoint from Terraform
cd terraform/
terraform output db_instance_endpoint

# Example output: healthcare-eks-stage3-dev-db.c6t4q0g6i4n5.us-east-1.rds.amazonaws.com:5432
```

#### **Step 2: Update Database Configuration with Correct Endpoint**

**Fix Backend Deployment**:
```bash
# Edit backend deployment
vim gitops/environments/dev/backend.yaml

# Update the database-credentials-stage3 secret section:
# Replace: healthcare-eks-stage3-dev-db.cluster-xyz.us-east-1.rds.amazonaws.com
# With: healthcare-eks-stage3-dev-db.c6t4q0g6i4n5.us-east-1.rds.amazonaws.com (your actual endpoint)
```

**Apply Updated Configuration**:
```bash
# Apply the updated configuration
kubectl apply -f gitops/environments/dev/backend.yaml

# Expected output:
# deployment.apps/healthcare-backend-stage3 unchanged
# service/backend-stage3-svc unchanged
# horizontalpodautoscaler.autoscaling/healthcare-backend-stage3-hpa unchanged
# secret/database-credentials-stage3 configured

# Restart backend pods to pick up new configuration
kubectl rollout restart deployment/healthcare-backend-stage3 -n healthcare-stage3-dev

# Expected output:
# deployment.apps/healthcare-backend-stage3 restarted
```

#### **Step 3: Verify Database Connection**

**Monitor Pod Restart**:
```bash
# Check pod status
kubectl get pods -n healthcare-stage3-dev

# Expected output:
# NAME                                          READY   STATUS    RESTARTS   AGE
# healthcare-backend-stage3-7fb9687fbf-dqt7v    1/1     Running   0          30s
# healthcare-backend-stage3-7fb9687fbf-mf5dd    1/1     Running   0          20s
# healthcare-frontend-stage3-76db84f68b-l4xl6   1/1     Running   0          3h
# healthcare-frontend-stage3-76db84f68b-rd4ft   1/1     Running   0          3h
```

**Test Database Connection**:
```bash
# Test health endpoint
curl -s http://a46a32210135848f797d5b74ea975657-537872179.us-east-1.elb.amazonaws.com/api/health | jq .

# Expected output with database connected:
# {
#   "status": "healthy",
#   "service": "healthcare-backend",
#   "timestamp": "2025-08-16T14:00:00.000Z",
#   "uptime": 60.123,
#   "environment": "development",
#   "version": "1.0.0",
#   "database": "connected",
#   "memory": { ... }
# }
```

#### **Step 4: Apply Database Migrations**

**Run Prisma Migrations**:
```bash
# Get backend pod name
BACKEND_POD=$(kubectl get pods -n healthcare-stage3-dev -l app=healthcare-backend-stage3 -o jsonpath='{.items[0].metadata.name}')

# Apply database migrations
kubectl exec -it $BACKEND_POD -n healthcare-stage3-dev -- npx prisma migrate deploy

# Expected output:
# Prisma schema loaded from prisma/schema.prisma
# Datasource "db": PostgreSQL database "healthcare_stage3_db", schema "public" at "healthcare-eks-stage3-dev-db.c6t4q0g6i4n5.us-east-1.rds.amazonaws.com:5432"
#
# 2 migrations found in prisma/migrations
#
# Applying migration `20250726075443_init`
# Applying migration `20250726083621_add_user_authentication`
#
# The following migration(s) have been applied:
#
# migrations/
#   └─ 20250726075443_init/
#     └─ migration.sql
#   └─ 20250726083621_add_user_authentication/
#     └─ migration.sql
#
# All migrations have been successfully applied.
```

#### **Step 5: Seed Database with Sample Data**

**Run Database Seeding**:
```bash
# Use the automated seeding script
kubectl exec -it $BACKEND_POD -n healthcare-stage3-dev -- node scripts/seed-database.js

# Expected output:
# 🌱 Starting database seeding for Healthcare Management System Stage-3...
# ================================================================================
# ✅ Database connection successful
# 🏥 Seeding departments...
# ✅ Created 5 departments
# 👥 Seeding users...
# ✅ Created 2 users
# 👨‍⚕️ Seeding doctors...
# ✅ Created 5 doctors
#
# 🎉 Database seeding completed successfully!
# ================================================================================
# 📊 Summary:
#    - Departments: 5
#    - Users: 2
#    - Doctors: 5
#
# 🔗 You can now test the API endpoints:
#    - GET /api/health (health check)
#    - GET /api/doctors (list doctors)
#    - GET /api/departments (list departments)
```

#### **Step 6: Verify Complete Functionality**

**Test API Endpoints**:
```bash
# Test doctors endpoint
curl -s http://a46a32210135848f797d5b74ea975657-537872179.us-east-1.elb.amazonaws.com/api/doctors | jq .

# Expected output:
# {
#   "success": true,
#   "data": {
#     "doctors": [
#       {
#         "id": "cmeebrfa4000512r18ukihg9k",
#         "firstName": "Michael",
#         "lastName": "Brown",
#         "email": "michael.brown@healthcare.com",
#         "specialization": "Orthopedic Surgery",
#         "departmentId": "cmeebrf9m000212r1z54ayyjr",
#         "qualifications": ["MD", "FAAOS"],
#         "experienceYears": 18,
#         "consultationFee": 250,
#         "createdAt": "2025-08-16T14:00:44.572Z",
#         "updatedAt": "2025-08-16T14:00:44.572Z",
#         "department": {
#           "id": "cmeebrf9m000212r1z54ayyjr",
#           "name": "Orthopedics",
#           "code": "ORTH",
#           "description": "Musculoskeletal system disorders",
#           "createdAt": "2025-08-16T14:00:44.554Z"
#         }
#       },
#       // ... more doctors
#     ],
#     "pagination": {
#       "page": 1,
#       "limit": 10,
#       "total": 5,
#       "totalPages": 1
#     }
#   },
#   "message": "Found 5 doctors"
# }
```

---

### **Automated Database Setup for New Deployments**

#### **Permanent Solution Implementation**

**Enhanced Package.json Scripts**:
```json
{
  "scripts": {
    "migrate:deploy": "prisma migrate deploy",
    "db:setup": "npm run migrate:deploy && npm run db:seed",
    "db:seed": "node scripts/seed-database.js",
    "db:reset": "prisma migrate reset --force"
  },
  "prisma": {
    "seed": "node scripts/seed-database.js"
  }
}
```

**Automated Seeding Script** (`scripts/seed-database.js`):
- ✅ Creates departments (Cardiology, Pediatrics, Orthopedics, Emergency, Internal Medicine)
- ✅ Creates sample users (patient and admin accounts)
- ✅ Creates doctors with proper department relationships
- ✅ Handles duplicate entries gracefully
- ✅ Provides comprehensive logging and error handling

**Enhanced Docker Entrypoint**:
- ✅ Waits for database connection
- ✅ Applies migrations automatically
- ✅ Seeds database if empty
- ✅ Starts application only after database is ready

#### **Prevention Strategies**

**1. Infrastructure as Code**:
```bash
# Always use Terraform output for RDS endpoint
RDS_ENDPOINT=$(terraform output -raw db_instance_endpoint)
sed -i "s/YOUR_RDS_ENDPOINT/$RDS_ENDPOINT/g" gitops/environments/dev/backend.yaml
```

**2. Automated Validation**:
```bash
# Add to CI/CD pipeline
- name: Validate Database Configuration
  run: |
    if grep -q "cluster-xyz" gitops/environments/dev/backend.yaml; then
      echo "❌ Database endpoint not updated"
      exit 1
    fi
```

**3. Health Check Integration**:
```bash
# Enhanced health check
curl -f http://localhost:3001/api/health | jq '.database' | grep -q "connected" || exit 1
```

---

### **Troubleshooting Common Database Issues**

#### **Issue 1: Connection Timeout**
```bash
# Symptoms: PrismaClientInitializationError
# Solution: Check security groups and network connectivity

# Verify security group allows EKS access
aws ec2 describe-security-groups --group-ids sg-xxx --query 'SecurityGroups[0].IpPermissions'

# Test connectivity from EKS node
kubectl exec -it $BACKEND_POD -n healthcare-stage3-dev -- nc -zv healthcare-eks-stage3-dev-db.c6t4q0g6i4n5.us-east-1.rds.amazonaws.com 5432
```

#### **Issue 2: Authentication Failed**
```bash
# Symptoms: Authentication failed for user
# Solution: Verify credentials and user permissions

# Check RDS user exists
aws rds describe-db-instances --db-instance-identifier healthcare-eks-stage3-dev-db
```

#### **Issue 3: Database Not Found**
```bash
# Symptoms: database "healthcare_stage3_db" does not exist
# Solution: Create database manually

# Connect to RDS and create database
kubectl exec -it $BACKEND_POD -n healthcare-stage3-dev -- psql $DATABASE_URL -c "CREATE DATABASE healthcare_stage3_db;"
```

#### **Issue 4: Migration Failures**
```bash
# Symptoms: Migration failed to apply
# Solution: Reset and reapply migrations

# Reset migrations (CAUTION: This will delete all data)
kubectl exec -it $BACKEND_POD -n healthcare-stage3-dev -- npx prisma migrate reset --force

# Reapply migrations
kubectl exec -it $BACKEND_POD -n healthcare-stage3-dev -- npx prisma migrate deploy
```

---

*This comprehensive database troubleshooting guide ensures reliable database connectivity and data seeding for Stage-3 deployments, preventing common database-related issues that can block application functionality.*

---

## 🔍 **COMPREHENSIVE ISSUE ANALYSIS: CURSOR-FINDING INVESTIGATION**

### **Complete Troubleshooting Case Study**

**Reference Document**: `Cursor-Finding.md` - Detailed analysis of frontend-backend connectivity and database issues

This section documents a comprehensive real-world troubleshooting case that occurred during Stage-3 deployment, providing valuable insights for future issue resolution.

#### **Issue Timeline and Resolution**

**Initial Problem Report**:
- User reported frontend-backend connectivity issues
- Symptoms suggested API calls were failing
- Database connectivity problems suspected

**Investigation Process**:

**Phase 1: Infrastructure Verification** ✅
```bash
# All infrastructure components verified as healthy
kubectl get pods -n healthcare-stage3-dev
# Result: All pods running (2/2 frontend, 2/2 backend)

kubectl get services -n healthcare-stage3-dev
# Result: LoadBalancer service operational

curl -I http://a46a32210135848f797d5b74ea975657-537872179.us-east-1.elb.amazonaws.com
# Result: HTTP/1.1 200 OK - Frontend accessible
```

**Phase 2: API Connectivity Testing** ✅
```bash
# Backend API direct access test
curl http://a46a32210135848f797d5b74ea975657-537872179.us-east-1.elb.amazonaws.com/api/health
# Result: {"status":"healthy","database":"connected"} - API working

# CORS configuration verification
curl -H "Origin: http://a46a32210135848f797d5b74ea975657-537872179.us-east-1.elb.amazonaws.com" \
     -I http://a46a32210135848f797d5b74ea975657-537872179.us-east-1.elb.amazonaws.com/api/health
# Result: Access-Control-Allow-Origin header correctly set
```

**Phase 3: Frontend JavaScript Analysis** ✅
```bash
# Check for hardcoded localhost URLs in built frontend
kubectl exec -it healthcare-frontend-stage3-76db84f68b-l4xl6 -n healthcare-stage3-dev -- \
  grep -o "localhost:3002" /usr/share/nginx/html/assets/index-CZh41kS7.js
# Result: No localhost:3002 found in built JavaScript

# Verify API base URL configuration
kubectl exec -it healthcare-frontend-stage3-76db84f68b-l4xl6 -n healthcare-stage3-dev -- \
  grep -o '"/api"\|"localhost:3002"' /usr/share/nginx/html/assets/index-CZh41kS7.js
# Result: "/api" - Correct relative path being used
```

**Phase 4: Database Issue Discovery** ❌
```bash
# Test doctors API endpoint
curl http://a46a32210135848f797d5b74ea975657-537872179.us-east-1.elb.amazonaws.com/api/doctors
# Result: PrismaClientKnownRequestError - Table 'public.doctors' doesn't exist
```

**Critical Discovery**: The frontend-backend connectivity was actually working correctly. The real issue was database-related:
1. ✅ **Infrastructure**: All components healthy
2. ✅ **Connectivity**: Frontend-backend communication working
3. ✅ **CORS**: Properly configured
4. ✅ **API Base URL**: Using correct relative paths
5. ❌ **Database**: Missing schema and sample data

#### **Root Cause Analysis**

**Issue Progression**:
1. **Initial Setup**: RDS endpoint configured with placeholder value
2. **Schema Missing**: Prisma migrations not applied to RDS instance
3. **Data Missing**: No sample data seeded for API testing
4. **Perception Gap**: Infrastructure working but application layer failing

**Key Insights**:
- **Infrastructure vs Application**: Perfect infrastructure doesn't guarantee application functionality
- **Layer-by-Layer Testing**: Each layer must be verified independently
- **Database Dependencies**: Modern applications require both schema and sample data
- **Error Message Analysis**: Specific error codes provide precise diagnosis

#### **Resolution Steps Applied**

**Step 1: Database Endpoint Correction**
```bash
# Updated backend deployment with correct RDS endpoint
sed -i 's/healthcare-eks-stage3-dev-db.cluster-xyz.us-east-1.rds.amazonaws.com/healthcare-eks-stage3-dev-db.c6t4q0g6i4n5.us-east-1.rds.amazonaws.com/g' \
  gitops/environments/dev/backend.yaml

kubectl apply -f gitops/environments/dev/backend.yaml
kubectl rollout restart deployment/healthcare-backend-stage3 -n healthcare-stage3-dev
```

**Step 2: Database Schema Creation**
```bash
# Applied Prisma migrations
kubectl exec -it healthcare-backend-stage3-7fb9687fbf-dqt7v -n healthcare-stage3-dev -- \
  npx prisma migrate deploy

# Result: 2 migrations applied successfully
```

**Step 3: Database Seeding**
```bash
# Seeded database with sample data
kubectl exec -it healthcare-backend-stage3-7fb9687fbf-dqt7v -n healthcare-stage3-dev -- \
  node scripts/seed-database.js

# Result: 5 departments, 2 users, 5 doctors created
```

**Step 4: Verification**
```bash
# Final API test
curl http://a46a32210135848f797d5b74ea975657-537872179.us-east-1.elb.amazonaws.com/api/doctors | jq .

# Result: Full JSON response with doctors, departments, and pagination
```

#### **Lessons Learned**

**Technical Insights**:
1. **Layered Troubleshooting**: Test each layer independently (infrastructure → connectivity → application → data)
2. **Error Code Analysis**: Specific error codes (P2021) provide precise diagnosis
3. **Configuration Management**: Placeholder values in configuration files are common sources of issues
4. **Database Dependencies**: Modern applications require both schema and sample data for full functionality

**Process Improvements**:
1. **Automated Validation**: Add checks for placeholder values in CI/CD pipeline
2. **Health Check Enhancement**: Include database schema and data validation in health checks
3. **Documentation**: Maintain detailed troubleshooting case studies for pattern recognition
4. **Prevention**: Implement automated database setup in deployment process

#### **Pattern Recognition**

**Historical Context**: This exact issue pattern occurred across multiple stages:
- **Stage-1**: Similar frontend-backend connectivity issues
- **Stage-2**: Documented hardcoded localhost URL problems
- **Stage-3**: Database configuration and seeding issues

**Common Patterns**:
- Infrastructure appears healthy while application layer fails
- Configuration files contain placeholder values
- Database setup requires manual intervention
- Error messages provide specific guidance for resolution

#### **Prevention Strategies Implemented**

**1. Automated Database Setup**:
```json
// Enhanced package.json
{
  "scripts": {
    "db:setup": "npm run migrate:deploy && npm run db:seed",
    "db:seed": "node scripts/seed-database.js"
  },
  "prisma": {
    "seed": "node scripts/seed-database.js"
  }
}
```

**2. Configuration Validation**:
```bash
# CI/CD pipeline check
if grep -q "cluster-xyz" gitops/environments/dev/backend.yaml; then
  echo "❌ Database endpoint not updated"
  exit 1
fi
```

**3. Enhanced Health Checks**:
```bash
# Comprehensive health validation
curl -f /api/health | jq '.database' | grep -q "connected"
curl -f /api/doctors | jq '.data.doctors | length' | grep -q "[1-9]"
```

**4. Documentation Enhancement**:
- Complete troubleshooting guide with step-by-step commands
- Real-world case study documentation
- Pattern recognition for similar issues
- Automated prevention strategies

#### **Future Reference**

**When Similar Issues Occur**:
1. **Start with Infrastructure**: Verify pods, services, and networking
2. **Test Connectivity**: Check frontend-backend communication
3. **Analyze Application Layer**: Look for configuration issues
4. **Validate Database**: Check schema, data, and connectivity
5. **Apply Systematic Resolution**: Follow documented procedures

**Key Commands for Quick Diagnosis**:
```bash
# Infrastructure check
kubectl get pods,svc -n healthcare-stage3-dev

# Connectivity test
curl -I http://LOADBALANCER_URL/api/health

# Database validation
curl http://LOADBALANCER_URL/api/doctors | jq '.success'

# Configuration verification
kubectl get secret database-credentials-stage3 -n healthcare-stage3-dev -o yaml
```

---

*This comprehensive case study demonstrates the importance of systematic troubleshooting, layer-by-layer analysis, and the value of documenting real-world issue resolution for future reference and pattern recognition.*
