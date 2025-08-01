# 🚀 Stage 1: Basic CI/CD Deployment
## Health Care Management System - Foundation Level

### 📋 Overview
This is **Stage 1** of the progressive CI/CD implementation for the Health Care Management System. This stage focuses on establishing a basic containerized deployment workflow using manual processes that form the foundation for future automation.

### 🎯 Stage 1 Goals
- ✅ Deploy containerized application to AWS EKS
- ✅ Make application accessible via internet (Port 80)
- ✅ Establish basic monitoring and health checks
- ✅ Create foundation for CI/CD evolution

### 🛠️ Tools & Technologies Used
- **Version Control**: GitHub
- **Containerization**: Docker + Docker Hub
- **Cloud Platform**: AWS EKS + EC2 + Load Balancer
- **Orchestration**: Kubernetes + kubectl
- **Monitoring**: AWS CloudWatch (basic)

### 📊 Expected Results
- **Deployment Time**: ~2.5 hours (first time)
- **Monthly Cost**: ~$163
- **Uptime Target**: 95%+
- **Response Time**: <2 seconds

---

## 🚀 Quick Start

### **Prerequisites**
- AWS Account with appropriate permissions
- Docker installed locally
- GitHub account
- Docker Hub account

### **Implementation Steps**
1. **Setup Tools** (30 min): Install AWS CLI, kubectl, eksctl
2. **GitHub Setup** (15 min): Create repository and upload code
3. **Docker Images** (20 min): Build and push to Docker Hub
4. **AWS EKS** (45 min): Create managed Kubernetes cluster
5. **Deploy Application** (30 min): Deploy using Kubernetes manifests
6. **Verify & Test** (15 min): Confirm application is accessible

### **Quick Commands**
```bash
# Navigate to Stage 1 directory
cd Project-Stages/Project-Stage-1-Basic-CI-CD-Deploy

# Run setup script
./scripts/setup-tools.sh

# Create EKS cluster (EKS 1.32)
./scripts/create-eks-cluster.sh

# Deploy to EKS
./scripts/deploy-to-eks.sh

# Verify deployment
./scripts/verify-deployment.sh
```

---

## 📁 Directory Structure

```
Project-Stage-1-Basic-CI-CD-Deploy/
├── README.md                    # This file
├── docs/
│   ├── setup-guide.md          # Detailed setup instructions
│   ├── troubleshooting.md      # Common issues and solutions
│   └── architecture.md         # Stage 1 architecture overview
├── k8s/
│   ├── namespace.yaml          # Kubernetes namespace
│   ├── database-deployment.yaml # PostgreSQL deployment
│   ├── backend-deployment.yaml  # Node.js backend deployment
│   ├── frontend-deployment.yaml # React frontend deployment
│   └── services.yaml           # Kubernetes services
├── scripts/
│   ├── setup-tools.sh          # Install required tools
│   ├── build-images.sh         # Build and push Docker images
│   ├── create-eks-cluster.sh   # Create EKS cluster
│   ├── deploy-to-eks.sh        # Deploy application to EKS
│   ├── verify-deployment.sh    # Verify deployment status
│   └── cleanup.sh              # Clean up resources
├── configs/
│   ├── aws-config.env.template        # AWS configuration template
│   ├── docker-config.env.template     # Docker Hub configuration
│   ├── app-config.env.template        # Application configuration
│   └── eks-iam-policy.json            # IAM policy for EKS deployment
└── examples/
    ├── sample-commands.md       # Example commands
    └── deployment-output.md     # Expected deployment output
```

---

## 🎯 Success Criteria

### **✅ Deployment Success Indicators**
- [ ] All pods running (Frontend, Backend, Database)
- [ ] External IP assigned to frontend service
- [ ] Application accessible via browser
- [ ] User registration/login functional
- [ ] Doctor listings displayed correctly
- [ ] Appointment booking working

### **📊 Performance Targets**
- **Pod Startup Time**: < 5 minutes
- **Page Load Time**: < 2 seconds
- **API Response Time**: < 500ms
- **System Availability**: > 95%

