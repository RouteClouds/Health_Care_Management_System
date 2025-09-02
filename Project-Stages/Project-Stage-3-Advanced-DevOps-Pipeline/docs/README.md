# Stage-3: Advanced DevOps Pipeline - Healthcare Management System

## 🎯 Overview

Stage-3 represents the evolution of our healthcare management system into an **enterprise-grade, cloud-native application** with world-class DevOps practices. Building upon the solid foundation of Stage-2's CI/CD automation, Stage-3 introduces Infrastructure as Code, comprehensive observability, GitOps workflows, and advanced deployment strategies.

## 🏗️ Architecture Overview

![Overall Architecture](Images/stage3-architecture-diagrams/01_overall_architecture_corrected.png)

### **Key Architectural Components**
- **Infrastructure as Code**: Terraform-managed AWS infrastructure
- **Container Registry**: AWS ECR for enterprise-grade image management
- **GitOps Deployment**: ArgoCD for declarative application management
- **Comprehensive Monitoring**: Prometheus + Grafana observability stack
- **Centralized Logging**: ELK stack for unified log management
- **Advanced Deployments**: Blue-green and canary deployment strategies

## 🚀 Quick Start

### **Prerequisites**
- ✅ Stage-2 successfully completed and operational
- ✅ AWS CLI configured with appropriate permissions
- ✅ Terraform installed (v1.6+)
- ✅ kubectl configured for EKS access
- ✅ Helm installed (v3.0+)

### **Rapid Deployment (30 minutes)**
```bash
# 1. Clone and navigate to Stage-3
cd Project-Stages/Project-Stage-3-Automated-CI-CD-Pipeline

# 2. Execute migration from Stage-2
./scripts/migration/migrate-to-stage3.sh

# 3. Validate migration
./scripts/validation/validate-migration.sh

# 4. Deploy infrastructure
cd terraform/environments/dev
terraform init && terraform apply

# 5. Deploy applications via GitOps
kubectl apply -f gitops/applications/
```

## 📚 Documentation

### Core Guides
- Master Setup Guide: MASTER-SETUP-GUIDE.md
- Architecture Guide: ARCHITECTURE-guide.md
- Operations Manual: OPERATIONS.md
- Troubleshooting Guide: TROUBLESHOOTING.md

### Consolidated Enhancement & RCA
- Stage-3 Enhancement Summary & Roadmap: "Stage-3 Enhancement Summary & Roadmap.md"
- RCA - Duplicate Infra & State Drift: "RCA - Duplicate Infra & State Drift.md"

### Archive
- docs/archive/ contains superseded docs and drafts preserved for reference


### How to Use This Documentation (Stage-3)

- New to Stage-3? Start with MASTER-SETUP-GUIDE.md for the full deployment.
- Want a quick orientation? Read this README’s Overview and Quick Start, then follow the links below.
- Day-to-day operations: See OPERATIONS.md (Daily checks, deployments, monitoring ops).
- Troubleshooting: See TROUBLESHOOTING.md (comprehensive, real outputs and fixes).
- Architecture visuals: See ARCHITECTURE-guide.md.
- Roadmap and current status: See RoadMap-For-Stage-3.md.
- Naming conventions and ALB: See Naming-Convention-For-Stage-3.md and ALB-Configuration-Guide.md.

Documentation structure snapshot:
- Core: MASTER-SETUP-GUIDE.md, ARCHITECTURE-guide.md, OPERATIONS.md, TROUBLESHOOTING.md, CONTRIBUTING.md
- Reference: RoadMap-For-Stage-3.md, Naming-Convention-For-Stage-3.md, ALB-Configuration-Guide.md
- Training: STUDENT-LEARNING-GUIDE.md, My-Understanding.md

### Observability (New – MVP via GitOps)
- Prometheus + Alertmanager + Grafana (kube-prometheus-stack) with dev-friendly storage
- EFK logging (Elasticsearch single-node, Fluent Bit, Kibana) with 7d retention
- Tracing (Jaeger) is post-MVP and can be enabled later
- See 2-sept-Observability-stack.md for the full plan and OPERATIONS.md for credential setup

- Archive: docs/archive/ contains superseded docs, raw logs, and detailed RCA history

### Specialized Documentation
- Migration Guide: docs/MIGRATION-GUIDE.md (placeholder)
- Security Guide: docs/SECURITY-GUIDE.md (placeholder)
- Performance Tuning: docs/PERFORMANCE-TUNING.md (placeholder)
- FAQ: docs/FAQ.md (placeholder)

### Project Management
- Project Tracker: Project-Tracker.md

## 🔧 Key Features & Capabilities

### **🏗️ Infrastructure as Code**
- **Terraform Modules**: Reusable, versioned infrastructure components
- **Multi-Environment**: Consistent dev/staging/prod environments
- **State Management**: Remote state with locking and versioning
- **Automated Provisioning**: Complete infrastructure in < 15 minutes

### **🔄 GitOps Workflows**
- **ArgoCD Integration**: Declarative application deployment
- **Automated Sync**: Self-healing and drift detection
- **Multi-Environment**: Environment-specific configurations
- **Rollback Capabilities**: Instant rollback to previous versions

### **📊 Comprehensive Observability**
- **Metrics**: Prometheus for application and infrastructure metrics
- **Visualization**: Grafana dashboards for real-time monitoring
- **Alerting**: Intelligent alerting with AlertManager
- **Logging**: Centralized log aggregation with ELK stack

