# 📜 **Stage-2 Scripts Reference Guide**
## **Complete Script Details, Purpose, and Usage Instructions**

### **📖 Document Purpose**
This document provides comprehensive details about all scripts available in Stage-2, including their purpose, when to run them, prerequisites, and expected outcomes.

**Target Audience**: DevOps engineers, developers, and system administrators working with Stage-2 CI/CD pipeline
**Last Updated**: August 8, 2025
**Total Scripts**: 16 scripts across 2 directories

---

## **📂 Script Directory Structure**
```
scripts/
├── setup-tools.sh                    # Tool installation
├── validate-infrastructure.sh        # Infrastructure validation
├── validate-stage2-setup.sh         # Complete Stage-2 setup validation
├── fix-testing-setup.sh             # Testing setup with fixes
├── validate-tests.js                # Testing infrastructure validation
├── validate-configs.js              # Quality gates configuration
├── setup-branch-protection.sh       # GitHub branch protection setup
├── test-branch-protection.sh        # Branch protection testing
├── quick-update.sh                  # Automated Git workflow helper
├── git-status-check.sh              # Repository status monitoring
├── development-mode.sh              # Temporary branch protection management
├── build-and-push-images.sh         # Docker image management
├── deploy-healthcare.sh             # Application deployment
└── deployment/                      # Deployment-specific scripts
    ├── create-eks-cluster.sh        # EKS cluster creation
    ├── deploy-staging.sh            # Staging deployment
    ├── deploy-production.sh         # Production deployment
    └── verify-deployment.sh         # Deployment verification
```

---

## **🛠️ Setup & Installation Scripts**

### **1. setup-tools.sh**
**Location**: `scripts/setup-tools.sh`  
**Purpose**: Install all required tools for Stage-2 CI/CD pipeline  
**When to Run**: First step of Stage-2 setup (Step 1 in Master Guide)

#### **What It Does:**
- Installs AWS CLI v2
- Installs kubectl (Kubernetes CLI)
- Installs eksctl (EKS management tool)
- Installs Docker and configures user permissions
- Installs GitHub CLI
- Installs Node.js 20 LTS
- Installs additional utilities (jq, curl, wget, unzip, git)

#### **Prerequisites:**
- Ubuntu 20.04+ or similar Linux distribution
- Internet connection
- Sudo privileges

#### **Usage:**
```bash
cd Project-Stages/Project-Stage-2-Automated-CI-CD-Pipeline
./scripts/setup-tools.sh
```

#### **Expected Outcome:**
- All tools installed and accessible via command line
- Docker daemon running and user added to docker group
- Node.js 20+ available for selenium-webdriver compatibility

#### **Verification:**
```bash
aws --version          # Should show v2.x
kubectl version --client  # Should show v1.28+
eksctl version         # Should show v0.150+
docker --version       # Should show v20.x+
gh --version          # Should show v2.x+
node --version        # Should show v20.x+
```

---

### **2. validate-infrastructure.sh**
**Location**: `scripts/validate-infrastructure.sh`  
**Purpose**: Verify all required tools are properly installed and configured  
**When to Run**: After setup-tools.sh to confirm installation success

#### **What It Does:**
- Checks version of all installed tools
- Verifies AWS CLI configuration
- Tests Docker daemon accessibility
- Validates GitHub CLI authentication
- Confirms Node.js version compatibility

#### **Prerequisites:**
- All tools installed via setup-tools.sh
- AWS credentials configured
- GitHub CLI authenticated

#### **Usage:**
```bash
./scripts/validate-infrastructure.sh
```

#### **Expected Outcome:**
- All tools report correct versions
- No missing dependencies or configuration issues
- Green checkmarks for all validation tests

---

### **3. validate-stage2-setup.sh** ⭐ **COMPREHENSIVE VALIDATION**
**Location**: `scripts/validate-stage2-setup.sh`
**Purpose**: Complete Stage-2 setup validation including all components
**When to Run**: Before starting Stage-2 setup, troubleshooting, or after major changes

#### **What It Does:**
- Validates all prerequisites (Node.js, Docker, AWS CLI, GitHub CLI)
- Checks repository structure and configuration
- Verifies GitHub authentication and secrets
- Validates branch protection rules
- Checks testing setup and dependencies
- Validates configuration files
- Provides comprehensive status report with recommendations

#### **Prerequisites:**
- Basic tools installed (can detect missing tools)
- Git repository context
- Internet connection for GitHub API calls

