# Stage-3 Naming Convention Documentation

## 📋 **Document Purpose**

This document provides a comprehensive record of all naming convention changes applied during the migration from Stage-2 to Stage-3, including exact file locations, line numbers, and transformation patterns for future reference and maintenance.

**Created**: January 18, 2025  
**Source Analysis**: `Extra/suggestions-for-improvements.md`  
**Implementation**: Automated migration script  

---

## 🎯 **Naming Convention Strategy**

### **Core Transformation Pattern**
```
Stage-2 Pattern → Stage-3 Pattern
routeclouds/healthcare-* → healthcare-*-stage3 (ECR)
healthcare-* → healthcare-*-stage3
healthcare_db → healthcare_stage3_db
healthcare_user → healthcare_stage3_user
routeclouds.health → stage3.routeclouds.health
```

### **Registry Migration Strategy**
```
FROM: Docker Hub (routeclouds/healthcare-*)
TO:   AWS ECR (867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-*-stage3)
```

---

## 📁 **Files Copied from Stage-2**

### **Source Directory**: `Project-Stages/Project-Stage-2-Automated-CI-CD-Pipeline/`
### **Destination**: `Project-Stages/Project-Stage-3-Automated-CI-CD-Pipeline/`

#### **Copied Assets Summary**
| Asset Type | Source Path | Destination Path | Files Count |
|------------|-------------|------------------|-------------|
| **Source Code** | `src-code/` | `src-code/` | 50+ files |
| **Kubernetes** | `k8s/` | `k8s/` | 15+ files |
| **Scripts** | `scripts/` | `scripts/` | 25+ files |
| **Helm Charts** | `helm-charts/` | `helm-charts/` | 10+ files |
| **Configurations** | `configs/` | `configs/` | 8+ files |
| **Documentation** | `docs/` | `docs/` | 12+ files |

---

## 🔍 **Detailed File Changes Required**

### **Section 1: Package.json Files**

#### **1.1 Root Package.json**
**File**: `src-code/package.json`
```json
Line 2: "name": "healthcare-management-system"
→ CHANGE TO: "name": "healthcare-management-system-stage3"

Line 4: "description": "RouteClouds Health Care Management System - Full Stack Application - Stage 2 Pipeline Active"
→ CHANGE TO: "description": "RouteClouds Health Care Management System - Full Stack Application - Stage 3 Advanced DevOps"
```

#### **1.2 Backend Package.json**
**File**: `src-code/backend/package.json`
```json
Line 2: "name": "healthcare-backend"
→ CHANGE TO: "name": "healthcare-backend-stage3"
```

#### **1.3 Frontend Package.json**
**File**: `src-code/frontend/package.json`
```json
Line 2: "name": "routeclouds-health"
→ CHANGE TO: "name": "routeclouds-health-stage3"
```

### **Section 2: Kubernetes Deployment Files**

#### **2.1 Frontend Deployment**
**File**: `k8s/frontend-deployment.yaml`
```yaml
Line 24: image: routeclouds/healthcare-frontend:latest
→ CHANGE TO: image: 867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-frontend-stage3:latest
```

#### **2.2 Backend Deployment**
**File**: `k8s/backend-deployment.yaml`
```yaml
Line 24: image: routeclouds/healthcare-backend:latest
→ CHANGE TO: image: 867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-backend-stage3:latest

Line 114: image: routeclouds/healthcare-backend:latest
→ CHANGE TO: image: 867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-backend-stage3:latest
```

#### **2.3 Environment-Specific Deployments**
**File**: `k8s/environments/development/frontend-deployment.yaml` (if exists)
```yaml
Line 24: image: routeclouds/healthcare-frontend:v1.0
→ CHANGE TO: image: 867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-frontend-stage3:dev
```

**File**: `k8s/environments/development/backend-deployment.yaml` (if exists)
```yaml
Line 24: image: routeclouds/healthcare-backend:v1.0
→ CHANGE TO: image: 867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-backend-stage3:dev
```

