# 🚀 **Healthcare Management System - Deployment Checklist**

## **Critical Files Verification Before Deployment**

### **✅ Required Files Must Exist:**

#### **1. Frontend Environment Files**
```bash
# Local development
src-code/frontend/.env
# Content: VITE_API_BASE_URL=http://localhost:3002/api

# Kubernetes deployment  
src-code/frontend/.env.k8s
# Content: VITE_API_BASE_URL=/api
```

#### **2. Environment-Specific Nginx Configurations**
```bash
# Local Docker Compose
src-code/nginx/nginx.local.conf
# Content: server backend:3002

# Kubernetes deployment
src-code/nginx/nginx.k8s.conf  
# Content: server backend-service:3002
```

#### **3. Environment-Specific Dockerfiles**
```bash
# Local development
src-code/Dockerfile.frontend
# Uses: nginx/frontend.conf

# Kubernetes deployment
src-code/Dockerfile.frontend.k8s
# Uses: nginx/nginx.k8s.conf + copies .env.k8s as .env
```

#### **4. Kubernetes Deployment Configuration**
```bash
# Frontend deployment
Project-Stages/Project-Stage-1-Basic-CI-CD-Deploy/k8s/frontend-deployment.yaml
# Must have: imagePullPolicy: Always
# Must NOT have: runtime environment variables
```

### **🔧 Pre-Deployment Commands**

#### **For Local Development:**
```bash
cd src-code
docker compose up -d
# Uses .env file automatically
# Nginx routes to backend:3002
```

#### **For Kubernetes Deployment:**
```bash
cd src-code

# Build with Kubernetes-specific configuration
docker build --no-cache -f Dockerfile.frontend.k8s -t routeclouds/healthcare-frontend:v1.0 .
docker build --no-cache -f Dockerfile.backend -t routeclouds/healthcare-backend:v1.0 .

# Push images
docker push routeclouds/healthcare-frontend:v1.0
docker push routeclouds/healthcare-backend:v1.0

# Deploy to EKS
cd ../Project-Stages/Project-Stage-1-Basic-CI-CD-Deploy
./scripts/create-eks-cluster.sh
./scripts/deploy-to-eks.sh
```

### **🧪 Post-Deployment Verification**

#### **1. Verify No Localhost in JavaScript**
```bash
kubectl exec $(kubectl get pods -n healthcare -l app=healthcare-frontend -o jsonpath='{.items[0].metadata.name}') -n healthcare -- grep -o "localhost:300[0-9]" /usr/share/nginx/html/assets/*.js || echo "✅ SUCCESS: Using relative API path"
```

#### **2. Test Application Functionality**
```bash
# Get application URL
FRONTEND_URL=$(kubectl get service frontend-service -n healthcare -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

# Test pages
curl -s -o /dev/null -w "%{http_code}" http://$FRONTEND_URL/
curl -s -o /dev/null -w "%{http_code}" http://$FRONTEND_URL/doctors
curl -s -o /dev/null -w "%{http_code}" http://$FRONTEND_URL/login

# Test API
curl -s http://$FRONTEND_URL/api/health
curl -s http://$FRONTEND_URL/api/doctors | jq '.data.doctors | length'
```

#### **3. Expected Results**
- All HTTP requests return `200`
- API health shows `"database":"connected"`
- Doctors API returns count > 0
- Frontend pages load with content
- No JavaScript console errors

### **⚠️ Common Issues and Solutions**

#### **Issue: Frontend shows empty pages**
**Cause**: JavaScript still contains localhost references
**Solution**: Rebuild frontend with correct .env.k8s file

#### **Issue: API calls fail from browser**
**Cause**: Wrong environment variables or nginx configuration
**Solution**: Verify nginx routes to correct backend service name

#### **Issue: Old Docker images cached**
**Cause**: Kubernetes using cached images
**Solution**: Ensure `imagePullPolicy: Always` in deployment

### **🎯 Success Criteria**
- ✅ Find Doctor page shows doctors list
- ✅ User registration creates accounts
- ✅ Login functionality works
- ✅ All interactive features functional
- ✅ No JavaScript errors in browser console

---
**Created**: August 1, 2025  
**Last Updated**: August 1, 2025
