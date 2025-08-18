# Stage-3 Project Destruction Guide

## ⚠️ **CRITICAL WARNING**

**This guide will completely destroy your Stage-3 environment and all associated resources.**

- ❌ **All data will be permanently lost**
- ❌ **All infrastructure will be deleted**
- ❌ **All configurations will be removed**
- ❌ **This action cannot be undone**

**Only proceed if you are absolutely certain you want to destroy the entire Stage-3 environment.**

---

## 📋 Table of Contents

1. [Pre-Destruction Checklist](#pre-destruction-checklist)
2. [Data Backup Procedures](#data-backup-procedures)
3. [🆕 Automated Complete Destruction](#automated-complete-destruction)
4. [Manual Application Cleanup](#manual-application-cleanup)
5. [Manual Infrastructure Destruction](#manual-infrastructure-destruction)
6. [AWS Resource Cleanup](#aws-resource-cleanup)
7. [Local Environment Cleanup](#local-environment-cleanup)
8. [Verification Procedures](#verification-procedures)
9. [Cost Verification](#cost-verification)
10. [🆕 Monitoring Stack Cleanup](#monitoring-stack-cleanup)

---

## 🚀 **QUICK START - Automated Destruction**

**For users who want complete automated destruction, jump to [Automated Complete Destruction](#automated-complete-destruction)**

---

## ✅ Pre-Destruction Checklist

### **Mandatory Verification Steps**

```bash
# 1. Confirm you're in the correct environment
kubectl config current-context
echo "Current cluster: $(kubectl config current-context)"
echo "⚠️  Verify this is the Stage-3 cluster you want to destroy"

# 2. List all resources that will be destroyed
kubectl get all --all-namespaces
kubectl get pv,pvc --all-namespaces

# 3. Check for any critical data
kubectl get secrets --all-namespaces
kubectl get configmaps --all-namespaces

# 4. Verify no production workloads are running
kubectl get pods --all-namespaces | grep -v "healthcare-stage3\|monitoring\|logging\|argocd"
```

### **Stakeholder Approval**
- [ ] **Project Manager Approval**: Confirmed destruction is authorized
- [ ] **Team Lead Approval**: All team members notified
- [ ] **Data Owner Approval**: Data backup/migration completed
- [ ] **Security Approval**: No compliance issues with destruction

### **Environment Verification**
- [ ] **Correct Cluster**: Verified Stage-3 cluster (not production)
- [ ] **Backup Completed**: All critical data backed up
- [ ] **Dependencies Checked**: No other systems depend on this environment
- [ ] **Timeline Confirmed**: Destruction scheduled during maintenance window

---

## 💾 Data Backup Procedures

### **Database Backup**
```bash
echo "📦 Creating final database backup..."

# Create comprehensive database backup
kubectl exec -n healthcare-stage3-dev deployment/healthcare-backend-stage3 -- pg_dump \
  -h $DB_HOST -U $DB_USER -d healthcare_stage3_db \
  --verbose --clean --create > final-backup-$(date +%Y%m%d-%H%M%S).sql

# Verify backup file
ls -la final-backup-*.sql
echo "✅ Database backup created"

# Upload to S3 for long-term storage
aws s3 cp final-backup-*.sql s3://healthcare-backups-stage3/final-destruction-backup/
echo "✅ Backup uploaded to S3"
```

### **Configuration Backup**
```bash
echo "📋 Backing up all configurations..."

# Create backup directory
mkdir -p destruction-backups/$(date +%Y%m%d-%H%M%S)
cd destruction-backups/$(date +%Y%m%d-%H%M%S)

# Backup Kubernetes configurations
kubectl get all --all-namespaces -o yaml > kubernetes-all-resources.yaml
kubectl get secrets --all-namespaces -o yaml > kubernetes-secrets.yaml
kubectl get configmaps --all-namespaces -o yaml > kubernetes-configmaps.yaml
kubectl get pv,pvc --all-namespaces -o yaml > kubernetes-storage.yaml

# Backup ArgoCD applications
kubectl get applications -n argocd -o yaml > argocd-applications.yaml
kubectl get appprojects -n argocd -o yaml > argocd-projects.yaml

# Backup monitoring configurations
helm get values prometheus -n monitoring > prometheus-values.yaml
kubectl get prometheusrules --all-namespaces -o yaml > prometheus-rules.yaml

# Backup Terraform state
cp -r ../../../terraform/environments/dev/.terraform ./terraform-state-backup
terraform show > terraform-current-state.txt

echo "✅ All configurations backed up"
```

### **Application Data Export**
```bash
echo "📊 Exporting application data..."

# Export user data
kubectl exec -n healthcare-stage3-dev deployment/healthcare-backend-stage3 -- \
  psql -h $DB_HOST -U $DB_USER -d healthcare_stage3_db \
  -c "COPY users TO STDOUT WITH CSV HEADER" > users-export.csv

# Export appointments data
kubectl exec -n healthcare-stage3-dev deployment/healthcare-backend-stage3 -- \
  psql -h $DB_HOST -U $DB_USER -d healthcare_stage3_db \
  -c "COPY appointments TO STDOUT WITH CSV HEADER" > appointments-export.csv

# Export system logs
kubectl logs deployment/healthcare-backend-stage3 -n healthcare-stage3-dev --since=720h > backend-logs.txt
kubectl logs deployment/healthcare-frontend-stage3 -n healthcare-stage3-dev --since=720h > frontend-logs.txt

echo "✅ Application data exported"
```

---

## 🆕 **Automated Complete Destruction**

### **🚀 One-Command Complete Infrastructure Destruction**

**NEW: We have created an automated script that handles complete infrastructure destruction with minimal user intervention.**

```bash
# Navigate to Stage-3 directory
cd Project-Stages/Project-Stage-3-Advanced-DevOps-Pipeline

# Run the automated complete destruction script
./scripts/cleanup/destroy-complete-infrastructure.sh
```

**What this script does:**
- ✅ **Kubernetes Cleanup**: Removes all namespaces, applications, and resources
- ✅ **Load Balancer Cleanup**: Automatically removes all load balancers
- ✅ **Terraform Destroy**: Runs complete Terraform infrastructure destruction
- ✅ **ECR Cleanup**: Removes container repositories and images
- ✅ **Resource Verification**: Confirms all resources are destroyed
- ✅ **Cost Optimization**: Ensures no ongoing AWS charges

**Safety Features:**
- 🔒 **Double Confirmation**: Requires typing 'DESTROY' and 'YES' to proceed
- 🔍 **Resource Preview**: Shows exactly what will be destroyed
- ✅ **Verification**: Confirms successful destruction of all resources
- 📊 **Status Report**: Provides detailed destruction status

### **🆕 Monitoring Stack Cleanup**

**NEW: Dedicated monitoring stack cleanup script for Prometheus, Grafana, and AlertManager.**

```bash
# Clean up monitoring stack only
./scripts/monitoring/cleanup-monitoring-stack.sh

# Validate monitoring cleanup
./scripts/monitoring/validate-monitoring-stack.sh
```

**Monitoring cleanup includes:**
- 🔍 **Prometheus**: Metrics collection system
- 📊 **Grafana**: Dashboard and visualization
- 🚨 **AlertManager**: Alert management system
- 📈 **Node Exporter**: System metrics collection
- 🎯 **Custom Rules**: Healthcare-specific alert rules

---

## 🔧 **Manual Application Cleanup**

**Note: Use this section only if you prefer manual step-by-step cleanup or if the automated script fails.**

### **Phase 1: Stop All Applications**
```bash
echo "🛑 Stopping all applications..."

# Scale down all deployments to 0
kubectl scale deployment --all --replicas=0 -n healthcare-stage3-dev
kubectl scale deployment --all --replicas=0 -n monitoring
kubectl scale deployment --all --replicas=0 -n logging
kubectl scale deployment --all --replicas=0 -n argocd

# Wait for pods to terminate
kubectl wait --for=delete pods --all -n healthcare-stage3-dev --timeout=300s
kubectl wait --for=delete pods --all -n monitoring --timeout=300s
kubectl wait --for=delete pods --all -n logging --timeout=300s

echo "✅ All applications stopped"
```

### **Phase 2: Delete ArgoCD Applications**
```bash
echo "🔄 Removing ArgoCD applications..."

# Delete all ArgoCD applications
kubectl delete applications --all -n argocd

# Delete ArgoCD projects
kubectl delete appprojects --all -n argocd

# Wait for applications to be removed
kubectl wait --for=delete applications --all -n argocd --timeout=300s

echo "✅ ArgoCD applications removed"
```

### **Phase 3: Remove Application Namespaces**
```bash
echo "🗂️ Removing application namespaces..."

# Delete application namespaces
kubectl delete namespace healthcare-stage3-dev --wait=true
kubectl delete namespace healthcare-stage3-staging --wait=true --ignore-not-found=true
kubectl delete namespace healthcare-stage3-prod --wait=true --ignore-not-found=true

echo "✅ Application namespaces removed"
```

---

## 🏗️ Infrastructure Destruction

### **Phase 1: Remove Monitoring and Logging**
```bash
echo "📊 Removing monitoring and logging infrastructure..."

# Remove Prometheus stack
helm uninstall prometheus -n monitoring

# Remove ELK stack
helm uninstall elasticsearch -n logging --ignore-not-found=true
helm uninstall kibana -n logging --ignore-not-found=true
helm uninstall logstash -n logging --ignore-not-found=true

# Delete monitoring and logging namespaces
kubectl delete namespace monitoring --wait=true
kubectl delete namespace logging --wait=true

echo "✅ Monitoring and logging removed"
```

### **Phase 2: Remove ArgoCD**
```bash
echo "🔄 Removing ArgoCD..."

# Delete ArgoCD installation
kubectl delete -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Delete ArgoCD namespace
kubectl delete namespace argocd --wait=true

echo "✅ ArgoCD removed"
```

---

## 🔧 **Manual Infrastructure Destruction**

**Note: Use this section only if you prefer manual step-by-step destruction or if the automated script fails.**

### **Phase 3: Terraform Infrastructure Destruction**
```bash
echo "🏗️ Destroying Terraform infrastructure..."

# Navigate to Terraform directory
cd terraform/environments/dev

# Show what will be destroyed
terraform plan -destroy

# Confirm destruction
echo "⚠️  This will destroy ALL infrastructure resources"
echo "⚠️  Including EKS cluster, RDS database, VPC, and all networking"
read -p "Type 'DESTROY' to confirm: " confirmation

if [ "$confirmation" = "DESTROY" ]; then
    # Destroy infrastructure
    terraform destroy -auto-approve
    echo "✅ Infrastructure destroyed"
else
    echo "❌ Destruction cancelled"
    exit 1
fi

cd ../../../
```

---

## ☁️ AWS Resource Cleanup

### **Phase 1: ECR Repository Cleanup**
```bash
echo "📦 Cleaning up ECR repositories..."

# List all images in repositories
aws ecr list-images --repository-name healthcare-frontend-stage3 --region us-east-1
aws ecr list-images --repository-name healthcare-backend-stage3 --region us-east-1

# Delete all images
aws ecr batch-delete-image \
    --repository-name healthcare-frontend-stage3 \
    --image-ids "$(aws ecr list-images --repository-name healthcare-frontend-stage3 --query 'imageIds[*]' --output json)" \
    --region us-east-1

aws ecr batch-delete-image \
    --repository-name healthcare-backend-stage3 \
    --image-ids "$(aws ecr list-images --repository-name healthcare-backend-stage3 --query 'imageIds[*]' --output json)" \
    --region us-east-1

# Delete repositories
aws ecr delete-repository --repository-name healthcare-frontend-stage3 --region us-east-1 --force
aws ecr delete-repository --repository-name healthcare-backend-stage3 --region us-east-1 --force

echo "✅ ECR repositories cleaned up"
```

### **Phase 2: S3 and DynamoDB Cleanup**
```bash
echo "🗄️ Cleaning up S3 and DynamoDB..."

# Empty and delete S3 bucket
aws s3 rm s3://healthcare-terraform-state-stage3-${AWS_ACCOUNT_ID} --recursive
aws s3 rb s3://healthcare-terraform-state-stage3-${AWS_ACCOUNT_ID}

# Delete DynamoDB table
aws dynamodb delete-table --table-name healthcare-terraform-locks-stage3 --region us-east-1

echo "✅ S3 and DynamoDB cleaned up"
```

### **Phase 3: IAM Cleanup**
```bash
echo "🔐 Cleaning up IAM resources..."

# List Stage-3 specific IAM resources
aws iam list-roles | grep healthcare-stage3
aws iam list-policies | grep healthcare-stage3

# Delete IAM roles (if created by Terraform, they should already be deleted)
# Manual cleanup if needed:
# aws iam delete-role --role-name healthcare-stage3-eks-role
# aws iam delete-role --role-name healthcare-stage3-node-role

echo "✅ IAM resources cleaned up"
```

---

## 💻 Local Environment Cleanup

### **Remove Local Configurations**
```bash
echo "🧹 Cleaning up local environment..."

# Remove kubectl context
kubectl config delete-context healthcare-eks-stage3-dev

# Remove kubeconfig entries
kubectl config unset clusters.healthcare-eks-stage3-dev
kubectl config unset users.healthcare-eks-stage3-dev

# Clean up local Docker images
docker images | grep healthcare-stage3 | awk '{print $3}' | xargs docker rmi -f

# Remove local Terraform state
rm -rf terraform/environments/dev/.terraform
rm -f terraform/environments/dev/terraform.tfstate*
rm -f terraform/environments/dev/tfplan

# Clean up environment variables
sed -i '/# Stage-3 Environment Variables/,/^$/d' ~/.bashrc

echo "✅ Local environment cleaned up"
```

### **Remove Local Files**
```bash
echo "📁 Removing local project files..."

# Archive important files before deletion
tar -czf stage3-archive-$(date +%Y%m%d).tar.gz \
    destruction-backups/ \
    Images/ \
    docs/ \
    *.md

# Move archive to safe location
mv stage3-archive-*.tar.gz ~/stage3-archives/

echo "✅ Local files archived and cleaned up"
```

---

## ✅ Verification Procedures

### **AWS Resource Verification**
```bash
echo "🔍 Verifying AWS resource cleanup..."

# Check EKS clusters
aws eks list-clusters --region us-east-1 | grep stage3

# Check ECR repositories
aws ecr describe-repositories --region us-east-1 | grep stage3

# Check RDS instances
aws rds describe-db-instances --region us-east-1 | grep stage3

# Check VPCs
aws ec2 describe-vpcs --region us-east-1 | grep stage3

# Check S3 buckets
aws s3 ls | grep stage3

# Check DynamoDB tables
aws dynamodb list-tables --region us-east-1 | grep stage3

echo "✅ AWS resource verification completed"
```

### **Local Environment Verification**
```bash
echo "🔍 Verifying local cleanup..."

# Check kubectl contexts
kubectl config get-contexts | grep stage3

# Check Docker images
docker images | grep stage3

# Check environment variables
env | grep STAGE3

# Check for remaining files
find . -name "*stage3*" -type f

echo "✅ Local environment verification completed"
```

---

## 💰 Cost Verification

### **Final Cost Check**
```bash
echo "💰 Performing final cost verification..."

# Check for any remaining billable resources
aws ce get-cost-and-usage \
    --time-period Start=2025-01-01,End=2025-01-31 \
    --granularity MONTHLY \
    --metrics BlendedCost \
    --group-by Type=DIMENSION,Key=SERVICE

echo "⚠️  Monitor your AWS bill for the next few days to ensure no unexpected charges"
echo "⚠️  Some resources may have delayed billing (like data transfer)"
```

---

## 📋 Destruction Completion Checklist

### **Final Verification**
- [ ] **Database Backup**: Final backup created and stored safely
- [ ] **Configuration Backup**: All configurations archived
- [ ] **Application Data**: Critical data exported
- [ ] **EKS Cluster**: Completely destroyed
- [ ] **RDS Database**: Destroyed (with final snapshot if needed)
- [ ] **VPC and Networking**: All networking resources removed
- [ ] **ECR Repositories**: Deleted with all images
- [ ] **S3 Buckets**: Emptied and deleted
- [ ] **DynamoDB Tables**: Deleted
- [ ] **IAM Resources**: Cleaned up
- [ ] **Local Environment**: kubectl contexts and configs removed
- [ ] **Cost Verification**: No unexpected ongoing charges

### **Documentation Updates**
- [ ] **Project Status**: Updated to "DESTROYED"
- [ ] **Team Notification**: All stakeholders informed
- [ ] **Archive Location**: Backup location documented
- [ ] **Lessons Learned**: Destruction process feedback documented

---

## 🎯 Post-Destruction Actions

### **Immediate Actions**
1. **Confirm Destruction**: Verify all resources are deleted
2. **Update Documentation**: Mark project as destroyed
3. **Notify Stakeholders**: Inform all relevant parties
4. **Monitor Costs**: Watch for unexpected charges

### **Follow-up Actions (24-48 hours)**
1. **Cost Verification**: Ensure no ongoing charges
2. **Backup Verification**: Confirm backups are accessible
3. **Documentation Archive**: Store all project documentation
4. **Lessons Learned**: Document destruction process improvements

---

## 🆕 **Monitoring Stack Cleanup**

### **Dedicated Monitoring Infrastructure Cleanup**

**NEW: We have created specialized scripts for monitoring stack management.**

#### **Complete Monitoring Stack Removal**
```bash
# Navigate to Stage-3 directory
cd Project-Stages/Project-Stage-3-Advanced-DevOps-Pipeline

# Clean up complete monitoring stack
./scripts/monitoring/cleanup-monitoring-stack.sh
```

**What gets removed:**
- 🔍 **Prometheus Server**: Metrics collection and storage
- 📊 **Grafana**: Dashboards and visualization
- 🚨 **AlertManager**: Alert management and notifications
- 📈 **Node Exporter**: System metrics collection
- 🎯 **Service Monitors**: Application monitoring configurations
- 📋 **Custom Alert Rules**: Healthcare-specific alerting
- 💾 **Persistent Volumes**: All monitoring data storage

#### **Monitoring Stack Validation**
```bash
# Validate monitoring cleanup
./scripts/monitoring/validate-monitoring-stack.sh
```

#### **Quick Monitoring Deployment (No Persistence)**
```bash
# For testing - deploy monitoring without persistent storage
./scripts/monitoring/quick-deploy-monitoring.sh
```

---

## 📊 **New Script Locations**

### **Infrastructure Destruction Scripts**
- **Complete Destruction**: `./scripts/cleanup/destroy-complete-infrastructure.sh`
- **Monitoring Cleanup**: `./scripts/monitoring/cleanup-monitoring-stack.sh`
- **Monitoring Validation**: `./scripts/monitoring/validate-monitoring-stack.sh`
- **Quick Monitoring Deploy**: `./scripts/monitoring/quick-deploy-monitoring.sh`

### **Script Features**
- ✅ **Enhanced Error Handling**: Robust failure recovery
- ✅ **Resource Verification**: Confirms successful cleanup
- ✅ **Cost Optimization**: Ensures no ongoing charges
- ✅ **Safety Confirmations**: Multiple confirmation steps
- ✅ **Detailed Logging**: Comprehensive operation logs

---

## ⚠️ **FINAL WARNING**

**Once this destruction process is completed:**
- ❌ **All Stage-3 infrastructure will be permanently deleted**
- ❌ **All application data will be lost (unless backed up)**
- ❌ **All configurations will need to be recreated from scratch**
- ❌ **This process cannot be reversed**

**Estimated Destruction Time:**
- 🚀 **Automated Script**: 15-30 minutes
- 🔧 **Manual Process**: 2-3 hours

---

## 🆕 **What's New in This Guide**

### **Added Features:**
- ✅ **Automated Complete Destruction Script**: One-command infrastructure removal
- ✅ **Monitoring Stack Management**: Dedicated monitoring cleanup scripts
- ✅ **Enhanced Safety Features**: Multiple confirmation steps
- ✅ **Resource Verification**: Automated verification of destruction
- ✅ **Cost Optimization**: Ensures no ongoing AWS charges

### **Improved Processes:**
- 🔄 **Streamlined Workflow**: Reduced destruction time from hours to minutes
- 🛡️ **Enhanced Safety**: Better confirmation and verification processes
- 📊 **Better Monitoring**: Dedicated monitoring infrastructure management
- 🔍 **Comprehensive Validation**: Automated verification of cleanup

---

*This enhanced destruction guide provides both automated and manual options for complete and safe removal of all Stage-3 resources while preserving critical data and configurations for future reference.*
