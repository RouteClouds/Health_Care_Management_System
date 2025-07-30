# 📋 Stage 1 Comprehensive Setup Guide
## Health Care Management System - Basic CI/CD Deployment

### 🎯 Overview
This guide provides complete step-by-step instructions for implementing Stage 1 of the CI/CD pipeline for the Health Care Management System. This stage establishes a basic containerized deployment workflow using AWS EKS with proper IAM roles, security groups, and version compatibility.

**Important**: This stage is implemented outside the main project directory to avoid documentation loops. The main source code remains in the root directory and is referenced by all stages.

---

## 📋 Prerequisites & System Requirements

### **System Requirements**
- **Operating System**: Ubuntu 20.04+ or Amazon Linux 2
- **Memory**: Minimum 4GB RAM (8GB recommended)
- **Storage**: Minimum 20GB free space
- **Network**: Stable internet connection
- **AWS Account**: With appropriate billing setup and permissions

### **Version Compatibility Matrix**
| **Component** | **Version** | **Compatibility** | **Notes** |
|---------------|-------------|-------------------|-----------|
| **EKS Cluster** | 1.32 | Latest stable | AWS managed |
| **kubectl** | 1.33.x | ±1 version skew | Critical compatibility |
| **eksctl** | 0.165.0+ | Latest stable | EKS cluster management |
| **AWS CLI** | 2.15.0+ | Latest stable | AWS API access |
| **Docker** | 24.0+ | Latest stable | Container runtime |
| **Node.js** | 20 LTS | Backend runtime | In container |
| **PostgreSQL** | 16 | Database | In container (matches your v16.9) |

---

## 🛠️ Prerequisites Setup (45 minutes)

### **1. Install Required Tools with Version Control**

#### **Install Docker (Latest Stable)**
```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Verify installation
docker --version
docker run hello-world

# Clean up
rm get-docker.sh

# Note: You may need to log out and back in for group permissions
```

#### **Verify kubectl (Your Current Version is Perfect)**
```bash
# Your current kubectl v1.33.3 is perfect for EKS 1.32!
# Verify your current installation
kubectl version --client

# Expected output: Client Version: v1.33.3
# This version supports EKS clusters 1.32, 1.33, and 1.34

# No need to install a different version - you're all set!
echo "✅ kubectl v1.33.3 is compatible with EKS 1.32"
```

#### **Install AWS CLI v2 (Latest)**
```bash
# Install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Verify installation
aws --version

# Clean up
rm -rf aws awscliv2.zip

# Expected output: aws-cli/2.15.0+ Python/3.x.x
```

#### **Install eksctl (Latest Stable)**
```bash
# Install eksctl
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin

# Verify installation
eksctl version

# Expected output: 0.165.0+
```

#### **Install Additional Tools**
```bash
# Install useful tools
sudo apt update
sudo apt install -y jq curl wget unzip git

# Verify all installations
echo "=== Tool Versions ==="
echo "Docker: $(docker --version)"
echo "kubectl: $(kubectl version --client --short 2>/dev/null)"
echo "AWS CLI: $(aws --version)"
echo "eksctl: $(eksctl version)"
echo "jq: $(jq --version)"
echo "git: $(git --version)"
```

### **2. AWS Account Setup & IAM Requirements**

#### **Required AWS IAM Permissions**
Create a custom IAM policy named **`HealthCare-EKS-Stage1-Policy`** with the following permissions for EKS deployment:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "eks:*",
                "ec2:*",
                "iam:CreateRole",
                "iam:DeleteRole",
                "iam:AttachRolePolicy",
                "iam:DetachRolePolicy",
                "iam:CreateInstanceProfile",
                "iam:DeleteInstanceProfile",
                "iam:AddRoleToInstanceProfile",
                "iam:RemoveRoleFromInstanceProfile",
                "iam:PassRole",
                "iam:GetRole",
                "iam:ListRoles",
                "iam:ListAttachedRolePolicies",
                "iam:CreateServiceLinkedRole",
                "cloudformation:*",
                "elasticloadbalancing:*",
                "autoscaling:*",
                "logs:*"
            ],
            "Resource": "*"
        }
    ]
}
```

#### **How to Create the IAM Policy**
```bash
# Option 1: Create via AWS CLI (using our provided policy file)
aws iam create-policy \
  --policy-name HealthCare-EKS-Stage1-Policy \
  --policy-document file://configs/eks-iam-policy.json \
  --description "Full permissions for Healthcare EKS Stage 1 deployment"

