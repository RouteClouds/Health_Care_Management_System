# 🏥 Stage 1: Basic CI/CD Deployment
## Healthcare Management System - EKS Deployment with Docker Hub

### 📋 **Overview**
Stage 1 demonstrates a basic CI/CD pipeline for the Healthcare Management System using:
- **Source Control**: GitHub Repository
- **Container Registry**: Docker Hub  
- **Orchestration**: AWS EKS (Kubernetes)
- **Deployment**: Manual kubectl with automated scripts
- **Database**: PostgreSQL with automatic initialization

---

## 🎯 **Two Deployment Options**

### **Option 1: EKS Deployment (Production-like)**
Deploy to AWS EKS cluster for production-like environment testing.

### **Option 2: Local Testing (Development)**
Run locally using Docker Compose for development and testing.

---

## 🚀 **EKS Deployment (Recommended)**

### **Prerequisites**
- ✅ **AWS CLI** configured with EKS permissions
- ✅ **kubectl** installed and configured for your EKS cluster
- ✅ **Docker** installed and logged into Docker Hub
- ✅ **EKS Cluster** running (see EKS setup section below)

### **Quick Start - EKS Deployment**
```bash
# 1. Clone the repository
git clone <your-repository-url>
cd Health_Care_Management_System/Project-Stages/Project-Stage-1-Basic-CI-CD-Deploy

# 2. Verify EKS cluster connection
kubectl get nodes

# 3. Run automated deployment
./scripts/deploy-to-eks.sh
```

### **What Happens Automatically:**
1. ✅ **Creates healthcare namespace**
2. ✅ **Deploys PostgreSQL database** with persistent storage
3. ✅ **Deploys backend API** with automatic database initialization
4. ✅ **Deploys frontend** with AWS Load Balancer
5. ✅ **Initializes database schema** and seeds sample data
6. ✅ **Verifies all services** are working correctly
7. ✅ **Provides application URL** for immediate access

### **Expected Output:**
```bash
🏥 Healthcare Management System - Stage 1 Deployment
✅ EKS cluster connection verified
✅ Healthcare namespace created
✅ Database deployed and ready
✅ Backend deployed and ready  
✅ Frontend deployed and ready
✅ Database initialized with schema and sample data
🌐 Application URL: http://your-load-balancer-url.elb.amazonaws.com
✅ Deployment completed successfully!
```

### **Access Your Application:**
```bash
# Get the external URL
kubectl get services -n healthcare

# Your application will be available at:
# http://your-load-balancer-url.elb.amazonaws.com
```

---

## 🐳 **Local Testing (Development)**

### **Prerequisites**
- ✅ **Docker** and **Docker Compose** installed
- ✅ **Git** for cloning the repository

### **Quick Start - Local Testing**
```bash
# 1. Clone the repository
git clone <your-repository-url>
cd Health_Care_Management_System/src-code

# 2. Start all services locally
docker compose up -d

# OR use the automated startup script
./start.sh
```

### **Local Access Points:**
- **Frontend**: http://localhost:5173
- **Backend API**: http://localhost:3002  
- **Database**: localhost:5432 (PostgreSQL)

### **What's Included Locally:**
- ✅ **Complete application stack** with all services
- ✅ **Automatic database initialization** and sample data
- ✅ **Hot reload** for development
- ✅ **All features working** (registration, login, booking)

---

## 📊 **Sample Data (Both Deployments)**

### **Automatically Created:**
- **4 Medical Departments**: Cardiology, Pulmonology, Neurology, Orthopedics
- **5 Doctors**: Complete profiles with specializations and consultation fees
- **Database Schema**: All tables for users, doctors, appointments, departments
- **User System**: Ready for registration and login

### **Features Ready to Test:**
- ✅ **User Registration & Login**
- ✅ **Doctor Browsing & Search**  
- ✅ **Appointment Booking System**
- ✅ **Department-based Filtering**
- ✅ **Responsive Web Interface**

---

## 🏗️ **EKS Cluster Setup (If Needed)**

If you don't have an EKS cluster yet:

```bash
# Create EKS cluster using eksctl
eksctl create cluster \
  --name healthcare-cluster \
  --region us-east-1 \
  --nodegroup-name healthcare-nodes \
  --node-type t3.medium \
  --nodes 2 \
  --nodes-min 1 \
  --nodes-max 4 \
  --managed

# Configure kubectl
aws eks update-kubeconfig --region us-east-1 --name healthcare-cluster

# Verify connection
kubectl get nodes
```

---

## 🔧 **Development Workflow**

### **For Testing Changes:**

#### **1. Make Code Changes**
```bash
# Edit source code in src-code/ directory
# Make your changes to backend, frontend, or configuration
```

#### **2. Build and Push Images (v1.0 for testing)**
```bash
cd src-code

# Build images with v1.0 tag (for testing)
docker build -f Dockerfile.backend -t routeclouds/healthcare-backend:v1.0 .
docker build -f Dockerfile.frontend -t routeclouds/healthcare-frontend:v1.0 .

# Push to Docker Hub
docker push routeclouds/healthcare-backend:v1.0
docker push routeclouds/healthcare-frontend:v1.0
```