#### **Usage:**
```bash
./scripts/validate-stage2-setup.sh
```

#### **Expected Outcome:**
- Comprehensive validation report with pass/fail/warning status
- Detailed recommendations for fixing issues
- Clear next steps based on current setup state
- Summary of total checks passed/failed

#### **Verification:**
```bash
# Script provides its own verification with detailed output
# Look for final summary showing passed/failed/warning counts
```

---

## **🧪 Testing & Quality Scripts**

### **4. fix-testing-setup.sh** ⭐ **RECOMMENDED**
**Location**: `scripts/fix-testing-setup.sh`  
**Purpose**: Complete testing infrastructure setup with automatic issue resolution  
**When to Run**: Step 3 of Master Guide (Testing Infrastructure Setup)

#### **What It Does:**
- Upgrades Node.js to v20+ if needed (selenium-webdriver requirement)
- Cleans up any incorrect installations
- Installs Jest and React Testing Library locally
- Installs Selenium WebDriver with proper configuration
- Creates Jest and Babel configurations
- Sets up test directories and sample tests
- Validates all testing components

#### **Prerequisites:**
- Basic tools installed (Node.js, npm)
- Internet connection
- Sudo privileges (for Node.js upgrade if needed)

#### **Usage:**
```bash
./scripts/fix-testing-setup.sh
```

#### **Expected Outcome:**
- Node.js 20+ installed
- Jest 30+ configured and working
- Selenium WebDriver ready for E2E testing
- Sample tests passing
- All testing dependencies resolved

#### **Verification:**
```bash
cd src-code
npx jest --version  # Should show 30.x.x
npm test -- --testPathIgnorePatterns=tests/e2e  # Should pass all unit tests
```

---

### **5. validate-tests.js**
**Location**: `scripts/validate-tests.js`  
**Purpose**: Alternative testing infrastructure validation (JavaScript-based)  
**When to Run**: Alternative to fix-testing-setup.sh for testing validation

#### **What It Does:**
- Validates Jest installation and configuration
- Checks Selenium WebDriver setup
- Verifies test environment configuration
- Runs basic test suite validation

#### **Prerequisites:**
- Node.js installed
- Testing dependencies installed

#### **Usage:**
```bash
node scripts/validate-tests.js
```

#### **Expected Outcome:**
- Testing infrastructure validated
- Configuration issues identified
- Test environment ready for CI/CD

---

### **6. validate-configs.js**
**Location**: `scripts/validate-configs.js`  
**Purpose**: Configure and validate quality gates (SonarQube, Trivy)  
**When to Run**: Step 4 of Master Guide (Quality & Security Gates)

#### **What It Does:**
- Configures SonarQube for code quality analysis
- Sets up Trivy for security vulnerability scanning
- Creates quality gate configurations
- Validates all quality tools

#### **Prerequisites:**
- Node.js and npm installed
- SonarQube account and token
- Internet connection for tool downloads

#### **Usage:**
```bash
node scripts/validate-configs.js
```

#### **Expected Outcome:**
- SonarQube scanner configured
- Trivy security scanner installed
- Quality gates ready for CI/CD pipeline
- All quality tools validated

---

## **🔒 Git Workflow & Branch Protection Scripts**

### **7. setup-branch-protection.sh** ⭐ **SECURITY ESSENTIAL**
**Location**: `scripts/setup-branch-protection.sh`
**Purpose**: Configure GitHub branch protection rules for main branch
**When to Run**: Step 6 of Master Guide (Repository Security Setup)

#### **What It Does:**
- Checks prerequisites (GitHub CLI, authentication, repository context)
- Creates proper JSON configuration for branch protection
- Configures required status checks (security-analysis, unit-testing, code-quality)
- Sets up required pull request reviews (1 approval required)
- Enables admin enforcement and strict mode
- Blocks force pushes and branch deletions
- Provides detailed success/error messages and next steps

#### **Prerequisites:**
- GitHub CLI installed and authenticated
- Repository admin permissions
- Git repository context (or manual repository specification)

#### **Usage:**
```bash
./scripts/setup-branch-protection.sh
```

#### **Expected Outcome:**
- Branch protection active on main branch
- Required status checks configured
- Pull request reviews mandatory
- Direct pushes to main blocked
- Comprehensive protection summary displayed

#### **Verification:**
```bash
gh api repos/:owner/:repo/branches/main/protection
# Should show configured protection rules
```

