#!/bin/bash

set -e

# Healthcare Management System - Stage 2 Staging Deployment
# This script deploys the application to the staging environment

IMAGE_TAG=${1:-latest}
NAMESPACE="healthcare-staging"
HELM_RELEASE="healthcare-staging"
CHART_PATH="../helm-charts/healthcare-system"

echo "🚀 Deploying Healthcare Management System to Staging Environment"
echo "📦 Image Tag: $IMAGE_TAG"
echo "🏷️ Namespace: $NAMESPACE"
echo "📊 Helm Release: $HELM_RELEASE"
echo "=================================================="

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

echo "✅ Prerequisites verified"

# Create namespace if it doesn't exist
echo "🏗️ Setting up namespace..."
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

# Apply namespace-specific configurations
echo "⚙️ Applying namespace configurations..."
kubectl apply -f ../k8s/environments/staging/namespace.yaml

# Deploy using Helm
echo "🚀 Deploying with Helm..."
helm upgrade --install $HELM_RELEASE $CHART_PATH \
    --namespace $NAMESPACE \
    --values $CHART_PATH/values/staging.yaml \
    --set image.tag=$IMAGE_TAG \
    --set environment=staging \
    --wait \
    --timeout=10m

# Wait for deployment to complete
echo "⏳ Waiting for deployment to complete..."
kubectl rollout status deployment/healthcare-backend -n $NAMESPACE --timeout=300s
kubectl rollout status deployment/healthcare-frontend -n $NAMESPACE --timeout=300s

# Verify deployment
echo "🔍 Verifying deployment..."
kubectl get pods -n $NAMESPACE
kubectl get services -n $NAMESPACE

# Run health checks
echo "🏥 Running health checks..."
BACKEND_POD=$(kubectl get pods -n $NAMESPACE -l app=healthcare-backend -o jsonpath='{.items[0].metadata.name}')
if [ ! -z "$BACKEND_POD" ]; then
    kubectl exec -n $NAMESPACE $BACKEND_POD -- curl -f http://localhost:3001/api/health || echo "⚠️ Backend health check failed"
fi

# Get service URLs
echo "🌐 Service URLs:"
kubectl get services -n $NAMESPACE -o wide

echo "✅ Staging deployment completed successfully"
echo "🎯 Next steps:"
echo "   1. Run E2E tests against staging environment"
echo "   2. Verify application functionality"
echo "   3. Promote to production if tests pass"
