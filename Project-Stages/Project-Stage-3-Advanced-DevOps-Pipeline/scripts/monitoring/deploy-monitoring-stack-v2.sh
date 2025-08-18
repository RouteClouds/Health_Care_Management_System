#!/bin/bash

# Healthcare System - Monitoring Stack Deployment v2
# Optimized deployment script with enhanced error handling and resource validation

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

# Check cluster resources
check_cluster_resources() {
    log_info "Checking cluster resources..."
    
    # Get node resources
    TOTAL_CPU=$(kubectl get nodes -o jsonpath='{.items[*].status.capacity.cpu}' | tr ' ' '\n' | sed 's/m$//' | awk '{sum += $1} END {print sum}')
    TOTAL_MEMORY=$(kubectl get nodes -o jsonpath='{.items[*].status.capacity.memory}' | tr ' ' '\n' | sed 's/Ki$//' | awk '{sum += $1} END {print sum/1024/1024}')
    
    log_info "Cluster resources: ${TOTAL_CPU}m CPU, ${TOTAL_MEMORY}Gi Memory"
    
    # Check if we have enough resources (minimum requirements)
    if [[ $TOTAL_CPU -lt 2000 ]]; then
        log_warning "Low CPU resources detected. Using minimal configuration."
        USE_MINIMAL_CONFIG=true
    else
        USE_MINIMAL_CONFIG=false
    fi
}

# Create optimized values file based on cluster resources
create_optimized_values() {
    log_info "Creating optimized values file..."
    
    VALUES_FILE="${MONITORING_DIR}/prometheus/values-runtime.yaml"
    
    if [[ "$USE_MINIMAL_CONFIG" == "true" ]]; then
        cat > "$VALUES_FILE" << 'EOF'
# Minimal Prometheus Stack Configuration for Healthcare System
fullnameOverride: "healthcare-monitoring"
namespaceOverride: "monitoring"

prometheus:
  prometheusSpec:
    resources:
      requests:
        memory: "256Mi"
        cpu: "100m"
      limits:
        memory: "512Mi"
        cpu: "200m"
    retention: "7d"
    retentionSize: "5GB"
    storageSpec:
      volumeClaimTemplate:
        spec:
          storageClassName: "gp2"
          accessModes: ["ReadWriteOnce"]
          resources:
            requests:
              storage: 5Gi

grafana:
  enabled: true
  adminPassword: "healthcare-admin-2024"
  resources:
    requests:
      memory: "128Mi"
      cpu: "50m"
    limits:
      memory: "256Mi"
      cpu: "100m"
  persistence:
    enabled: true
    storageClassName: "gp2"
    size: 2Gi
  service:
    type: LoadBalancer

alertmanager:
  enabled: true
  alertmanagerSpec:
    resources:
      requests:
        memory: "64Mi"
        cpu: "25m"
      limits:
        memory: "128Mi"
        cpu: "50m"
    storage:
      volumeClaimTemplate:
        spec:
          storageClassName: "gp2"
          accessModes: ["ReadWriteOnce"]
          resources:
            requests:
              storage: 1Gi

nodeExporter:
  enabled: true
kubeStateMetrics:
  enabled: true
prometheusOperator:
  enabled: true
defaultRules:
  create: true
EOF
    else
        cp "${MONITORING_DIR}/prometheus/values-optimized.yaml" "$VALUES_FILE"
    fi
    
    log_success "Values file created: $VALUES_FILE"
}

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

# Deploy Prometheus stack
deploy_prometheus_stack() {
    log_info "Deploying Prometheus stack..."
    
    VALUES_FILE="${MONITORING_DIR}/prometheus/values-runtime.yaml"
    
    helm upgrade --install "$RELEASE_NAME" prometheus-community/kube-prometheus-stack \
        --namespace "$NAMESPACE" \
        --values "$VALUES_FILE" \
        --wait \
        --timeout 15m \
        --debug
    
    log_success "Prometheus stack deployed"
}