---

### **8. test-branch-protection.sh**
**Location**: `scripts/test-branch-protection.sh`
**Purpose**: Test branch protection rules by creating test PR
**When to Run**: After setting up branch protection to verify it works

#### **What It Does:**
- Creates test branch with sample changes
- Creates pull request to test protection
- Monitors status checks execution
- Verifies merge blocking until requirements met
- Tests protection enforcement
- Generates test report
- Automatically cleans up test branch and PR

#### **Prerequisites:**
- Branch protection configured
- GitHub CLI authenticated
- Git repository with main branch

#### **Usage:**
```bash
./scripts/test-branch-protection.sh
```

#### **Expected Outcome:**
- Test PR created successfully
- Status checks triggered automatically
- Merge blocked until checks pass
- Protection rules verified working
- Test cleanup completed automatically

---

### **9. quick-update.sh** ⭐ **DEVELOPER PRODUCTIVITY**
**Location**: `scripts/quick-update.sh`
**Purpose**: Automated Git workflow helper for standard branch protection workflow
**When to Run**: For regular updates following proper Git workflow

#### **What It Does:**
- Checks prerequisites and repository status
- Guides user through commit message creation
- Creates timestamped feature branch automatically
- Commits all changes with proper message
- Pushes branch to GitHub
- Creates pull request with detailed description
- Provides next steps and monitoring commands

#### **Prerequisites:**
- Git repository with changes to commit
- GitHub CLI authenticated
- Branch protection configured (recommended)

#### **Usage:**
```bash
./scripts/quick-update.sh
```

#### **Expected Outcome:**
- Feature branch created and pushed
- Pull request created with proper description
- Standard workflow followed correctly
- Ready for review and merge process

---

### **10. git-status-check.sh**
**Location**: `scripts/git-status-check.sh`
**Purpose**: Comprehensive Git repository status monitoring
**When to Run**: Before making changes, troubleshooting, or checking repository health

#### **What It Does:**
- Shows basic repository information (location, remote URL)
- Displays current branch and all available branches
- Checks for uncommitted, staged, and untracked changes
- Shows recent commit history and branch comparisons
- Verifies remote sync status (ahead/behind commits)
- Checks branch protection status via GitHub API
- Shows recent contributors and branch activity
- Provides personalized recommendations based on current state

#### **Prerequisites:**
- Git repository context
- GitHub CLI for protection status (optional)

#### **Usage:**
```bash
./scripts/git-status-check.sh
```

#### **Expected Outcome:**
- Comprehensive repository status overview
- Clear understanding of current state
- Actionable recommendations for next steps
- No changes made to repository

---

### **11. development-mode.sh** ⚠️ **USE WITH CAUTION**
**Location**: `scripts/development-mode.sh`
**Purpose**: Temporary branch protection management for active development phases
**When to Run**: During bulk updates or rapid development iterations

#### **What It Does:**
- **disable**: Safely removes branch protection with automatic backup
- **enable**: Restores branch protection from backup
- **status**: Shows current protection state and backup status
- Provides warnings and confirmations to prevent misuse
- Creates automatic backup of protection settings
- Includes built-in safety checks and reminders

#### **Prerequisites:**
- GitHub CLI authenticated with admin permissions
- Repository admin access
- Understanding of security implications

#### **Usage:**
```bash
./scripts/development-mode.sh [disable|enable|status]

# Examples:
./scripts/development-mode.sh status   # Check current state
./scripts/development-mode.sh disable # Remove protection (with backup)
./scripts/development-mode.sh enable  # Restore protection
```

#### **Expected Outcome:**
- **disable**: Protection removed, backup created, warnings displayed
- **enable**: Protection restored from backup, security re-enabled
- **status**: Clear report of current protection state

#### **⚠️ Important Notes:**
- Only use during active development phases
- Always re-enable protection when done
- Not recommended for production repositories
- Notify team members when protection is disabled

---

## **🐳 Build & Container Scripts**

### **12. build-and-push-images.sh**
**Location**: `scripts/build-and-push-images.sh`  
**Purpose**: Build Docker images and push to Docker Hub registry  
**When to Run**: Before deployment or as part of CI/CD pipeline

#### **What It Does:**
- Builds healthcare-backend Docker image
- Builds healthcare-frontend Docker image
- Tags images with version and latest tags
- Pushes images to Docker Hub registry
- Includes interactive Docker login prompts

