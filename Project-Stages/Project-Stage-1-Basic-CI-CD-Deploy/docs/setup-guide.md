# 📋 Stage 1 Setup Guide
## Complete Implementation Instructions

### 🎯 Overview
This guide provides step-by-step instructions for implementing Stage 1 of the CI/CD pipeline for the Health Care Management System.

---

## 🛠️ Prerequisites Setup

### **1. Install Required Tools (30 minutes)**

#### **Install Docker**
```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Verify installation
docker --version
docker run hello-world
```

#### **Install kubectl**
```bash
# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Verify installation
kubectl version --client
```

#### **Install AWS CLI**
```bash
# Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Verify installation
aws --version
```

#### **Install eksctl**
```bash
# Install eksctl
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin

# Verify installation
eksctl version
```

### **2. Configure AWS Credentials**
```bash
# Configure AWS CLI
aws configure

# Enter the following when prompted:
# AWS Access Key ID: [Your Access Key]
# AWS Secret Access Key: [Your Secret Key]
# Default region name: us-east-1
# Default output format: json

# Verify configuration
aws sts get-caller-identity
```

---

## 📁 GitHub Repository Setup (15 minutes)

### **1. Create GitHub Repository**
1. Go to https://github.com
2. Click "New repository"
3. Repository name: `health-care-management-system`
4. Set to Public (for Docker Hub integration)
5. Initialize with README
6. Add .gitignore (Node.js template)

### **2. Clone and Upload Code**
```bash
# Clone the repository
git clone https://github.com/YOUR-USERNAME/health-care-management-system.git
cd health-care-management-system/src-code

# Copy existing project code (adjust path as needed)
cp -r /home/ubuntu/Projects/Health_Care_Management_System/src-code/frontend .
cp -r /home/ubuntu/Projects/Health_Care_Management_System/src-code/backend .
cp /home/ubuntu/Projects/Health_Care_Management_System/src-code/docker-compose.yml .
cp /home/ubuntu/Projects/Health_Care_Management_System/Dockerfile.* .

# Add and commit
git add .
git commit -m "Initial upload: Health Care Management System"
git push origin main
```

---

## 🐳 Docker Hub Setup (20 minutes)

### **1. Create Docker Hub Account**
1. Go to https://hub.docker.com
2. Create account: `your-dockerhub-username`
3. Verify email address

### **2. Create Repositories**
1. Create repository: `your-username/healthcare-frontend`
2. Create repository: `your-username/healthcare-backend`
3. Set both to Public

### **3. Build and Push Images**
```bash
# Navigate to your project directory
cd /path/to/health-care-management-system/src-code

# Build frontend image
docker build -f Dockerfile.frontend -t your-username/healthcare-frontend:v1.0 .

# Build backend image
docker build -f Dockerfile.backend -t your-username/healthcare-backend:v1.0 .

# Login to Docker Hub
docker login
# Enter your Docker Hub username and password

# Push images
docker push your-username/healthcare-frontend:v1.0
docker push your-username/healthcare-backend:v1.0

# Verify images are uploaded
echo "Check your Docker Hub repositories to confirm images are uploaded"
```

---

## ☁️ AWS EKS Cluster Setup (45 minutes)

### **1. Create EKS Cluster**
```bash
# Create EKS cluster (this takes 15-20 minutes)
eksctl create cluster \
  --name healthcare-cluster \
  --region us-east-1 \
  --nodegroup-name healthcare-nodes \
  --node-type t3.medium \
  --nodes 2 \
  --nodes-min 1 \
  --nodes-max 4 \
  --managed

# Configure kubectl to use the new cluster
aws eks update-kubeconfig --region us-east-1 --name healthcare-cluster

# Verify cluster is ready
kubectl get nodes
kubectl cluster-info
```

### **2. Verify Cluster Setup**
```bash
# Check cluster status
eksctl get cluster --region us-east-1

# Check node status
kubectl get nodes -o wide

# Check system pods
kubectl get pods -n kube-system
```

---

## 🚀 Application Deployment (30 minutes)

### **1. Prepare Kubernetes Manifests**
Navigate to the Stage 1 directory and use the provided Kubernetes manifests:
```bash
cd Project-Stages/Project-Stage-1-Basic-CI-CD-Deploy
ls k8s/
```

### **2. Update Image Names**
Edit the deployment files to use your Docker Hub images:
```bash
# Edit backend deployment
# Change image: your-username/healthcare-backend:v1.0

# Edit frontend deployment  
# Change image: your-username/healthcare-frontend:v1.0
```

### **3. Deploy to EKS**
```bash
# Apply Kubernetes manifests in order
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/database-deployment.yaml
kubectl apply -f k8s/backend-deployment.yaml
kubectl apply -f k8s/frontend-deployment.yaml
kubectl apply -f k8s/services.yaml

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

## 🔧 Troubleshooting

### **Common Issues**

#### **Pods Not Starting**
```bash
# Check pod status
kubectl describe pod <pod-name> -n healthcare

# Check logs
kubectl logs <pod-name> -n healthcare

# Common fixes:
# - Verify image names are correct
# - Check if images are public on Docker Hub
# - Verify resource limits
```

#### **External IP Pending**
```bash
# Check load balancer status
kubectl describe service frontend-service -n healthcare

# Wait 5-10 minutes for AWS Load Balancer provisioning
# If still pending after 15 minutes, check AWS console
```

#### **Database Connection Issues**
```bash
# Check database pod
kubectl logs deployment/postgres-db -n healthcare

# Verify service endpoints
kubectl get endpoints postgres-service -n healthcare

# Check environment variables
kubectl describe deployment healthcare-backend -n healthcare
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
