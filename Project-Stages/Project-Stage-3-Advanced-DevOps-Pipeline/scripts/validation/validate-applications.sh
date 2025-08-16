#!/bin/bash

echo "🚀 Application Validation Script"
echo "==============================="

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
NAMESPACE="healthcare-stage3-dev"

# Validation counters
TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0

validate_check() {
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    if [ $1 -eq 0 ]; then
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
        log_success "$2"
    else
        FAILED_CHECKS=$((FAILED_CHECKS + 1))
        log_error "$2"
    fi
}

log_info "Starting application validation..."

# 1. Validate deployments exist
log_info "1. Validating deployments..."
kubectl get deployment healthcare-frontend-stage3 -n $NAMESPACE > /dev/null 2>&1
validate_check $? "Frontend deployment exists"

kubectl get deployment healthcare-backend-stage3 -n $NAMESPACE > /dev/null 2>&1
validate_check $? "Backend deployment exists"

# 2. Validate deployment status
log_info "2. Validating deployment status..."
FRONTEND_READY=$(kubectl get deployment healthcare-frontend-stage3 -n $NAMESPACE -o jsonpath='{.status.readyReplicas}' 2>/dev/null || echo "0")
FRONTEND_DESIRED=$(kubectl get deployment healthcare-frontend-stage3 -n $NAMESPACE -o jsonpath='{.spec.replicas}' 2>/dev/null || echo "0")

if [ "$FRONTEND_READY" = "$FRONTEND_DESIRED" ] && [ "$FRONTEND_READY" -gt 0 ]; then
    validate_check 0 "Frontend deployment is ready ($FRONTEND_READY/$FRONTEND_DESIRED replicas)"
else
    validate_check 1 "Frontend deployment not ready ($FRONTEND_READY/$FRONTEND_DESIRED replicas)"
fi

BACKEND_READY=$(kubectl get deployment healthcare-backend-stage3 -n $NAMESPACE -o jsonpath='{.status.readyReplicas}' 2>/dev/null || echo "0")
BACKEND_DESIRED=$(kubectl get deployment healthcare-backend-stage3 -n $NAMESPACE -o jsonpath='{.spec.replicas}' 2>/dev/null || echo "0")

if [ "$BACKEND_READY" = "$BACKEND_DESIRED" ] && [ "$BACKEND_READY" -gt 0 ]; then
    validate_check 0 "Backend deployment is ready ($BACKEND_READY/$BACKEND_DESIRED replicas)"
else
    validate_check 1 "Backend deployment not ready ($BACKEND_READY/$BACKEND_DESIRED replicas)"
fi

# 3. Validate pods are running
log_info "3. Validating pod status..."
FRONTEND_PODS_RUNNING=$(kubectl get pods -n $NAMESPACE -l app=healthcare-frontend-stage3 --field-selector=status.phase=Running --no-headers | wc -l)
BACKEND_PODS_RUNNING=$(kubectl get pods -n $NAMESPACE -l app=healthcare-backend-stage3 --field-selector=status.phase=Running --no-headers | wc -l)

if [ "$FRONTEND_PODS_RUNNING" -gt 0 ]; then
    validate_check 0 "Frontend pods are running ($FRONTEND_PODS_RUNNING pods)"
else
    validate_check 1 "No frontend pods are running"
fi

if [ "$BACKEND_PODS_RUNNING" -gt 0 ]; then
    validate_check 0 "Backend pods are running ($BACKEND_PODS_RUNNING pods)"
else
    validate_check 1 "No backend pods are running"
fi

# 4. Validate services
log_info "4. Validating services..."
kubectl get service frontend-stage3-svc -n $NAMESPACE > /dev/null 2>&1
validate_check $? "Frontend service exists"

kubectl get service backend-stage3-svc -n $NAMESPACE > /dev/null 2>&1
validate_check $? "Backend service exists"

# 5. Validate service endpoints
log_info "5. Validating service endpoints..."
FRONTEND_ENDPOINTS=$(kubectl get endpoints frontend-stage3-svc -n $NAMESPACE -o jsonpath='{.subsets[0].addresses}' 2>/dev/null)
if [ -n "$FRONTEND_ENDPOINTS" ] && [ "$FRONTEND_ENDPOINTS" != "null" ]; then
    validate_check 0 "Frontend service has endpoints"
else
    validate_check 1 "Frontend service has no endpoints"
fi