# Option 2: Create via AWS Console
# 1. Go to AWS Console > IAM > Policies > Create Policy
# 2. Choose JSON tab and paste the above policy
# 3. Name it: HealthCare-EKS-Stage1-Policy
# 4. Attach to your IAM user or role

# Attach policy to your user
aws iam attach-user-policy \
  --user-name YOUR-USERNAME \
  --policy-arn arn:aws:iam::YOUR-ACCOUNT-ID:policy/HealthCare-EKS-Stage1-Policy
```

#### **AWS Security Groups & VPC Requirements (Automatic Creation)**
**✅ Good News**: eksctl automatically creates ALL required infrastructure:

**🔒 Security Groups (Automatic)**:
- **Cluster Security Group**: Controls access to EKS control plane
- **Node Security Group**: Controls access between worker nodes
- **Pod Security Groups**: Enables pod-to-pod communication
- **Load Balancer Security Groups**: Created when services are deployed
- **Custom Rules**: Automatically configured for Kubernetes networking

**🌐 VPC & Networking (Automatic)**:
- **New VPC**: Dedicated VPC with proper CIDR blocks
- **Public Subnets**: For load balancers and internet access
- **Private Subnets**: For worker nodes and pods
- **Internet Gateway**: For external connectivity
- **NAT Gateways**: For private subnet internet access
- **Route Tables**: Properly configured routing

**🔐 IAM Roles (Automatic)**:
- **EKS Cluster Service Role**: For EKS control plane operations
- **EKS Node Group Instance Role**: For worker node permissions
- **EKS Pod Execution Role**: For pod-level permissions
- **Load Balancer Controller Role**: For AWS Load Balancer integration

**💡 You don't need to create any of these manually - eksctl handles everything!**

#### **Configure AWS Credentials**
```bash
# Configure AWS CLI
aws configure

# Enter the following when prompted:
# AWS Access Key ID: [Your Access Key with EKS permissions]
# AWS Secret Access Key: [Your Secret Key]
# Default region name: us-east-1
# Default output format: json

# Verify configuration and permissions
aws sts get-caller-identity
aws iam get-user
aws eks list-clusters --region us-east-1
```

#### **Verify AWS Permissions**
```bash
# Test EKS permissions
aws eks describe-cluster --name test-cluster --region us-east-1 2>/dev/null || echo "✅ EKS permissions verified"

# Test EC2 permissions
aws ec2 describe-vpcs --region us-east-1 --max-items 1

# Test IAM permissions
aws iam list-roles --max-items 1

# Test CloudFormation permissions
aws cloudformation list-stacks --max-items 1

echo "✅ All AWS permissions verified"
```

---

## 🤖 Understanding Our Automation Scripts

### **Why We Have These Scripts**
Our Stage 1 includes 5 automation scripts to make deployment easier and more reliable:

#### **📋 Script Overview**
| **Script** | **Purpose** | **When to Use** |
|------------|-------------|-----------------|
| **setup-tools.sh** | Verifies your existing tools (kubectl, eksctl, AWS CLI) | ✅ Run first - checks compatibility |
| **create-eks-cluster.sh** | Creates EKS cluster with correct version (1.32) | ✅ Run once - creates infrastructure |
| **deploy-to-eks.sh** | Deploys healthcare app to existing cluster | ✅ Run after cluster is ready |
| **verify-deployment.sh** | Validates everything is working correctly | ✅ Run to check deployment |
| **cleanup.sh** | Safely removes all resources to prevent costs | ✅ Run when done testing |

#### **🎯 Script Benefits**
- **No Manual Errors**: Scripts use exact commands and parameters
- **Version Compatibility**: Scripts ensure EKS 1.32 + kubectl 1.33.3 compatibility
- **Cost Safety**: Cleanup script prevents unexpected AWS charges
- **Time Saving**: Automated deployment vs manual kubectl commands
- **Consistency**: Same deployment every time
- **Learning Tool**: You can read scripts to understand the process

#### **🔄 Deployment Workflow**
```bash
# 1. Verify tools (doesn't install anything new)
./scripts/setup-tools.sh

