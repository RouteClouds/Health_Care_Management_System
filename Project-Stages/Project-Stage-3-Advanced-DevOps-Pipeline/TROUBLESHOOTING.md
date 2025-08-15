# Stage-3 Troubleshooting Guide

## 📋 Table of Contents

1. [Quick Diagnostic Commands](#quick-diagnostic-commands)
2. [ECR & Container Issues](#ecr--container-issues)
3. [Terraform Infrastructure Issues](#terraform-infrastructure-issues)
4. [GitOps & ArgoCD Issues](#gitops--argocd-issues)
5. [Monitoring & Observability Issues](#monitoring--observability-issues)
6. [Application-Specific Issues](#application-specific-issues)
7. [Network & Connectivity Issues](#network--connectivity-issues)
8. [Performance Issues](#performance-issues)
9. [Security Issues](#security-issues)
10. [Emergency Procedures](#emergency-procedures)

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
