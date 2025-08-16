# 🎓 **Student Learning Guide: Stage-3 Advanced DevOps Pipeline**

## 📋 **Overview**

Welcome to the **Stage-3 Advanced DevOps Pipeline** - a comprehensive learning experience designed to teach enterprise-grade DevOps practices through hands-on implementation of a healthcare management system.

**Learning Duration**: 6-8 weeks  
**Difficulty Level**: Intermediate to Advanced  
**Prerequisites**: Basic knowledge of Docker, Kubernetes, Git, and cloud computing

---

## 🎯 **Learning Objectives**

By completing this stage, you will master:

### **Core DevOps Skills**
- ✅ **CI/CD Pipeline Automation** with GitHub Actions
- ✅ **Infrastructure as Code** with Terraform
- ✅ **GitOps Workflows** with ArgoCD
- ✅ **Container Orchestration** with Kubernetes
- ✅ **Database Management** with automated migrations and seeding
- ✅ **Monitoring & Observability** with Prometheus/Grafana
- ✅ **Security Best Practices** with vulnerability scanning

### **Advanced Concepts**
- ✅ **Multi-environment Management** (dev/staging/prod)
- ✅ **Network Resilience** and error handling
- ✅ **Auto-scaling** and resource optimization
- ✅ **Secrets Management** and security hardening
- ✅ **Troubleshooting** and operational procedures

---

## 📚 **Prerequisites Check**

### **Required Knowledge**
```bash
# Basic understanding of:
✅ Docker containers and images
✅ Kubernetes pods, services, deployments
✅ Git version control and GitHub
✅ Linux command line basics
✅ Cloud computing concepts (AWS)
✅ Basic networking concepts
```

### **Required Tools**
```bash
# Install these tools before starting:
✅ AWS CLI v2 (configured with credentials)
✅ Terraform v1.6+
✅ kubectl (latest stable)
✅ Docker Desktop or Docker Engine
✅ Git and GitHub account
✅ Code editor (VS Code recommended)
```

### **AWS Account Setup**
```bash
# Required AWS permissions:
✅ EC2 (for EKS nodes)
✅ EKS (for Kubernetes cluster)
✅ RDS (for PostgreSQL database)
✅ ECR (for container registry)
✅ IAM (for roles and policies)
✅ VPC (for networking)
```

---

## 📅 **6-Week Learning Path**

### **Week 1: CI/CD Pipeline Understanding**

**Learning Goals:**
- Understand GitHub Actions workflow structure
- Learn about automated testing and security scanning
- Master Docker image building and pushing

**Activities:**
1. **Study the Pipeline** (`/.github/workflows/stage3-ci.yml`)
   ```yaml
   # Analyze each job:
   - terraform-validate    # Infrastructure validation
   - unit-tests           # Automated testing
   - security-scan        # Vulnerability scanning
   - build-images         # Docker image building
   - update-gitops        # GitOps automation
   ```

2. **Hands-on Exercise:**
   ```bash
   # Fork the repository
   git clone https://github.com/YOUR_USERNAME/Health_Care_Management_System.git
   
   # Study the source code structure
   cd Project-Stages/Project-Stage-3-Advanced-DevOps-Pipeline/src-code
   
   # Understand the application architecture
   # - Frontend: React with Vite
   # - Backend: Node.js with Express and Prisma
   # - Database: PostgreSQL with automated seeding
   ```

3. **Learning Checkpoint:**
   - [ ] Can explain each pipeline stage
   - [ ] Understands Docker multi-stage builds
   - [ ] Knows how image tagging works with commit SHA

### **Week 2: Infrastructure as Code**

**Learning Goals:**
- Master Terraform configuration and state management
- Understand AWS infrastructure components
- Learn about multi-environment deployments

**Activities:**
1. **Study Terraform Structure** (`/terraform/`)
   ```hcl
   # Analyze modules:
   - modules/eks/         # Kubernetes cluster
   - modules/rds/         # Database
   - modules/networking/  # VPC and security groups
   - environments/dev/    # Environment-specific configs
   ```

2. **Hands-on Exercise:**
   ```bash
   # Navigate to Terraform directory
   cd terraform/environments/dev
   
   # Initialize Terraform
   terraform init
   
   # Plan infrastructure changes
   terraform plan
   
   # Study the planned resources
   # - EKS cluster with node groups
   # - RDS PostgreSQL instance
   # - ECR repositories
   # - Load balancers and security groups
   ```