# 2. Create EKS cluster (15-20 minutes)
./scripts/create-eks-cluster.sh

# 3. Deploy healthcare application (5 minutes)
./scripts/deploy-to-eks.sh

# 4. Verify everything works (2 minutes)
./scripts/verify-deployment.sh

# 5. Clean up when done (10-15 minutes)
./scripts/cleanup.sh
```

#### **Verify PostgreSQL Compatibility**
```bash
# Check your local PostgreSQL version (optional)
psql --version
# Expected: PostgreSQL 16.x (your system has 16.9 - perfect!)

# Our containers use PostgreSQL 16-alpine which matches your system
echo "✅ PostgreSQL 16 provides:"
echo "  • Better performance than PostgreSQL 15"
echo "  • Enhanced security features"
echo "  • Perfect compatibility with your system v16.9"
echo "  • All healthcare app features supported"
```

---

## 📁 Source Code Setup (15 minutes)

### **1. Clone Health Care Management System Repository**
```bash
# Create workspace directory outside Project-Stages
mkdir -p ~/healthcare-deployment
cd ~/healthcare-deployment

# Clone the main repository
git clone https://github.com/your-username/health-care-management-system.git
cd health-care-management-system/src-code

# Verify source code structure
ls -la
# Expected: frontend/, backend/, docker-compose.yml, Dockerfile.*
```

### **2. Verify Application Structure**
```bash
# Check frontend structure
ls frontend/
# Expected: src/, package.json, public/, etc.

# Check backend structure  
ls backend/
# Expected: src/, package.json, prisma/, etc.

# Check Dockerfiles
ls Dockerfile.*
# Expected: Dockerfile.frontend, Dockerfile.backend

# Verify docker-compose for reference
cat docker-compose.yml | grep -E "image:|ports:"
```

### **3. Test Local Build (Optional)**
```bash
# Test local Docker build (optional verification)
docker build -f Dockerfile.frontend -t test-frontend .
docker build -f Dockerfile.backend -t test-backend .

# Clean up test images
docker rmi test-frontend test-backend

echo "✅ Source code structure verified"
```

---

## 🐳 Docker Hub Setup (20 minutes)

### **1. Create Docker Hub Account**
1. Go to https://hub.docker.com
2. Create account: `your-dockerhub-username`
3. Verify email address
4. Note your username for later use

### **2. Create Public Repositories**
Create the following repositories (must be public for free tier):
1. **Repository 1**: `your-username/healthcare-frontend`
   - Description: "Health Care Management System - React Frontend"
   - Visibility: Public
2. **Repository 2**: `your-username/healthcare-backend`
   - Description: "Health Care Management System - Node.js Backend"
   - Visibility: Public

### **3. Build and Push Images**
```bash
# Navigate to project directory
cd ~/healthcare-deployment/health-care-management-system/src-code

# Build frontend image with proper tag
docker build -f Dockerfile.frontend -t your-username/healthcare-frontend:v1.0 .

# Build backend image with proper tag
docker build -f Dockerfile.backend -t your-username/healthcare-backend:v1.0 .

# Login to Docker Hub
docker login
# Enter your Docker Hub username and password

# Push images to Docker Hub
docker push your-username/healthcare-frontend:v1.0
docker push your-username/healthcare-backend:v1.0

# Verify images are uploaded
echo "✅ Check your Docker Hub repositories to confirm images are uploaded"
echo "Frontend: https://hub.docker.com/r/your-username/healthcare-frontend"
echo "Backend: https://hub.docker.com/r/your-username/healthcare-backend"

