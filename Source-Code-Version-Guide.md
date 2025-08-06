# 📁 **Source Code Version Guide**
## **Healthcare Management System - Stage-Specific Source Code**

### **📋 Document Information**
```yaml
Document: Source-Code-Version-Guide.md
Purpose: Guide students to use correct source code for each stage
Created: August 6, 2025
Status: ✅ READY FOR TRAINING
Target Audience: DevOps Training Students
```

---

## 🎯 **Problem Statement**

### **The Challenge**
As the Healthcare Management System evolved through different CI/CD pipeline stages, the source code was enhanced with additional dependencies and configurations. This creates a challenge:

- **Stage-1 students** need clean, minimal source code
- **Stage-2 students** need enhanced source code with testing frameworks
- **Using wrong version** causes confusion and deployment issues

---

## 📁 **Source Code Directory Structure**

### **🏗️ Current Project Layout**
```bash
Healthcare Management System/
└── Project-Stages/
    ├── Project-Stage-1-Basic-CI-CD-Deploy/
    │   └── src-code/           # ✅ Clean Stage-1 Version
    └── Project-Stage-2-Automated-CI-CD-Pipeline/
        └── src-code/           # ✅ Enhanced Stage-2 Version
```

---

## 🎓 **Stage-Specific Usage Guide**

### **📚 For Stage-1 Students**

#### **✅ Use: `Project-Stages/Project-Stage-1-Basic-CI-CD-Deploy/src-code/`**
```yaml
Purpose: Clean, minimal healthcare application
Dependencies: Only essential production dependencies
Features:
  ✅ Core healthcare management functionality
  ✅ Basic React frontend with TypeScript
  ✅ Node.js backend with Express and Prisma
  ✅ PostgreSQL database integration
  ❌ No testing frameworks
  ❌ No linting/formatting tools
  ❌ No security scanning dependencies
```

#### **📦 Stage-1 Dependencies**
```json
// Backend (Project-Stages/Project-Stage-1-Basic-CI-CD-Deploy/src-code/backend/package.json)
{
  "dependencies": {
    "express": "^4.21.2",
    "bcrypt": "^5.1.1",
    "cors": "^2.8.5",
    "prisma": "^5.22.0"
  },
  "devDependencies": {
    "@types/express": "^4.17.23",
    "@types/node": "^20.19.9",
    "typescript": "^5.8.3",
    "ts-node": "^10.9.2"
  }
}

// Frontend (Project-Stages/Project-Stage-1-Basic-CI-CD-Deploy/src-code/frontend/package.json)
{
  "dependencies": {
    "react": "^18.3.1",
    "react-dom": "^18.3.1",
    "axios": "^1.11.0"
  },
  "devDependencies": {
    "@types/react": "^18.3.5",
    "@vitejs/plugin-react": "^4.3.1",
    "vite": "^5.4.2"
  }
}
```

### **📚 For Stage-2 Students**

#### **✅ Use: `Project-Stages/Project-Stage-2-Automated-CI-CD-Pipeline/src-code/`**
```yaml
Purpose: Enhanced application with testing and quality tools
Dependencies: Production + Development + Testing frameworks
Features:
  ✅ All Stage-1 functionality
  ✅ Jest testing framework
  ✅ Supertest for API testing
  ✅ ESLint for code quality
  ✅ Prettier for code formatting
  ✅ TypeScript testing types
  ✅ Vitest for frontend testing
  ✅ Security scanning compatibility
```

#### **📦 Stage-2 Enhanced Dependencies**
```json
// Backend (Project-Stages/Project-Stage-2-Automated-CI-CD-Pipeline/src-code/backend/package.json)
{
  "devDependencies": {
    // Stage-1 dependencies +
    "@types/jest": "^29.5.0",
    "@types/supertest": "^6.0.0",
    "eslint": "^8.45.0",
    "jest": "^29.5.0",
    "supertest": "^6.3.0",
    "ts-jest": "^29.1.0",
    "prettier": "^3.0.0"
  }
}

// Frontend (Project-Stages/Project-Stage-2-Automated-CI-CD-Pipeline/src-code/frontend/package.json)
{
  "devDependencies": {
    // Stage-1 dependencies +
    "@testing-library/react": "^14.2.1",
    "eslint": "^9.9.1",
    "vitest": "^1.3.1",
    "prettier": "^3.0.0"
  }
}
```

---

## 🚀 **Quick Start Instructions**

### **🎯 For Stage-1 Students**

#### **Step 1: Use Correct Source Code**
```bash
# Navigate to Stage-1 source code
cd Project-Stages/Project-Stage-1-Basic-CI-CD-Deploy/src-code/

# Verify you're using the clean version
ls -la backend/package.json frontend/package.json
```

#### **Step 2: Install Dependencies**
```bash
# Install backend dependencies
cd backend
npm install

# Install frontend dependencies
cd ../frontend
npm install
```

#### **Step 3: Build Docker Images**
```bash
# Navigate back to source root
cd ..

# Build images (should work without issues)
docker build -f Dockerfile.backend -t healthcare-backend:stage1 .
docker build -f Dockerfile.frontend -t healthcare-frontend:stage1 .
```

