# 📋 **Stage 2 Documentation Index**
## **Healthcare Management System - Automated CI/CD Pipeline**

### **🎯 Welcome to Stage 2**

This is your **single entry point** for all Stage 2 documentation. Stage 2 implements **automated CI/CD pipeline** with GitHub Actions, automated testing, and deployment automation building upon the foundation established in Stage 1.

**Prerequisites**: ✅ Stage 1 must be completed successfully before proceeding with Stage 2.

---

## **🚀 Quick Start - Choose Your Path**

### **👤 For New Users (First Time Stage 2 Setup)**
**Time Required**: 60-90 minutes  
**Start Here**: 📖 [STAGE-2-MASTER-GUIDE.md](./STAGE-2-MASTER-GUIDE.md)

### **🔧 For Troubleshooting Issues**
**When You Need Help**: Problems with GitHub Actions, automated testing, or deployments  
**Go To**: 🔍 [STAGE-2-TROUBLESHOOTING-REFERENCE.md](./STAGE-2-TROUBLESHOOTING-REFERENCE.md)

### **⚙️ For Operations & Maintenance**
**For Pipeline Management**: Monitoring workflows, managing environments, rollbacks  
**Go To**: 🛠️ [STAGE-2-OPERATIONS-GUIDE.md](./STAGE-2-OPERATIONS-GUIDE.md)

---

## **📚 Complete Documentation Structure**

### **📖 1. Master Setup Guide** 
**File**: `STAGE-2-MASTER-GUIDE.md`  
**Purpose**: Complete end-to-end automated CI/CD pipeline setup  
**Content**:
- ✅ Prerequisites and Stage 1 verification
- 🔧 GitHub Actions workflow configuration
- 🧪 Automated testing setup (Unit, Integration, E2E)
- 🚀 Automated deployment pipeline
- 🌍 Environment-specific configurations (Dev, Staging, Prod)

### **🔍 2. Troubleshooting Reference**
**File**: `STAGE-2-TROUBLESHOOTING-REFERENCE.md`  
**Purpose**: Comprehensive CI/CD pipeline issue resolution  
**Content**:
- 📑 Quick issue index for GitHub Actions problems
- 🔧 Workflow failures and debugging
- 🧪 Testing pipeline issues
- 🚀 Deployment automation problems
- 🛡️ Security and secrets management issues

### **🛠️ 3. Operations Guide**
**File**: `STAGE-2-OPERATIONS-GUIDE.md`  
**Purpose**: Pipeline monitoring, environment management, and maintenance  
**Content**:
- ✅ Pipeline health monitoring
- 🌍 Environment management (Dev/Staging/Prod)
- 🔄 Rollback procedures and deployment strategies
- 📊 Performance monitoring and optimization

### **📋 4. This Index**
**File**: `STAGE-2-INDEX.md`
**Purpose**: Navigation hub and quick reference
**Content**:
- 🗺️ Documentation roadmap
- ⚡ Common GitHub Actions commands
- ❓ FAQ section

### **🚀 5. Implementation Roadmap**
**File**: `IMPLEMENTATION-ROADMAP.md`
**Purpose**: Step-by-step implementation guide for Jest + Selenium + SonarQube + Trivy stack
**Content**:
- 📋 Complete 4-phase implementation plan
- ⏱️ Time estimates and success criteria
- 🔧 Tool-specific configuration examples
- ✅ Validation and testing procedures

---

## **⚡ Common Commands Reference**

### **🔧 GitHub Actions Commands**
```bash
# View workflow runs
gh workflow list
gh run list --workflow=ci-cd-pipeline.yml

# Trigger manual workflow
gh workflow run ci-cd-pipeline.yml

# View workflow logs
gh run view <run-id> --log

# Cancel running workflow
gh run cancel <run-id>
```

### **🧪 Testing Commands**
```bash
# Run unit tests with Jest
npm test
npm run test:coverage

# Run integration tests
npm run test:integration

# Run E2E tests with Selenium WebDriver
npm run test:e2e
npm run test:e2e:chrome    # Chrome browser
npm run test:e2e:firefox   # Firefox browser

# Code quality and formatting
npm run lint
npm run format
npm run format:check

# SonarQube analysis
npm run sonar
```

### **🚀 Deployment Commands**
```bash
# Deploy to specific environment
gh workflow run deploy.yml -f environment=staging
gh workflow run deploy.yml -f environment=production

# Check deployment status
kubectl get deployments -n healthcare-staging
kubectl get deployments -n healthcare-prod

# Rollback deployment
kubectl rollout undo deployment/healthcare-backend -n healthcare-staging
```

---

## **❓ Frequently Asked Questions**

### **🚀 Getting Started**
**Q: I completed Stage 1. How do I start Stage 2?**  
A: Start with [STAGE-2-MASTER-GUIDE.md](./STAGE-2-MASTER-GUIDE.md) - it will verify Stage 1 and guide you through automated pipeline setup.

**Q: How long does Stage 2 setup take?**  
A: 60-90 minutes for experienced users, 2-3 hours for beginners including testing setup.

**Q: What's different from Stage 1?**  
A: Stage 2 automates everything: builds, tests, and deployments happen automatically on code push.

