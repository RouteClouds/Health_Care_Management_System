# Stage-3 Operations Manual

## 📋 Table of Contents

1. [Daily Operations](#daily-operations)
2. [Deployment Operations](#deployment-operations)
3. [Monitoring Operations](#monitoring-operations)
4. [Infrastructure Operations](#infrastructure-operations)
5. [Security Operations](#security-operations)
6. [Backup & Recovery](#backup--recovery)
7. [Performance Management](#performance-management)
8. [Incident Response](#incident-response)

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
