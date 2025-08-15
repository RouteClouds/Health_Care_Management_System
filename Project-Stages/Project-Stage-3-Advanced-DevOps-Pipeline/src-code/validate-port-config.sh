#!/bin/bash

# Healthcare Management System - Port Configuration Validator
# This script validates that all port configurations are correct and consistent
# Prevents frontend-backend communication issues in Kubernetes

set -e

echo "🔍 Healthcare Management System - Port Configuration Validator"
echo "============================================================="
echo ""

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    local status=$1
    local message=$2
    if [ "$status" = "SUCCESS" ]; then
        echo -e "${GREEN}✅ $message${NC}"
    elif [ "$status" = "ERROR" ]; then
        echo -e "${RED}❌ $message${NC}"
    elif [ "$status" = "WARNING" ]; then
        echo -e "${YELLOW}⚠️  $message${NC}"
    elif [ "$status" = "INFO" ]; then
        echo -e "${BLUE}ℹ️  $message${NC}"
    fi
}

ERRORS=0
WARNINGS=0

echo "🔧 Checking Frontend Configuration..."
echo "------------------------------------"

# Check .env.k8s file
if [ -f "frontend/.env.k8s" ]; then
    if grep -q "VITE_API_BASE_URL=/api" frontend/.env.k8s; then
        print_status "SUCCESS" "Frontend .env.k8s has correct API base URL (/api)"
    else
        print_status "ERROR" "Frontend .env.k8s missing or incorrect VITE_API_BASE_URL=/api"
        ERRORS=$((ERRORS + 1))
    fi
else
    print_status "ERROR" "Frontend .env.k8s file missing"
    ERRORS=$((ERRORS + 1))
fi

# Check API service configuration
if [ -f "frontend/src/services/api.ts" ]; then
    if grep -q "localhost:3002" frontend/src/services/api.ts; then
        print_status "WARNING" "Frontend API service has localhost:3002 fallback (acceptable for local dev)"
        WARNINGS=$((WARNINGS + 1))
    fi
    if grep -q "VITE_API_BASE_URL" frontend/src/services/api.ts; then
        print_status "SUCCESS" "Frontend API service uses VITE_API_BASE_URL environment variable"
    else
        print_status "ERROR" "Frontend API service not using VITE_API_BASE_URL"
        ERRORS=$((ERRORS + 1))
    fi
else
    print_status "ERROR" "Frontend API service file missing"
    ERRORS=$((ERRORS + 1))
fi

echo ""
echo "🔧 Checking Backend Configuration..."
echo "-----------------------------------"

# Check backend port configuration
if [ -f "../k8s/backend-deployment.yaml" ]; then
    if grep -q "containerPort: 3002" ../k8s/backend-deployment.yaml; then
        print_status "SUCCESS" "Backend deployment uses correct port 3002"
    else
        print_status "ERROR" "Backend deployment missing or incorrect containerPort"
        ERRORS=$((ERRORS + 1))
    fi
    
    if grep -q "port: 3002" ../k8s/backend-deployment.yaml; then
        print_status "SUCCESS" "Backend service exposes correct port 3002"
    else
        print_status "ERROR" "Backend service missing or incorrect port"
        ERRORS=$((ERRORS + 1))
    fi
else
    print_status "ERROR" "Backend deployment file missing"
    ERRORS=$((ERRORS + 1))
fi

echo ""
echo "🔧 Checking Nginx Configuration..."
echo "---------------------------------"

# Check nginx configuration
if [ -f "nginx/nginx.k8s.conf" ]; then
    if grep -q "proxy_pass http://backend" nginx/nginx.k8s.conf && grep -q "backend-service:3002" nginx/nginx.k8s.conf; then
        print_status "SUCCESS" "Nginx proxies to correct backend service:3002"
    else
        print_status "ERROR" "Nginx proxy configuration incorrect"
        ERRORS=$((ERRORS + 1))
    fi
else
    print_status "ERROR" "Nginx Kubernetes configuration missing"
    ERRORS=$((ERRORS + 1))
fi