#### **Prerequisites:**
- Docker installed and running
- Docker Hub account
- Source code available in src-code directory
- Dockerfiles present (Dockerfile.backend, Dockerfile.frontend)

#### **Usage:**
```bash
./scripts/build-and-push-images.sh
```

#### **Expected Outcome:**
- Both Docker images built successfully
- Images pushed to Docker Hub
- Images available for deployment

#### **Verification:**
```bash
docker images | grep healthcare  # Should show both images
# Check Docker Hub for pushed images
```

---

### **13. deploy-healthcare.sh**
**Location**: `scripts/deploy-healthcare.sh`  
**Purpose**: Deploy healthcare application to Kubernetes cluster  
**When to Run**: After EKS cluster creation and image building

#### **What It Does:**
- Creates healthcare namespace
- Deploys PostgreSQL database
- Deploys backend API service
- Deploys frontend application
- Configures services and load balancers

#### **Prerequisites:**
- EKS cluster running and accessible
- kubectl configured for cluster
- Docker images available in registry
- Kubernetes manifests in k8s directory

#### **Usage:**
```bash
./scripts/deploy-healthcare.sh
```

#### **Expected Outcome:**
- All application components deployed
- Services running and accessible
- Load balancer provisioned
- Application ready for testing

---

## **☸️ Deployment Scripts**

### **14. create-eks-cluster.sh**
**Location**: `scripts/deployment/create-eks-cluster.sh`  
**Purpose**: Create multi-environment EKS cluster for Stage-2  
**When to Run**: Step 6 of Master Guide (Multi-Environment Deployment)

#### **What It Does:**
- Creates EKS cluster with multi-environment support
- Sets up development, staging, and production namespaces
- Configures RBAC and service accounts
- Sets up ingress controllers and load balancers
- Configures node groups with appropriate sizing

#### **Prerequisites:**
- AWS CLI configured with proper permissions
- eksctl installed
- kubectl installed

#### **Usage:**
```bash
./scripts/deployment/create-eks-cluster.sh
```

#### **Expected Outcome:**
- EKS cluster created with 3+ nodes
- Multiple namespaces configured
- kubectl context updated
- Cluster ready for multi-environment deployments

#### **Verification:**
```bash
kubectl get nodes  # Should show 3+ Ready nodes
kubectl get namespaces | grep healthcare  # Should show dev/staging/prod namespaces
```

---

### **15. deploy-staging.sh**
**Location**: `scripts/deployment/deploy-staging.sh`  
**Purpose**: Deploy application to staging environment  
**When to Run**: Part of CI/CD pipeline or manual staging deployment

#### **What It Does:**
- Deploys application to healthcare-staging namespace
- Configures staging-specific settings
- Sets up staging database
- Configures staging ingress and services

#### **Prerequisites:**
- EKS cluster running
- Docker images available
- Staging namespace created

#### **Usage:**
```bash
./scripts/deployment/deploy-staging.sh [image-tag]
```

#### **Parameters:**
- `image-tag`: Optional Docker image tag (defaults to latest)

#### **Expected Outcome:**
- Application deployed to staging environment
- Staging URL accessible
- Environment isolated from production

---

### **16. deploy-production.sh**
**Location**: `scripts/deployment/deploy-production.sh`  
**Purpose**: Deploy application to production environment  
**When to Run**: After successful staging deployment and testing

#### **What It Does:**
- Deploys application to healthcare-prod namespace
- Configures production-specific settings
- Sets up production database with persistence
- Configures production ingress with SSL/TLS

#### **Prerequisites:**
- EKS cluster running
- Tested Docker images available
- Production namespace created
- Staging deployment successful

#### **Usage:**
```bash
./scripts/deployment/deploy-production.sh [image-tag]
```

#### **Parameters:**
- `image-tag`: Required Docker image tag for production deployment

#### **Expected Outcome:**
- Application deployed to production environment
- Production URL accessible with SSL
- High availability configuration active

---

### **17. verify-deployment.sh**
**Location**: `scripts/deployment/verify-deployment.sh`  
**Purpose**: Verify deployment status across all environments  
**When to Run**: After any deployment to confirm success

#### **What It Does:**
- Checks pod status in all namespaces
- Verifies service endpoints
- Tests application health endpoints
- Validates load balancer configuration
- Runs basic connectivity tests

#### **Prerequisites:**
- kubectl configured for cluster
- Applications deployed to environments

