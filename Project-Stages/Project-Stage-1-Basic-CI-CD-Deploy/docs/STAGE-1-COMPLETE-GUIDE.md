# 🚀 **Stage 1 Complete Deployment Guide**
## **Healthcare Management System - From Setup to Success**

### **📖 Document Content Index**
- [🎯 Welcome to Stage 1](#-welcome-to-stage-1)
- [🚀 Quick Start - Choose Your Path](#-quick-start---choose-your-path)
- [📋 Prerequisites & Requirements](#-prerequisites--requirements)
- [🛠️ Step 1: Tool Installation](#️-step-1-install-required-tools-15-minutes)
- [🔑 Step 2: AWS Configuration](#-step-2-configure-aws-credentials-10-minutes)
- [☸️ Step 3: EKS Cluster Setup](#️-step-3-create-eks-cluster-20-minutes)
- [🐳 Step 4: Build & Push Images](#-step-4-build-and-push-docker-images-10-minutes)
- [🚀 Step 5: Deploy to EKS](#-step-5-deploy-to-aws-eks-20-minutes)
- [✅ Step 6: Verify Success](#-step-6-verify-deployment-success-10-minutes)
- [💰 Cost Management & Cleanup](#-cost-management--cleanup)
- [📜 Complete Script Reference](#-complete-script-reference)
- [🔍 Basic Troubleshooting](#-basic-troubleshooting)
- [🎉 Success Indicators](#-success-indicators)

**Document Purpose**: Complete end-to-end deployment guide with navigation and onboarding
**Target Audience**: All Stage 1 users (beginners to advanced)
**Estimated Time**: 55-70 minutes (includes Docker build step)
**Success Rate**: 95%+ when prerequisites are met
**Last Updated**: August 6, 2025

---

## **🎯 Welcome to Stage 1**

This is your **single comprehensive guide** for deploying the Healthcare Management System using AWS EKS. Stage 1 establishes a basic containerized deployment workflow with proper IAM roles, security groups, and version compatibility.

### **What You'll Accomplish**
- ✅ **Complete AWS EKS deployment** with 2-node cluster
- ✅ **Containerized healthcare application** (React frontend + Node.js backend + PostgreSQL)
- ✅ **Production-ready infrastructure** with LoadBalancer and proper networking
- ✅ **Cost-effective setup** (~$0.30-0.50/hour while running)
- ✅ **Clean deployment workflow** using Docker Hub and Kubernetes

### **Architecture Overview**
```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Developer     │    │   Docker Hub     │    │   AWS EKS       │
│   Workstation   │───▶│   Registry       │───▶│   Cluster       │
└─────────────────┘    └──────────────────┘    └─────────────────┘
         │                                               │
         ▼                                               ▼
┌─────────────────┐                            ┌─────────────────┐
│   Source Code   │                            │   Healthcare    │
│   + Scripts     │                            │   Application   │
└─────────────────┘                            └─────────────────┘
```

---

## **🚀 Quick Start - Choose Your Path**

### **👤 For New Users (First Time Setup)**
**Time Required**: 55-70 minutes  
**Recommended Path**: Follow this guide step-by-step from beginning to end

### **🔄 For Returning Users**
**Time Required**: 20-30 minutes  
**Quick Path**: Jump to [Step 3: EKS Cluster Setup](#️-step-3-create-eks-cluster-20-minutes)

### **🆘 Having Issues?**
**Troubleshooting**: See [Basic Troubleshooting](#-basic-troubleshooting) or [STAGE-1-OPERATIONS-TROUBLESHOOTING.md](./STAGE-1-OPERATIONS-TROUBLESHOOTING.md)

---

## **📋 Prerequisites & Requirements**

### **💻 System Requirements**
- **OS**: Ubuntu 20.04+ (recommended) or similar Linux distribution
- **RAM**: 4GB minimum, 8GB recommended
- **Storage**: 10GB free space
- **Network**: Stable internet connection

### **☁️ AWS Requirements**
- **AWS Account** with billing enabled
- **IAM User** with programmatic access
- **Required Permissions**:
  - EKS Full Access
  - EC2 Full Access
  - IAM Role Management
  - VPC Management
  - CloudFormation Access

### **🐳 Docker Hub Requirements**
- **Docker Hub Account** (free tier sufficient)
- **Repository Access** for pushing images

### **💰 Cost Expectations**
- **EKS Cluster**: ~$0.10/hour
- **EC2 Instances**: ~$0.20-0.40/hour (2x t3.medium)
- **Total**: ~$0.30-0.50/hour while running
- **Daily Cost**: ~$7-12 if left running 24/7

---

## **🛠️ Step 1: Install Required Tools (15 minutes)**

### **Option A: Automated Setup Script (Recommended)**
```bash
# Navigate to project directory
cd Project-Stages/Project-Stage-1-Basic-CI-CD-Deploy

# Run automated setup script
./scripts/setup-tools.sh

# Script location: scripts/setup-tools.sh
# This installs: AWS CLI, kubectl, eksctl, Docker, and additional tools
```

### **Option B: Manual Installation Commands**

#### **Install AWS CLI**
```bash
# Download and install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
rm -rf aws awscliv2.zip

# Verify installation
aws --version
```

#### **Install kubectl**
```bash
# Download kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

# Install kubectl
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Verify installation
kubectl version --client
```

#### **Install eksctl**
```bash
# Download and install eksctl
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin

# Verify installation
eksctl version
```

#### **Install Docker**
```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
rm get-docker.sh

# Verify installation (may need to log out/in)
docker --version
```

#### **Install Additional Tools**
```bash
# Install useful utilities
sudo apt update
sudo apt install -y jq curl wget unzip

# Verify installations
jq --version
curl --version
```

---

## **🔑 Step 2: Configure AWS Credentials (10 minutes)**

### **Configure AWS CLI**
```bash
# Configure AWS credentials
aws configure

# Enter your credentials:
# AWS Access Key ID: [Your Access Key]
# AWS Secret Access Key: [Your Secret Key]
# Default region name: us-east-1
# Default output format: json
```

### **Verify AWS Configuration**
```bash
# Test AWS connectivity
aws sts get-caller-identity

# Expected output shows your AWS account details
# {
#   "UserId": "AIDACKCEVSQ6C2EXAMPLE",
#   "Account": "123456789012",
#   "Arn": "arn:aws:iam::123456789012:user/your-username"
# }
```

### **Set Default Region**
```bash
# Ensure consistent region usage
export AWS_DEFAULT_REGION=us-east-1
echo 'export AWS_DEFAULT_REGION=us-east-1' >> ~/.bashrc
```

---

## **☸️ Step 3: Create EKS Cluster (20 minutes)**

### **Option A: Automated Cluster Creation (Recommended)**
```bash
# Create the EKS cluster (takes 15-20 minutes)
./scripts/create-eks-cluster.sh

# Script location: scripts/create-eks-cluster.sh
# Monitor progress - you'll see:
# - EKS cluster creation
# - Node group creation
# - kubectl configuration
```

### **Option B: Manual EKS Cluster Creation**
```bash
# Set cluster configuration variables
CLUSTER_NAME="healthcare-cluster"
REGION="us-east-1"
CLUSTER_VERSION="1.32"
NODE_GROUP_NAME="healthcare-nodes"
NODE_TYPE="t3.medium"
DESIRED_NODES=2
MIN_NODES=1
MAX_NODES=4

# Verify prerequisites
aws sts get-caller-identity  # Check AWS credentials
eksctl version              # Check eksctl installation
kubectl version --client    # Check kubectl installation

# Create EKS cluster with managed node group
eksctl create cluster \
  --name $CLUSTER_NAME \
  --version $CLUSTER_VERSION \
  --region $REGION \
  --nodegroup-name $NODE_GROUP_NAME \
  --node-type $NODE_TYPE \
  --nodes $DESIRED_NODES \
  --nodes-min $MIN_NODES \
  --nodes-max $MAX_NODES \
  --managed \
  --with-oidc \
  --full-ecr-access \
  --asg-access \
  --external-dns-access \
  --alb-ingress-access

# This command will:
# - Create EKS cluster (10-12 minutes)
# - Create managed node group (5-8 minutes)
# - Configure kubectl context automatically
# - Set up OIDC provider for service accounts
# - Configure IAM roles and policies
```

### **Update Kubeconfig (Important)**
```bash
# Update kubeconfig to connect to your EKS cluster
# Replace 'healthcare-cluster' with your actual cluster name if different
aws eks update-kubeconfig --region us-east-1 --name healthcare-cluster

# Verify connection to cluster
kubectl cluster-info

# Expected output:
# Kubernetes control plane is running at https://xxx.eks.us-east-1.amazonaws.com
# CoreDNS is running at https://xxx.eks.us-east-1.amazonaws.com/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
```

### **Verify Cluster Creation**
```bash
# Check cluster status
kubectl get nodes

# Expected output: 2 worker nodes in "Ready" state
# NAME                             STATUS   ROLES    AGE   VERSION
# ip-192-168-x-x.ec2.internal     Ready    <none>   2m    v1.32.x
# ip-192-168-x-x.ec2.internal     Ready    <none>   2m    v1.32.x

# Check all system pods are running
kubectl get pods -n kube-system

# Verify cluster details
kubectl get svc
```

---

## **🐳 Step 4: Build and Push Docker Images (10 minutes)**

### **Option A: Automated Build Script (Recommended)**
```bash
# Build and push both images automatically
./scripts/build-and-push-images.sh

# The script will:
# 1. Check Docker Hub authentication (prompts login if needed)
# 2. Build backend image with all NPM dependencies
# 3. Build frontend image with React compilation
# 4. Push both images to Docker Hub
# 5. Tag with both v1.0 and latest
```

### **Option B: Manual Docker Commands**

#### **Docker Hub Login (Required)**
```bash
# Login to Docker Hub (required for pushing)
docker login

# Enter your Docker Hub username and password
# Create account at https://hub.docker.com if needed
```

#### **Build Backend Image**
```bash
# Navigate to source code directory
cd src-code

# Build backend Docker image
docker build -f Dockerfile.backend \
  -t routeclouds/healthcare-backend:v1.0 \
  -t routeclouds/healthcare-backend:latest .

# Push backend image to Docker Hub
docker push routeclouds/healthcare-backend:v1.0
docker push routeclouds/healthcare-backend:latest
```

#### **Build Frontend Image**
```bash
# Build frontend Docker image (from same src-code directory)
docker build -f Dockerfile.frontend \
  -t routeclouds/healthcare-frontend:v1.0 \
  -t routeclouds/healthcare-frontend:latest .

# Push frontend image to Docker Hub
docker push routeclouds/healthcare-frontend:v1.0
docker push routeclouds/healthcare-frontend:latest
```

#### **Verify Images**
```bash
# Check local images
docker images | grep healthcare

# Expected output:
# routeclouds/healthcare-backend   v1.0     <image-id>   <time>   <size>
# routeclouds/healthcare-backend   latest   <image-id>   <time>   <size>
# routeclouds/healthcare-frontend  v1.0     <image-id>   <time>   <size>
# routeclouds/healthcare-frontend  latest   <image-id>   <time>   <size>

# Return to Stage-1 root directory
cd ..
```

### **Build Time Expectations**
- **First build**: 5-8 minutes (downloads base images + installs NPM packages)
- **Subsequent builds**: 2-3 minutes (uses Docker layer caching)
- **Backend**: Installs Node.js dependencies and sets up API server
- **Frontend**: Installs React dependencies, compiles with Vite, optimizes for production

### **Troubleshooting Docker Build**
```bash
# If build fails with NPM errors:
./scripts/clean-dependencies.sh  # Clean conflicting dependencies
./scripts/build-and-push-images.sh  # Try build again

# If Docker daemon not running:
sudo systemctl start docker
sudo systemctl enable docker

# If permission denied:
sudo usermod -aG docker $USER
# Log out and log back in

# If push fails:
docker login  # Ensure you're logged into Docker Hub
```

---

## **🚀 Step 5: Deploy to AWS EKS (20 minutes)**

### **Option A: Automated Application Deployment (Recommended)**
```bash
# Deploy the healthcare application
./scripts/deploy-to-eks.sh

# Script location: scripts/deploy-to-eks.sh
# This will:
# - Create healthcare namespace
# - Deploy database, backend, and frontend
# - Create load balancer
# - Configure services
```

### **Option B: Manual Application Deployment**
```bash
# Navigate to Kubernetes manifests directory
cd k8s

# 1. Create healthcare namespace
kubectl apply -f namespace.yaml

# 2. Deploy PostgreSQL database
kubectl apply -f database-deployment.yaml

# Wait for database to be ready
kubectl wait --for=condition=available --timeout=300s deployment/postgres-db -n healthcare

# 3. Deploy backend API
kubectl apply -f backend-deployment.yaml

# Wait for backend to be ready
kubectl wait --for=condition=available --timeout=300s deployment/healthcare-backend -n healthcare

# 4. Deploy frontend application
kubectl apply -f frontend-deployment.yaml

# Wait for frontend to be ready
kubectl wait --for=condition=available --timeout=300s deployment/healthcare-frontend -n healthcare

# 5. Check all deployments
kubectl get deployments -n healthcare

# 6. Check all services
kubectl get services -n healthcare

# 7. Get LoadBalancer URL (may take 3-5 minutes)
kubectl get service frontend-service -n healthcare

# Return to project root
cd ..
```

### **Monitor Deployment Progress**
```bash
# Watch pods starting up
kubectl get pods -n healthcare -w

# Check deployment status
kubectl get deployments -n healthcare

# View service details
kubectl get services -n healthcare

# Check events for any issues
kubectl get events -n healthcare --sort-by='.lastTimestamp'
```

---

## **✅ Step 6: Verify Deployment Success (10 minutes)**

### **Check Application Status**
```bash
# Verify all pods are running
kubectl get pods -n healthcare

# Expected output: All pods should show "Running" status
# NAME                                   READY   STATUS    RESTARTS   AGE
# healthcare-backend-xxx-xxx             1/1     Running   0          2m
# healthcare-frontend-xxx-xxx            1/1     Running   0          2m
# postgres-db-xxx-xxx                    1/1     Running   0          3m

# Check services and get LoadBalancer URL
kubectl get services -n healthcare

# Look for EXTERNAL-IP for frontend-service (may take 3-5 minutes)
```

### **Access the Application**
```bash
# Get the LoadBalancer URL
FRONTEND_URL=$(kubectl get service frontend-service -n healthcare -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
echo "Application URL: http://$FRONTEND_URL"

# Test the application
curl -I http://$FRONTEND_URL
# Should return HTTP 200 OK
```

### **Test Application Features**
1. **Open the application** in your browser using the LoadBalancer URL
2. **Test user registration** - Create a new user account
3. **Test user login** - Login with created credentials
4. **Test "Find a Doctor"** - Search for doctors by department
5. **Test navigation** - Browse different sections of the application

### **Verify Backend API**
```bash
# Test backend health endpoint
kubectl port-forward service/backend-service 3002:3002 -n healthcare &
curl http://localhost:3002/health
# Should return: {"status":"healthy","timestamp":"..."}

# Stop port forwarding
pkill -f "kubectl port-forward"
```

---

## **💰 Cost Management & Cleanup**

### **⚠️ IMPORTANT: Always Cleanup When Done**
**EKS clusters incur charges even when idle. Always cleanup after testing!**

### **Option A: Automated Cleanup (Recommended)**
```bash
# Complete cleanup of all resources
./scripts/cleanup.sh

# Script location: scripts/cleanup.sh
# This will:
# - Delete healthcare namespace and all pods
# - Delete EKS cluster and node groups
# - Clean up local Docker images (optional)
# - Remove AWS resources

# Verify cleanup completed
aws eks describe-cluster --name healthcare-cluster --region us-east-1
# Should return: cluster not found
```

### **Option B: Manual Cleanup Commands**
```bash
# 1. Delete application resources first
kubectl delete namespace healthcare --timeout=300s

# 2. Delete EKS cluster (takes 10-15 minutes)
eksctl delete cluster --name healthcare-cluster --region us-east-1 --wait

# 3. Clean up local Docker images (optional)
docker images | grep healthcare | awk '{print $3}' | xargs -r docker rmi -f

# 4. Verify all resources are deleted
aws eks list-clusters --region us-east-1
aws ec2 describe-instances --region us-east-1 --filters "Name=tag:eksctl.cluster.k8s.io/v1alpha1/cluster-name,Values=healthcare-cluster"

# 5. Check for any remaining LoadBalancers
aws elbv2 describe-load-balancers --region us-east-1 | grep healthcare

# 6. Verify no charges are accumulating
aws ce get-cost-and-usage --time-period Start=2025-08-06,End=2025-08-07 --granularity DAILY --metrics BlendedCost
```

### **Emergency Cleanup (If Standard Cleanup Fails)**
```bash
# Use enhanced cleanup scripts for stuck resources
./scripts/diagnose-aws-resources.sh           # Identify stuck resources
./scripts/cleanup-cloudformation.sh           # Clean CloudFormation stacks
./scripts/force-delete-failed-stack.sh        # Handle DELETE_FAILED stacks
./scripts/manual-cleanup-stuck-resources.sh   # Manual resource cleanup
./scripts/verify-complete-cleanup.sh          # Verify everything is gone

# Script locations: All in scripts/ directory
```

### **Cost Monitoring**
```bash
# Check current AWS costs
aws ce get-cost-and-usage \
  --time-period Start=2025-08-06,End=2025-08-07 \
  --granularity DAILY \
  --metrics BlendedCost

# Set up billing alerts (recommended)
aws budgets create-budget \
  --account-id $(aws sts get-caller-identity --query Account --output text) \
  --budget file://budget-config.json
```

---

## **📜 Complete Script Reference**

### **🛠️ Setup & Installation Scripts**
| Script | Location | Purpose | Manual Alternative |
|--------|----------|---------|-------------------|
| `setup-tools.sh` | `scripts/setup-tools.sh` | Install AWS CLI, kubectl, eksctl, Docker | See Step 1 manual commands |

### **🚀 Deployment Scripts**
| Script | Location | Purpose | Manual Alternative |
|--------|----------|---------|-------------------|
| `create-eks-cluster.sh` | `scripts/create-eks-cluster.sh` | Create EKS cluster with node groups | See Step 3 manual eksctl commands |
| `build-and-push-images.sh` | `scripts/build-and-push-images.sh` | Build and push Docker images | See Step 4 manual Docker commands |
| `deploy-to-eks.sh` | `scripts/deploy-to-eks.sh` | Deploy application to Kubernetes | See Step 5 manual kubectl commands |

### **🔍 Verification Scripts**
| Script | Location | Purpose | Manual Alternative |
|--------|----------|---------|-------------------|
| `verify-deployment.sh` | `scripts/verify-deployment.sh` | Check deployment status | `kubectl get pods -n healthcare` |
| `init-database.sh` | `scripts/init-database.sh` | Initialize database with seed data | Manual SQL execution |

### **🧹 Cleanup Scripts**
| Script | Location | Purpose | Manual Alternative |
|--------|----------|---------|-------------------|
| `cleanup.sh` | `scripts/cleanup.sh` | Complete resource cleanup | See Cost Management manual commands |
| `cleanup-cloudformation.sh` | `scripts/cleanup-cloudformation.sh` | Clean CloudFormation stacks | `aws cloudformation delete-stack` |
| `diagnose-aws-resources.sh` | `scripts/diagnose-aws-resources.sh` | Identify stuck resources | Manual AWS CLI resource queries |

### **🔧 Troubleshooting Scripts**
| Script | Location | Purpose | Manual Alternative |
|--------|----------|---------|-------------------|
| `fix-deployment.sh` | `scripts/fix-deployment.sh` | Fix common deployment issues | Manual kubectl troubleshooting |
| `force-delete-failed-stack.sh` | `scripts/force-delete-failed-stack.sh` | Handle DELETE_FAILED stacks | Manual CloudFormation operations |
| `manual-cleanup-stuck-resources.sh` | `scripts/manual-cleanup-stuck-resources.sh` | Clean stuck AWS resources | Manual AWS resource deletion |
| `verify-complete-cleanup.sh` | `scripts/verify-complete-cleanup.sh` | Verify all resources deleted | Manual AWS resource verification |

### **🛠️ Utility Scripts**
| Script | Location | Purpose | Manual Alternative |
|--------|----------|---------|-------------------|
| `clean-dependencies.sh` | `scripts/clean-dependencies.sh` | Clean NPM dependencies | Manual `rm -rf node_modules && npm install` |

### **📖 Script Usage Patterns**

#### **Prefer Scripts When:**
- ✅ **Learning the system** - Scripts show best practices
- ✅ **Quick deployment** - Automated error handling
- ✅ **Consistent results** - Tested configurations
- ✅ **Troubleshooting** - Built-in diagnostics

#### **Use Manual Commands When:**
- ✅ **Understanding internals** - See exactly what happens
- ✅ **Custom configurations** - Modify parameters
- ✅ **Debugging issues** - Step-by-step control
- ✅ **Learning Kubernetes/AWS** - Educational value

---

## **🔍 Basic Troubleshooting**

### **Option A: Automated Troubleshooting Scripts**
```bash
# Comprehensive deployment diagnosis
./scripts/verify-deployment.sh

# Fix common deployment issues automatically
./scripts/fix-deployment.sh

# Script locations: scripts/verify-deployment.sh, scripts/fix-deployment.sh
```

### **Option B: Manual Troubleshooting Commands**

#### **Issue: Pods Not Starting**
```bash
# Check pod details
kubectl describe pods -n healthcare

# Check logs for specific pod
kubectl logs <pod-name> -n healthcare

# Check all pod statuses
kubectl get pods -n healthcare -o wide

# Check events for issues
kubectl get events -n healthcare --sort-by='.lastTimestamp'

# Common fix: Wait 2-3 minutes for image pulls
kubectl get pods -n healthcare -w  # Watch pod status changes
```

#### **Issue: Frontend Shows Empty Pages**
```bash
# Check frontend logs
kubectl logs -l app=healthcare-frontend -n healthcare

# Check frontend service
kubectl describe service frontend-service -n healthcare

# Restart frontend pods
kubectl delete pods -l app=healthcare-frontend -n healthcare

# Check if frontend can reach backend
kubectl exec -it <frontend-pod> -n healthcare -- curl http://backend-service:3002/health
```

#### **Issue: API Calls Failing**
```bash
# Check backend logs
kubectl logs -l app=healthcare-backend -n healthcare

# Check backend service
kubectl describe service backend-service -n healthcare

# Verify database connection
kubectl exec -it <postgres-pod> -n healthcare -- psql -U healthcare_user -d healthcare_db -c "\dt"

# Test backend health endpoint
kubectl port-forward service/backend-service 3002:3002 -n healthcare &
curl http://localhost:3002/health
```

#### **Issue: LoadBalancer Pending**
```bash
# Check service status
kubectl describe service frontend-service -n healthcare

# Check AWS LoadBalancer creation
aws elbv2 describe-load-balancers --region us-east-1 | grep healthcare

# Wait 3-5 minutes for AWS to provision LoadBalancer
kubectl get service frontend-service -n healthcare -w
```

#### **Issue: Database Connection Problems**
```bash
# Check database pod status
kubectl get pods -l app=postgres-db -n healthcare

# Check database logs
kubectl logs -l app=postgres-db -n healthcare

# Test database connectivity from backend
kubectl exec -it <backend-pod> -n healthcare -- nc -zv postgres-service 5432

# Reset database if needed
kubectl delete pod -l app=postgres-db -n healthcare
```

#### **Issue: Docker Build Failures**
```bash
# Clean dependencies and retry
./scripts/clean-dependencies.sh
./scripts/build-and-push-images.sh

# Manual dependency cleanup
rm -rf src-code/node_modules src-code/backend/node_modules src-code/frontend/node_modules
cd src-code && npm install && cd backend && npm install && cd ../frontend && npm install && cd ../..

# Check Docker daemon
sudo systemctl status docker
sudo systemctl start docker
```

### **🆘 Need More Help?**
For comprehensive troubleshooting, see: [STAGE-1-OPERATIONS-TROUBLESHOOTING.md](./STAGE-1-OPERATIONS-TROUBLESHOOTING.md)

---

## **🎉 Success Indicators**

### **✅ Deployment Success Checklist**
- [ ] **All tools installed** - AWS CLI, kubectl, eksctl, Docker
- [ ] **AWS credentials configured** - `aws sts get-caller-identity` works
- [ ] **EKS cluster created** - 2 nodes in "Ready" state
- [ ] **Docker images built and pushed** - Images visible in Docker Hub
- [ ] **Application deployed** - All pods running in healthcare namespace
- [ ] **LoadBalancer accessible** - Frontend URL returns HTTP 200
- [ ] **Application functional** - Can register users and find doctors

### **🎯 Key Success Metrics**
- **Cluster Status**: `kubectl get nodes` shows 2 Ready nodes
- **Pod Status**: `kubectl get pods -n healthcare` shows all Running
- **Service Status**: `kubectl get svc -n healthcare` shows EXTERNAL-IP
- **Application Access**: Frontend URL loads healthcare application
- **API Functionality**: User registration and doctor search work

### **📊 Performance Indicators**
- **Deployment Time**: 55-70 minutes total
- **Cluster Creation**: 15-20 minutes
- **Image Build**: 5-8 minutes (first time)
- **Application Deployment**: 3-5 minutes
- **LoadBalancer Ready**: 3-5 minutes

### **💰 Cost Verification**
- **Hourly Cost**: ~$0.30-0.50 while running
- **Cleanup Verification**: No EKS clusters listed after cleanup
- **Billing Check**: AWS costs stop accumulating after cleanup

---

## **🔗 Related Documentation**

- **🛠️ Operations & Troubleshooting**: [STAGE-1-OPERATIONS-TROUBLESHOOTING.md](./STAGE-1-OPERATIONS-TROUBLESHOOTING.md)
- **📚 Historical Issues**: [STAGE-1-ISSUE-KNOWLEDGE-BASE.md](./STAGE-1-ISSUE-KNOWLEDGE-BASE.md)
- **🔧 Validation & Maintenance**: [STAGE-1-VALIDATION-MAINTENANCE.md](./STAGE-1-VALIDATION-MAINTENANCE.md)
- **📜 Script Usage**: [How-Use-Scripts.md](../scripts/How-Use-Scripts.md)
- **⚡ Quick Reference**: [QUICK-REFERENCE.md](../scripts/QUICK-REFERENCE.md)

---

## **📋 Document Information**

**Guide Version**: 2.0
**Last Updated**: August 6, 2025
**Estimated Time**: 55-70 minutes (includes Docker build step)
**Success Rate**: 95%+ when prerequisites are met
**New Features**: Complete manual command alternatives for all scripts

**🎉 Congratulations! You've successfully deployed the Healthcare Management System on AWS EKS!**