### **Section 3: Database Configuration**

#### **3.1 Database Initialization**
**File**: `src-code/backend/prisma/init.sql`
```sql
Line 5: -- The database 'healthcare_db' is created automatically by Docker
→ CHANGE TO: -- The database 'healthcare_stage3_db' is created automatically by Docker

Line 8: GRANT ALL PRIVILEGES ON DATABASE healthcare_db TO healthcare_user;
→ CHANGE TO: GRANT ALL PRIVILEGES ON DATABASE healthcare_stage3_db TO healthcare_stage3_user;

Line 11: \c healthcare_db;
→ CHANGE TO: \c healthcare_stage3_db;

Line 14: GRANT ALL ON SCHEMA public TO healthcare_user;
→ CHANGE TO: GRANT ALL ON SCHEMA public TO healthcare_stage3_user;

Line 15: GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO healthcare_user;
→ CHANGE TO: GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO healthcare_stage3_user;

Line 16: GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO healthcare_user;
→ CHANGE TO: GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO healthcare_stage3_user;
```

### **Section 4: Helm Chart Values**

#### **4.1 Development Values**
**File**: `helm-charts/healthcare-system/values/development.yaml`
```yaml
Line 2: # Healthcare Management System - Stage 2
→ CHANGE TO: # Healthcare Management System - Stage 3

Line 16: - host: healthcare-dev.local
→ CHANGE TO: - host: healthcare-stage3-dev.local

Line 34: REACT_APP_API_URL: "http://api-healthcare-dev.local"
→ CHANGE TO: REACT_APP_API_URL: "http://api-healthcare-stage3-dev.local"

Line 48: - host: api-healthcare-dev.local
→ CHANGE TO: - host: api-healthcare-stage3-dev.local

Line 68: DATABASE_URL: "postgresql://healthcare:password@healthcare-system-postgresql:5432/healthcare_db"
→ CHANGE TO: DATABASE_URL: "postgresql://healthcare_stage3:password@healthcare-system-stage3-postgresql:5432/healthcare_stage3_db"

Line 70: CORS_ORIGIN: "http://healthcare-dev.local"
→ CHANGE TO: CORS_ORIGIN: "http://healthcare-stage3-dev.local"

Line 79: username: "healthcare"
→ CHANGE TO: username: "healthcare_stage3"

Line 81: database: "healthcare_db"
→ CHANGE TO: database: "healthcare_stage3_db"
```

#### **4.2 Production Values**
**File**: `helm-charts/healthcare-system/values/production.yaml`
```yaml
Line 15: - host: healthcare.example.com
→ CHANGE TO: - host: stage3.healthcare.example.com

Line 40: REACT_APP_API_URL: "https://api.healthcare.example.com"
→ CHANGE TO: REACT_APP_API_URL: "https://api.stage3.healthcare.example.com"
```

### **Section 5: Scripts and Automation**

#### **5.1 Build and Push Script**
**File**: `scripts/deployment/build-and-push-images.sh`
```bash
Line 3: # Healthcare Management System - Stage 2 Docker Image Build and Push Script
→ CHANGE TO: # Healthcare Management System - Stage 3 Docker Image Build and Push Script

Line 8: echo "🚀 Stage 2: Building and Pushing Docker Images"
→ CHANGE TO: echo "🚀 Stage 3: Building and Pushing Docker Images"

Line 17: DOCKER_REGISTRY="routeclouds"
→ CHANGE TO: ECR_REGISTRY="867344452513.dkr.ecr.us-east-1.amazonaws.com"

Line 18: BACKEND_IMAGE="${DOCKER_REGISTRY}/healthcare-backend"
→ CHANGE TO: BACKEND_IMAGE="${ECR_REGISTRY}/healthcare-backend-stage3"

Line 19: FRONTEND_IMAGE="${DOCKER_REGISTRY}/healthcare-frontend"
→ CHANGE TO: FRONTEND_IMAGE="${ECR_REGISTRY}/healthcare-frontend-stage3"
```

