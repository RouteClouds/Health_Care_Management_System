#!/bin/bash

# Deploy Prometheus Stack for Healthcare System Monitoring
# This script deploys a comprehensive monitoring stack with Prometheus, Grafana, and AlertManager

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
MONITORING_DIR="${PROJECT_ROOT}/monitoring"
NAMESPACE="monitoring"
RELEASE_NAME="healthcare-monitoring"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    # Check if kubectl is available and configured
    if ! command -v kubectl &> /dev/null; then
        log_error "kubectl is not installed or not in PATH"
        exit 1
    fi
    
    # Check if helm is available
    if ! command -v helm &> /dev/null; then
        log_error "helm is not installed or not in PATH"
        exit 1
    fi
    
    # Check cluster connectivity
    if ! kubectl cluster-info &> /dev/null; then
        log_error "Cannot connect to Kubernetes cluster"
        exit 1
    fi
    
    # Check if EKS cluster is the correct one
    CLUSTER_NAME=$(kubectl config current-context | grep -o 'healthcare-eks-stage3-dev' || echo "")
    if [[ -z "$CLUSTER_NAME" ]]; then
        log_warning "Current cluster context doesn't appear to be healthcare-eks-stage3-dev"
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
    
    log_success "Prerequisites check completed"
}

# Add Helm repositories
add_helm_repos() {
    log_info "Adding Helm repositories..."
    
    # Add Prometheus community repo
    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
    
    # Update repositories
    helm repo update
    
    log_success "Helm repositories added and updated"
}

# Create namespace
create_namespace() {
    log_info "Creating monitoring namespace..."
    
    if kubectl get namespace "$NAMESPACE" &> /dev/null; then
        log_warning "Namespace $NAMESPACE already exists"
    else
        kubectl create namespace "$NAMESPACE"
        log_success "Namespace $NAMESPACE created"
    fi
    
    # Label namespace for monitoring
    kubectl label namespace "$NAMESPACE" monitoring=enabled --overwrite
}

# Deploy Prometheus stack
deploy_prometheus_stack() {
    log_info "Deploying Prometheus stack..."
    
    # Check if values file exists
    VALUES_FILE="${MONITORING_DIR}/prometheus/values.yaml"
    if [[ ! -f "$VALUES_FILE" ]]; then
        log_error "Values file not found: $VALUES_FILE"
        exit 1
    fi
    
    # Deploy using Helm
    helm upgrade --install "$RELEASE_NAME" prometheus-community/kube-prometheus-stack \
        --namespace "$NAMESPACE" \
        --values "$VALUES_FILE" \
        --wait \
        --timeout 10m
    
    log_success "Prometheus stack deployed successfully"
}

# Apply custom resources
apply_custom_resources() {
    log_info "Applying custom monitoring resources..."
    
    # Apply healthcare-specific alert rules
    if [[ -f "${MONITORING_DIR}/prometheus/healthcare-alerts.yaml" ]]; then
        kubectl apply -f "${MONITORING_DIR}/prometheus/healthcare-alerts.yaml"
        log_success "Healthcare alert rules applied"
    fi
    
    # Apply service monitors
    if [[ -f "${MONITORING_DIR}/prometheus/service-monitors.yaml" ]]; then
        kubectl apply -f "${MONITORING_DIR}/prometheus/service-monitors.yaml"
        log_success "Service monitors applied"
    fi
}

# Wait for pods to be ready
wait_for_pods() {
    log_info "Waiting for monitoring pods to be ready..."
    
    # Wait for Prometheus
    kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=prometheus \
        -n "$NAMESPACE" --timeout=300s
    
    # Wait for Grafana
    kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=grafana \
        -n "$NAMESPACE" --timeout=300s
    
    # Wait for AlertManager
    kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=alertmanager \
        -n "$NAMESPACE" --timeout=300s
    
    log_success "All monitoring pods are ready"
}

# Get access information
get_access_info() {
    log_info "Getting access information..."
    
    echo
    echo "=== MONITORING STACK ACCESS INFORMATION ==="
    echo
    
    # Grafana access
    echo "📊 GRAFANA DASHBOARD:"
    GRAFANA_LB=$(kubectl get service "${RELEASE_NAME}-grafana" -n "$NAMESPACE" \
        -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || echo "")
    
    if [[ -n "$GRAFANA_LB" ]]; then
        echo "   URL: http://${GRAFANA_LB}"
        echo "   Username: admin"
        echo "   Password: healthcare-admin-2024"
    else
        echo "   Load Balancer not ready yet. Use port-forward:"
        echo "   kubectl port-forward -n $NAMESPACE svc/${RELEASE_NAME}-grafana 3000:80"
        echo "   Then access: http://localhost:3000"
        echo "   Username: admin"
        echo "   Password: healthcare-admin-2024"
    fi
    
    echo
    echo "🔍 PROMETHEUS:"
    echo "   Port-forward: kubectl port-forward -n $NAMESPACE svc/${RELEASE_NAME}-prometheus 9090:9090"
    echo "   Then access: http://localhost:9090"
    
    echo
    echo "🚨 ALERTMANAGER:"
    echo "   Port-forward: kubectl port-forward -n $NAMESPACE svc/${RELEASE_NAME}-alertmanager 9093:9093"
    echo "   Then access: http://localhost:9093"
    
    echo
    echo "=== MONITORING VERIFICATION ==="
    echo "Run the following commands to verify the deployment:"
    echo "   kubectl get pods -n $NAMESPACE"
    echo "   kubectl get servicemonitors -n $NAMESPACE"
    echo "   kubectl get prometheusrules -n $NAMESPACE"
    echo
}

# Verify deployment
verify_deployment() {
    log_info "Verifying deployment..."
    
    # Check pod status
    echo "Pod Status:"
    kubectl get pods -n "$NAMESPACE" -o wide
    
    echo
    echo "Service Status:"
    kubectl get services -n "$NAMESPACE"
    
    echo
    echo "ServiceMonitors:"
    kubectl get servicemonitors -n "$NAMESPACE" 2>/dev/null || echo "No ServiceMonitors found"
    
    echo
    echo "PrometheusRules:"
    kubectl get prometheusrules -n "$NAMESPACE" 2>/dev/null || echo "No PrometheusRules found"
    
    log_success "Deployment verification completed"
}

# Main execution
main() {
    echo "🚀 Healthcare System - Prometheus Stack Deployment"
    echo "=================================================="
    echo
    
    check_prerequisites
    add_helm_repos
    create_namespace
    deploy_prometheus_stack
    apply_custom_resources
    wait_for_pods
    verify_deployment
    get_access_info
    
    echo
    log_success "Prometheus stack deployment completed successfully!"
    echo
    echo "Next steps:"
    echo "1. Access Grafana dashboard and verify data sources"
    echo "2. Import healthcare-specific dashboards"
    echo "3. Configure alert notification channels"
    echo "4. Test alert rules with sample scenarios"
    echo
}

# Execute main function
main "$@"
