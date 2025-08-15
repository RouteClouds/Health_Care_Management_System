#!/bin/bash

# 🔍 Deployment Verification Script
# This script verifies that deployments are working correctly and pods are updated

set -e

echo "🔍 Deployment Verification - Healthcare Management System"
echo "======================================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
NAMESPACE="healthcare"

echo -e "${BLUE}📋 Configuration:${NC}"
echo "  Namespace: ${NAMESPACE}"
echo ""

# Check if kubectl is available and cluster is accessible
echo -e "${BLUE}🔍 Checking cluster connectivity...${NC}"
if ! kubectl cluster-info &>/dev/null; then
    echo -e "${RED}❌ Error: Cannot connect to Kubernetes cluster${NC}"
    echo "Please ensure:"
    echo "  1. kubectl is installed"
    echo "  2. EKS cluster is running"
    echo "  3. kubeconfig is properly configured"
    echo ""
    echo "To configure EKS access:"
    echo "  aws eks update-kubeconfig --name healthcare-cluster-stage2 --region us-east-1"
    exit 1
fi

echo -e "${GREEN}✅ Cluster connectivity verified${NC}"
echo ""

# Check if namespace exists
if ! kubectl get namespace ${NAMESPACE} &>/dev/null; then
    echo -e "${RED}❌ Namespace '${NAMESPACE}' not found${NC}"
    echo "Please create the namespace first:"
    echo "  kubectl create namespace ${NAMESPACE}"
    exit 1
fi

# Function to check pod age and status
check_pod_freshness() {
    echo -e "${BLUE}📊 Checking pod status and freshness...${NC}"
    
    # Get pod information
    PODS=$(kubectl get pods -n ${NAMESPACE} --no-headers)
    
    if [ -z "$PODS" ]; then
        echo -e "${RED}❌ No pods found in namespace ${NAMESPACE}${NC}"
        return 1
    fi
    
    echo "$PODS" | while read line; do
        POD_NAME=$(echo $line | awk '{print $1}')
        STATUS=$(echo $line | awk '{print $3}')
        AGE=$(echo $line | awk '{print $5}')
        
        # Check if pod is running
        if [ "$STATUS" = "Running" ]; then
            echo -e "${GREEN}✅ ${POD_NAME}: ${STATUS} (Age: ${AGE})${NC}"
        else
            echo -e "${YELLOW}⚠️  ${POD_NAME}: ${STATUS} (Age: ${AGE})${NC}"
        fi
    done
}

# Function to check image tags
check_image_tags() {
    echo -e "${BLUE}🏷️  Checking image tags in use...${NC}"
    
    kubectl get pods -n ${NAMESPACE} -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.containers[0].image}{"\n"}{end}' | while read line; do
        POD_NAME=$(echo $line | awk '{print $1}')
        IMAGE=$(echo $line | awk '{print $2}')
        
        if [[ $IMAGE == *":latest" ]]; then
            echo -e "${GREEN}✅ ${POD_NAME}: ${IMAGE}${NC}"
        else
            echo -e "${YELLOW}⚠️  ${POD_NAME}: ${IMAGE} (not using latest tag)${NC}"
        fi
    done
}

# Function to check deployment status
check_deployment_status() {
    echo -e "${BLUE}🚀 Checking deployment status...${NC}"
    
    DEPLOYMENTS=("healthcare-frontend" "healthcare-backend" "postgres-db")
    
    for DEPLOYMENT in "${DEPLOYMENTS[@]}"; do
        if kubectl get deployment ${DEPLOYMENT} -n ${NAMESPACE} &>/dev/null; then
            READY=$(kubectl get deployment ${DEPLOYMENT} -n ${NAMESPACE} -o jsonpath='{.status.readyReplicas}')
            DESIRED=$(kubectl get deployment ${DEPLOYMENT} -n ${NAMESPACE} -o jsonpath='{.spec.replicas}')
            
            if [ "$READY" = "$DESIRED" ]; then
                echo -e "${GREEN}✅ ${DEPLOYMENT}: ${READY}/${DESIRED} replicas ready${NC}"
            else
                echo -e "${YELLOW}⚠️  ${DEPLOYMENT}: ${READY}/${DESIRED} replicas ready${NC}"
            fi
        else
            echo -e "${RED}❌ ${DEPLOYMENT}: Deployment not found${NC}"
        fi
    done
}

# Function to check services
check_services() {
    echo -e "${BLUE}🌐 Checking services...${NC}"
    
    SERVICES=$(kubectl get services -n ${NAMESPACE} --no-headers)
    
    echo "$SERVICES" | while read line; do
        SERVICE_NAME=$(echo $line | awk '{print $1}')
        TYPE=$(echo $line | awk '{print $2}')
        EXTERNAL_IP=$(echo $line | awk '{print $4}')
        
        if [ "$TYPE" = "LoadBalancer" ]; then
            if [ "$EXTERNAL_IP" != "<pending>" ] && [ "$EXTERNAL_IP" != "<none>" ]; then
                echo -e "${GREEN}✅ ${SERVICE_NAME}: ${TYPE} (${EXTERNAL_IP})${NC}"
            else
                echo -e "${YELLOW}⚠️  ${SERVICE_NAME}: ${TYPE} (${EXTERNAL_IP})${NC}"
            fi
        else
            echo -e "${GREEN}✅ ${SERVICE_NAME}: ${TYPE}${NC}"
        fi
    done
}

