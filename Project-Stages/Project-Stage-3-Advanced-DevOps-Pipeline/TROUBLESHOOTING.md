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

*This troubleshooting guide provides comprehensive solutions for common Stage-3 issues. Keep this guide updated as new issues are discovered and resolved.*