echo ""
echo "🔧 Checking Kubernetes Manifests..."
echo "-----------------------------------"

# Check frontend deployment
if [ -f "../k8s/frontend-deployment.yaml" ]; then
    if grep -q "containerPort: 80" ../k8s/frontend-deployment.yaml; then
        print_status "SUCCESS" "Frontend deployment uses correct port 80"
    else
        print_status "ERROR" "Frontend deployment missing or incorrect containerPort"
        ERRORS=$((ERRORS + 1))
    fi
    
    if grep -q "targetPort: 80" ../k8s/frontend-deployment.yaml; then
        print_status "SUCCESS" "Frontend service targets correct port 80"
    else
        print_status "ERROR" "Frontend service missing or incorrect targetPort"
        ERRORS=$((ERRORS + 1))
    fi
else
    print_status "ERROR" "Frontend deployment file missing"
    ERRORS=$((ERRORS + 1))
fi

echo ""
echo "🔧 Checking Docker Compose Configuration..."
echo "------------------------------------------"

# Check docker-compose.yml
if [ -f "docker-compose.yml" ]; then
    if grep -q "5173:80" docker-compose.yml; then
        print_status "SUCCESS" "Docker Compose maps frontend to port 5173"
    else
        print_status "WARNING" "Docker Compose frontend port mapping may be incorrect"
        WARNINGS=$((WARNINGS + 1))
    fi
    
    if grep -q "3002:3002" docker-compose.yml; then
        print_status "SUCCESS" "Docker Compose maps backend to port 3002"
    else
        print_status "WARNING" "Docker Compose backend port mapping may be incorrect"
        WARNINGS=$((WARNINGS + 1))
    fi
else
    print_status "WARNING" "Docker Compose file missing"
    WARNINGS=$((WARNINGS + 1))
fi

echo ""
echo "🔧 Checking for Hardcoded Port Issues..."
echo "----------------------------------------"

# Check for hardcoded localhost:3000 (exclude validation scripts)
if grep -r "localhost:3000" . --exclude-dir=node_modules --exclude-dir=dist --exclude-dir=coverage --exclude="validate-*.sh" 2>/dev/null; then
    print_status "ERROR" "Found hardcoded localhost:3000 references"
    ERRORS=$((ERRORS + 1))
else
    print_status "SUCCESS" "No hardcoded localhost:3000 references found"
fi

# Check for incorrect port 3000 in configs (exclude monitoring services like Grafana)
if grep -r "targetPort: 3000" ../k8s/ --exclude-dir=monitoring 2>/dev/null; then
    print_status "ERROR" "Found incorrect targetPort: 3000 in Kubernetes manifests"
    ERRORS=$((ERRORS + 1))
else
    print_status "SUCCESS" "No incorrect targetPort: 3000 found in Kubernetes manifests (monitoring excluded)"
fi

echo ""
echo "📋 Validation Summary"
echo "===================="

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    print_status "SUCCESS" "All port configurations are correct! Frontend-backend communication should work."
    echo ""
    echo "🚀 Configuration Summary:"
    echo "   ✅ Frontend runs on port 80 in containers"
    echo "   ✅ Backend runs on port 3002 in containers"
    echo "   ✅ Nginx proxies /api to backend-service:3002"
    echo "   ✅ Frontend uses /api for API calls (relative URLs)"
    echo "   ✅ No hardcoded localhost references in production code"
    exit 0
elif [ $ERRORS -eq 0 ]; then
    print_status "WARNING" "Port configuration validation completed with $WARNINGS warning(s)."
    echo ""
    echo "🔧 Warnings can usually be ignored for local development."
    exit 0
else
    print_status "ERROR" "Port configuration validation failed with $ERRORS error(s) and $WARNINGS warning(s)."
    echo ""
    echo "🛠️  Required Actions:"
    echo "   1. Fix all errors listed above"
    echo "   2. Ensure frontend uses /api for API calls"
    echo "   3. Verify nginx proxy configuration"
    echo "   4. Check Kubernetes service configurations"
    echo "   5. Run this script again to validate"
    exit 1
fi