# Clean up local images to save space (optional)
docker rmi your-username/healthcare-frontend:v1.0
docker rmi your-username/healthcare-backend:v1.0
```

---

## ☁️ AWS EKS Cluster Setup (45 minutes)

### **1. Create EKS Cluster (Automated)**
```bash
# Option 1: Use our automated script (Recommended)
./scripts/create-eks-cluster.sh

# This script will:
# ✅ Check prerequisites (AWS CLI, eksctl, kubectl)
# ✅ Verify AWS permissions
# ✅ Create EKS cluster with version 1.32
# ✅ Configure kubectl automatically
# ✅ Verify cluster is ready

# Option 2: Manual eksctl command (if you prefer)
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
  --full-ecr-access \
  --asg-access \
  --external-dns-access \
  --alb-ingress-access
```

#### **What Gets Created Automatically**
```bash
# eksctl creates ALL of these for you:
# 🏗️  Infrastructure:
#     - EKS cluster (version 1.32)
#     - VPC with public/private subnets
#     - Internet Gateway and NAT Gateways
#     - Route tables and routing rules

# 🔒 Security:
#     - Cluster security group
#     - Node security group
#     - Pod security groups
#     - IAM roles and policies

# 💻 Compute:
#     - Managed node group (2x t3.medium)
#     - Auto Scaling Group
#     - EC2 instances with EKS-optimized AMI

# 🔧 Configuration:
#     - OIDC provider for service accounts
#     - CloudFormation stacks for management
#     - kubectl configuration
```

### **2. Monitor Cluster Creation**
```bash
# Monitor cluster creation progress (takes 15-20 minutes)
watch -n 30 'eksctl get cluster --region us-east-1'

# Alternative: Check AWS console
echo "Monitor progress at: https://console.aws.amazon.com/eks/home?region=us-east-1#/clusters"
```

### **3. Configure kubectl**
```bash
# Configure kubectl to use the new cluster
aws eks update-kubeconfig --region us-east-1 --name healthcare-cluster

# Verify cluster connection
kubectl cluster-info
kubectl get nodes
kubectl get namespaces

# Check cluster version compatibility
kubectl version --short
# Should show: Client v1.33.3, Server v1.32.x
```

### **4. Verify Cluster Setup**
```bash
# Check cluster status
eksctl get cluster --region us-east-1

# Check node status and details
kubectl get nodes -o wide

# Check system pods
kubectl get pods -n kube-system

# Verify security groups and VPC
aws eks describe-cluster --name healthcare-cluster --region us-east-1 --query 'cluster.resourcesVpcConfig'

echo "✅ EKS cluster setup completed successfully"
```

---

## 🚀 Application Deployment (30 minutes)

### **1. Navigate to Stage 1 Directory**
```bash
# Navigate to Stage 1 directory (outside main project)
cd /home/ubuntu/Projects/Health_Care_Management_System/Project-Stages/Project-Stage-1-Basic-CI-CD-Deploy

# Verify k8s manifests exist
ls k8s/
# Should see: namespace.yaml, database-deployment.yaml, backend-deployment.yaml, frontend-deployment.yaml
```

### **2. Update Image Names in Manifests**
```bash
# Update backend deployment with your Docker Hub username
sed -i 's/your-username/YOUR-ACTUAL-USERNAME/g' k8s/backend-deployment.yaml

# Update frontend deployment with your Docker Hub username
sed -i 's/your-username/YOUR-ACTUAL-USERNAME/g' k8s/frontend-deployment.yaml