### **🔧 GitHub Actions**
**Q: My GitHub Actions workflow failed. What should I do?**  
A: Check [STAGE-2-TROUBLESHOOTING-REFERENCE.md](./STAGE-2-TROUBLESHOOTING-REFERENCE.md) - it covers common workflow failures and debugging steps.

**Q: How do I add secrets for AWS access?**  
A: Follow the secrets management section in the master guide for secure credential setup.

**Q: Can I test workflows locally before pushing?**  
A: Yes, use `act` tool for local GitHub Actions testing, covered in the operations guide.

### **🧪 Testing & Quality**
**Q: What types of tests are automated?**
A: Unit tests (Jest), Integration tests (Supertest), E2E tests (Selenium WebDriver), code quality (SonarQube), and security scanning (Trivy).

**Q: How do I add new tests to the pipeline?**
A: Follow the testing framework setup in the master guide and implementation roadmap.

**Q: What happens if tests fail?**
A: Deployment is automatically blocked. Fix tests and push again to trigger new pipeline run.

**Q: Which browsers are supported for E2E testing?**
A: Chrome, Firefox, Safari, and Edge through Selenium WebDriver for maximum compatibility.

**Q: How does SonarQube quality gate work?**
A: SonarQube analyzes code quality and blocks deployment if coverage <80% or quality ratings below A.

### **🌍 Environment Management**
**Q: How many environments are created?**  
A: Three environments: Development (auto-deploy), Staging (manual approval), Production (manual approval).

**Q: How do I promote code from staging to production?**  
A: Use GitHub Environments with manual approval process, detailed in operations guide.

**Q: Can I rollback a deployment?**  
A: Yes, both automated and manual rollback procedures are available in operations guide.

### **💰 Cost Management**
**Q: How much does Stage 2 cost compared to Stage 1?**  
A: Similar AWS costs (~$0.30-0.50/hour per environment) but GitHub Actions usage may apply for private repos.

**Q: How do I optimize pipeline costs?**  
A: Use efficient workflows, cache dependencies, and manage environment lifecycles as covered in operations guide.

---

## **🎯 Success Criteria for Stage 2**

### **✅ Pipeline Automation Success**
- [ ] GitHub Actions workflows configured and running
- [ ] Automated builds on code push working
- [ ] All test suites passing in pipeline
- [ ] Automated deployment to staging environment
- [ ] Manual promotion to production working

### **✅ Testing Integration Success**
- [ ] Unit tests running automatically
- [ ] Integration tests covering API endpoints
- [ ] E2E tests covering user workflows
- [ ] Code quality checks passing
- [ ] Test coverage reports generated

### **✅ Environment Management Success**
- [ ] Development environment auto-deploys on main branch
- [ ] Staging environment deploys on manual trigger
- [ ] Production environment requires approval
- [ ] Rollback procedures tested and working
- [ ] Environment-specific configurations working

---

## **🔗 External Resources**

### **📚 Prerequisites Knowledge**
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Jest Testing Framework](https://jestjs.io/docs/getting-started)
- [Cypress E2E Testing](https://docs.cypress.io/)
- [Helm Package Manager](https://helm.sh/docs/)

### **🛠️ Required Tools**
- [GitHub CLI](https://cli.github.com/)
- [Act (Local GitHub Actions)](https://github.com/nektos/act)
- [Helm](https://helm.sh/docs/intro/install/)
- [Node.js 20 LTS](https://nodejs.org/)

### **🎓 Learning Path**
- **Stage 1**: Basic CI/CD with manual deployment ✅
- **Stage 2**: Automated CI/CD with GitHub Actions ⬅️ **You are here**
- **Stage 3**: Advanced monitoring and infrastructure automation
- **Stage 4**: Enterprise DevSecOps and multi-environment management

---

## **📞 Support & Contribution**

### **🐛 Found an Issue?**
1. Check [STAGE-2-TROUBLESHOOTING-REFERENCE.md](./STAGE-2-TROUBLESHOOTING-REFERENCE.md)
2. Review GitHub Actions workflow logs
3. Search existing GitHub issues
4. Create new issue with workflow logs and error details

### **💡 Want to Contribute?**
1. Fork the repository
2. Create feature branch
3. Add/update tests for your changes
4. Ensure all pipeline checks pass
5. Submit pull request

### **📧 Need Help?**
- Review troubleshooting guide first
- Check GitHub Actions workflow logs
- Verify Stage 1 is working correctly
- Create GitHub issue for pipeline-specific problems

---

## **🔄 Stage Progression**

### **📋 From Stage 1 to Stage 2**
- **Stage 1**: Manual deployment with kubectl commands
- **Stage 2**: Automated deployment with GitHub Actions
- **Key Changes**: Everything becomes automated and environment-aware

### **📋 From Stage 2 to Stage 3**
- **Stage 2**: Basic automation with GitHub Actions
- **Stage 3**: Advanced monitoring, Infrastructure as Code, advanced deployment strategies
- **Preparation**: Master Stage 2 automation before adding complexity

---

**Documentation Version**: 1.0  
**Last Updated**: August 1, 2025  
**Stage**: 2 - Automated CI/CD Pipeline  
**Status**: ✅ Ready for Implementation  
**Prerequisites**: Stage 1 completion required
