# 📋 Stage 1 Sample Commands
## Health Care Management System - Basic CI/CD Deployment

### 🎯 Overview
This document provides sample commands and examples for Stage 1 implementation.

---

## 🛠️ Setup Commands

### **Tool Installation**
```bash
# Run automated setup
./scripts/setup-tools.sh

# Manual verification
docker --version
kubectl version --client
aws --version
eksctl version
```

### **AWS Configuration**
```bash
# Configure AWS credentials
aws configure

# Test AWS access
aws sts get-caller-identity
aws eks list-clusters --region us-east-1
```

---

## 🐳 Docker Commands

### **Build Images**
```bash
# Navigate to source code directory
cd ~/healthcare-deployment/health-care-management-system

# Build frontend image
docker build -f Dockerfile.frontend -t your-username/healthcare-frontend:v1.0 ./frontend

# Build backend image
docker build -f Dockerfile.backend -t your-username/healthcare-backend:v1.0 ./backend

# List built images
docker images | grep healthcare
```

### **Push to Docker Hub**
```bash
# Login to Docker Hub
docker login

# Push images
docker push your-username/healthcare-frontend:v1.0
docker push your-username/healthcare-backend:v1.0

# Verify on Docker Hub
echo "Check: https://hub.docker.com/r/your-username/healthcare-frontend"
echo "Check: https://hub.docker.com/r/your-username/healthcare-backend"
```

### **Local Testing (Optional)**
```bash
# Test images locally
docker run -d -p 3000:80 your-username/healthcare-frontend:v1.0
docker run -d -p 3002:3002 your-username/healthcare-backend:v1.0

# Check running containers
docker ps

# Stop containers
docker stop $(docker ps -q)
```

---

## ☁️ EKS Commands

### **Cluster Creation**
```bash
# Create EKS cluster
eksctl create cluster \
  --name healthcare-cluster \
  --version 1.32 \
  --region us-east-1 \
  --nodegroup-name healthcare-nodes \
  --node-type t3.medium \
  --nodes 2 \
  --nodes-min 1 \
  --nodes-max 4 \
  --managed \
  --with-oidc \
  --full-ecr-access

# Monitor creation progress
watch -n 30 'eksctl get cluster --region us-east-1'
```

### **Cluster Configuration**
```bash
# Configure kubectl
aws eks update-kubeconfig --region us-east-1 --name healthcare-cluster

# Verify cluster access
kubectl cluster-info
kubectl get nodes
kubectl get namespaces
```

### **Cluster Information**
```bash
# Get cluster details
eksctl get cluster --region us-east-1
kubectl version --short
kubectl config current-context

# Check node details
kubectl get nodes -o wide
kubectl describe nodes
```

---

## 🚀 Deployment Commands

### **Application Deployment**
```bash
# Navigate to Stage 1 directory
cd /home/ubuntu/Projects/Health_Care_Management_System/Project-Stages/Project-Stage-1-Basic-CI-CD-Deploy

# Update image names (replace YOUR-USERNAME)
sed -i 's/your-username/YOUR-USERNAME/g' k8s/backend-deployment.yaml
sed -i 's/your-username/YOUR-USERNAME/g' k8s/frontend-deployment.yaml

# Deploy application
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/database-deployment.yaml
kubectl apply -f k8s/backend-deployment.yaml
kubectl apply -f k8s/frontend-deployment.yaml

# Or use the automated script
./scripts/deploy-to-eks.sh
```

### **Monitoring Deployment**
```bash
# Watch pod creation
kubectl get pods -n healthcare -w

# Check deployment status
kubectl get deployments -n healthcare
kubectl get services -n healthcare
kubectl get all -n healthcare

# Wait for deployments to be ready
kubectl wait --for=condition=available --timeout=300s deployment --all -n healthcare
```

---

## 🔍 Verification Commands

### **Application Status**
```bash
# Run verification script
./scripts/verify-deployment.sh

# Manual verification
kubectl get pods -n healthcare
kubectl get services -n healthcare
kubectl get endpoints -n healthcare
```

### **Get External Access**
```bash
# Get external IP
kubectl get service frontend-service -n healthcare

# Wait for external IP assignment
kubectl get service frontend-service -n healthcare -w

# Get external IP programmatically
EXTERNAL_IP=$(kubectl get service frontend-service -n healthcare -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
echo "Application URL: http://$EXTERNAL_IP"
```

### **Test Application**
```bash
# Test main page
curl -I http://$EXTERNAL_IP

# Test API health
curl http://$EXTERNAL_IP/api/health

# Test with browser
echo "Open: http://$EXTERNAL_IP"
```

---

## 📊 Monitoring Commands

### **Resource Usage**
```bash
# Check node resources
kubectl top nodes

# Check pod resources
kubectl top pods -n healthcare

# Describe resources
kubectl describe nodes
kubectl describe pods -n healthcare
```