# Wait for pods with timeout
wait_for_pods() {
    log_info "Waiting for pods to be ready..."
    
    # Wait for each component with individual timeouts
    local components=("prometheus" "grafana" "alertmanager")
    
    for component in "${components[@]}"; do
        log_info "Waiting for $component..."
        if kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=$component \
            -n "$NAMESPACE" --timeout=300s; then
            log_success "$component is ready"
        else
            log_warning "$component is taking longer than expected"
        fi
    done
}

# Verify deployment
verify_deployment() {
    log_info "Verifying deployment..."
    
    echo "=== POD STATUS ==="
    kubectl get pods -n "$NAMESPACE" -o wide
    
    echo -e "\n=== SERVICE STATUS ==="
    kubectl get services -n "$NAMESPACE"
    
    echo -e "\n=== PVC STATUS ==="
    kubectl get pvc -n "$NAMESPACE"
    
    # Check if Grafana is accessible
    GRAFANA_POD=$(kubectl get pods -n "$NAMESPACE" -l app.kubernetes.io/name=grafana -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")
    if [[ -n "$GRAFANA_POD" ]]; then
        if kubectl get pod "$GRAFANA_POD" -n "$NAMESPACE" -o jsonpath='{.status.phase}' | grep -q "Running"; then
            log_success "Grafana pod is running"
        else
            log_warning "Grafana pod is not running yet"
        fi
    fi
}

# Get access information
get_access_info() {
    log_info "Getting access information..."
    
    echo -e "\n=== MONITORING STACK ACCESS ==="
    
    # Grafana access
    echo "📊 GRAFANA:"
    GRAFANA_LB=$(kubectl get service "${RELEASE_NAME}-grafana" -n "$NAMESPACE" \
        -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || echo "")
    
    if [[ -n "$GRAFANA_LB" ]]; then
        echo "   URL: http://${GRAFANA_LB}"
    else
        echo "   Port-forward: kubectl port-forward -n $NAMESPACE svc/${RELEASE_NAME}-grafana 3000:80"
        echo "   Then access: http://localhost:3000"
    fi
    echo "   Username: admin"
    echo "   Password: healthcare-admin-2024"
    
    echo -e "\n🔍 PROMETHEUS:"
    echo "   Port-forward: kubectl port-forward -n $NAMESPACE svc/${RELEASE_NAME}-prometheus 9090:9090"
    echo "   Then access: http://localhost:9090"
    
    echo -e "\n🚨 ALERTMANAGER:"
    echo "   Port-forward: kubectl port-forward -n $NAMESPACE svc/${RELEASE_NAME}-alertmanager 9093:9093"
    echo "   Then access: http://localhost:9093"
}

# Apply custom resources
apply_custom_resources() {
    log_info "Applying custom monitoring resources..."
    
    # Apply healthcare-specific alert rules
    if [[ -f "${MONITORING_DIR}/prometheus/healthcare-alerts.yaml" ]]; then
        kubectl apply -f "${MONITORING_DIR}/prometheus/healthcare-alerts.yaml" || log_warning "Failed to apply alert rules"
    fi
    
    # Apply service monitors
    if [[ -f "${MONITORING_DIR}/prometheus/service-monitors.yaml" ]]; then
        kubectl apply -f "${MONITORING_DIR}/prometheus/service-monitors.yaml" || log_warning "Failed to apply service monitors"
    fi
}

# Main execution
main() {
    echo "🚀 Healthcare System - Monitoring Stack Deployment v2"
    echo "====================================================="
    
    check_prerequisites
    check_cluster_resources
    create_optimized_values
    add_helm_repos
    create_namespace
    deploy_prometheus_stack
    wait_for_pods
    apply_custom_resources
    verify_deployment
    get_access_info
    
    echo -e "\n${GREEN}✅ Monitoring stack deployment completed!${NC}"
    echo -e "\nNext steps:"
    echo "1. Access Grafana and verify data sources"
    echo "2. Import healthcare dashboards"
    echo "3. Test alert rules"
    echo "4. Configure notification channels"
}

# Execute main function
main "$@"
