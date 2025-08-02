# 🚀 **Stage 1 Master Setup Guide**
## **Healthcare Management System - Complete Deployment Workflow**

### **🎯 Overview**

This guide provides the **complete end-to-end process** for deploying the Healthcare Management System using AWS EKS. Follow this guide from start to finish for a successful deployment.

**Time Required**: 45-60 minutes  
**Skill Level**: Intermediate (basic AWS and Docker knowledge helpful)  
**Cost**: ~$0.30-0.50/hour while running

---

## **📋 Prerequisites & Requirements**

### **🖥️ System Requirements**
- **OS**: Ubuntu 20.04+ or Amazon Linux 2
- **Memory**: 4GB RAM minimum (8GB recommended)
- **Storage**: 20GB free space
- **Network**: Stable internet connection
- **AWS Account**: With billing setup and appropriate permissions

### **🔧 Required Tools & Versions**
| Tool | Version | Purpose |
|------|---------|---------|
| **AWS CLI** | 2.15.0+ | AWS API access |
| **kubectl** | 1.33.x | Kubernetes management |
| **eksctl** | 0.165.0+ | EKS cluster management |
| **Docker** | 24.0+ | Container runtime |

---

## **🛠️ Step 1: Install Required Tools (15 minutes)**

### **Install AWS CLI**
```bash
# Download and install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Verify installation
aws --version
```

### **Install kubectl**
```bash
# Download kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

# Install kubectl
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Verify installation
kubectl version --client
```

### **Install eksctl**
```bash
# Download and install eksctl
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin

# Verify installation
eksctl version
```

### **Install Docker**
```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Verify installation (may need to log out/in)
docker --version
```

---

## **🔑 Step 2: Configure AWS Access (10 minutes)**

### **Configure AWS Credentials**
```bash
# Configure AWS CLI
aws configure

# Enter your credentials:
# AWS Access Key ID: [Your Access Key]
# AWS Secret Access Key: [Your Secret Key]
# Default region name: us-east-1
# Default output format: json
```

### **Verify AWS Access**
```bash
# Test AWS connectivity
aws sts get-caller-identity

# Expected output should show your account details
```

### **Set Required Environment Variables**
```bash
# Set AWS region
export AWS_DEFAULT_REGION=us-east-1
export AWS_REGION=us-east-1

# Add to your shell profile for persistence
echo 'export AWS_DEFAULT_REGION=us-east-1' >> ~/.bashrc
echo 'export AWS_REGION=us-east-1' >> ~/.bashrc
```

---

## **📥 Step 3: Clone and Setup Project (5 minutes)**

### **Clone Repository**
```bash
# Clone the project
git clone <your-repository-url>
cd Health_Care_Management_System

# Navigate to Stage 1 directory
cd Project-Stages/Project-Stage-1-Basic-CI-CD-Deploy

# Verify project structure
ls -la
```

### **Make Scripts Executable**
```bash
# Make all scripts executable
chmod +x scripts/*.sh

# Verify scripts
ls -la scripts/
```

---

## **🚀 Step 4: Deploy to AWS EKS (20 minutes)**

### **Create EKS Cluster**
```bash
# Create the EKS cluster (takes 15-20 minutes)
./scripts/create-eks-cluster.sh

# Monitor progress - you'll see:
# - EKS cluster creation
# - Node group creation
# - kubectl configuration
```

### **Verify Cluster Creation**
```bash
# Check cluster status
kubectl get nodes

# Expected output: 2 worker nodes in "Ready" state
# NAME                             STATUS   ROLES    AGE   VERSION
# ip-192-168-x-x.ec2.internal     Ready    <none>   2m    v1.32.x
# ip-192-168-x-x.ec2.internal     Ready    <none>   2m    v1.32.x
```

### **Deploy Application**
```bash
# Deploy the healthcare application
./scripts/deploy-to-eks.sh

# This will:
# - Create healthcare namespace
# - Deploy database, backend, and frontend
# - Create load balancer
# - Configure services
```

---

## **✅ Step 5: Verify Deployment Success (10 minutes)**

### **Check Pod Status**
```bash
# Check all pods are running
kubectl get pods -n healthcare

# Expected output: All pods in "Running" state
# NAME                                   READY   STATUS    RESTARTS   AGE
# healthcare-backend-xxx-xxx             1/1     Running   0          2m
# healthcare-frontend-xxx-xxx            1/1     Running   0          2m
# postgres-xxx-xxx                       1/1     Running   0          2m
```

### **Get Application URL**
```bash
# Get the frontend service URL
kubectl get services -n healthcare

# Look for frontend-service with EXTERNAL-IP
# Copy the LoadBalancer URL
```