### **🎯 For Stage-2 Students**

#### **Step 1: Use Enhanced Source Code**
```bash
# Navigate to enhanced source code
cd Project-Stages/Project-Stage-2-Automated-CI-CD-Pipeline/src-code/

# Verify you're using the enhanced version
grep -c "jest\|eslint" backend/package.json frontend/package.json
```

#### **Step 2: Install Dependencies (Workspace Bypass)**
```bash
# Install backend dependencies
cd backend
npm install --no-workspaces

# Install frontend dependencies
cd ../frontend
npm install --no-workspaces
```

#### **Step 3: Build Docker Images**
```bash
# Navigate back to source root
cd ..

# Build images with no cache
docker build --no-cache -f Dockerfile.backend -t healthcare-backend:stage2 .
docker build -f Dockerfile.frontend -t healthcare-frontend:stage2 .
```

---

## ⚠️ **Common Issues & Solutions**

### **🚨 Issue 1: Stage-1 Student Uses Wrong Source Code**

#### **Symptoms:**
```bash
# Student uses Stage-2 source code for Stage-1
npm error Missing: @types/jest@29.5.14 from lock file
npm error Missing: eslint@8.57.1 from lock file
```

#### **Solution:**
```bash
echo "❌ You're using Stage-2 source code for Stage-1!"
echo "✅ Switch to: Project-Stages/Project-Stage-1-Basic-CI-CD-Deploy/src-code/"
cd Project-Stages/Project-Stage-1-Basic-CI-CD-Deploy/src-code/
```

### **🚨 Issue 2: Package Lock File Conflicts**

#### **Symptoms:**
```bash
npm ci can only install packages when package.json and package-lock.json are in sync
```

#### **Solution:**
```bash
# Remove lock files and reinstall
rm -f package-lock.json
npm install
```

### **🚨 Issue 3: Docker Build Failures**

#### **Symptoms:**
```bash
Docker build fails with dependency errors
```

#### **Solution:**
```bash
# Use correct source code version
# For Stage-1: use Project-Stages/Project-Stage-1-Basic-CI-CD-Deploy/src-code/
# For Stage-2: use Project-Stages/Project-Stage-2-Automated-CI-CD-Pipeline/src-code/
```

---

## 📚 **Best Practices**

### **✅ For Instructors**
```yaml
Setup Guidelines:
  ✅ Always specify which source code version to use
  ✅ Include version check in lab instructions
  ✅ Provide clear troubleshooting steps
  ✅ Test both versions before class

Student Guidance:
  ✅ Explain why different versions exist
  ✅ Show how to identify current version
  ✅ Demonstrate switching between versions
  ✅ Emphasize checking source code first when issues arise
```

### **✅ For Students**
```yaml
Before Starting Any Stage:
  ✅ Verify you're using correct source code version
  ✅ Check package.json for expected dependencies
  ✅ Remove any existing package-lock.json files
  ✅ Follow stage-specific installation instructions

When Encountering Issues:
  ✅ First check: Am I using the right source code version?
  ✅ Second check: Are my dependencies synchronized?
  ✅ Third check: Am I following stage-specific instructions?
  ✅ Document and share solutions with classmates
```

---

## 🔍 **Version Identification**

### **🎯 Quick Version Check Commands**

#### **Check if you're using Stage-1 version:**
```bash
# Should return 0 (no matches)
grep -c "jest\|eslint\|prettier" backend/package.json

# Should show minimal scripts
grep -A 5 "scripts" backend/package.json
```

#### **Check if you're using Stage-2 version:**
```bash
# Should return >0 (multiple matches)
grep -c "jest\|eslint\|prettier" backend/package.json

# Should show testing and linting scripts
grep -A 10 "scripts" backend/package.json
```

---

## 🎓 **Educational Value**

### **📚 Learning Outcomes**
```yaml
Students Learn:
  ✅ How enterprise applications evolve across stages
  ✅ Dependency management in different environments
  ✅ Version control and code organization strategies
  ✅ Troubleshooting methodology for dependency conflicts
  ✅ Best practices for staged development approaches
```

### **🏢 Real-World Applications**
```yaml
Enterprise Scenarios:
  ✅ Managing multiple environment configurations
  ✅ Handling legacy vs modern application versions
  ✅ Coordinating team development across different features
  ✅ Maintaining backward compatibility during upgrades
  ✅ Implementing gradual rollout strategies
```

---

## 📞 **Support & Troubleshooting**

### **🆘 When Students Need Help**
```yaml
First Steps:
  1. Verify source code version being used
  2. Check package.json dependencies match expectations
  3. Ensure following stage-specific instructions
  4. Review common issues section above

Escalation Path:
  1. Check with classmates for similar issues
  2. Review stage-specific documentation
  3. Consult instructor or teaching assistant
  4. Document issue for future students
```

---

**Document Status**: ✅ **READY FOR TRAINING**  
**Last Updated**: August 6, 2025  
**Version**: 1.0  
**Next Review**: When Stage-3 development begins