### **🚀 Advanced Deployments**
- **Blue-Green Deployments**: Zero-downtime deployments
- **Canary Releases**: Gradual rollout with automated validation
- **Auto-Scaling**: HPA, VPA, and cluster autoscaling
- **Performance Optimization**: Resource optimization and cost management

## 🎯 Stage Evolution Comparison

![Pipeline Evolution](Images/stage3-architecture-diagrams/06_corrected_pipeline_comparison.png)

| Feature | Stage-1 | Stage-2 | Stage-3 |
|---------|---------|---------|---------|
| **Deployment** | Manual Scripts | GitHub Actions | GitOps (ArgoCD) |
| **Infrastructure** | Manual Setup | Manual EKS | Terraform IaC |
| **Registry** | Local/Docker Hub | Docker Hub | AWS ECR |
| **Monitoring** | Basic Logs | CloudWatch | Prometheus/Grafana |
| **Logging** | Container Logs | Basic Aggregation | ELK Stack |
| **Scaling** | Manual | Manual | Automated (HPA/VPA) |
| **Security** | Basic | Improved | Enterprise-grade |

## 📦 Container Registry Strategy

![Registry Comparison](Images/stage3-architecture-diagrams/02_registry_comparison.png)

**Migration from Docker Hub to AWS ECR:**
- ✅ **Native AWS Integration**: IAM-based authentication
- ✅ **Cost Efficiency**: No rate limiting issues
- ✅ **Enterprise Security**: VPC endpoints and encryption
- ✅ **Performance**: Same-region registry reduces pull times

## 🚫 Architecture Decisions

### **Why No Istio Service Mesh?**
![Istio Justification](Images/stage3-architecture-diagrams/04_no_istio_justification.png)

For our **monolithic healthcare application**, we chose Kubernetes-native solutions over Istio because:
- ✅ **Right-sized Complexity**: Service mesh designed for microservices
- ✅ **Learning Focus**: Concentrate on core DevOps concepts
- ✅ **Resource Efficiency**: Avoid unnecessary infrastructure overhead
- ✅ **Maintenance Simplicity**: Reduce operational complexity

## 🏷️ Naming Conventions

![Naming Strategy](Images/stage3-architecture-diagrams/05_naming_convention_changes.png)

**Systematic Resource Separation:**
- **EKS Clusters**: `healthcare-eks-stage3-{env}`
- **ECR Repositories**: `healthcare-{service}-stage3`
- **Namespaces**: `healthcare-stage3-{env}`
- **Services**: `{service}-stage3-svc`

## 📊 Project Status

| Component | Status | Progress | Notes |
|-----------|--------|----------|-------|
| **Documentation** | 🟡 In Progress | 60% | Core guides being created |
| **Migration Scripts** | 🔴 Planned | 0% | Automation development pending |
| **Infrastructure** | 🔴 Planned | 0% | Terraform modules to be created |
| **Monitoring** | 🔴 Planned | 0% | Prometheus stack pending |
| **GitOps** | 🔴 Planned | 0% | ArgoCD configuration pending |

**Legend**: 🟢 Complete | 🟡 In Progress | 🔴 Planned | ⚫ Blocked

## 🎓 Learning Objectives

### **Technical Skills Development**
- **Infrastructure as Code**: Terraform proficiency and best practices
- **GitOps Workflows**: ArgoCD and declarative deployments
- **Observability**: Prometheus, Grafana, and monitoring strategies
- **Container Management**: Enterprise registry and image lifecycle
- **Performance Optimization**: Auto-scaling and resource management

### **DevOps Culture & Practices**
- **Automation First**: Eliminate manual processes
- **Infrastructure Immutability**: Treat infrastructure as code
- **Observability-Driven**: Monitor everything, alert intelligently
- **Security by Design**: Implement security at every layer
- **Continuous Improvement**: Iterate and optimize continuously

## 🚀 Getting Started

1. **Review Prerequisites**: Ensure Stage-2 is complete and operational
2. **Read Master Setup Guide**: Understand the complete deployment process
3. **Study Architecture**: Review visual architecture documentation
4. **Execute Migration**: Follow the automated migration process
5. **Deploy Infrastructure**: Use Terraform for infrastructure provisioning
6. **Monitor Progress**: Track implementation using Project Tracker

## 🆘 Support & Resources

- **Issues**: Check [Troubleshooting Guide](TROUBLESHOOTING.md)
- **Operations**: Refer to [Operations Manual](OPERATIONS.md)
- **Architecture**: Study [Architecture Guide](ARCHITECTURE-guide.md)
- **Progress**: Monitor [Project Tracker](Project-Tracker.md)

---

## ♻️ Rebuild After Complete Destruction (New)

To rebuild Stage-3 cleanly after teardown:

```bash
cd Project-Stages/Project-Stage-3-Advanced-DevOps-Pipeline
chmod +x scripts/deployment/rebuild-stage3.sh
./scripts/deployment/rebuild-stage3.sh
```

This script:
- Validates infra is destroyed
- Creates/initializes Terraform backend (S3 + DynamoDB)
- Provisions infra via Terraform (VPC, EKS, RDS)
- Configures ALB Controller IAM + IRSA with explicit DescribeListenerAttributes permission
- Installs ALB Controller (Helm) and verifies readiness
- Applies GitOps manifests (Ingress with ingressClassName: alb) and validates /api/health

See Stage-3-Destruction-Guide.md for details and TROUBLESHOOTING.md for IAM/ALB controller tips.


**Ready to transform your healthcare management system into an enterprise-grade, cloud-native application!** 🚀

*Stage-3 represents the pinnacle of modern DevOps practices, providing students with real-world experience in enterprise-grade infrastructure and deployment strategies.*
