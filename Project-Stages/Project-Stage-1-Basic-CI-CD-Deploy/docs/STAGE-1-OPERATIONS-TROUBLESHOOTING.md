# 🛠️ **Stage 1 Operations & Troubleshooting Guide**
## **Healthcare Management System - Complete Operational Reference**

### **📖 Document Content Index**
- [🎯 Purpose](#-purpose)
- [✅ Pre-Deployment Operations](#-pre-deployment-operations)
- [🚀 Deployment Procedures](#-deployment-procedures)
- [🧪 Post-Deployment Testing](#-post-deployment-testing)
- [📊 Monitoring & Health Checks](#-monitoring--health-checks)
- [🔧 Maintenance Operations](#-maintenance-operations)
- [🚨 Critical Issues Resolution](#-critical-issues-resolution)
- [☸️ EKS Cluster Issues](#️-eks-cluster-issues)
- [🐳 Docker & Container Issues](#-docker--container-issues)
- [🌐 Networking & Connectivity](#-networking--connectivity)
- [💰 Cost & Billing Management](#-cost--billing-management)
- [🔑 Authentication & Permissions](#-authentication--permissions)
- [🆘 Emergency Procedures](#-emergency-procedures)
- [📋 Operational Checklists](#-operational-checklists)

**Document Purpose**: Complete operational procedures and comprehensive troubleshooting database
**Target Audience**: Operations teams, system administrators, and DevOps engineers
**Estimated Read Time**: 45 minutes
**Last Updated**: August 6, 2025

---

## **🎯 Purpose**

This guide combines **operational procedures** and **comprehensive troubleshooting** for Stage 1 deployment. Use this as your primary reference for:

- ✅ **Pre-deployment verification**
- 🧪 **Post-deployment testing**
- 📊 **Monitoring and health checks**
- 🔧 **Maintenance operations**
- 🚨 **Issue resolution**
- 🧹 **Complete cleanup procedures**
- 🆘 **Emergency procedures**

---

## **✅ Pre-Deployment Operations**

### **🔍 Environment Verification**
```bash
# Verify all required tools are installed
./scripts/verify-prerequisites.sh

# Manual verification
aws --version          # Should be v2.x
kubectl version --client  # Should be v1.28+
eksctl version         # Should be v0.150+
docker --version       # Should be v20.x+
```

### **☁️ AWS Account Verification**
```bash
# Verify AWS credentials and permissions
aws sts get-caller-identity

# Check required permissions
aws iam get-user
aws eks list-clusters --region us-east-1
aws ec2 describe-vpcs --region us-east-1

# Verify billing is enabled
aws ce get-cost-and-usage --time-period Start=2025-08-05,End=2025-08-06 --granularity DAILY --metrics BlendedCost
```

### **🐳 Docker Hub Verification**
```bash
# Verify Docker Hub access
docker login

# Test image pull capability
docker pull hello-world
docker run hello-world
docker rmi hello-world
```

### **💰 Cost Estimation**
```bash
# Calculate expected costs
echo "Expected hourly cost: $0.30-0.50"
echo "Expected daily cost (if left running): $7-12"
echo "Recommended testing duration: 2-4 hours"
```

---

## **🚀 Deployment Procedures**

### **📋 Standard Deployment Workflow**
```bash
# 1. Tool Installation (15 minutes)
./scripts/setup-tools.sh

# 2. AWS Configuration (5 minutes)
aws configure

# 3. EKS Cluster Creation (20 minutes)
./scripts/create-eks-cluster.sh

# 4. Docker Image Build & Push (10 minutes)
./scripts/build-and-push-images.sh

# 5. Application Deployment (10 minutes)
./scripts/deploy-to-eks.sh

# 6. Verification (5 minutes)
./scripts/verify-deployment.sh
```

### **🔄 Deployment Status Monitoring**
```bash
# Monitor cluster creation
watch -n 30 'eksctl get cluster --region us-east-1'

# Monitor node group creation
watch -n 30 'kubectl get nodes'

# Monitor application deployment
watch -n 10 'kubectl get pods -n healthcare'

# Monitor service creation
watch -n 30 'kubectl get services -n healthcare'
```

### **📊 Deployment Validation**
```bash
# Validate cluster health
kubectl get nodes
kubectl get pods --all-namespaces
kubectl cluster-info

# Validate application deployment
kubectl get all -n healthcare
kubectl describe deployment healthcare-backend -n healthcare
kubectl describe deployment healthcare-frontend -n healthcare

# Validate networking
kubectl get services -n healthcare
kubectl get ingress -n healthcare
```

---

## **🧪 Post-Deployment Testing**

### **🔍 Application Health Checks**
```bash
# Test backend health endpoint
kubectl port-forward service/backend-service 3002:3002 -n healthcare &
curl http://localhost:3002/health
pkill -f "kubectl port-forward"

# Test frontend accessibility
FRONTEND_URL=$(kubectl get service frontend-service -n healthcare -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
curl -I http://$FRONTEND_URL

# Test database connectivity
kubectl exec -it $(kubectl get pods -n healthcare -l app=postgres-db -o jsonpath='{.items[0].metadata.name}') -n healthcare -- psql -U healthcare_user -d healthcare_db -c "SELECT version();"
```

### **🧪 Functional Testing**
```bash
# Test user registration API
curl -X POST http://$FRONTEND_URL/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"testpass123","firstName":"Test","lastName":"User"}'

# Test doctor search API
curl http://$FRONTEND_URL/api/doctors

# Test department listing
curl http://$FRONTEND_URL/api/doctors/departments/all
```

### **📊 Performance Testing**
```bash
# Test response times
time curl -s http://$FRONTEND_URL > /dev/null
time curl -s http://$FRONTEND_URL/api/health > /dev/null

# Test concurrent connections
for i in {1..10}; do
  curl -s http://$FRONTEND_URL &
done
wait
```

---

## **📊 Monitoring & Health Checks**

### **☸️ Kubernetes Monitoring**
```bash
# Monitor pod health
kubectl get pods -n healthcare -o wide
kubectl top pods -n healthcare

# Monitor node health
kubectl get nodes -o wide
kubectl top nodes

# Monitor events
kubectl get events -n healthcare --sort-by='.lastTimestamp'

# Monitor resource usage
kubectl describe nodes
```

### **🔍 Application Monitoring**
```bash
# Monitor application logs
kubectl logs -f deployment/healthcare-backend -n healthcare
kubectl logs -f deployment/healthcare-frontend -n healthcare
kubectl logs -f deployment/postgres-db -n healthcare

# Monitor service endpoints
kubectl get endpoints -n healthcare

# Monitor ingress/load balancer
kubectl describe service frontend-service -n healthcare
```

### **💰 Cost Monitoring**
```bash
# Check current costs
aws ce get-cost-and-usage \
  --time-period Start=2025-08-06,End=2025-08-07 \
  --granularity DAILY \
  --metrics BlendedCost

# Monitor EKS cluster costs
aws eks describe-cluster --name healthcare-cluster --region us-east-1 --query 'cluster.status'

# Monitor EC2 instance costs
aws ec2 describe-instances --region us-east-1 \
  --filters "Name=tag:eksctl.cluster.k8s.io/v1alpha1/cluster-name,Values=healthcare-cluster" \
  --query 'Reservations[].Instances[].{InstanceId:InstanceId,InstanceType:InstanceType,State:State.Name}'
```

---

## **🔧 Maintenance Operations**

### **🔄 Regular Maintenance Tasks**
```bash
# Update kubectl context
aws eks update-kubeconfig --region us-east-1 --name healthcare-cluster

# Check for pod restarts
kubectl get pods -n healthcare -o wide

# Clean up completed jobs
kubectl delete jobs --field-selector status.successful=1 -n healthcare

# Update Docker images (if needed)
kubectl set image deployment/healthcare-backend healthcare-backend=routeclouds/healthcare-backend:latest -n healthcare
kubectl set image deployment/healthcare-frontend healthcare-frontend=routeclouds/healthcare-frontend:latest -n healthcare
```

### **📊 Health Check Automation**
```bash
# Create health check script
cat > health-check.sh << 'EOF'
#!/bin/bash
echo "=== Kubernetes Health Check ==="
kubectl get nodes
kubectl get pods -n healthcare
kubectl get services -n healthcare

echo "=== Application Health Check ==="
FRONTEND_URL=$(kubectl get service frontend-service -n healthcare -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
curl -s -I http://$FRONTEND_URL | head -1
EOF

chmod +x health-check.sh
./health-check.sh
```

### **🔄 Backup Procedures**
```bash
# Backup Kubernetes configurations
kubectl get all -n healthcare -o yaml > healthcare-backup.yaml

# Backup database (if needed)
kubectl exec -it $(kubectl get pods -n healthcare -l app=postgres-db -o jsonpath='{.items[0].metadata.name}') -n healthcare -- pg_dump -U healthcare_user healthcare_db > db-backup.sql
```

---

## **🚨 Critical Issues Resolution**

### **🔥 Issue #1: Frontend-Backend Communication Failure**
**Symptoms**: Frontend loads but "Find a Doctor" and user registration don't work
**Root Cause**: Frontend hardcoded with localhost:3002 instead of /api

**Solution**:
```bash
# Check if issue exists
kubectl exec $(kubectl get pods -n healthcare -l app=healthcare-frontend -o jsonpath='{.items[0].metadata.name}') -n healthcare -- grep -o "localhost:300[0-9]" /usr/share/nginx/html/assets/*.js

# If localhost found, rebuild with fixed configuration
cd Project-Stages/Project-Stage-1-Basic-CI-CD-Deploy/src-code
# Ensure frontend/.env has: VITE_API_BASE_URL=/api
docker build -f Dockerfile.frontend -t routeclouds/healthcare-frontend:v1.0 .
docker push routeclouds/healthcare-frontend:v1.0

# Redeploy frontend
kubectl delete pods -l app=healthcare-frontend -n healthcare
```

### **🔥 Issue #2: EKS Cluster Creation Timeout**
**Symptoms**: eksctl hangs during cluster creation
**Root Cause**: AWS service limits or network issues

**Solution**:
```bash
# Check cluster creation status
aws eks describe-cluster --name healthcare-cluster --region us-east-1

# Check CloudFormation stacks
aws cloudformation list-stacks --region us-east-1 --stack-status-filter CREATE_IN_PROGRESS

# If stuck, cancel and retry
eksctl delete cluster --name healthcare-cluster --region us-east-1 --wait
./scripts/create-eks-cluster.sh
```

### **🔥 Issue #3: Docker Build NPM CI Failures**
**Symptoms**: Docker build fails with "npm ci" exit code 1
**Root Cause**: Workspace configuration conflicts

**Solution**:
```bash
# Clean dependencies
./scripts/clean-dependencies.sh

# Or manual cleanup
rm -rf src-code/node_modules src-code/backend/node_modules src-code/frontend/node_modules
cd src-code && npm install && cd backend && npm install && cd ../frontend && npm install && cd ../..

# Rebuild images
./scripts/build-and-push-images.sh
```

### **🔥 Issue #4: LoadBalancer Stuck in Pending**
**Symptoms**: EXTERNAL-IP shows <pending> for frontend-service
**Root Cause**: AWS LoadBalancer provisioning delay or limits

**Solution**:
```bash
# Check service status
kubectl describe service frontend-service -n healthcare

# Check AWS LoadBalancer
aws elbv2 describe-load-balancers --region us-east-1

# Wait up to 10 minutes, then recreate if needed
kubectl delete service frontend-service -n healthcare
kubectl apply -f k8s/frontend-deployment.yaml
```

---

## **☸️ EKS Cluster Issues**

### **Issue: Cluster Not Accessible**
```bash
# Update kubeconfig
aws eks update-kubeconfig --region us-east-1 --name healthcare-cluster

# Verify cluster exists
aws eks describe-cluster --name healthcare-cluster --region us-east-1

# Check kubectl context
kubectl config current-context
kubectl config get-contexts
```

### **Issue: Nodes Not Ready**
```bash
# Check node status
kubectl get nodes -o wide
kubectl describe nodes

# Check node group
eksctl get nodegroup --cluster healthcare-cluster --region us-east-1

# Check EC2 instances
aws ec2 describe-instances --region us-east-1 --filters "Name=tag:eksctl.cluster.k8s.io/v1alpha1/cluster-name,Values=healthcare-cluster"
```

### **Issue: Pod Scheduling Failures**
```bash
# Check pod events
kubectl describe pods -n healthcare

# Check node resources
kubectl top nodes
kubectl describe nodes

# Check taints and tolerations
kubectl get nodes -o json | jq '.items[].spec.taints'
```

---

## **🐳 Docker & Container Issues**

### **Issue: Image Pull Failures**
```bash
# Check image exists in Docker Hub
docker pull routeclouds/healthcare-backend:v1.0
docker pull routeclouds/healthcare-frontend:v1.0

# Check pod events
kubectl describe pods -n healthcare

# Verify image names in deployments
kubectl get deployments -n healthcare -o yaml | grep image:
```

### **Issue: Container Startup Failures**
```bash
# Check container logs
kubectl logs -l app=healthcare-backend -n healthcare
kubectl logs -l app=healthcare-frontend -n healthcare

# Check container status
kubectl get pods -n healthcare -o wide

# Check resource limits
kubectl describe pods -n healthcare | grep -A 5 "Limits\|Requests"
```

### **Issue: Docker Build Failures**
```bash
# Check Docker daemon
sudo systemctl status docker
sudo systemctl start docker

# Check disk space
df -h

# Clean Docker cache
docker system prune -f

# Rebuild with verbose output
docker build -f Dockerfile.backend -t test-backend . --no-cache
```

---

## **🌐 Networking & Connectivity**

### **Issue: Service Discovery Failures**
```bash
# Check services
kubectl get services -n healthcare
kubectl get endpoints -n healthcare

# Test service connectivity
kubectl exec -it <pod-name> -n healthcare -- nslookup backend-service
kubectl exec -it <pod-name> -n healthcare -- curl http://backend-service:3002/health
```

### **Issue: External Access Problems**
```bash
# Check LoadBalancer status
kubectl get services -n healthcare -o wide
aws elbv2 describe-load-balancers --region us-east-1

# Check security groups
aws ec2 describe-security-groups --region us-east-1 --filters "Name=group-name,Values=*healthcare*"

# Test connectivity
FRONTEND_URL=$(kubectl get service frontend-service -n healthcare -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
curl -v http://$FRONTEND_URL
```

### **Issue: DNS Resolution Problems**
```bash
# Check CoreDNS
kubectl get pods -n kube-system -l k8s-app=kube-dns

# Test DNS resolution
kubectl exec -it <pod-name> -n healthcare -- nslookup kubernetes.default.svc.cluster.local

# Check DNS configuration
kubectl get configmap coredns -n kube-system -o yaml
```

---

## **💰 Cost & Billing Management**

### **Issue: Unexpected High Costs**
```bash
# Check current costs
aws ce get-cost-and-usage \
  --time-period Start=2025-08-05,End=2025-08-07 \
  --granularity DAILY \
  --metrics BlendedCost \
  --group-by Type=DIMENSION,Key=SERVICE

# Check running resources
aws eks list-clusters --region us-east-1
aws ec2 describe-instances --region us-east-1 --filters "Name=instance-state-name,Values=running"
aws elbv2 describe-load-balancers --region us-east-1
```

### **Issue: Resources Not Cleaned Up**
```bash
# Emergency cleanup procedure
./scripts/diagnose-aws-resources.sh
./scripts/cleanup-cloudformation.sh
./scripts/force-delete-failed-stack.sh
./scripts/manual-cleanup-stuck-resources.sh
./scripts/verify-complete-cleanup.sh

# Manual verification
aws eks list-clusters --region us-east-1
aws ec2 describe-instances --region us-east-1 --filters "Name=tag:eksctl.cluster.k8s.io/v1alpha1/cluster-name,Values=healthcare-cluster"
aws elbv2 describe-load-balancers --region us-east-1 | grep healthcare
```

### **Cost Optimization**
```bash
# Use spot instances (for testing)
eksctl create cluster --spot --instance-types=t3.medium,t3.small

# Set up auto-scaling
kubectl apply -f - <<EOF
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: healthcare-backend-hpa
  namespace: healthcare
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: healthcare-backend
  minReplicas: 1
  maxReplicas: 3
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
EOF
```

---

## **🔑 Authentication & Permissions**

### **Issue: AWS Credentials Problems**
```bash
# Check current credentials
aws sts get-caller-identity

# Check credential configuration
aws configure list

# Test permissions
aws eks list-clusters --region us-east-1
aws ec2 describe-vpcs --region us-east-1
aws iam get-user
```

### **Issue: Kubernetes RBAC Problems**
```bash
# Check current context
kubectl config current-context

# Check permissions
kubectl auth can-i create pods --namespace healthcare
kubectl auth can-i get services --namespace healthcare

# Check service accounts
kubectl get serviceaccounts -n healthcare
kubectl describe serviceaccount default -n healthcare
```

### **Issue: Docker Hub Authentication**
```bash
# Check Docker login status
docker info | grep Username

# Re-login if needed
docker logout
docker login

# Test image push
docker tag hello-world:latest yourusername/test:latest
docker push yourusername/test:latest
docker rmi yourusername/test:latest
```

---

## **🆘 Emergency Procedures**

### **🚨 Complete System Recovery**
```bash
# 1. Stop all running processes
pkill -f kubectl
pkill -f docker

# 2. Clean up local resources
docker system prune -af
docker volume prune -f

# 3. Reset kubectl context
kubectl config unset current-context
aws eks update-kubeconfig --region us-east-1 --name healthcare-cluster

# 4. Verify cluster accessibility
kubectl get nodes

# 5. Redeploy if needed
./scripts/deploy-to-eks.sh
```

### **🚨 Emergency Cluster Deletion**
```bash
# Force delete cluster (use with caution)
eksctl delete cluster --name healthcare-cluster --region us-east-1 --force

# Clean up remaining resources
aws cloudformation list-stacks --region us-east-1 --stack-status-filter DELETE_FAILED
aws ec2 describe-instances --region us-east-1 --filters "Name=tag:eksctl.cluster.k8s.io/v1alpha1/cluster-name,Values=healthcare-cluster"

# Manual resource cleanup if needed
./scripts/manual-cleanup-stuck-resources.sh
```

### **🚨 Emergency Cost Control**
```bash
# Immediate cost reduction
kubectl scale deployment --replicas=0 --all -n healthcare
eksctl scale nodegroup --cluster healthcare-cluster --name healthcare-nodes --nodes 0 --region us-east-1

# Complete shutdown
./scripts/cleanup.sh

# Verify no charges
aws ce get-cost-and-usage --time-period Start=2025-08-06,End=2025-08-07 --granularity DAILY --metrics BlendedCost
```

---

## **📋 Operational Checklists**

### **✅ Pre-Deployment Checklist**
- [ ] AWS CLI installed and configured
- [ ] kubectl installed and working
- [ ] eksctl installed and working
- [ ] Docker installed and running
- [ ] Docker Hub account accessible
- [ ] AWS credentials have required permissions
- [ ] Billing alerts configured
- [ ] Cost expectations understood

### **✅ Post-Deployment Checklist**
- [ ] All pods running in healthcare namespace
- [ ] All services have endpoints
- [ ] LoadBalancer has external IP
- [ ] Frontend accessible via browser
- [ ] Backend health endpoint responding
- [ ] Database connectivity verified
- [ ] User registration working
- [ ] Doctor search functionality working
- [ ] Cleanup procedure tested

### **✅ Maintenance Checklist**
- [ ] Monitor pod health daily
- [ ] Check AWS costs weekly
- [ ] Update Docker images monthly
- [ ] Backup configurations monthly
- [ ] Review security settings quarterly
- [ ] Update documentation as needed

### **✅ Emergency Response Checklist**
- [ ] Identify the issue scope
- [ ] Check system health status
- [ ] Review recent changes
- [ ] Apply appropriate fix procedure
- [ ] Verify fix effectiveness
- [ ] Document incident and resolution
- [ ] Update procedures if needed

---

## **🔗 Related Documentation**

- **🚀 Complete Deployment Guide**: [STAGE-1-COMPLETE-GUIDE.md](./STAGE-1-COMPLETE-GUIDE.md)
- **📚 Historical Issues**: [STAGE-1-ISSUE-KNOWLEDGE-BASE.md](./STAGE-1-ISSUE-KNOWLEDGE-BASE.md)
- **🔧 Validation & Maintenance**: [STAGE-1-VALIDATION-MAINTENANCE.md](./STAGE-1-VALIDATION-MAINTENANCE.md)
- **📜 Script Usage**: [How-Use-Scripts.md](../scripts/How-Use-Scripts.md)
- **⚡ Quick Reference**: [QUICK-REFERENCE.md](../scripts/QUICK-REFERENCE.md)

---

## **📋 Document Information**

**Guide Version**: 2.0
**Last Updated**: August 6, 2025
**Document Type**: Operations & Troubleshooting Reference
**Maintenance**: Update after each major issue resolution

**🛠️ This guide provides comprehensive operational and troubleshooting coverage for Stage 1 deployments.**