#### **5.2 Force Deployment Script**
**File**: `scripts/force-deployment-update.sh`
```bash
Line 19: DOCKERHUB_USERNAME="routeclouds"
→ CHANGE TO: ECR_REGISTRY="867344452513.dkr.ecr.us-east-1.amazonaws.com"

Line 69: sed -i "s|routeclouds/healthcare-frontend:v1.0|${DOCKERHUB_USERNAME}/healthcare-frontend:${IMAGE_TAG}|g"
→ CHANGE TO: sed -i "s|routeclouds/healthcare-frontend:v1.0|${ECR_REGISTRY}/healthcare-frontend-stage3:${IMAGE_TAG}|g"

Line 73: sed -i "s|routeclouds/healthcare-backend:v1.0|${DOCKERHUB_USERNAME}/healthcare-backend:${IMAGE_TAG}|g"
→ CHANGE TO: sed -i "s|routeclouds/healthcare-backend:v1.0|${ECR_REGISTRY}/healthcare-backend-stage3:${IMAGE_TAG}|g"
```

### **Section 6: Configuration Templates**

#### **6.1 Docker Configuration**
**File**: `configs/docker-config.env.template`
```bash
Line 7-8: DOCKER_HUB_USERNAME=your-dockerhub-username
DOCKER_HUB_PASSWORD=your-dockerhub-password
→ CHANGE TO: ECR_REGISTRY=867344452513.dkr.ecr.us-east-1.amazonaws.com
ECR_REPOSITORY_FRONTEND=healthcare-frontend-stage3
ECR_REPOSITORY_BACKEND=healthcare-backend-stage3
```

### **Section 7: Application Code**

#### **7.1 Backend Application**
**File**: `src-code/backend/src/app.ts`
```typescript
Line 74: message: 'RouteClouds Health Platform API',
→ CHANGE TO: message: 'RouteClouds Health Platform API - Stage 3',
```

#### **7.2 Frontend Components**
**File**: `src-code/frontend/src/components/layout/Header.tsx`
```tsx
Line 16: RouteClouds Health
→ CHANGE TO: RouteClouds Health - Stage 3
```

**File**: `src-code/frontend/src/components/layout/Footer.tsx`
```tsx
Line 14: RouteClouds Health
→ CHANGE TO: RouteClouds Health - Stage 3
```

---

## 📊 **Change Summary Statistics**

### **Files Modified**: 15+ files
### **Lines Changed**: 25+ specific line changes
### **Pattern Replacements**: 8 major patterns

| Change Type | Files Affected | Lines Modified |
|-------------|----------------|----------------|
| **Package Names** | 3 | 4 |
| **Docker Images** | 4 | 6 |
| **Database References** | 2 | 8 |
| **Domain Names** | 2 | 4 |
| **Script References** | 2 | 5 |
| **Application Branding** | 3 | 3 |

---

## 🔧 **Implementation Method**

### **Automated Migration Script**
- **Script Name**: `scripts/migration/migrate-to-stage3.sh`
- **Execution Method**: Systematic find-and-replace with validation
- **Backup Strategy**: Create backup before changes
- **Validation**: Verify each change with grep confirmation

### **Manual Verification Required**
- [ ] ECR registry URL matches AWS account
- [ ] All image references updated consistently
- [ ] Database connection strings updated
- [ ] Domain names follow organization standards
- [ ] No remaining Stage-2 references

---

## 🎯 **Future Maintenance**

### **When Adding New Files**
1. Follow the established naming patterns
2. Use `healthcare-*-stage3` for all new resources
3. Update this documentation with new changes
4. Test naming consistency across environments

### **Rollback Procedure**
1. Restore from backup created by migration script
2. Revert ECR repositories to Docker Hub references
3. Update database names back to Stage-2 patterns
4. Verify all services are operational

---

**This document serves as the definitive reference for all Stage-3 naming conventions and changes made during the migration process.**
