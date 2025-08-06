# 📁 **Stage 2 Directory Structure**
## **Automated CI/CD Pipeline Organization**

### **🎯 Overview**
This document describes the complete directory structure for Stage 2 implementation, including reused assets from Stage 1 and new Stage 2 specific configurations.

---

## **📋 Complete Directory Structure**

```bash
Stage-2-Automated-CI-CD-Pipeline/
├── .github/                           # GitHub Actions CI/CD workflows
│   └── workflows/                     # Workflow definitions
├── tests/                             # Testing configurations and files
│   ├── jest-config/                   # Jest unit testing setup
│   ├── selenium-config/               # Selenium E2E testing setup
│   ├── e2e/                          # End-to-end test files
│   └── unit/                         # Unit test files
├── configs/                          # Configuration files
│   ├── environments/                 # Environment-specific configs (NEW)
│   ├── quality-gates/                # SonarQube configurations (NEW)
│   ├── security/                     # Trivy security configurations (NEW)
│   ├── app-config.env.template       # Application config template (FROM STAGE 1)
│   ├── aws-config.env.template       # AWS config template (FROM STAGE 1)
│   ├── docker-config.env.template    # Docker config template (FROM STAGE 1)
│   └── eks-iam-policy.json           # EKS IAM policy (FROM STAGE 1)
├── k8s/                              # Kubernetes manifests
│   ├── environments/                 # Environment-specific K8s configs (NEW)
│   │   ├── development/              # Development environment
│   │   ├── staging/                  # Staging environment
│   │   └── production/               # Production environment
│   ├── monitoring/                   # Monitoring configurations (NEW)
│   ├── ingress/                      # Ingress configurations (NEW)
│   ├── backend-deployment.yaml       # Backend deployment (FROM STAGE 1)
│   ├── database-deployment.yaml      # Database deployment (FROM STAGE 1)
│   ├── frontend-deployment.yaml      # Frontend deployment (FROM STAGE 1)
│   └── namespace.yaml                # Namespace definition (FROM STAGE 1)
├── scripts/                          # Deployment and utility scripts
│   ├── deployment/                   # Deployment automation (NEW)
│   │   ├── create-eks-cluster.sh     # EKS cluster creation (FROM STAGE 1)
│   │   └── verify-deployment.sh      # Deployment verification (FROM STAGE 1)
│   ├── quality/                      # Quality gate scripts (NEW)
│   ├── security/                     # Security scanning scripts (NEW)
│   └── setup-tools.sh                # Tool installation (FROM STAGE 1)
├── docs/                             # Documentation
│   ├── implementation/               # Implementation guides (NEW)
│   ├── IMPLEMENTATION-ROADMAP.md     # Complete implementation guide
│   ├── IMPLEMENTATION-PLAN-SUMMARY.md # Implementation summary
│   ├── stage-2-project-tracker.md    # Project progress tracker
│   ├── DIRECTORY-STRUCTURE.md        # This file
│   ├── STAGE-2-INDEX.md             # Stage 2 documentation index
│   ├── STAGE-2-MASTER-GUIDE.md      # Master implementation guide
│   ├── STAGE-2-OPERATIONS-GUIDE.md  # Operations procedures
│   └── STAGE-2-TROUBLESHOOTING-REFERENCE.md # Troubleshooting guide
├── Stage-2-Architecture/             # Architecture diagrams and generation
│   ├── Stage-2-Architecture-Diagram.png
│   ├── Stage-2-Pipeline-Flow-Diagram.png
│   ├── generate_*.py                 # Diagram generation scripts
│   └── stage2-diagrams-env/          # Python virtual environment
├── examples/                         # Example configurations
├── Extra-Information.md              # Additional tool information
└── README.md                         # Stage 2 overview
```

---

## **🔄 Asset Reuse Strategy**