# Function to test application connectivity
test_application() {
    echo -e "${BLUE}🌍 Testing application connectivity...${NC}"
    
    # Get frontend service URL
    FRONTEND_URL=$(kubectl get service frontend-service -n ${NAMESPACE} -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || echo "")
    
    if [ -n "$FRONTEND_URL" ] && [ "$FRONTEND_URL" != "null" ]; then
        echo "Testing frontend: http://${FRONTEND_URL}"
        
        # Test frontend
        if curl -s -I "http://${FRONTEND_URL}" | grep -q "200 OK"; then
            echo -e "${GREEN}✅ Frontend: Responding (200 OK)${NC}"
        else
            echo -e "${YELLOW}⚠️  Frontend: Not responding or error${NC}"
        fi
        
        # Test backend API
        if curl -s -I "http://${FRONTEND_URL}/api/health" | grep -q "200 OK"; then
            echo -e "${GREEN}✅ Backend API: Responding (200 OK)${NC}"
        else
            echo -e "${YELLOW}⚠️  Backend API: Not responding or error${NC}"
        fi
        
        echo ""
        echo -e "${GREEN}🌍 Application URL: http://${FRONTEND_URL}${NC}"
    else
        echo -e "${YELLOW}⚠️  LoadBalancer URL not yet available${NC}"
        echo "This is normal for new deployments. Wait a few minutes and try again."
    fi
}

# Function to check recent events
check_recent_events() {
    echo -e "${BLUE}📋 Recent events (last 10)...${NC}"
    
    kubectl get events -n ${NAMESPACE} --sort-by='.lastTimestamp' | tail -10 | while read line; do
        if echo "$line" | grep -q -i "error\|failed\|warning"; then
            echo -e "${YELLOW}⚠️  $line${NC}"
        else
            echo -e "${GREEN}ℹ️  $line${NC}"
        fi
    done
}

# Main verification process
echo -e "${BLUE}🔍 Starting deployment verification...${NC}"
echo ""

check_pod_freshness
echo ""

check_image_tags
echo ""

check_deployment_status
echo ""

check_services
echo ""

test_application
echo ""

check_recent_events
echo ""

# Summary
echo -e "${BLUE}📋 Verification Summary:${NC}"
echo ""

# Count running pods
RUNNING_PODS=$(kubectl get pods -n ${NAMESPACE} --no-headers | grep "Running" | wc -l)
TOTAL_PODS=$(kubectl get pods -n ${NAMESPACE} --no-headers | wc -l)

if [ "$RUNNING_PODS" -eq "$TOTAL_PODS" ] && [ "$TOTAL_PODS" -gt 0 ]; then
    echo -e "${GREEN}✅ All pods are running (${RUNNING_PODS}/${TOTAL_PODS})${NC}"
else
    echo -e "${YELLOW}⚠️  Some pods may have issues (${RUNNING_PODS}/${TOTAL_PODS} running)${NC}"
fi

# Check if using latest images
LATEST_IMAGES=$(kubectl get pods -n ${NAMESPACE} -o jsonpath='{range .items[*]}{.spec.containers[0].image}{"\n"}{end}' | grep -c ":latest" || echo "0")
TOTAL_IMAGES=$(kubectl get pods -n ${NAMESPACE} -o jsonpath='{range .items[*]}{.spec.containers[0].image}{"\n"}{end}' | grep -v "postgres" | wc -l)

if [ "$LATEST_IMAGES" -eq "$TOTAL_IMAGES" ]; then
    echo -e "${GREEN}✅ All application images using latest tag${NC}"
else
    echo -e "${YELLOW}⚠️  Some images not using latest tag${NC}"
fi

echo ""
echo -e "${BLUE}🔧 Useful commands for monitoring:${NC}"
echo "  kubectl get pods -n ${NAMESPACE} -w"
echo "  kubectl logs -f deployment/healthcare-frontend -n ${NAMESPACE}"
echo "  kubectl logs -f deployment/healthcare-backend -n ${NAMESPACE}"
echo "  kubectl get events -n ${NAMESPACE} --sort-by='.lastTimestamp'"
echo ""

if [ "$RUNNING_PODS" -eq "$TOTAL_PODS" ] && [ "$TOTAL_PODS" -gt 0 ]; then
    echo -e "${GREEN}🎉 Deployment verification completed successfully!${NC}"
    exit 0
else
    echo -e "${YELLOW}⚠️  Deployment verification completed with warnings${NC}"
    echo "Check the issues above and run troubleshooting commands if needed."
    exit 1
fi