3. **Learning Checkpoint:**
   - [ ] Can read and understand Terraform configurations
   - [ ] Understands infrastructure dependencies
   - [ ] Knows how to manage Terraform state

### **Week 3: GitOps and ArgoCD**

**Learning Goals:**
- Understand GitOps principles and benefits
- Learn ArgoCD application management
- Master declarative deployment strategies

**Activities:**
1. **Study GitOps Manifests** (`/gitops/`)
   ```yaml
   # Analyze configurations:
   - environments/dev/frontend.yaml  # Frontend deployment
   - environments/dev/backend.yaml   # Backend deployment
   - argocd/applications/           # ArgoCD applications
   ```

2. **Hands-on Exercise:**
   ```bash
   # Study the GitOps workflow
   # 1. Code changes trigger pipeline
   # 2. Pipeline builds new images
   # 3. Pipeline updates GitOps manifests
   # 4. ArgoCD detects changes and deploys
   
   # Practice manual GitOps updates
   ./scripts/fix-gitops-sync.sh
   ```

3. **Learning Checkpoint:**
   - [ ] Understands GitOps vs traditional deployment
   - [ ] Can manage ArgoCD applications
   - [ ] Knows how to troubleshoot sync issues

### **Week 4: Database Management and Automation**

**Learning Goals:**
- Master database migrations with Prisma
- Understand automated seeding strategies
- Learn database connectivity and validation

**Activities:**
1. **Study Database Automation** (`/src-code/backend/`)
   ```javascript
   // Analyze components:
   - prisma/schema.prisma           # Database schema
   - prisma/migrations/             # Migration files
   - scripts/seed-database.js       # Automated seeding
   - scripts/docker-entrypoint.sh   # Container startup
   ```

2. **Hands-on Exercise:**
   ```bash
   # Test database operations locally
   cd src-code/backend
   
   # Run migrations
   npx prisma migrate dev
   
   # Seed database
   npm run db:seed
   
   # Study the sample data structure
   # - 5 departments (Cardiology, Pediatrics, etc.)
   # - 2 users (patient and admin)
   # - 5 doctors with department relationships
   ```

3. **Learning Checkpoint:**
   - [ ] Can create and run database migrations
   - [ ] Understands automated seeding benefits
   - [ ] Knows how to validate database connectivity

### **Week 5: Monitoring and Observability**

**Learning Goals:**
- Understand monitoring stack architecture
- Learn metrics collection and alerting
- Master log aggregation and analysis

**Activities:**
1. **Study Monitoring Configuration** (`/monitoring/`)
   ```yaml
   # Analyze components:
   - prometheus/          # Metrics collection
   - grafana/            # Visualization dashboards
   - alerts/             # Alerting rules
   - logging/            # Log aggregation
   ```

2. **Hands-on Exercise:**
   ```bash
   # Deploy monitoring stack
   helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
   helm install prometheus prometheus-community/kube-prometheus-stack -n monitoring --create-namespace
   
   # Access Grafana dashboard
   kubectl port-forward svc/prometheus-grafana 3000:80 -n monitoring
   ```

3. **Learning Checkpoint:**
   - [ ] Can deploy and configure monitoring stack
   - [ ] Understands key metrics to monitor
   - [ ] Knows how to create custom dashboards

### **Week 6: Troubleshooting and Operations**

**Learning Goals:**
- Master troubleshooting methodologies
- Learn operational procedures and best practices
- Understand automated recovery mechanisms

**Activities:**
1. **Study Troubleshooting Guide** (`/TROUBLESHOOTING.md`)
   ```markdown
   # Practice common scenarios:
   - Database connectivity issues
   - GitOps sync problems
   - Pod startup failures
   - Network connectivity problems
   ```

2. **Hands-on Exercise:**
   ```bash
   # Practice troubleshooting commands
   kubectl get pods -n healthcare-stage3-dev
   kubectl logs deployment/healthcare-backend-stage3 -n healthcare-stage3-dev
   kubectl describe pod POD_NAME -n healthcare-stage3-dev
   
   # Test connectivity
   ./test-frontend-backend-connectivity.sh
   
   # Practice recovery procedures
   ./scripts/fix-gitops-sync.sh
   ```