### **Logs and Debugging**
```bash
# View pod logs
kubectl logs deployment/healthcare-frontend -n healthcare
kubectl logs deployment/healthcare-backend -n healthcare
kubectl logs deployment/postgres-db -n healthcare

# Follow logs in real-time
kubectl logs -f deployment/healthcare-backend -n healthcare

# Check PostgreSQL version (should be 16.x)
kubectl exec -it deployment/postgres-db -n healthcare -- psql -U healthcare_user -d healthcare_db -c "SELECT version();"

# Describe problematic pods
kubectl describe pod <pod-name> -n healthcare
```

### **Events and Troubleshooting**
```bash
# Check cluster events
kubectl get events -n healthcare --sort-by='.lastTimestamp'

# Check pod events
kubectl describe pod <pod-name> -n healthcare

# Check service endpoints
kubectl get endpoints -n healthcare

# Port forward for debugging
kubectl port-forward service/backend-service 3002:3002 -n healthcare
```

---

## 🧹 Cleanup Commands

### **Application Cleanup**
```bash
# Delete application resources
kubectl delete namespace healthcare

# Or delete individual resources
kubectl delete -f k8s/frontend-deployment.yaml
kubectl delete -f k8s/backend-deployment.yaml
kubectl delete -f k8s/database-deployment.yaml
kubectl delete -f k8s/namespace.yaml
```

### **Cluster Cleanup**
```bash
# Delete EKS cluster
eksctl delete cluster --name healthcare-cluster --region us-east-1

# Or use cleanup script
./scripts/cleanup.sh
```

### **Local Cleanup**
```bash
# Remove local Docker images
docker rmi your-username/healthcare-frontend:v1.0
docker rmi your-username/healthcare-backend:v1.0

# Clean up Docker system
docker system prune -f
```

---

## 🔧 Troubleshooting Commands

### **Common Issues**

#### **Pods Not Starting**
```bash
# Check pod status
kubectl get pods -n healthcare
kubectl describe pod <pod-name> -n healthcare
kubectl logs <pod-name> -n healthcare

# Check image pull issues
kubectl describe pod <pod-name> -n healthcare | grep -A 10 Events
```

#### **Service Not Accessible**
```bash
# Check service configuration
kubectl get services -n healthcare
kubectl describe service frontend-service -n healthcare

# Check endpoints
kubectl get endpoints -n healthcare

# Test internal connectivity
kubectl exec -it <pod-name> -n healthcare -- curl http://backend-service:3002/api/health
```

#### **External IP Pending**
```bash
# Check load balancer status
kubectl describe service frontend-service -n healthcare

# Check AWS load balancer in console
aws elbv2 describe-load-balancers --region us-east-1

# Wait for provisioning
kubectl get service frontend-service -n healthcare -w
```

---

## 📚 Useful Aliases

### **kubectl Shortcuts**
```bash
# Add to ~/.bashrc or ~/.zshrc
alias k='kubectl'
alias kgp='kubectl get pods'
alias kgs='kubectl get services'
alias kgd='kubectl get deployments'
alias kga='kubectl get all'
alias kns='kubectl config set-context --current --namespace'
alias klogs='kubectl logs'
alias kdesc='kubectl describe'

# Healthcare namespace specific
alias khc='kubectl --namespace=healthcare'
alias kgphc='kubectl get pods -n healthcare'
alias klogshc='kubectl logs -n healthcare'
```

### **AWS Shortcuts**
```bash
# Add to ~/.bashrc or ~/.zshrc
alias awseks='aws eks'
alias awsec2='aws ec2'
alias awsiam='aws iam'
alias awscf='aws cloudformation'

# EKS specific
alias eksls='eksctl get cluster'
alias eksdel='eksctl delete cluster'
alias eksupdate='aws eks update-kubeconfig'
```

---

## 🎯 Next Steps Commands

### **Prepare for Stage 2**
```bash
# Document current setup
kubectl get all -n healthcare > stage1-deployment-summary.txt
eksctl get cluster --region us-east-1 > stage1-cluster-info.txt

# Plan Stage 2
echo "Stage 2 will add:"
echo "- GitHub Actions automation"
echo "- Automated testing"
echo "- Environment-specific deployments"
```

### **Monitor Costs**
```bash
# Check AWS costs (requires AWS CLI with cost explorer permissions)
aws ce get-cost-and-usage \
  --time-period Start=2024-07-01,End=2024-07-31 \
  --granularity MONTHLY \
  --metrics BlendedCost \
  --group-by Type=DIMENSION,Key=SERVICE
```

---

## 🎉 Success Verification

### **Final Checklist**
```bash
# Verify all components
echo "✅ Checking all components..."
kubectl get all -n healthcare
echo ""
echo "✅ External access:"
kubectl get service frontend-service -n healthcare
echo ""
echo "✅ Application health:"
curl -s http://$EXTERNAL_IP/health || echo "Health check pending..."
echo ""
echo "🎉 Stage 1 deployment complete!"
```
