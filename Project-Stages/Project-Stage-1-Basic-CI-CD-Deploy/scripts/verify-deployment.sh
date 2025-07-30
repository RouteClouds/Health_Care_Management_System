#!/bin/bash

# Stage 1 - Verify Deployment Script
# Health Care Management System - Basic CI/CD Deployment

set -e

echo "🔍 Stage 1: Verifying Health Care Management System Deployment"
echo "=============================================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Check if kubectl is configured
if ! kubectl cluster-info &> /dev/null; then
    print_error "kubectl is not configured or cluster is not accessible"
    exit 1
fi

echo ""
print_info "=== CLUSTER VERIFICATION ==="

# Check cluster info
print_info "Cluster information:"
kubectl cluster-info

# Check nodes
print_info "Cluster nodes:"
kubectl get nodes -o wide

# Check cluster version
print_info "Cluster version:"
kubectl version --short

echo ""
print_info "=== DEPLOYMENT VERIFICATION ==="

# Check namespace
print_info "Checking healthcare namespace..."
if kubectl get namespace healthcare &> /dev/null; then
    print_status "Healthcare namespace exists"
else
    print_error "Healthcare namespace not found"
    exit 1
fi

# Check deployments
print_info "Checking deployments..."
kubectl get deployments -n healthcare

# Verify all deployments are ready
DEPLOYMENTS=("postgres-db" "healthcare-backend" "healthcare-frontend")
for deployment in "${DEPLOYMENTS[@]}"; do
    if kubectl get deployment $deployment -n healthcare &> /dev/null; then
        READY=$(kubectl get deployment $deployment -n healthcare -o jsonpath='{.status.readyReplicas}')
        DESIRED=$(kubectl get deployment $deployment -n healthcare -o jsonpath='{.spec.replicas}')
        if [ "$READY" = "$DESIRED" ]; then
            print_status "$deployment: $READY/$DESIRED replicas ready"
        else
            print_warning "$deployment: $READY/$DESIRED replicas ready"
        fi
    else
        print_error "$deployment: deployment not found"
    fi
done

echo ""
print_info "=== POD VERIFICATION ==="

# Check pods
print_info "Checking pods..."
kubectl get pods -n healthcare -o wide

# Check pod status
print_info "Pod status details:"
for pod in $(kubectl get pods -n healthcare -o jsonpath='{.items[*].metadata.name}'); do
    STATUS=$(kubectl get pod $pod -n healthcare -o jsonpath='{.status.phase}')
    if [ "$STATUS" = "Running" ]; then
        print_status "$pod: $STATUS"
    else
        print_warning "$pod: $STATUS"
        # Show pod events if not running
        kubectl describe pod $pod -n healthcare | tail -10
    fi
done

echo ""
print_info "=== SERVICE VERIFICATION ==="

# Check services
print_info "Checking services..."
kubectl get services -n healthcare

# Check service endpoints
print_info "Service endpoints:"
kubectl get endpoints -n healthcare

# Get external IP
EXTERNAL_IP=$(kubectl get service frontend-service -n healthcare -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || echo "")

if [ ! -z "$EXTERNAL_IP" ] && [ "$EXTERNAL_IP" != "null" ]; then
    print_status "External IP assigned: $EXTERNAL_IP"

    echo ""
    print_info "=== APPLICATION VERIFICATION ==="

    # Test application access
    print_info "Testing application access..."

    # Test main page
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://$EXTERNAL_IP || echo "000")
    if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "301" ] || [ "$HTTP_CODE" = "302" ]; then
        print_status "Main application accessible (HTTP $HTTP_CODE)"
    else
        print_warning "Main application returned HTTP $HTTP_CODE"
    fi

    # Test API health endpoint
    API_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://$EXTERNAL_IP/api/health || echo "000")
    if [ "$API_CODE" = "200" ]; then
        print_status "API health endpoint accessible (HTTP $API_CODE)"
    else
        print_warning "API health endpoint returned HTTP $API_CODE"
    fi

    echo ""
    print_info "Application URLs:"
    echo "🌐 Main Application: http://$EXTERNAL_IP"
    echo "🔍 Health Check: http://$EXTERNAL_IP/health"
    echo "🔌 API Endpoint: http://$EXTERNAL_IP/api"

else
    print_warning "External IP not yet assigned or still pending"
    print_info "Check status with: kubectl get service frontend-service -n healthcare"
fi

echo ""
print_info "=== RESOURCE USAGE ==="

# Check resource usage
print_info "Node resource usage:"
kubectl top nodes 2>/dev/null || print_warning "Metrics server not available"

print_info "Pod resource usage:"
kubectl top pods -n healthcare 2>/dev/null || print_warning "Metrics server not available"

echo ""
print_info "=== VERIFICATION SUMMARY ==="

# Summary
echo "Deployment Status Summary:"
echo "========================="
kubectl get all -n healthcare

echo ""
print_info "=== NEXT STEPS ==="

if [ ! -z "$EXTERNAL_IP" ] && [ "$EXTERNAL_IP" != "null" ]; then
    print_status "✅ Deployment verification completed successfully!"
    echo ""
    print_info "Recommended next steps:"
    echo "1. 🌐 Open http://$EXTERNAL_IP in your browser"
    echo "2. 👤 Test user registration and login"
    echo "3. 👨‍⚕️ Verify doctor listings display"
    echo "4. 📅 Test appointment booking functionality"
    echo "5. 💰 Monitor AWS costs in the console"
    echo "6. 📊 Plan for Stage 2 automation"
else
    print_warning "⚠️  Deployment partially complete - waiting for external IP"
    echo ""
    print_info "Wait a few more minutes and run this script again, or check:"
    echo "kubectl get service frontend-service -n healthcare -w"
fi

echo ""
print_info "For troubleshooting, check:"
echo "• Pod logs: kubectl logs <pod-name> -n healthcare"
echo "• Pod details: kubectl describe pod <pod-name> -n healthcare"
echo "• Service details: kubectl describe service <service-name> -n healthcare"

echo ""
print_status "Verification completed!"