#### **Usage:**
```bash
./scripts/deployment/verify-deployment.sh [environment]
```

#### **Parameters:**
- `environment`: Optional specific environment (dev/staging/prod), defaults to all

#### **Expected Outcome:**
- All pods running successfully
- Services accessible
- Health checks passing
- Load balancers operational

---

## **🔄 Script Execution Order**

### **📋 Complete Stage-2 Setup Sequence**
Follow this order for first-time Stage-2 setup:

```bash
# Step 0: Validate Current Setup (5 minutes)
./scripts/validate-stage2-setup.sh

# Step 1: Install Tools (15 minutes)
./scripts/setup-tools.sh
./scripts/validate-infrastructure.sh

# Step 2: Setup Testing Infrastructure (20 minutes)
./scripts/fix-testing-setup.sh

# Step 3: Configure Quality Gates (15 minutes)
node scripts/validate-configs.js

# Step 4: Setup Repository Security (10 minutes)
./scripts/setup-branch-protection.sh
./scripts/test-branch-protection.sh

# Step 5: Create Infrastructure (20 minutes)
./scripts/deployment/create-eks-cluster.sh

# Step 6: Build and Deploy (15 minutes)
./scripts/build-and-push-images.sh
./scripts/deploy-healthcare.sh

# Step 7: Verify Deployment (5 minutes)
./scripts/deployment/verify-deployment.sh
```

### **🔄 CI/CD Pipeline Sequence**
Automated pipeline execution order:

```bash
# Triggered by git push
1. Quality Gates: node scripts/validate-configs.js
2. Build Images: ./scripts/build-and-push-images.sh
3. Deploy Staging: ./scripts/deployment/deploy-staging.sh
4. Verify Staging: ./scripts/deployment/verify-deployment.sh staging
5. Deploy Production: ./scripts/deployment/deploy-production.sh (on main branch)
6. Verify Production: ./scripts/deployment/verify-deployment.sh prod
```

### **🔄 Git Workflow Sequence**
For regular development workflow:

```bash
# Daily development workflow
1. Check Status: ./scripts/git-status-check.sh
2. Make Changes: # Edit files, create new features
3. Quick Update: ./scripts/quick-update.sh
4. Monitor PR: gh pr view --web
5. Merge After Approval: gh pr merge --squash
```

### **🔄 Development Mode Sequence**
For bulk updates or rapid development:

```bash
# Development mode workflow (use sparingly)
1. Check Status: ./scripts/development-mode.sh status
2. Disable Protection: ./scripts/development-mode.sh disable
3. Make Changes: # Edit multiple files, bulk updates
4. Push Directly: git add . && git commit -m "message" && git push origin main
5. Re-enable Protection: ./scripts/development-mode.sh enable
6. Verify Protection: ./scripts/development-mode.sh status
```

---

## **🚨 Troubleshooting Scripts**

### **Common Script Issues & Solutions**

#### **Issue: Permission Denied**
```bash
# Make scripts executable
chmod +x scripts/*.sh
chmod +x scripts/deployment/*.sh

# Or make all scripts executable at once
find scripts/ -name "*.sh" -exec chmod +x {} \;
```

#### **Issue: Node.js Version Conflicts**
```bash
# Use fix-testing-setup.sh to resolve automatically
./scripts/fix-testing-setup.sh

# Or manually upgrade Node.js
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs
```

#### **Issue: Docker Permission Errors**
```bash
# Add user to docker group and restart
sudo usermod -aG docker $USER
# Log out and log back in, or restart terminal
```

#### **Issue: AWS Credentials Not Configured**
```bash
# Configure AWS CLI before running deployment scripts
aws configure
# Verify: aws sts get-caller-identity
```

#### **Issue: kubectl Context Not Set**
```bash
# Update kubeconfig after cluster creation
aws eks update-kubeconfig --region us-east-1 --name healthcare-cluster-stage2
```

---

## **📊 Script Dependencies Matrix**