BACKEND_ENDPOINTS=$(kubectl get endpoints backend-stage3-svc -n $NAMESPACE -o jsonpath='{.subsets[0].addresses}' 2>/dev/null)
if [ -n "$BACKEND_ENDPOINTS" ] && [ "$BACKEND_ENDPOINTS" != "null" ]; then
    validate_check 0 "Backend service has endpoints"
else
    validate_check 1 "Backend service has no endpoints"
fi

# 6. Validate load balancer
log_info "6. Validating load balancer..."
LB_HOSTNAME=$(kubectl get service frontend-stage3-svc -n $NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null)
if [ -n "$LB_HOSTNAME" ]; then
    validate_check 0 "Load balancer hostname is available: $LB_HOSTNAME"
    
    # Test load balancer connectivity
    log_info "6.1. Testing load balancer connectivity..."
    if curl -s --max-time 10 "http://$LB_HOSTNAME" > /dev/null 2>&1; then
        validate_check 0 "Load balancer is accessible"
    else
        validate_check 1 "Load balancer is not accessible"
    fi
else
    validate_check 1 "Load balancer hostname not available"
fi

# 7. Validate image tags
log_info "7. Validating image tags..."
FRONTEND_IMAGE=$(kubectl get deployment healthcare-frontend-stage3 -n $NAMESPACE -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null)
BACKEND_IMAGE=$(kubectl get deployment healthcare-backend-stage3 -n $NAMESPACE -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null)

if echo "$FRONTEND_IMAGE" | grep -q "healthcare-frontend-stage3:"; then
    validate_check 0 "Frontend image tag is valid: $FRONTEND_IMAGE"
else
    validate_check 1 "Frontend image tag is invalid or missing"
fi

if echo "$BACKEND_IMAGE" | grep -q "healthcare-backend-stage3:"; then
    validate_check 0 "Backend image tag is valid: $BACKEND_IMAGE"
else
    validate_check 1 "Backend image tag is invalid or missing"
fi

# 8. Validate resource limits
log_info "8. Validating resource limits..."
FRONTEND_LIMITS=$(kubectl get deployment healthcare-frontend-stage3 -n $NAMESPACE -o jsonpath='{.spec.template.spec.containers[0].resources.limits}' 2>/dev/null)
BACKEND_LIMITS=$(kubectl get deployment healthcare-backend-stage3 -n $NAMESPACE -o jsonpath='{.spec.template.spec.containers[0].resources.limits}' 2>/dev/null)

if [ -n "$FRONTEND_LIMITS" ] && [ "$FRONTEND_LIMITS" != "null" ]; then
    validate_check 0 "Frontend resource limits are configured"
else
    validate_check 1 "Frontend resource limits not configured"
fi

if [ -n "$BACKEND_LIMITS" ] && [ "$BACKEND_LIMITS" != "null" ]; then
    validate_check 0 "Backend resource limits are configured"
else
    validate_check 1 "Backend resource limits not configured"
fi

# 9. Validate horizontal pod autoscaler
log_info "9. Validating horizontal pod autoscaler..."
kubectl get hpa healthcare-frontend-stage3-hpa -n $NAMESPACE > /dev/null 2>&1
validate_check $? "Frontend HPA is configured"

kubectl get hpa healthcare-backend-stage3-hpa -n $NAMESPACE > /dev/null 2>&1
validate_check $? "Backend HPA is configured"

# 10. Validate secrets
log_info "10. Validating secrets..."
kubectl get secret database-credentials-stage3 -n $NAMESPACE > /dev/null 2>&1
validate_check $? "Database credentials secret exists"

# 11. Validate configmaps
log_info "11. Validating configmaps..."
CONFIGMAPS=$(kubectl get configmaps -n $NAMESPACE --no-headers | wc -l)
if [ "$CONFIGMAPS" -gt 0 ]; then
    validate_check 0 "ConfigMaps are present ($CONFIGMAPS found)"
else
    validate_check 1 "No ConfigMaps found"
fi

# Summary
echo ""
echo "==============================="
echo "📊 Application Validation Summary"
echo "==============================="
echo "Total Checks: $TOTAL_CHECKS"
echo "Passed: $PASSED_CHECKS"
echo "Failed: $FAILED_CHECKS"

if [ $FAILED_CHECKS -eq 0 ]; then
    log_success "🎉 All application validation checks passed!"
    echo ""
    echo "✅ Applications are deployed and running correctly"
    exit 0
else
    log_error "❌ $FAILED_CHECKS application validation checks failed"
    echo ""
    echo "🔧 Please fix the failed checks before proceeding"
    exit 1
fi
