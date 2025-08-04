# 🚀 **New User Getting Started Guide**
## **Stage 1: Healthcare Management System Basic CI/CD**

### **📖 Document Content Index**
- [👋 Welcome to Stage 1](#-welcome-to-stage-1)
- [🎯 What You'll Learn](#-what-youll-learn)
- [📍 Step-by-Step Roadmap](#-step-by-step-roadmap-10-steps)
- [📚 Phase 1: Understanding the Project](#-phase-1-understanding-the-project-steps-1-3)
- [🛠️ Phase 2: Tools Setup](#️-phase-2-tools-setup-steps-4-5)
- [🏗️ Phase 3: Infrastructure Deployment](#️-phase-3-infrastructure-deployment-steps-6-8)
- [✅ Phase 4: Verification & Management](#-phase-4-verification--management-steps-9-10)
- [🗂️ Quick Reference](#️-quick-reference-where-to-find-everything)
- [⚠️ Important Notes](#️-important-notes-for-new-users)
- [🎉 Success Indicators](#-success-indicators)

**Document Purpose**: Step-by-step onboarding guide for new Stage 1 users
**Target Audience**: New developers, DevOps engineers, and team members
**Estimated Read Time**: 30 minutes
**Last Updated**: August 2, 2025

---

### **👋 Welcome to Stage 1!**
**New to this project?** This guide will get you up and running quickly with our basic CI/CD pipeline using AWS EKS and Docker Hub.

**📊 Visual Roadmap**: First, check out `Stage-1-Architecture/Stage-1-Onboarding-Roadmap.png` for a complete visual guide!

---

## **🎯 What You'll Learn**
- How to deploy a healthcare application to AWS EKS
- Basic Kubernetes concepts and operations
- Docker containerization and registry usage
- AWS EKS cluster management
- Cost-effective deployment strategies
- Manual deployment workflow

---

## **📍 Step-by-Step Roadmap (10 Steps)**

### **📚 Phase 1: Understanding the Project (Steps 1-3)**

#### **🔍 Step 1: Read the Master Guide**
```bash
📁 Location: docs/STAGE-1-INDEX.md
🎯 Purpose: Complete project overview and navigation
⏱️ Time: 10 minutes
```

**What you'll learn:**
- Stage 1 vs Stage 2 differences
- Basic CI/CD workflow with AWS EKS
- Technology stack overview
- Cost breakdown (~$163/month)

#### **🏗️ Step 2: View Architecture Diagrams**
```bash
📁 Location: Stage-1-Architecture/
🎯 Purpose: Visual understanding of the system
⏱️ Time: 10 minutes
```

**Key diagrams to review:**
- `stage1_complete_workflow.png` - End-to-end deployment
- `stage1_aws_infrastructure.png` - AWS EKS architecture
- `Stage-1-Onboarding-Roadmap.png` - This getting started guide

#### **📋 Step 3: Check Prerequisites**
```bash
📁 Location: docs/STAGE-1-MASTER-GUIDE.md
🎯 Purpose: Ensure you have required tools and access
⏱️ Time: 15 minutes
```

**Required tools:**
- AWS CLI (configured with credentials)
- kubectl (Kubernetes CLI)
- eksctl (EKS cluster management)
- Docker (containerization)
- Git (version control)

---

### **🛠️ Phase 2: Tools Setup (Steps 4-5)**

#### **⚙️ Step 4: Install Required Tools**
```bash
📁 Location: scripts/setup-tools.sh
🎯 Purpose: Automated tool installation
⏱️ Time: 15 minutes
```

**Installation script:**
```bash
# Run the automated setup
./scripts/setup-tools.sh

# Or install manually:
# AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip && sudo ./aws/install

# kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# eksctl
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin
```

#### **🔑 Step 5: Configure AWS Access**
```bash
📁 Location: AWS CLI configuration
🎯 Purpose: Set up AWS credentials and region
⏱️ Time: 10 minutes
```

**Configuration steps:**
```bash
# Configure AWS credentials
aws configure

# Required inputs:
# AWS Access Key ID: [Your access key]
# AWS Secret Access Key: [Your secret key]
# Default region name: us-east-1
# Default output format: json

# Verify configuration
aws sts get-caller-identity
aws eks list-clusters
```

---

### **🏗️ Phase 3: Infrastructure Deployment (Steps 6-8)**

#### **☸️ Step 6: Create EKS Cluster**
```bash
📁 Location: scripts/create-eks-cluster.sh
🎯 Purpose: Set up AWS EKS cluster
⏱️ Time: 15-20 minutes
```

**Deployment command:**
```bash
# Create the EKS cluster
./scripts/create-eks-cluster.sh

# What this script does:
# - Creates EKS cluster named "healthcare-cluster"
# - Sets up worker nodes (t3.medium)
# - Configures kubectl context
# - Installs AWS Load Balancer Controller
```

**Expected output:**
```bash
✅ EKS cluster "healthcare-cluster" created successfully
✅ Worker nodes are ready
✅ kubectl configured for cluster access
✅ AWS Load Balancer Controller installed
```

#### **📂 Step 7: Locate Source Code**
```bash
📁 Location: ../../src-code/
🎯 Purpose: Find the healthcare application code
⏱️ Time: 5 minutes
```

**Source code structure:**
```bash
../../src-code/
├── frontend/              # React application
│   ├── src/              # React components
│   ├── package.json      # Dependencies
│   └── Dockerfile        # Container build
├── backend/              # Node.js API
│   ├── src/              # API endpoints
│   ├── package.json      # Dependencies
│   └── Dockerfile        # Container build
└── docker-compose.yml    # Local development
```

#### **🚀 Step 8: Deploy to EKS**
```bash
📁 Location: scripts/deploy-to-eks.sh
🎯 Purpose: Deploy healthcare application
⏱️ Time: 10-15 minutes
```

**Deployment command:**
```bash
# Deploy the application
./scripts/deploy-to-eks.sh

# What this script does:
# - Builds Docker images
# - Pushes to Docker Hub
# - Applies Kubernetes manifests
# - Creates services and ingress
# - Sets up database
```

---

### **✅ Phase 4: Verification & Management (Steps 9-10)**

#### **🔍 Step 9: Verify Deployment**
```bash
📁 Location: scripts/verify-deployment.sh
🎯 Purpose: Ensure everything is working
⏱️ Time: 10 minutes
```

**Verification steps:**
```bash
# Run verification script
./scripts/verify-deployment.sh

# Manual verification:
kubectl get pods -n healthcare
kubectl get services -n healthcare
kubectl get ingress -n healthcare

# Check application health
curl http://[LOAD_BALANCER_URL]/health
```

**Success indicators:**
- All pods are in "Running" status
- Services have external IPs
- Application responds to health checks
- Frontend loads in browser

#### **💰 Step 10: Cleanup (Optional)**
```bash
📁 Location: scripts/cleanup.sh
🎯 Purpose: Remove resources to save costs
⏱️ Time: 10 minutes
```

**Cleanup command:**
```bash
# Remove all resources
./scripts/cleanup.sh

# What this removes:
# - EKS cluster and worker nodes
# - Load balancers and networking
# - All Kubernetes resources
# - CloudFormation stacks
```

**⚠️ Important**: Always cleanup when not actively using to avoid AWS charges!

---

## **🗂️ Quick Reference: Where to Find Everything**

### **📚 Documentation**
```bash
docs/
├── STAGE-1-INDEX.md                    # 🏠 Main entry point
├── STAGE-1-MASTER-GUIDE.md            # 📋 Complete guide
├── STAGE-1-OPERATIONS-GUIDE.md        # 🔧 Operations manual
├── STAGE-1-TROUBLESHOOTING-REFERENCE.md # 🆘 Problem solving
└── NEW-USER-GETTING-STARTED.md        # 👋 This guide
```

### **💻 Source Code**
```bash
../../src-code/                         # 📂 Application code (shared)
├── frontend/                           # ⚛️ React app
├── backend/                            # 🟢 Node.js API
└── docker-compose.yml                 # 🐳 Local development
```

### **🤖 Scripts**
```bash
scripts/
├── setup-tools.sh                     # ⚙️ Tool installation
├── create-eks-cluster.sh              # ☸️ EKS cluster setup
├── deploy-to-eks.sh                   # 🚀 Application deployment
├── verify-deployment.sh               # ✅ Verification
└── cleanup.sh                         # 💰 Resource cleanup
```

### **🏗️ Infrastructure**
```bash
k8s/                                    # ☸️ Kubernetes manifests
├── frontend-deployment.yaml           # React deployment
├── backend-deployment.yaml            # Node.js deployment
├── database-deployment.yaml           # PostgreSQL deployment
└── ingress.yaml                       # Load balancer config
```

### **📊 Architecture**
```bash
Stage-1-Architecture/
├── Stage-1-Onboarding-Roadmap.png     # 🗺️ Getting started
├── stage1_complete_workflow.png       # 🔄 Complete workflow
├── stage1_aws_infrastructure.png      # 🏗️ AWS architecture
└── stage1_cost_timeline.png           # 💰 Cost breakdown
```

---

## **⚠️ Important Notes for New Users**

### **🎯 Stage 1 Characteristics**
- **Simple & Basic**: No advanced testing or quality gates
- **Manual Deployment**: Script-based (not automated CI/CD)
- **Cost Conscious**: Designed for learning and development
- **EKS Focus**: Learn Kubernetes on AWS
- **Shared Code**: Uses same source code as Stage 2

### **💰 Cost Management**
```yaml
Estimated Costs:
- EKS Cluster: ~$0.30/hour ($216/month)
- Worker Nodes: ~$0.0464/hour ($33.4/month)
- Load Balancer: ~$0.0225/hour ($16.2/month)
- Total: ~$163/month

Cost Saving Tips:
- Always cleanup when not using
- Use t3.medium nodes (cost-effective)
- Monitor AWS billing dashboard
- Set up billing alerts
```

### **🔒 Security Considerations**
- **AWS Credentials**: Keep secure, never commit to Git
- **EKS Access**: Use IAM roles and policies
- **Network Security**: Default VPC with security groups
- **Container Security**: Images from trusted sources

### **🆘 Getting Help**
1. **Check troubleshooting guide**: `docs/STAGE-1-TROUBLESHOOTING-REFERENCE.md`
2. **Review operations manual**: `docs/STAGE-1-OPERATIONS-GUIDE.md`
3. **Verify AWS resources**: `scripts/diagnose-aws-resources.sh`
4. **Check logs**: `kubectl logs -f deployment/healthcare-backend -n healthcare`

---

## **🎉 Success Indicators**

### **✅ You're Ready When:**
- [ ] You understand Stage 1 vs Stage 2 differences
- [ ] You can create and manage EKS clusters
- [ ] You've successfully deployed the healthcare application
- [ ] You can access the application via load balancer
- [ ] You understand cost implications
- [ ] You can cleanup resources properly

### **🚀 Next Steps After Stage 1:**
1. **Explore the application** - Test healthcare workflows
2. **Learn Kubernetes** - Understand pods, services, deployments
3. **Monitor costs** - Set up AWS billing alerts
4. **Try modifications** - Make changes to source code
5. **Move to Stage 2** - Experience advanced CI/CD pipeline

---

## **🔄 Stage 1 vs Stage 2 Comparison**

### **Stage 1 (Basic CI/CD)**
```yaml
Deployment: Manual scripts
Testing: None (basic functionality only)
Quality Gates: None
Security Scanning: None
Monitoring: Basic kubectl commands
Environments: Single (EKS cluster)
Complexity: Low (perfect for learning)
Cost: ~$163/month
```

### **Stage 2 (Advanced CI/CD)**
```yaml
Deployment: Automated GitHub Actions
Testing: Jest + Vitest + Selenium (80% coverage)
Quality Gates: SonarQube (A-rating required)
Security Scanning: Trivy (zero critical CVEs)
Monitoring: Prometheus + Grafana
Environments: Multi (dev/staging/prod)
Complexity: High (enterprise-grade)
Cost: Higher (more services)
```

---

**🎯 Remember**: Stage 1 is perfect for learning Kubernetes and AWS EKS basics. It's simpler than Stage 2 but provides the foundation for understanding container orchestration and cloud deployment.

**📅 Estimated Total Time**: 1.5-2 hours for complete setup and first deployment

**🏥 Healthcare Focus**: Even in Stage 1, the application is designed for healthcare use cases with patient management and appointment scheduling.