| Script | Depends On | Must Run Before |
|--------|------------|-----------------|
| `setup-tools.sh` | None | All other scripts |
| `validate-infrastructure.sh` | `setup-tools.sh` | Testing/deployment scripts |
| `validate-stage2-setup.sh` | None (can detect issues) | Any major setup steps |
| `fix-testing-setup.sh` | `setup-tools.sh` | Quality gates, CI/CD |
| `validate-tests.js` | `fix-testing-setup.sh` | CI/CD pipeline |
| `validate-configs.js` | `fix-testing-setup.sh` | CI/CD pipeline |
| `setup-branch-protection.sh` | GitHub CLI, auth | Development workflow |
| `test-branch-protection.sh` | Branch protection setup | Development workflow |
| `quick-update.sh` | Git repo, GitHub CLI | None (workflow tool) |
| `git-status-check.sh` | Git repo | None (monitoring tool) |
| `development-mode.sh` | GitHub CLI, admin access | None (management tool) |
| `create-eks-cluster.sh` | `setup-tools.sh`, AWS config | Deployment scripts |
| `build-and-push-images.sh` | Docker, Docker Hub login | Deployment scripts |
| `deploy-healthcare.sh` | EKS cluster, images built | Verification scripts |
| `deploy-staging.sh` | EKS cluster, images built | Production deployment |
| `deploy-production.sh` | Staging successful | Verification |
| `verify-deployment.sh` | Applications deployed | None |

---

## **⚡ Quick Reference Commands**

### **🔍 Check Script Status**
```bash
# Check if scripts are executable
ls -la scripts/*.sh scripts/deployment/*.sh

# Check Node.js and npm versions
node --version && npm --version

# Check Docker status
docker --version && docker info

# Check AWS configuration
aws sts get-caller-identity

# Check kubectl context
kubectl config current-context
```

### **🧹 Cleanup Commands**
```bash
# Clean up failed deployments
kubectl delete namespace healthcare-dev healthcare-staging healthcare-prod

# Clean up Docker images
docker images | grep healthcare | awk '{print $3}' | xargs docker rmi -f

# Reset kubectl context
kubectl config unset current-context
```

### **📋 Verification Commands**
```bash
# Verify complete Stage-2 setup
./scripts/validate-stage2-setup.sh

# Verify all tools installed
./scripts/validate-infrastructure.sh

# Verify testing setup
cd src-code && npm test -- --testPathIgnorePatterns=tests/e2e

# Verify branch protection
./scripts/test-branch-protection.sh

# Verify deployments
./scripts/deployment/verify-deployment.sh

# Verify cluster health
kubectl get nodes && kubectl get pods --all-namespaces
```

### **🔄 Git Workflow Commands**
```bash
# Check repository status
./scripts/git-status-check.sh

# Quick update workflow
./scripts/quick-update.sh

# Branch protection management
./scripts/development-mode.sh status
./scripts/development-mode.sh disable  # Use with caution
./scripts/development-mode.sh enable   # Always re-enable

# Setup branch protection
./scripts/setup-branch-protection.sh
```

---

## **📚 Additional Resources**

### **🔗 Related Documentation**
- **[STAGE-2-MASTER-GUIDE.md](../docs/STAGE-2-MASTER-GUIDE.md)** - Complete deployment guide
- **[STAGE-2-OPERATIONS-GUIDE.md](../docs/STAGE-2-OPERATIONS-GUIDE.md)** - Operational procedures
- **[STAGE-2-TROUBLESHOOTING-REFERENCE.md](../docs/STAGE-2-TROUBLESHOOTING-REFERENCE.md)** - Issue resolution

### **🛠️ Script Customization**
All scripts can be customized by editing the variables at the top of each file:
- Cluster names and regions
- Docker image names and tags
- Namespace names
- Resource configurations

### **📞 Support**
For script-specific issues:
1. Check the troubleshooting section above
2. Review the script's error output
3. Verify prerequisites are met
4. Check related documentation
5. Ensure proper execution order

---

## **📋 Document Information**

**Document Version**: 2.0
**Last Updated**: August 8, 2025
**Total Scripts Documented**: 17
**Coverage**: Complete Stage-2 script ecosystem including Git workflow and branch protection
**Maintenance**: Update when new scripts are added or existing scripts are modified

### **📋 Recent Updates (v2.0)**
- Added comprehensive Git workflow scripts (quick-update.sh, git-status-check.sh)
- Added branch protection management (setup-branch-protection.sh, test-branch-protection.sh)
- Added development mode script for temporary protection management
- Added complete Stage-2 validation script (validate-stage2-setup.sh)
- Updated execution sequences and dependency matrix
- Enhanced troubleshooting and verification sections

**🎯 This document provides complete guidance for all Stage-2 scripts, ensuring successful CI/CD pipeline deployment and management.**
