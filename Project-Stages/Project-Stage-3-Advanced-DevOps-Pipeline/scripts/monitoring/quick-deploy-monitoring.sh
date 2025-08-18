#!/bin/bash

# Quick Deploy Monitoring Stack (No Persistence)
# This script deploys monitoring stack without persistent storage for quick testing

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
NC='\033[0m'

# Logging functions
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    # Check tools
    for tool in kubectl helm; do
        if ! command -v $tool &> /dev/null; then
            log_error "$tool is not installed"
            exit 1
        fi
    done
    
    # Check cluster connectivity
    if ! kubectl cluster-info &> /dev/null; then
        log_error "Cannot connect to Kubernetes cluster"
        exit 1
    fi
    
    log_success "Prerequisites check completed"
}

# Add Helm repositories
add_helm_repos() {
    log_info "Adding Helm repositories..."
    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
    helm repo update
    log_success "Helm repositories updated"
}

# Create namespace
create_namespace() {
    log_info "Creating monitoring namespace..."
    kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -
    kubectl label namespace "$NAMESPACE" monitoring=enabled --overwrite
    log_success "Namespace ready"
}

# Deploy Prometheus stack without persistence
deploy_monitoring_stack() {
    log_info "Deploying monitoring stack (no persistence)..."
    
    VALUES_FILE="${MONITORING_DIR}/prometheus/values-no-persistence.yaml"
    
    if [[ ! -f "$VALUES_FILE" ]]; then
        log_error "Values file not found: $VALUES_FILE"
        exit 1
    fi
    
    log_info "Using values file: $VALUES_FILE"
    
    # Deploy with shorter timeout and no wait for PVCs
    helm upgrade --install "$RELEASE_NAME" prometheus-community/kube-prometheus-stack \
        --namespace "$NAMESPACE" \
        --values "$VALUES_FILE" \
        --timeout 10m \
        --wait
    
    log_success "Monitoring stack deployed"
}

# Wait for pods to be ready
wait_for_pods() {
    log_info "Waiting for pods to be ready..."
    
    # Wait for key components
    local components=("prometheus" "grafana" "alertmanager")
    
    for component in "${components[@]}"; do
        log_info "Waiting for $component pods..."
        
        # Wait with timeout
        if kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=$component \
            -n "$NAMESPACE" --timeout=300s; then
            log_success "$component is ready"
        else
            log_warning "$component is taking longer than expected, continuing..."
        fi
    done
}

# Quick verification
quick_verify() {
    log_info "Quick verification..."
    
    echo "=== POD STATUS ==="
    kubectl get pods -n "$NAMESPACE"
    
    echo -e "\n=== SERVICE STATUS ==="
    kubectl get services -n "$NAMESPACE"
    
    # Check if main components are running
    local prometheus_running=$(kubectl get pods -n "$NAMESPACE" -l app.kubernetes.io/name=prometheus --no-headers 2>/dev/null | grep -c "Running" || echo "0")
    local grafana_running=$(kubectl get pods -n "$NAMESPACE" -l app.kubernetes.io/name=grafana --no-headers 2>/dev/null | grep -c "Running" || echo "0")
    
    if [[ $prometheus_running -gt 0 && $grafana_running -gt 0 ]]; then
        log_success "✅ Core monitoring components are running"
    else
        log_warning "⚠️  Some components may not be ready yet"
    fi
}

# Get access information
get_access_info() {
    log_info "Getting access information..."
    
    echo -e "\n=== QUICK ACCESS GUIDE ==="
    
    # Grafana access
    echo "📊 GRAFANA:"
    echo "   Port-forward: kubectl port-forward -n $NAMESPACE svc/${RELEASE_NAME}-grafana 3000:80"
    echo "   Then access: http://localhost:3000"
    echo "   Username: admin"
    echo "   Password: healthcare-admin-2024"
    
    echo -e "\n🔍 PROMETHEUS:"
    echo "   Port-forward: kubectl port-forward -n $NAMESPACE svc/${RELEASE_NAME}-prometheus 9090:9090"
    echo "   Then access: http://localhost:9090"
    
    echo -e "\n🚨 ALERTMANAGER:"
    echo "   Port-forward: kubectl port-forward -n $NAMESPACE svc/${RELEASE_NAME}-alertmanager 9093:9093"
    echo "   Then access: http://localhost:9093"
    
    echo -e "\n⚠️  NOTE: This deployment uses NO persistent storage."
    echo "   Data will be lost when pods restart."
    echo "   Use this for testing only."
}

# Apply basic monitoring resources
apply_basic_resources() {
    log_info "Applying basic monitoring resources..."
    
    # Apply healthcare-specific alert rules (if they exist)
    if [[ -f "${MONITORING_DIR}/prometheus/healthcare-alerts.yaml" ]]; then
        kubectl apply -f "${MONITORING_DIR}/prometheus/healthcare-alerts.yaml" || log_warning "Failed to apply alert rules"
        log_success "Healthcare alert rules applied"
    fi
    
    # Apply service monitors (if they exist)
    if [[ -f "${MONITORING_DIR}/prometheus/service-monitors.yaml" ]]; then
        kubectl apply -f "${MONITORING_DIR}/prometheus/service-monitors.yaml" || log_warning "Failed to apply service monitors"
        log_success "Service monitors applied"
    fi
}

# Main execution
main() {
    echo "🚀 Healthcare System - Quick Monitoring Deployment"
    echo "================================================="
    echo "⚠️  WARNING: This deployment uses NO persistent storage!"
    echo "   Use this for testing and development only."
    echo "================================================="
    
    check_prerequisites
    add_helm_repos
    create_namespace
    deploy_monitoring_stack
    wait_for_pods
    apply_basic_resources
    quick_verify
    get_access_info
    
    echo -e "\n${GREEN}✅ Quick monitoring deployment completed!${NC}"
    echo -e "\nTo validate the deployment, run:"
    echo "   ./scripts/monitoring/validate-monitoring-stack.sh"
    echo -e "\nTo clean up, run:"
    echo "   ./scripts/monitoring/cleanup-monitoring-stack.sh"
}

# Execute main function
main "$@"
