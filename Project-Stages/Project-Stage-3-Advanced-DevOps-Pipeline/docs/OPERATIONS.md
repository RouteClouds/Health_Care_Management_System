# Stage-3 Operations Manual

## 📋 Table of Contents

1. [Pipeline Behavior & Execution Flow](#pipeline-behavior--execution-flow)
2. [Daily Operations](#daily-operations)
3. [Deployment Operations](#deployment-operations)
4. [Monitoring Operations](#monitoring-operations)
5. [Infrastructure Operations](#infrastructure-operations)
6. [Security Operations](#security-operations)
7. [Backup & Recovery](#backup--recovery)
8. [Performance Management](#performance-management)
9. [Incident Response](#incident-response)

---

## 🔄 Pipeline Behavior & Execution Flow

### **Understanding Stage-3 Pipeline Execution**

The Stage-3 pipeline is designed to handle both **initial infrastructure creation** and **ongoing application updates** intelligently. Here's how it behaves in different scenarios:

### **🚀 Scenario 1: First-Time Pipeline Execution (Fresh Deployment)**

**What Happens:**
1. **Terraform Validation** ✅ (2-3 minutes)
2. **Unit Tests** ✅ (3-5 minutes)
3. **Security Scanning** ✅ (2-4 minutes)
4. **Build and Push Images** ✅ (5-8 minutes)
5. **Infrastructure Deployment** ⏳ (25-35 minutes) - **EKS Cluster Creation**
6. **GitOps Deployment** ⏳ (5-10 minutes) - **Application Deployment**

**Total Time: 40-65 minutes**

#### **Infrastructure Deployment Stage (25-35 minutes)**

**What Gets Created:**
- **VPC with subnets** (2-3 minutes)
- **Security Groups** (1-2 minutes)
- **EKS Cluster** (15-20 minutes) ⏰ **Longest step**
- **EKS Node Groups** (5-8 minutes)
- **RDS Database** (5-10 minutes)
- **S3 Buckets** (1-2 minutes)
- **ECR Repositories** (1-2 minutes)

**Pipeline Behavior:**
- ✅ **Pipeline WAITS** for EKS cluster to be fully ready
- ✅ **No timeout failures** - Terraform handles the wait automatically
- ✅ **Parallel resource creation** where possible
- ✅ **Dependency management** ensures correct order

**Why EKS Takes 15-20 Minutes:**
- AWS provisions control plane nodes
- Sets up networking and security
- Configures cluster endpoints
- Initializes cluster add-ons

#### **GitOps Deployment Stage (5-10 minutes)**

**What Happens After Infrastructure is Ready:**
- ArgoCD connects to the new EKS cluster
- Deploys frontend and backend applications
- Sets up ingress controllers
- Configures monitoring stack

**Pipeline Success Criteria:**
- All Terraform resources created successfully
- EKS cluster status: `ACTIVE`
- Node groups status: `ACTIVE`
- Applications deployed and running

### **🔄 Scenario 2: Code Changes (Infrastructure Already Exists)**

**What Happens:**
1. **Terraform Validation** ✅ (1-2 minutes)
2. **Unit Tests** ✅ (3-5 minutes)
3. **Security Scanning** ✅ (2-4 minutes)
4. **Build and Push Images** ✅ (5-8 minutes) - **New images with latest code**
5. **Infrastructure Deployment** ✅ (2-5 minutes) - **No changes, quick validation**
6. **GitOps Deployment** ✅ (3-5 minutes) - **Rolling update of applications**

**Total Time: 16-29 minutes**

#### **Infrastructure Deployment Behavior:**

**Terraform State Check:**
- Compares current infrastructure with desired state
- **No changes needed** = Quick validation (2-3 minutes)
- **Minor changes** = Apply only differences (3-5 minutes)
- **Major changes** = Full resource updates (varies)

**What Terraform Detects:**
```bash
# Example Terraform output for no changes:
No changes. Your infrastructure matches the configuration.

# Example for minor changes:
Plan: 0 to add, 2 to change, 0 to destroy.
```

#### **GitOps Deployment Behavior:**

**Rolling Updates:**
- ArgoCD detects new Docker images
- Performs rolling update of pods
- **Zero-downtime deployment**
- Health checks ensure successful deployment

**Update Process:**
1. Pull new Docker images
2. Create new pods with updated images
3. Wait for new pods to be ready
4. Terminate old pods
5. Update service endpoints

### **📊 Pipeline Execution Timeline**

#### **First Deployment (Fresh Infrastructure):**
```
0-5 min:    Terraform Validation + Unit Tests + Security Scanning
5-13 min:   Build and Push Docker Images
13-48 min:  Infrastructure Deployment (EKS cluster creation)
48-58 min:  GitOps Deployment (Application deployment)
```

#### **Code Updates (Existing Infrastructure):**
```
0-5 min:    Validation + Tests + Scanning
5-13 min:   Build and Push New Images
13-18 min:  Infrastructure Validation (no changes)
18-23 min:  Rolling Application Update
```

#### **Infrastructure Updates:**
```
0-5 min:    Validation + Tests + Scanning
5-13 min:   Build and Push Images
13-33 min:  Infrastructure Changes (varies by scope)
33-43 min:  Application Configuration Updates
```

### **🎯 Key Takeaways**

1. **First-time deployment takes 40-65 minutes** due to EKS cluster creation
2. **Subsequent code changes take 16-29 minutes** with existing infrastructure
3. **Pipeline automatically waits** for infrastructure to be ready
4. **No manual intervention required** for standard deployments
5. **Rolling updates ensure zero downtime** for application changes

---

## 📅 Daily Operations

### **Morning Health Checks (15 minutes)**
```bash
# Daily health check script
#!/bin/bash
echo "🌅 Starting daily health checks..."

# Check cluster health
kubectl get nodes
kubectl get pods --all-namespaces | grep -v Running | grep -v Completed

# Check application status
kubectl get pods -n healthcare-stage3-dev
kubectl get services -n healthcare-stage3-dev

# Check ArgoCD sync status
kubectl get applications -n argocd

# Check monitoring stack
kubectl get pods -n monitoring
kubectl get pods -n logging

echo "✅ Daily health check completed"
```

### **Application Health Verification**
```bash
# Verify application endpoints
echo "🔍 Checking application endpoints..."

# Frontend health check
FRONTEND_URL=$(kubectl get svc frontend-stage3-svc -n healthcare-stage3-dev -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
curl -s -o /dev/null -w "%{http_code}" http://$FRONTEND_URL

# Backend health check
BACKEND_URL=$(kubectl get svc backend-stage3-svc -n healthcare-stage3-dev -o jsonpath='{.spec.clusterIP}')
kubectl exec -n healthcare-stage3-dev deployment/healthcare-backend-stage3 -- curl -s http://localhost:3001/health

# Database connectivity
kubectl exec -n healthcare-stage3-dev deployment/healthcare-backend-stage3 -- npm run db:check

echo "✅ Application health verified"
```

### **Resource Utilization Check**
```bash
# Check resource usage
kubectl top nodes
kubectl top pods -n healthcare-stage3-dev
kubectl top pods -n monitoring
kubectl top pods -n logging

# Check persistent volume usage
kubectl get pv
df -h /var/lib/docker
```

---

## 🚀 Deployment Operations

### **GitOps Deployment Workflow**

#### **Standard Deployment Process**
1. **Code Changes**: Developer commits to feature branch
2. **CI Pipeline**: GitHub Actions builds and tests
3. **Image Build**: New images pushed to ECR with tags
4. **GitOps Update**: Automated update of image tags in GitOps repo
5. **ArgoCD Sync**: Automatic deployment to cluster
6. **Validation**: Health checks and monitoring verification

#### **Manual Deployment Commands**
```bash
# Force ArgoCD sync for immediate deployment
argocd app sync healthcare-frontend-stage3 --force
argocd app sync healthcare-backend-stage3 --force

# Check deployment status
argocd app get healthcare-frontend-stage3
argocd app get healthcare-backend-stage3

# View deployment history
argocd app history healthcare-frontend-stage3
```

### **Rollback Procedures**

#### **Automated Rollback via ArgoCD**
```bash
# Rollback to previous version
argocd app rollback healthcare-frontend-stage3 <revision-id>

# Rollback to specific revision
argocd app history healthcare-frontend-stage3
argocd app rollback healthcare-frontend-stage3 --revision 5
```

#### **Emergency Rollback via kubectl**
```bash
# Emergency rollback using kubectl
kubectl rollout undo deployment/healthcare-frontend-stage3 -n healthcare-stage3-dev
kubectl rollout undo deployment/healthcare-backend-stage3 -n healthcare-stage3-dev

# Check rollback status
kubectl rollout status deployment/healthcare-frontend-stage3 -n healthcare-stage3-dev
```

### **Blue-Green Deployment Operations**
```bash
# Switch traffic to green environment
kubectl patch service frontend-stage3-svc -n healthcare-stage3-dev -p '{"spec":{"selector":{"version":"green"}}}'

# Verify green environment health
kubectl get pods -n healthcare-stage3-dev -l version=green

# Rollback to blue if issues
kubectl patch service frontend-stage3-svc -n healthcare-stage3-dev -p '{"spec":{"selector":{"version":"blue"}}}'
```

---

---

## 🔐 Credential Handling for Observability (Student‑Friendly)

To keep the repository safe and easy for new users, we never commit real passwords. Use one of the following options:

- Option A (Recommended): Gmail App Password
  - Enable 2‑Step Verification on your Google account
  - Create an App Password for “Mail”→“Other” and copy the 16‑character value
  - Use this value in the Alertmanager Secret (smtp_auth_password)
- Option B: Alternative SMTP provider (SendGrid, Mailgun, SES)
  - Create an SMTP user and password, note the host:port
  - Use those values in the Secret
- Option C: Local‑only (no outbound email)
  - Keep Alertmanager configured but without credentials; use UI/Slack later

Create Secrets locally (do not commit):

1) Grafana admin Secret
```bash
cat > grafana-admin-secret.yaml <<'EOF'
apiVersion: v1
kind: Secret
metadata:
  name: grafana-admin
  namespace: monitoring
stringData:
  admin-user: admin
  admin-password: <choose-strong-password>
EOF
kubectl apply -f grafana-admin-secret.yaml
```

2) Alertmanager email Secret
```bash
cat > alertmanager-secret.yaml <<'EOF'
apiVersion: v1
kind: Secret
metadata:
  name: alertmanager-config
  namespace: monitoring
stringData:
  alertmanager.yaml: |
    global:
      smtp_smarthost: 'smtp.gmail.com:587'
      smtp_from: '<your-email@example.com>'
      smtp_auth_username: '<your-email@example.com>'
      smtp_auth_password: '<APP_PASSWORD>'
      smtp_require_tls: true
    route:
      receiver: 'email'
    receivers:
    - name: 'email'
      email_configs:
      - to: '<your-email@example.com>'
        send_resolved: true
EOF
kubectl apply -f alertmanager-secret.yaml
```

Test email delivery:
- Wait 2–5 minutes; the built‑in “Watchdog” alert should deliver a test email
- Or temporarily create a test alert rule with a low threshold


## 📊 Monitoring Operations

### **Grafana Dashboard Management**

#### **Access Grafana Dashboard**
```bash
# Port forward to Grafana
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80 &

# Access credentials
kubectl get secret prometheus-grafana -n monitoring -o jsonpath="{.data.admin-password}" | base64 --decode
```

#### **Key Dashboards to Monitor**
- **Infrastructure Overview**: Node metrics, cluster health
- **Application Performance**: Response times, error rates
- **Business Metrics**: User activity, feature usage
- **Security Dashboard**: Failed logins, suspicious activity

### **Prometheus Alert Management**

#### **Check Active Alerts**
```bash
# Port forward to Prometheus
kubectl port-forward -n monitoring svc/prometheus-server 9090:80 &

# View active alerts
curl -s http://localhost:9090/api/v1/alerts | jq '.data.alerts[] | select(.state=="firing")'
```

#### **Alert Response Procedures**
```bash
# High CPU Alert Response
kubectl top nodes
kubectl top pods --all-namespaces --sort-by=cpu

# High Memory Alert Response
kubectl describe nodes | grep -A 5 "Allocated resources"
kubectl get pods --all-namespaces --sort-by='.status.containerStatuses[0].restartCount'

# Application Error Rate Alert
kubectl logs -n healthcare-stage3-dev deployment/healthcare-backend-stage3 --tail=100
kubectl logs -n healthcare-stage3-dev deployment/healthcare-frontend-stage3 --tail=100
```

### **Log Analysis Operations**

#### **Kibana Dashboard Access**
```bash
# Port forward to Kibana
kubectl port-forward -n logging svc/kibana 5601:5601 &

# Access Kibana at http://localhost:5601
```

#### **Common Log Queries**
```bash
# Search for errors in last hour
# Kibana Query: level:ERROR AND @timestamp:[now-1h TO now]

# Search for specific user activity
# Kibana Query: user_id:"12345" AND @timestamp:[now-24h TO now]

# Search for API endpoint performance
# Kibana Query: path:"/api/appointments" AND response_time:>1000
```

---

## 🏗️ Infrastructure Operations

### **Terraform Operations**

#### **Infrastructure Updates**
```bash
# Navigate to environment
cd terraform/environments/dev

# Check for configuration drift
terraform plan

# Apply infrastructure changes
terraform apply

# View current state
terraform show
terraform state list
```

#### **Infrastructure Scaling**
```bash
# Scale EKS node group
terraform apply -var="desired_nodes=5"

# Scale RDS instance
terraform apply -var="db_instance_class=db.t3.medium"
```

### **Kubernetes Cluster Operations**

#### **Node Management**
```bash
# Drain node for maintenance
kubectl drain <node-name> --ignore-daemonsets --delete-emptydir-data

# Cordon node (prevent new pods)
kubectl cordon <node-name>

# Uncordon node (allow new pods)
kubectl uncordon <node-name>
```

#### **Namespace Management**
```bash
# Create new environment namespace
kubectl create namespace healthcare-stage3-staging

# Apply resource quotas
kubectl apply -f configs/resource-quotas/staging-quota.yaml

# Set up network policies
kubectl apply -f configs/network-policies/staging-policies.yaml
```

---

## 🔒 Security Operations

### **Security Monitoring**

#### **Check Security Policies**
```bash
# Verify network policies
kubectl get networkpolicies --all-namespaces

# Check pod security standards
kubectl get pods -o jsonpath='{.items[*].spec.securityContext}' -n healthcare-stage3-dev

# Review RBAC permissions
kubectl get rolebindings,clusterrolebindings --all-namespaces
```

#### **Security Incident Response**
```bash
# Check for suspicious pod activity
kubectl get events --sort-by='.lastTimestamp' | grep -i "failed\|error\|warning"

# Review failed authentication attempts
kubectl logs -n kube-system deployment/aws-load-balancer-controller | grep -i "auth"

# Check for privilege escalation attempts
kubectl get pods --all-namespaces -o jsonpath='{.items[?(@.spec.securityContext.privileged==true)].metadata.name}'
```

### **Certificate Management**
```bash
# Check certificate expiration
kubectl get certificates --all-namespaces

# Renew certificates
kubectl delete certificate healthcare-tls-stage3 -n healthcare-stage3-dev
kubectl apply -f configs/certificates/healthcare-cert.yaml
```

---

## 💾 Backup & Recovery

### **Database Backup Operations**
```bash
# Create database backup
kubectl exec -n healthcare-stage3-dev deployment/healthcare-backend-stage3 -- pg_dump -h $DB_HOST -U $DB_USER healthcare_stage3_db > backup-$(date +%Y%m%d).sql

# Upload backup to S3
aws s3 cp backup-$(date +%Y%m%d).sql s3://healthcare-backups-stage3/database/
```

### **Configuration Backup**
```bash
# Backup all Kubernetes configurations
kubectl get all --all-namespaces -o yaml > k8s-backup-$(date +%Y%m%d).yaml

# Backup ArgoCD applications
kubectl get applications -n argocd -o yaml > argocd-backup-$(date +%Y%m%d).yaml

# Backup monitoring configurations
helm get values prometheus -n monitoring > prometheus-values-$(date +%Y%m%d).yaml
```

### **Disaster Recovery Procedures**
```bash
# Complete cluster recovery
# 1. Restore infrastructure with Terraform
cd terraform/environments/dev && terraform apply

# 2. Restore ArgoCD applications
kubectl apply -f argocd-backup-latest.yaml

# 3. Restore database
kubectl exec -n healthcare-stage3-dev deployment/healthcare-backend-stage3 -- psql -h $DB_HOST -U $DB_USER -d healthcare_stage3_db < backup-latest.sql
```

---

## ⚡ Performance Management

### **Performance Monitoring**
```bash
# Check application performance metrics
kubectl exec -n monitoring deployment/prometheus-server -- promtool query instant 'rate(http_requests_total[5m])'

# Monitor resource utilization trends
kubectl exec -n monitoring deployment/prometheus-server -- promtool query instant 'node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes'
```

### **Auto-scaling Operations**
```bash
# Check HPA status
kubectl get hpa -n healthcare-stage3-dev

# Manually scale deployment
kubectl scale deployment healthcare-backend-stage3 --replicas=5 -n healthcare-stage3-dev

# Check VPA recommendations
kubectl describe vpa healthcare-backend-vpa -n healthcare-stage3-dev
```

### **Performance Optimization**
```bash
# Optimize resource requests/limits
kubectl patch deployment healthcare-backend-stage3 -n healthcare-stage3-dev -p '{"spec":{"template":{"spec":{"containers":[{"name":"backend","resources":{"requests":{"memory":"256Mi","cpu":"200m"},"limits":{"memory":"512Mi","cpu":"400m"}}}]}}}}'

# Enable caching
kubectl apply -f configs/redis-cache.yaml
```

---

## 🚨 Incident Response

### **Incident Classification**
- **P1 (Critical)**: Complete service outage
- **P2 (High)**: Significant feature impairment
- **P3 (Medium)**: Minor feature issues
- **P4 (Low)**: Cosmetic or documentation issues

### **Incident Response Workflow**
1. **Detection**: Monitoring alerts or user reports
2. **Assessment**: Determine severity and impact
3. **Response**: Immediate mitigation actions
4. **Communication**: Stakeholder notifications
5. **Resolution**: Root cause fix implementation
6. **Post-mortem**: Lessons learned documentation

### **Emergency Contacts**
- **On-call Engineer**: [Contact Information]
- **DevOps Lead**: [Contact Information]
- **Platform Team**: [Contact Information]
- **Security Team**: [Contact Information]

---

## 📈 Operational Metrics

### **Key Performance Indicators**
- **Uptime**: Target 99.9%
- **Response Time**: < 200ms average
- **Error Rate**: < 0.1%
- **Deployment Frequency**: Daily
- **Mean Time to Recovery**: < 30 minutes

### **Daily Operational Reports**
```bash
# Generate daily report
./scripts/operations/generate-daily-report.sh

# Key metrics to track:
# - Application availability
# - Performance metrics
# - Security incidents
# - Resource utilization
# - Cost optimization opportunities
```

---

*This operations manual provides comprehensive procedures for day-to-day management of the Stage-3 healthcare management system, ensuring reliable and efficient operations.*
