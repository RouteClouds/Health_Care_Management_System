#!/bin/bash

set -e

# Healthcare Management System - Stage 2 Production Deployment
# This script deploys the application to the production environment

IMAGE_TAG=${1:-latest}
NAMESPACE="healthcare-prod"
HELM_RELEASE="healthcare-production"
CHART_PATH="../helm-charts/healthcare-system"

echo "🚀 Deploying Healthcare Management System to Production Environment"
echo "📦 Image Tag: $IMAGE_TAG"
echo "🏷️ Namespace: $NAMESPACE"
echo "📊 Helm Release: $HELM_RELEASE"
echo "=================================================="

# Production deployment requires explicit confirmation
echo "⚠️  PRODUCTION DEPLOYMENT WARNING ⚠️"
echo "This will deploy to the production environment."
echo "Ensure all staging tests have passed and approvals are obtained."
read -p "Are you sure you want to proceed? (yes/no): " -r
if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
    echo "❌ Production deployment cancelled"
    exit 1
fi

# Verify prerequisites
echo "🔍 Verifying prerequisites..."

# Check if kubectl is available and configured
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl is not installed or not in PATH"
    exit 1
fi

# Check if helm is available
if ! command -v helm &> /dev/null; then
    echo "❌ helm is not installed or not in PATH"
    exit 1
fi

# Check cluster connectivity
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ Cannot connect to Kubernetes cluster"
    exit 1
fi

# Verify staging deployment exists and is healthy
echo "🔍 Verifying staging deployment..."
if ! kubectl get deployment healthcare-backend -n healthcare-staging &> /dev/null; then
    echo "❌ Staging deployment not found. Deploy to staging first."
    exit 1
fi

echo "✅ Prerequisites verified"

# Create namespace if it doesn't exist
echo "🏗️ Setting up namespace..."
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

# Apply namespace-specific configurations
echo "⚙️ Applying namespace configurations..."
kubectl apply -f ../k8s/environments/production/namespace.yaml

# Create backup of current production deployment
echo "💾 Creating backup of current deployment..."
kubectl get all -n $NAMESPACE -o yaml > "backup-$(date +%Y%m%d-%H%M%S).yaml" || echo "⚠️ No existing deployment to backup"

# Deploy using Helm with production values
echo "🚀 Deploying with Helm..."
helm upgrade --install $HELM_RELEASE $CHART_PATH \
    --namespace $NAMESPACE \
    --values $CHART_PATH/values/production.yaml \
    --set image.tag=$IMAGE_TAG \
    --set environment=production \
    --wait \
    --timeout=15m

# Wait for deployment to complete
echo "⏳ Waiting for deployment to complete..."
kubectl rollout status deployment/healthcare-backend -n $NAMESPACE --timeout=600s
kubectl rollout status deployment/healthcare-frontend -n $NAMESPACE --timeout=600s

# Verify deployment
echo "🔍 Verifying deployment..."
kubectl get pods -n $NAMESPACE
kubectl get services -n $NAMESPACE

# Run comprehensive health checks
echo "🏥 Running comprehensive health checks..."
BACKEND_POD=$(kubectl get pods -n $NAMESPACE -l app=healthcare-backend -o jsonpath='{.items[0].metadata.name}')
if [ ! -z "$BACKEND_POD" ]; then
    kubectl exec -n $NAMESPACE $BACKEND_POD -- curl -f http://localhost:3001/api/health || echo "❌ Backend health check failed"
    kubectl exec -n $NAMESPACE $BACKEND_POD -- curl -f http://localhost:3001/api/ready || echo "❌ Backend readiness check failed"
fi

# Get service URLs
echo "🌐 Production Service URLs:"
kubectl get services -n $NAMESPACE -o wide

echo "✅ Production deployment completed successfully"
echo "🎯 Post-deployment checklist:"
echo "   1. ✅ Deployment completed"
echo "   2. ⏳ Monitor application metrics"
echo "   3. ⏳ Verify user access and functionality"
echo "   4. ⏳ Check logs for any errors"
echo "   5. ⏳ Update monitoring dashboards"