3. **Learning Checkpoint:**
   - [ ] Can diagnose common deployment issues
   - [ ] Knows how to read logs and debug problems
   - [ ] Understands automated recovery mechanisms

---

## 🚀 **Quick Start Guide**

### **Step 1: Environment Setup**
```bash
# 1. Clone the repository
git clone https://github.com/RouteClouds/Health_Care_Management_System.git
cd Project-Stages/Project-Stage-3-Advanced-DevOps-Pipeline

# 2. Configure AWS credentials
aws configure
# Enter your AWS Access Key ID, Secret Access Key, and region (us-east-1)

# 3. Install required tools
./setup/install-tools.sh

# 4. Verify prerequisites
./scripts/validate-stage2-setup.sh
```

### **Step 2: GitHub Setup**
```bash
# 1. Fork the repository to your GitHub account
# 2. Add repository secrets in GitHub:
#    - AWS_ACCESS_KEY_ID
#    - AWS_SECRET_ACCESS_KEY
# 3. Enable GitHub Actions in your forked repository
```

### **Step 3: Deploy Infrastructure**
```bash
# 1. Create AWS backend for Terraform
./setup/create-aws-backend.sh

# 2. Create ECR repositories
./setup/create-ecr-repositories.sh

# 3. Deploy infrastructure
cd terraform/environments/dev
terraform init
terraform plan
terraform apply
```

### **Step 4: Trigger Automated Pipeline**
```bash
# 1. Make a small change to trigger pipeline
echo "# Student deployment" >> README.md
git add .
git commit -m "feat: trigger student deployment pipeline"
git push origin main

# 2. Monitor pipeline progress
# Visit: https://github.com/YOUR_USERNAME/Health_Care_Management_System/actions
```

---

## ⚠️ **Common Student Issues and Solutions**

### **Issue 1: AWS Credentials Not Configured**
```bash
# Symptoms:
# - "Unable to locate credentials" error
# - Terraform authentication failures

# Solution:
aws configure
# Or set environment variables:
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="us-east-1"
```

### **Issue 2: Terraform State Lock**
```bash
# Symptoms:
# - "Error acquiring the state lock" message

# Solution:
cd terraform/environments/dev
terraform force-unlock LOCK_ID
# Replace LOCK_ID with the ID from the error message
```

### **Issue 3: GitOps Sync Issues**
```bash
# Symptoms:
# - Pods not updating to new images
# - Old image tags in deployments

# Solution:
./scripts/fix-gitops-sync.sh
# This automatically updates GitOps manifests with latest image tags
```

### **Issue 4: Database Connection Failures**
```bash
# Symptoms:
# - "PrismaClientInitializationError"
# - API endpoints returning database errors

# Solution:
# 1. Check RDS endpoint in backend.yaml
# 2. Verify database credentials
# 3. Run database setup:
kubectl exec -it BACKEND_POD -- npx prisma migrate deploy
kubectl exec -it BACKEND_POD -- npm run db:seed
```

---

## 📊 **Learning Assessment**

### **Self-Assessment Checklist**

**Week 1-2: Foundation**
- [ ] Can explain CI/CD pipeline stages
- [ ] Understands Docker containerization
- [ ] Knows basic Terraform concepts
- [ ] Can navigate the codebase structure

**Week 3-4: Intermediate**
- [ ] Understands GitOps principles
- [ ] Can manage database migrations
- [ ] Knows how to troubleshoot deployments
- [ ] Can read Kubernetes manifests

**Week 5-6: Advanced**
- [ ] Can set up monitoring stack
- [ ] Understands security best practices
- [ ] Can optimize resource usage
- [ ] Masters operational procedures

### **Practical Exercises**

1. **Deploy a Feature**: Add a new API endpoint and deploy it through the pipeline
2. **Fix a Bug**: Identify and fix a deployment issue using troubleshooting guides
3. **Scale the Application**: Modify auto-scaling configurations
4. **Add Monitoring**: Create a custom Grafana dashboard
5. **Security Hardening**: Implement additional security measures

---

*This learning guide provides a structured approach to mastering enterprise-grade DevOps practices through hands-on experience with a real-world healthcare management system.*