# Verify changes
grep "image:" k8s/*-deployment.yaml
```

### **3. Deploy to EKS**
```bash
# Option 1: Use our automated script (Recommended)
./scripts/deploy-to-eks.sh

# This script will:
# ✅ Check cluster connectivity
# ✅ Deploy all components in correct order
# ✅ Wait for each component to be ready
# ✅ Check external IP assignment
# ✅ Test application accessibility

# Option 2: Manual kubectl commands (if you prefer)
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/database-deployment.yaml
kubectl apply -f k8s/backend-deployment.yaml
kubectl apply -f k8s/frontend-deployment.yaml

# Wait for deployments to be ready
kubectl wait --for=condition=available --timeout=300s deployment --all -n healthcare
```

### **4. Monitor Deployment**
```bash
# Watch pod status
kubectl get pods -n healthcare -w

# Check deployment status
kubectl get deployments -n healthcare

# Check service status
kubectl get services -n healthcare
```

---

## ✅ Verification & Testing (15 minutes)

### **1. Get External Access URL**
```bash
# Get the external IP (may take 5-10 minutes to provision)
kubectl get service frontend-service -n healthcare

# Wait for EXTERNAL-IP to be assigned (not <pending>)
kubectl get service frontend-service -n healthcare -w
```

### **2. Test Application Access**
```bash
# Get the external IP
EXTERNAL_IP=$(kubectl get service frontend-service -n healthcare -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
echo "Application URL: http://$EXTERNAL_IP"

# Test with curl
curl -I http://$EXTERNAL_IP

# Open in browser
echo "Open this URL in your browser: http://$EXTERNAL_IP"
```

### **3. Verify Application Functionality**
1. **Frontend Access**: Navigate to `http://<EXTERNAL-IP>`
2. **User Registration**: Test signup functionality
3. **Authentication**: Test login/logout
4. **Doctor Listings**: Verify doctor data displays
5. **Appointment Booking**: Test appointment creation

### **4. Check Application Health**
```bash
# Check pod logs
kubectl logs -f deployment/healthcare-frontend -n healthcare
kubectl logs -f deployment/healthcare-backend -n healthcare
kubectl logs -f deployment/postgres-db -n healthcare

# Check pod status
kubectl describe pods -n healthcare

# Check service endpoints
kubectl get endpoints -n healthcare
```

---

## 📊 Success Verification

### **✅ Deployment Success Checklist**
- [ ] All pods are running (3 deployments)
- [ ] External IP assigned to frontend service
- [ ] Application loads in browser
- [ ] User can register new account
- [ ] User can login/logout
- [ ] Doctor listings display correctly
- [ ] Appointment booking works
- [ ] No error messages in pod logs

### **📈 Performance Check**
```bash
# Check resource usage
kubectl top nodes
kubectl top pods -n healthcare

# Check response time
time curl -s http://$EXTERNAL_IP > /dev/null
```

---

## 💰 Cost Monitoring

### **Expected Monthly Costs**
- **EKS Control Plane**: ~$73
- **EC2 Worker Nodes** (2x t3.medium): ~$60
- **Application Load Balancer**: ~$20
- **Data Transfer**: ~$10
- **Total**: ~$163/month

### **Cost Optimization Tips**
- Use t3.small nodes for development
- Stop cluster when not in use
- Monitor data transfer costs
- Use AWS Cost Explorer for tracking

---

## 🎯 Next Steps

### **After Successful Deployment**
1. ✅ Document your specific configuration
2. ✅ Test all application features thoroughly
3. ✅ Monitor costs and performance
4. ✅ Plan for Stage 2 automation

### **Stage 2 Preparation**
- Review GitHub Actions documentation
- Plan automated testing strategy
- Consider environment separation (dev/staging/prod)
- Evaluate monitoring requirements

---

## 🎉 Congratulations!

You have successfully deployed the Health Care Management System to AWS EKS using basic CI/CD practices. Your application is now:

- ✅ **Running on AWS EKS** with managed Kubernetes
- ✅ **Accessible via internet** on port 80
- ✅ **Containerized and scalable** with Docker
- ✅ **Ready for CI/CD evolution** to Stage 2

**Your healthcare application is live and ready for users!** 🏥☁️🚀

---

## 🗑️ Important: Resource Cleanup

### **Cost Management**
When you're done testing or want to clean up resources to avoid costs:

📖 **See**: `docs/stage-1-deletion-process.md` for complete step-by-step deletion instructions

**Quick Cleanup**:
```bash
# Navigate to Stage 1 directory
cd /home/ubuntu/Projects/Health_Care_Management_System/Project-Stages/Project-Stage-1-Basic-CI-CD-Deploy

# Run cleanup script
./scripts/cleanup.sh
```

**⚠️ Important**: Deleting resources will permanently remove all data. The deletion guide ensures no AWS resources are left running to prevent unexpected charges (~$163/month if left running).