### **✅ Reused from Stage 1**
```bash
Kubernetes Manifests (4 files):
├── backend-deployment.yaml     ✅ Base deployment configuration
├── database-deployment.yaml    ✅ PostgreSQL database setup
├── frontend-deployment.yaml    ✅ React frontend deployment
└── namespace.yaml              ✅ Namespace definition

Configuration Templates (4 files):
├── app-config.env.template     ✅ Application environment variables
├── aws-config.env.template     ✅ AWS credentials and settings
├── docker-config.env.template  ✅ Docker build configurations
└── eks-iam-policy.json         ✅ EKS IAM permissions

Infrastructure Scripts (3 files):
├── create-eks-cluster.sh       ✅ EKS cluster creation automation
├── verify-deployment.sh        ✅ Deployment validation logic
└── setup-tools.sh              ✅ Tool installation automation
```

### **🆕 New for Stage 2**
```bash
CI/CD Pipeline:
├── .github/workflows/          ✅ GitHub Actions automation
├── tests/                      ✅ Jest + Selenium testing frameworks
└── configs/quality-gates/      ✅ SonarQube + Trivy integration

Enhanced Infrastructure:
├── k8s/environments/           ✅ Multi-environment deployment
├── configs/environments/       ✅ Environment-specific configurations
└── scripts/deployment/         ✅ Advanced deployment automation

Quality & Security:
├── configs/quality-gates/      ✅ Code quality enforcement
├── configs/security/           ✅ Security scanning policies
├── scripts/quality/            ✅ Quality gate automation
└── scripts/security/           ✅ Security scanning automation
```

---

## **🎯 Source Code Integration**

### **📂 Source Code Location**
```bash
Source Code Path: /home/ubuntu/Projects/Health_Care_Management_System/src-code/
├── frontend/                   # React + TypeScript application
├── backend/                    # Node.js + TypeScript API
├── Dockerfile.frontend         # Frontend container configuration
├── Dockerfile.backend          # Backend container configuration
└── package.json               # Root package dependencies
```

### **🔗 Integration Strategy**
```yaml
Access Method: Reference-based configuration
├── GitHub Actions: Checkout from src-code directory
├── Docker Build: Reference src-code Dockerfiles
├── K8s Manifests: Use images built from src-code
└── Testing: Run tests against src-code application

Benefits:
├── Clean Separation: Source code independent of deployment stages
├── Reusability: Same source code used across all stages
├── Maintainability: Single source of truth for application code
└── Scalability: Easy to add new deployment stages
```

---

## **📊 Directory Status**

### **✅ Phase A Completion Status**
```bash
✅ A.1: Complete directory structure created
✅ A.2: Stage 1 assets copied successfully
✅ A.3: Directory permissions validated
✅ A.4: Directory structure documented

Total Directories Created: 15
Total Files Copied: 11
Total Scripts Copied: 3
Status: Phase A Complete
```

### **📈 Next Phase Preparation**
```bash
Ready for Phase B: Core CI/CD Pipeline
├── .github/workflows/ ready for GitHub Actions
├── tests/ ready for Jest and Selenium configuration
├── configs/ ready for SonarQube and Trivy setup
└── Source code integration points established
```

---

## **🔧 Usage Guidelines**

### **📁 Directory Conventions**
```bash
Configuration Files:
├── .template files: Copy and customize for your environment
├── .yaml files: Kubernetes manifests ready for deployment
└── .json files: Policy and configuration definitions

Scripts:
├── deployment/: Infrastructure and deployment automation
├── quality/: Code quality and testing automation
└── security/: Security scanning and policy enforcement

Tests:
├── jest-config/: Unit testing configuration
├── selenium-config/: E2E testing configuration
├── unit/: Unit test files
└── e2e/: End-to-end test files
```

### **🎯 Best Practices**
```yaml
File Organization:
├── Keep environment-specific configs in environments/
├── Store reusable templates in root configs/
├── Organize scripts by function (deployment, quality, security)
└── Maintain clear separation between Stage 1 and Stage 2 assets

Naming Conventions:
├── Use descriptive names for configuration files
├── Include environment suffix for environment-specific files
├── Use .template extension for template files
└── Follow kebab-case for directory names
```

---

**Directory Structure Version**: 1.0  
**Created**: August 2, 2025  
**Phase A Status**: ✅ Complete  
**Next Phase**: B (Core CI/CD Pipeline)  
**Total Setup Time**: 15 minutes
