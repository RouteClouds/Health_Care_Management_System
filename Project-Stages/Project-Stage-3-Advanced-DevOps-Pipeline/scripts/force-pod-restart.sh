#!/bin/bash

# 🔄 Force Pod Restart Script
# This script forces pods to restart and pull the latest images

set -e

echo "🔄 Force Pod Restart - Healthcare Management System"
echo "=================================================="

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

# Show current deployment status
echo -e "${BLUE}📊 Current deployment status:${NC}"
kubectl get pods -n ${NAMESPACE} -o wide
echo ""

# Update deployments to use latest tag and force image pull
echo -e "${BLUE}🏷️  Updating deployments to use 'latest' tag with imagePullPolicy: Always${NC}"

# Update frontend deployment to use latest tag
kubectl patch deployment healthcare-frontend -n ${NAMESPACE} -p '{
  "spec": {
    "template": {
      "spec": {
        "containers": [
          {
            "name": "frontend",
            "image": "867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-frontend-stage3:latest",
            "imagePullPolicy": "Always"
          }
        ]
      }
    }
  }
}'

# Update backend deployment to use latest tag
kubectl patch deployment healthcare-backend -n ${NAMESPACE} -p '{
  "spec": {
    "template": {
      "spec": {
        "containers": [
          {
            "name": "backend",
            "image": "867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-backend-stage3:latest",
            "imagePullPolicy": "Always"
          }
        ]
      }
    }
  }
}'

# Also update init container for backend
kubectl patch deployment healthcare-backend -n ${NAMESPACE} -p '{
  "spec": {
    "template": {
      "spec": {
        "initContainers": [
          {
            "name": "db-init",
            "image": "867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-backend-stage3:latest"
          }
        ]
      }
    }
  }
}'

echo -e "${GREEN}✅ Deployments updated to use latest images${NC}"

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

echo ""
echo -e "${GREEN}🎉 Pod restart completed successfully!${NC}"
echo ""
echo -e "${BLUE}📋 Summary:${NC}"
echo "  ✅ Deployments updated to use 'latest' tag"
echo "  ✅ Image pull policy set to 'Always'"
echo "  ✅ Deployments restarted"
echo "  ✅ Rollout completed"
echo "  ✅ All pods running with latest images"
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