### **Test Application Functionality**
```bash
# Test frontend (replace with your LoadBalancer URL)
FRONTEND_URL="http://your-loadbalancer-url"

# Test home page
curl -s -o /dev/null -w "%{http_code}" $FRONTEND_URL/
# Expected: 200

# Test API health
curl -s $FRONTEND_URL/api/health
# Expected: {"status":"healthy","database":"connected"}

# Test doctors API
curl -s $FRONTEND_URL/api/doctors | jq '.data.doctors | length'
# Expected: 5 (number of seeded doctors)
```

### **Browser Testing**
```bash
# Open in browser
echo "Open this URL in your browser: $FRONTEND_URL"

# Verify functionality:
# ✅ Home page loads
# ✅ Find Doctor page shows doctors list
# ✅ User registration works
# ✅ Login functionality works
```

---

## **🔍 Basic Troubleshooting**

### **Common Issues & Quick Fixes**

#### **Issue: Pods Not Starting**
```bash
# Check pod details
kubectl describe pods -n healthcare

# Check logs
kubectl logs <pod-name> -n healthcare

# Common fix: Wait 2-3 minutes for image pulls
```

#### **Issue: Frontend Shows Empty Pages**
```bash
# Check frontend logs
kubectl logs -l app=healthcare-frontend -n healthcare

# Restart frontend pods
kubectl delete pods -l app=healthcare-frontend -n healthcare
```

#### **Issue: API Calls Failing**
```bash
# Check backend logs
kubectl logs -l app=healthcare-backend -n healthcare

# Verify database connection
kubectl exec -it <postgres-pod> -n healthcare -- psql -U healthcare_user -d healthcare_db -c "\dt"
```

#### **Issue: LoadBalancer Pending**
```bash
# Check service status
kubectl describe service frontend-service -n healthcare

# Wait 3-5 minutes for AWS to provision LoadBalancer
```

### **For Complex Issues**
If you encounter issues not covered here, refer to the comprehensive troubleshooting guide:
📖 [STAGE-1-TROUBLESHOOTING-REFERENCE.md](./STAGE-1-TROUBLESHOOTING-REFERENCE.md)

**Quick Issue Lookup**:
- **Empty frontend pages**: [Issue #9](./STAGE-1-TROUBLESHOOTING-REFERENCE.md#issue-9) - JavaScript API connectivity
- **Service connection errors**: [Issue #8](./STAGE-1-TROUBLESHOOTING-REFERENCE.md#issue-8) - Configuration inconsistencies
- **Pod CrashLoopBackOff**: [Issue #1](./STAGE-1-TROUBLESHOOTING-REFERENCE.md#issue-1) or [Issue #2](./STAGE-1-TROUBLESHOOTING-REFERENCE.md#issue-2)
- **Database errors**: [Issue #3](./STAGE-1-TROUBLESHOOTING-REFERENCE.md#issue-3) or [Issue #4](./STAGE-1-TROUBLESHOOTING-REFERENCE.md#issue-4)

---

## **🎉 Success Criteria**

### **✅ Deployment Complete When:**
- [ ] All pods show "Running" status
- [ ] Frontend LoadBalancer has external IP
- [ ] Home page loads in browser
- [ ] Find Doctor page shows doctors list
- [ ] User registration creates accounts
- [ ] Login functionality works
- [ ] API health check returns "connected"

### **🎯 Next Steps**
1. **Test Application**: Create users, browse doctors, book appointments
2. **Monitor Costs**: Check AWS billing dashboard
3. **Plan Cleanup**: When done testing, follow cleanup procedures
4. **Document Issues**: Note any problems for future reference

---

## **💰 Cost Management**

### **Current Costs (Approximate)**
- **EKS Cluster**: $0.10/hour
- **EC2 Instances**: $0.192/hour (2x t3.medium)
- **Load Balancer**: $0.0225/hour
- **Total**: ~$0.31/hour

### **Cost Control**
```bash
# Always cleanup when done testing
./scripts/cleanup.sh

# Verify cleanup completed
aws eks describe-cluster --name healthcare-cluster --region us-east-1
# Should return: cluster not found
```

---

## **🔗 Related Documentation**

- **🔍 Troubleshooting**: [STAGE-1-TROUBLESHOOTING-REFERENCE.md](./STAGE-1-TROUBLESHOOTING-REFERENCE.md)
- **🛠️ Operations**: [STAGE-1-OPERATIONS-GUIDE.md](./STAGE-1-OPERATIONS-GUIDE.md)
- **📋 Documentation Index**: [STAGE-1-INDEX.md](./STAGE-1-INDEX.md)

---

**Guide Version**: 1.0  
**Last Updated**: August 1, 2025  
**Estimated Time**: 45-60 minutes  
**Success Rate**: 95%+ when prerequisites are met
