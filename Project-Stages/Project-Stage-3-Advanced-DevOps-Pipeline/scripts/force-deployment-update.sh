#!/bin/bash

# 🚀 Force Deployment Update Script
# This script forces a deployment update by using dynamic image tags and restarting deployments

set -e

echo "🚀 Force Deployment Update - Healthcare Management System"
echo "========================================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
NAMESPACE="healthcare"
ECR_REGISTRY="867344452513.dkr.ecr.us-east-1.amazonaws.com"

# Generate unique image tag
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
GIT_SHA=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
IMAGE_TAG="v1.0-${GIT_SHA}-${TIMESTAMP}"

echo -e "${BLUE}📋 Configuration:${NC}"
echo "  Namespace: ${NAMESPACE}"
echo "  Docker Hub Username: ${DOCKERHUB_USERNAME}"
echo "  New Image Tag: ${IMAGE_TAG}"
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

# Check if namespace exists
if ! kubectl get namespace ${NAMESPACE} &>/dev/null; then
    echo -e "${YELLOW}⚠️  Namespace '${NAMESPACE}' not found. Creating...${NC}"
    kubectl create namespace ${NAMESPACE}
fi

echo -e "${GREEN}✅ Cluster connectivity verified${NC}"
echo ""

# Show current deployment status
echo -e "${BLUE}📊 Current deployment status:${NC}"
kubectl get pods -n ${NAMESPACE} -o wide
echo ""

# Update image tags in deployment files
echo -e "${BLUE}🏷️  Updating image tags to: ${IMAGE_TAG}${NC}"

# Create temporary copies of deployment files
TEMP_DIR=$(mktemp -d)
cp ../k8s/frontend-deployment.yaml ${TEMP_DIR}/
cp ../k8s/backend-deployment.yaml ${TEMP_DIR}/

# Update frontend deployment
sed -i "s|867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-frontend-stage3:v1.0|${DOCKERHUB_USERNAME}/healthcare-frontend:${IMAGE_TAG}|g" \
    ${TEMP_DIR}/frontend-deployment.yaml

# Update backend deployment  
sed -i "s|867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-backend-stage3:v1.0|${DOCKERHUB_USERNAME}/healthcare-backend:${IMAGE_TAG}|g" \
    ${TEMP_DIR}/backend-deployment.yaml

echo -e "${GREEN}✅ Image tags updated in temporary files${NC}"

# Apply the updated manifests
echo -e "${BLUE}🚀 Applying updated manifests...${NC}"
kubectl apply -f ${TEMP_DIR}/frontend-deployment.yaml
kubectl apply -f ${TEMP_DIR}/backend-deployment.yaml

# Force rollout restart to ensure new images are pulled
echo -e "${BLUE}🔄 Forcing rollout restart...${NC}"
kubectl rollout restart deployment/healthcare-frontend -n ${NAMESPACE}
kubectl rollout restart deployment/healthcare-backend -n ${NAMESPACE}

# Wait for rollout to complete
echo -e "${BLUE}⏳ Waiting for rollout to complete...${NC}"
kubectl rollout status deployment/healthcare-frontend -n ${NAMESPACE} --timeout=300s
kubectl rollout status deployment/healthcare-backend -n ${NAMESPACE} --timeout=300s

echo -e "${GREEN}✅ Rollout completed successfully${NC}"
echo ""

# Show updated deployment status
echo -e "${BLUE}📊 Updated deployment status:${NC}"
kubectl get pods -n ${NAMESPACE} -o wide
echo ""

# Show image tags in use
echo -e "${BLUE}🏷️  Image tags currently in use:${NC}"
kubectl get pods -n ${NAMESPACE} -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.containers[0].image}{"\n"}{end}' | column -t
echo ""

# Show services
echo -e "${BLUE}🌐 Services:${NC}"
kubectl get services -n ${NAMESPACE}
echo ""

# Get frontend URL
FRONTEND_URL=$(kubectl get service frontend-service -n ${NAMESPACE} -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || echo "Not available")
if [ "$FRONTEND_URL" != "Not available" ]; then
    echo -e "${GREEN}🌍 Frontend URL: http://${FRONTEND_URL}${NC}"
else
    echo -e "${YELLOW}⚠️  Frontend URL not yet available (LoadBalancer provisioning)${NC}"
fi

# Cleanup temporary files
rm -rf ${TEMP_DIR}

echo ""
echo -e "${GREEN}🎉 Deployment update completed successfully!${NC}"
echo ""
echo -e "${BLUE}📋 Summary:${NC}"
echo "  ✅ New image tag applied: ${IMAGE_TAG}"
echo "  ✅ Deployments restarted"
echo "  ✅ Rollout completed"
echo "  ✅ All pods running with new images"
echo ""
echo -e "${BLUE}🔍 To monitor the deployment:${NC}"
echo "  kubectl get pods -n ${NAMESPACE} -w"
echo ""
echo -e "${BLUE}🌐 To test the application:${NC}"
if [ "$FRONTEND_URL" != "Not available" ]; then
    echo "  curl -I http://${FRONTEND_URL}"
    echo "  Open: http://${FRONTEND_URL}"
else
    echo "  kubectl get services -n ${NAMESPACE}  # Get LoadBalancer URL"
fi
echo ""
echo -e "${BLUE}📊 To check logs:${NC}"
echo "  kubectl logs -f deployment/healthcare-frontend -n ${NAMESPACE}"
echo "  kubectl logs -f deployment/healthcare-backend -n ${NAMESPACE}"