---

## 🔗 Source Code Reference

This stage uses the main application source code from:
```
../../src-code/frontend/     # React frontend application
../../src-code/backend/      # Node.js backend API
../../src-code/docker-compose.yml  # Local development reference
```

**Note**: Stage 1 references the main source code but has its own deployment configurations and documentation.

---

## 📚 Documentation

### **Essential Reading**
1. **Setup Guide**: `docs/comprehensive-setup-guide.md` - Complete implementation steps
2. **Troubleshooting**: `docs/troubleshooting.md` - Common issues and fixes
3. **Deletion Process**: `docs/stage-1-deletion-process.md` - Complete cost-safe cleanup
4. **Sample Commands**: `examples/sample-commands.md` - Example usage

### **Quick References**
- **Sample Commands**: `examples/sample-commands.md`
- **Configuration Templates**: `configs/` directory
- **Kubernetes Manifests**: `k8s/` directory

---

## 🎯 Next Steps

### **After Stage 1 Completion**
1. ✅ Verify all functionality is working
2. ✅ Document any customizations made
3. ✅ Review performance and costs
4. ✅ Plan for Stage 2 evolution

### **Stage 2 Preview**
- Automated CI/CD with GitHub Actions
- Automated testing pipeline
- Environment-specific deployments
- Advanced monitoring setup

---

## 💡 Key Benefits of This Approach

### **✅ Why Stage 1 First**
- **Learning Foundation**: Understand basic concepts before automation
- **Risk Mitigation**: Manual process allows better understanding
- **Cost Control**: Start simple, scale complexity gradually
- **Team Alignment**: Everyone understands the baseline

### **✅ Preparation for Evolution**
- **Clean Architecture**: Ready for automation layers
- **Documented Process**: Clear steps for automation
- **Tested Foundation**: Proven deployment process
- **Scalable Structure**: Easy to enhance in future stages

---

## 🆘 Support

### **Getting Help**
- **Documentation**: Check `docs/` directory first
- **Troubleshooting**: See `docs/troubleshooting.md`
- **Examples**: Reference `examples/` directory
- **Scripts**: Use automation in `scripts/` directory

### **Common Commands**
```bash
# Check deployment status
kubectl get pods -n healthcare

# View application logs
kubectl logs -f deployment/healthcare-backend -n healthcare

# Get external access URL
kubectl get service frontend-service -n healthcare

# Clean up resources (when needed)
./scripts/cleanup.sh
```

---

## 🎉 Ready to Deploy!

This Stage 1 setup provides everything you need to deploy the Health Care Management System to AWS EKS with a solid foundation for future CI/CD evolution.

**Start with**: `docs/setup-guide.md` for detailed implementation steps.

**Goal**: Get your healthcare application running on AWS EKS and accessible via the internet! 🏥☁️

---

## 📊 Version Compatibility

### **Optimized for Your System**
- **EKS Cluster**: 1.32 (latest standard support)
- **kubectl**: 1.33.x (your current v1.33.3 is perfect!)
- **eksctl**: 0.211.0+ (your current version is perfect!)
- **AWS CLI**: 2.15.0+
- **Docker**: 24.0+
- **Node.js**: 20 LTS (in containers)
- **PostgreSQL**: 16 (in containers, matches your system v16.9)

### **Why EKS 1.32 is Perfect for You**
- ✅ **Perfect Compatibility**: Your kubectl v1.33.3 works perfectly with EKS 1.32
- ✅ **Standard Support**: No extra costs (extended support costs extra)
- ✅ **Latest Stable**: Released January 2025 - very recent and stable
- ✅ **Long Support**: Standard support until March 2026
- ✅ **Future-Proof**: Plenty of time before needing to upgrade

### **AWS Requirements**
- **IAM Permissions**: EKS, EC2, IAM, CloudFormation, ELB
- **Service Limits**: VPC, EC2 instances, Load Balancers
- **Region**: us-east-1 (configurable)
- **Billing**: Active AWS account with billing enabled
