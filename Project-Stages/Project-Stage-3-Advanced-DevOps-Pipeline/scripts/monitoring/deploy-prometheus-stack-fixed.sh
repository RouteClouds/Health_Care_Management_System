#!/bin/bash

# Fixed Prometheus Stack Deployment Script for Healthcare System
# This script deploys a comprehensive monitoring stack with resource validation and enhanced timeout handling

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

# Check cluster resources
check_cluster_resources() {
    log_info "Checking cluster resource availability..."
    
    # Get node resources
    TOTAL_CPU=$(kubectl get nodes -o jsonpath='{.items[*].status.allocatable.cpu}' | tr ' ' '\n' | awk '{sum += $1} END {print sum}')
    TOTAL_MEMORY=$(kubectl get nodes -o jsonpath='{.items[*].status.allocatable.memory}' | tr ' ' '\n' | awk '{sum += $1} END {print sum}')
    
    # Convert to numeric values
    TOTAL_CPU_NUM=$(echo $TOTAL_CPU | sed 's/m//')
    TOTAL_MEMORY_NUM=$(echo $TOTAL_MEMORY | sed 's/Ki//')
    
    # Calculate available resources (assuming 50% for monitoring)
    AVAILABLE_CPU=$((TOTAL_CPU_NUM / 2))
    AVAILABLE_MEMORY=$((TOTAL_MEMORY_NUM / 2))
    
    log_info "Total cluster resources: ${TOTAL_CPU_NUM}m CPU, ${TOTAL_MEMORY_NUM}Ki Memory"
    log_info "Available for monitoring: ${AVAILABLE_CPU}m CPU, ${AVAILABLE_MEMORY}Ki Memory"
    
    # Check if we have enough resources
    REQUIRED_CPU=400  # 250m + 100m + 50m
    REQUIRED_MEMORY=896000  # 512Mi + 256Mi + 128Mi in KiB
    
    if [ $AVAILABLE_CPU -lt $REQUIRED_CPU ]; then
        log_error "Insufficient CPU: Required ${REQUIRED_CPU}m, Available ${AVAILABLE_CPU}m"
        log_warning "Consider scaling up your cluster or reducing resource requirements"
        return 1
    fi
    
    if [ $AVAILABLE_MEMORY -lt $REQUIRED_MEMORY ]; then
        log_error "Insufficient Memory: Required ${REQUIRED_MEMORY}Ki, Available ${AVAILABLE_MEMORY}Ki"
        log_warning "Consider scaling up your cluster or reducing resource requirements"
        return 1
    fi
    
    log_success "Cluster has sufficient resources for monitoring stack"
    return 0
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

# Clean up existing failed deployments
cleanup_failed_deployment() {
    log_info "Checking for existing failed deployments..."
    
    # Check if release exists
    if helm list -n "$NAMESPACE" | grep -q "$RELEASE_NAME"; then
        log_warning "Found existing release, cleaning up..."
        helm uninstall "$RELEASE_NAME" -n "$NAMESPACE" --timeout 10m || true
        sleep 30
    fi
    
    # Check for stuck PVCs
    STUCK_PVC=$(kubectl get pvc -n "$NAMESPACE" --field-selector=status.phase=Pending -o name 2>/dev/null || true)
    if [ -n "$STUCK_PVC" ]; then
        log_warning "Found stuck PVCs, deleting..."
        echo "$STUCK_PVC" | xargs kubectl delete --force --grace-period=0 || true
        sleep 30
    fi
    
    # Check for stuck pods
    STUCK_PODS=$(kubectl get pods -n "$NAMESPACE" --field-selector=status.phase=Pending -o name 2>/dev/null || true)
    if [ -n "$STUCK_PODS" ]; then
        log_warning "Found stuck pods, forcing deletion..."
        echo "$STUCK_PODS" | xargs kubectl delete --force --grace-period=0 || true
        sleep 30
    fi
    
    log_success "Cleanup completed"
}

# Deploy Prometheus stack with enhanced timeout handling
deploy_prometheus_stack_optimized() {
    log_info "Deploying optimized Prometheus stack..."
    
    # Use optimized values file
    VALUES_FILE="${MONITORING_DIR}/prometheus/values-optimized.yaml"
    if [[ ! -f "$VALUES_FILE" ]]; then
        log_error "Optimized values file not found: $VALUES_FILE"
        log_info "Falling back to original values file..."
        VALUES_FILE="${MONITORING_DIR}/prometheus/values.yaml"
        if [[ ! -f "$VALUES_FILE" ]]; then
            log_error "Values file not found: $VALUES_FILE"
            exit 1
        fi
    fi
    
    # Deploy with extended timeout and retry logic
    for attempt in {1..3}; do
        log_info "Deployment attempt $attempt/3"
        
        # Deploy using Helm with extended timeout
        helm upgrade --install "$RELEASE_NAME" prometheus-community/kube-prometheus-stack \
            --namespace "$NAMESPACE" \
            --values "$VALUES_FILE" \
            --wait \
            --timeout 20m \
            --atomic
        
        if [ $? -eq 0 ]; then
            log_success "Prometheus stack deployed successfully on attempt $attempt"
            return 0
        else
            log_warning "Deployment attempt $attempt failed, cleaning up..."
            helm uninstall "$RELEASE_NAME" -n "$NAMESPACE" --timeout 5m || true
            kubectl delete pvc --all -n "$NAMESPACE" --timeout 2m || true
            sleep 60
        fi
    done
    
    log_error "All deployment attempts failed"
    return 1
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

# Enhanced pod waiting with better timeout handling
wait_for_pods_optimized() {
    log_info "Waiting for monitoring pods with enhanced timeout handling..."
    
    # Wait for operator first
    log_info "Waiting for Prometheus Operator..."
    kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=prometheus-operator \
        -n "$NAMESPACE" --timeout=600s || {
        log_warning "Prometheus Operator not ready, checking status..."
        kubectl describe pod -l app.kubernetes.io/name=prometheus-operator -n "$NAMESPACE"
    }
    
    # Wait for Prometheus with longer timeout
    log_info "Waiting for Prometheus..."
    kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=prometheus \
        -n "$NAMESPACE" --timeout=900s || {
        log_warning "Prometheus pod not ready, checking status..."
        kubectl describe pod -l app.kubernetes.io/name=prometheus -n "$NAMESPACE"
    }
    
    # Wait for Grafana with longer timeout
    log_info "Waiting for Grafana..."
    kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=grafana \
        -n "$NAMESPACE" --timeout=900s || {
        log_warning "Grafana pod not ready, checking status..."
        kubectl describe pod -l app.kubernetes.io/name=grafana -n "$NAMESPACE"
    }
    
    # Wait for AlertManager with longer timeout
    log_info "Waiting for AlertManager..."
    kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=alertmanager \
        -n "$NAMESPACE" --timeout=900s || {
        log_warning "AlertManager pod not ready, checking status..."
        kubectl describe pod -l app.kubernetes.io/name=alertmanager -n "$NAMESPACE"
    }
    
    log_success "Pod waiting completed"
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
    
    # Check resource usage
    echo
    echo "Resource Usage:"
    kubectl top pods -n "$NAMESPACE" 2>/dev/null || echo "Metrics server not available"
    
    log_success "Deployment verification completed"
}

# Main execution
main() {
    echo "🚀 Healthcare System - Fixed Prometheus Stack Deployment"
    echo "========================================================"
    echo
    
    check_prerequisites
    
    # Check cluster resources
    if ! check_cluster_resources; then
        log_error "Insufficient cluster resources. Please scale up your cluster or use minimal monitoring."
        echo
        echo "To scale up your cluster:"
        echo "aws eks update-nodegroup-config --cluster-name healthcare-eks-stage3-dev \\"
        echo "  --nodegroup-name healthcare-nodes --scaling-config minSize=3,maxSize=5"
        echo
        echo "Or use minimal monitoring:"
        echo "helm install minimal-monitoring prometheus-community/kube-prometheus-stack \\"
        echo "  --set prometheus.enabled=false --set grafana.enabled=true --set alertmanager.enabled=false"
        exit 1
    fi
    
    add_helm_repos
    create_namespace
    cleanup_failed_deployment
    deploy_prometheus_stack_optimized
    apply_custom_resources
    wait_for_pods_optimized
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


