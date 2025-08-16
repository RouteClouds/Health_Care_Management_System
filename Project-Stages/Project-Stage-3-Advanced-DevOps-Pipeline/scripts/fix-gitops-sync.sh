#!/bin/bash

echo "🔄 GitOps Sync Fix Script"
echo "========================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Configuration
ECR_REGISTRY="867344452513.dkr.ecr.us-east-1.amazonaws.com"
NAMESPACE="healthcare-stage3-dev"
GITOPS_DIR="gitops/environments/dev"

# Step 1: Check current state
log_info "Checking current deployment state..."
kubectl get pods -n $NAMESPACE

# Step 2: Get latest commit SHA
LATEST_SHA=$(git rev-parse HEAD)
log_info "Latest commit SHA: $LATEST_SHA"

# Step 3: Check current GitOps manifest
log_info "Current GitOps manifest:"
grep "image:" $GITOPS_DIR/frontend.yaml

# Step 4: Update GitOps manifests
log_info "Updating GitOps manifests..."
sed -i "s|image: .*healthcare-frontend-stage3:.*|image: $ECR_REGISTRY/healthcare-frontend-stage3:$LATEST_SHA|g" $GITOPS_DIR/frontend.yaml
sed -i "s|image: .*healthcare-backend-stage3:.*|image: $ECR_REGISTRY/healthcare-backend-stage3:$LATEST_SHA|g" $GITOPS_DIR/backend.yaml

# Step 5: Verify updates
log_info "Updated manifests:"
echo "Frontend:" && grep "image:" $GITOPS_DIR/frontend.yaml
echo "Backend:" && grep "image:" $GITOPS_DIR/backend.yaml

# Step 6: Apply updates
log_info "Applying updated manifests..."
kubectl apply -f $GITOPS_DIR/

# Step 7: Monitor deployment
log_info "Monitoring deployment..."
kubectl rollout status deployment/healthcare-frontend-stage3 -n $NAMESPACE --timeout=300s
kubectl rollout status deployment/healthcare-backend-stage3 -n $NAMESPACE --timeout=300s

# Step 8: Verify health
log_info "Verifying application health..."
kubectl get pods -n $NAMESPACE

# Step 9: Test connectivity
log_info "Testing connectivity..."
FRONTEND_URL=$(kubectl get svc frontend-stage3-svc -n $NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
if curl -s -I http://$FRONTEND_URL | grep -q "200 OK"; then
    log_success "✅ Frontend accessible: http://$FRONTEND_URL"
else
    log_warning "⚠️ Frontend may still be starting up"
fi

if curl -s -I http://$FRONTEND_URL/api/health | grep -q "200 OK"; then
    log_success "✅ Backend API accessible via frontend proxy"
else
    log_warning "⚠️ Backend API may still be starting up"
fi

log_success "🎉 GitOps sync fix completed!"
echo ""
echo "Next steps:"
echo "1. Monitor pods: kubectl get pods -n $NAMESPACE -w"
echo "2. Check logs: kubectl logs deployment/healthcare-frontend-stage3 -n $NAMESPACE"
echo "3. Test app: curl -I http://$FRONTEND_URL"
