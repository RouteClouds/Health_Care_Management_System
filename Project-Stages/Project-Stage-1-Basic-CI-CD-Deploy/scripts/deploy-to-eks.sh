#!/bin/bash

# Stage 1 - Deploy to EKS Script
# Health Care Management System - Basic CI/CD Deployment

set -e

echo "🚀 Stage 1: Deploying Health Care Management System to EKS"
echo "=========================================================="

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
    print_info "Please run: aws eks update-kubeconfig --region us-east-1 --name healthcare-cluster"
    exit 1
fi

# Check if k8s directory exists
if [ ! -d "k8s" ]; then
    print_error "k8s directory not found. Please run this script from the Stage 1 directory."
    exit 1
fi

print_info "Current cluster context:"
kubectl config current-context

print_info "Cluster nodes:"
kubectl get nodes

echo ""
print_info "Deploying application components..."

# Deploy namespace
print_info "Creating healthcare namespace..."
kubectl apply -f k8s/namespace.yaml
print_status "Namespace created"

# Deploy database
print_info "Deploying PostgreSQL database..."
kubectl apply -f k8s/database-deployment.yaml
print_status "Database deployment created"

# Wait for database to be ready
print_info "Waiting for database to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/postgres-db -n healthcare
print_status "Database is ready"

# Deploy backend
print_info "Deploying backend API..."
kubectl apply -f k8s/backend-deployment.yaml
print_status "Backend deployment created"

# Wait for backend to be ready
print_info "Waiting for backend to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/healthcare-backend -n healthcare
print_status "Backend is ready"

# Deploy frontend
print_info "Deploying frontend application..."
kubectl apply -f k8s/frontend-deployment.yaml
print_status "Frontend deployment created"

# Wait for frontend to be ready
print_info "Waiting for frontend to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/healthcare-frontend -n healthcare
print_status "Frontend is ready"

# Initialize database automatically
echo ""
print_info "Initializing database with schema and sample data..."
if [ -f "scripts/init-database.sh" ]; then
    ./scripts/init-database.sh
    if [ $? -eq 0 ]; then
        print_status "Database initialized successfully"
    else
        print_warning "Database initialization had issues, but deployment continues"
    fi
else
    print_warning "Database initialization script not found, skipping..."
fi

echo ""
print_info "Checking deployment status..."

# Check all deployments
kubectl get deployments -n healthcare

# Check all pods
kubectl get pods -n healthcare

# Check all services
kubectl get services -n healthcare

echo ""
print_info "Getting external access URL..."

# Wait for external IP
print_info "Waiting for external IP to be assigned (this may take 5-10 minutes)..."
kubectl get service frontend-service -n healthcare

echo ""
print_warning "Waiting for Load Balancer to be provisioned..."
echo "This may take 5-10 minutes. You can monitor progress with:"
echo "kubectl get service frontend-service -n healthcare -w"

# Try to get external IP
EXTERNAL_IP=""
for i in {1..30}; do
    EXTERNAL_IP=$(kubectl get service frontend-service -n healthcare -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || echo "")
    if [ ! -z "$EXTERNAL_IP" ] && [ "$EXTERNAL_IP" != "null" ]; then
        break
    fi
    echo "Waiting for external IP... (attempt $i/30)"
    sleep 30
done

if [ ! -z "$EXTERNAL_IP" ] && [ "$EXTERNAL_IP" != "null" ]; then
    print_status "External IP assigned: $EXTERNAL_IP"
    echo ""
    print_info "Application URLs:"
    echo "🌐 Main Application: http://$EXTERNAL_IP"
    echo "🔍 Health Check: http://$EXTERNAL_IP/health"
    echo "🔌 API Endpoint: http://$EXTERNAL_IP/api"
    echo ""
    print_info "Testing application access..."
    if curl -s -o /dev/null -w "%{http_code}" http://$EXTERNAL_IP | grep -q "200\|301\|302"; then
        print_status "Application is accessible!"
    else
        print_warning "Application may still be starting up. Please wait a few more minutes."
    fi
else
    print_warning "External IP not yet assigned. Check status with:"
    echo "kubectl get service frontend-service -n healthcare"
fi

echo ""
print_info "Deployment summary:"
echo "==================="
kubectl get all -n healthcare

echo ""
print_status "Stage 1 deployment completed!"
print_info "Next steps:"
echo "1. Test the application in your browser"
echo "2. Verify all functionality works"
echo "3. Monitor costs in AWS console"
echo "4. Plan for Stage 2 automation"

echo ""
print_warning "To clean up resources later, run:"
echo "./scripts/cleanup.sh"