#### **3. Deploy to EKS**
```bash
cd ../Project-Stages/Project-Stage-1-Basic-CI-CD-Deploy

# Restart deployments to pull latest v1.0 images
kubectl rollout restart deployment/healthcare-backend -n healthcare
kubectl rollout restart deployment/healthcare-frontend -n healthcare

# Monitor rollout
kubectl rollout status deployment/healthcare-backend -n healthcare
kubectl rollout status deployment/healthcare-frontend -n healthcare
```

**Note**: Using **v1.0 tag for testing** means no manifest changes needed - just rebuild and restart!

---

## 📁 **Project Structure**

```
Project-Stage-1-Basic-CI-CD-Deploy/
├── README.md                     # This file
├── k8s/                          # Kubernetes manifests
│   ├── namespace.yaml           # Healthcare namespace
│   ├── postgres-deployment.yaml # Database deployment
│   ├── backend-deployment.yaml  # Backend API deployment  
│   └── frontend-deployment.yaml # Frontend deployment
├── scripts/                      # Automation scripts
│   ├── deploy-to-eks.sh         # Main deployment script
│   ├── init-database.sh         # Database initialization
│   ├── verify-deployment.sh     # Deployment verification
│   └── cleanup.sh               # Environment cleanup
├── docs/                         # Documentation
│   ├── Stage-1-Troubleshooting-Guide.md
│   ├── comprehensive-setup-guide.md
│   └── AUTOMATED-SETUP-GUIDE.md
└── Cursor-Docs/                  # Development documentation
    ├── Cursor-Troubleshoot-Strategy.md
    └── Docker-Troubleshooting-Guide.md
```

---

## 🧪 **Testing & Verification**

### **API Endpoints:**
```bash
# Get your application URL
EXTERNAL_URL=$(kubectl get service frontend-service -n healthcare -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

# Test health endpoint
curl http://$EXTERNAL_URL/api/health

# Test doctors endpoint  
curl http://$EXTERNAL_URL/api/doctors

# Test registration
curl -X POST http://$EXTERNAL_URL/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser","email":"test@example.com","password":"password123","firstName":"Test","lastName":"User"}'
```

### **Frontend Features:**
1. **Open application URL in browser**
2. **Register a new user account**
3. **Login with credentials**
4. **Browse available doctors**
5. **Book an appointment**
6. **Test all functionality**

---

## 🔧 **Troubleshooting**

### **Quick Diagnostics:**
```bash
# Check all resources
kubectl get all -n healthcare

# Check pod logs
kubectl logs -l app=healthcare-backend -n healthcare
kubectl logs -l app=healthcare-frontend -n healthcare

# Check events
kubectl get events -n healthcare --sort-by='.lastTimestamp'

# Re-run database initialization if needed
./scripts/init-database.sh
```

### **Common Issues:**
- **Pods not ready**: Check logs and run database initialization
- **API not working**: Verify database schema and sample data
- **Frontend not loading**: Check service and ingress configuration
- **Registration failing**: Ensure database tables exist

### **Detailed Troubleshooting:**
See `docs/Stage-1-Troubleshooting-Guide.md` for comprehensive troubleshooting procedures.

---

## 🎯 **Success Indicators**

### **EKS Deployment Success:**
```bash
✅ All pods running (2/2 Ready)
✅ External LoadBalancer URL available
✅ API endpoints responding correctly
✅ Database with sample data (4 departments, 5 doctors)
✅ Frontend loading and functional
✅ User registration and login working
✅ Appointment booking system operational
```

### **Local Testing Success:**
```bash
✅ All containers running and healthy
✅ Frontend accessible at http://localhost:5173
✅ Backend API responding at http://localhost:3002
✅ Database initialized with sample data
✅ All features working locally
```

---

## 🚀 **Next Steps**

### **Stage 2 Preview:**
The next stage will add:
- **Automated CI/CD** with GitHub Actions
- **Environment-specific** configurations (dev/staging/prod)
- **Advanced monitoring** with Prometheus and Grafana
- **Automated testing** pipelines
- **Security scanning** and compliance checks

### **Production Considerations:**
- **SSL/TLS certificates** for HTTPS
- **Custom domain** configuration
- **Resource limits** and auto-scaling
- **Backup and disaster recovery**
- **Monitoring and alerting**

---

## 📞 **Support**

If you encounter issues:

1. **Check the troubleshooting guide**: `docs/Stage-1-Troubleshooting-Guide.md`
2. **Run verification script**: `./scripts/verify-deployment.sh`
3. **Check logs**: `kubectl logs -n healthcare -l app=healthcare-backend`
4. **Review documentation**: All guides in `docs/` directory

**This stage provides a solid foundation for healthcare management system deployment with automatic database initialization and comprehensive error handling.**
