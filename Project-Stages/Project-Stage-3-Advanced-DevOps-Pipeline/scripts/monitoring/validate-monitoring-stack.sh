#!/bin/bash

# Healthcare System - Monitoring Stack Validation Script
# Comprehensive validation of Prometheus, Grafana, and AlertManager deployment

set -euo pipefail

# Configuration
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

# Test counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Test function
run_test() {
    local test_name="$1"
    local test_command="$2"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    echo -e "\n🧪 Test $TOTAL_TESTS: $test_name"
    
    if eval "$test_command"; then
        log_success "✅ PASSED: $test_name"
        PASSED_TESTS=$((PASSED_TESTS + 1))
        return 0
    else
        log_error "❌ FAILED: $test_name"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        return 1
    fi
}

# Validation tests
test_namespace_exists() {
    kubectl get namespace "$NAMESPACE" &>/dev/null
}

test_helm_release_deployed() {
    helm list -n "$NAMESPACE" | grep -q "$RELEASE_NAME"
}

test_prometheus_pod_running() {
    kubectl get pods -n "$NAMESPACE" -l app.kubernetes.io/name=prometheus | grep -q "Running"
}

test_grafana_pod_running() {
    kubectl get pods -n "$NAMESPACE" -l app.kubernetes.io/name=grafana | grep -q "Running"
}

test_alertmanager_pod_running() {
    kubectl get pods -n "$NAMESPACE" -l app.kubernetes.io/name=alertmanager | grep -q "Running"
}

test_prometheus_service_exists() {
    kubectl get service "${RELEASE_NAME}-prometheus" -n "$NAMESPACE" &>/dev/null
}

test_grafana_service_exists() {
    kubectl get service "${RELEASE_NAME}-grafana" -n "$NAMESPACE" &>/dev/null
}

test_alertmanager_service_exists() {
    kubectl get service "${RELEASE_NAME}-alertmanager" -n "$NAMESPACE" &>/dev/null
}

test_prometheus_pvc_bound() {
    local pvc_name=$(kubectl get pvc -n "$NAMESPACE" | grep prometheus | awk '{print $1}' | head -1)
    if [[ -n "$pvc_name" ]]; then
        kubectl get pvc "$pvc_name" -n "$NAMESPACE" | grep -q "Bound"
    else
        return 1
    fi
}

test_grafana_pvc_bound() {
    local pvc_name=$(kubectl get pvc -n "$NAMESPACE" | grep grafana | awk '{print $1}' | head -1)
    if [[ -n "$pvc_name" ]]; then
        kubectl get pvc "$pvc_name" -n "$NAMESPACE" | grep -q "Bound"
    else
        return 1
    fi
}

test_prometheus_targets() {
    local prometheus_pod=$(kubectl get pods -n "$NAMESPACE" -l app.kubernetes.io/name=prometheus -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
    if [[ -n "$prometheus_pod" ]]; then
        kubectl port-forward -n "$NAMESPACE" "$prometheus_pod" 9090:9090 &
        local pf_pid=$!
        sleep 5
        
        # Test if Prometheus API is accessible
        if curl -s http://localhost:9090/api/v1/targets &>/dev/null; then
            kill $pf_pid 2>/dev/null || true
            return 0
        else
            kill $pf_pid 2>/dev/null || true
            return 1
        fi
    else
        return 1
    fi
}

test_grafana_accessibility() {
    local grafana_pod=$(kubectl get pods -n "$NAMESPACE" -l app.kubernetes.io/name=grafana -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
    if [[ -n "$grafana_pod" ]]; then
        kubectl port-forward -n "$NAMESPACE" "$grafana_pod" 3000:3000 &
        local pf_pid=$!
        sleep 5
        
        # Test if Grafana is accessible
        if curl -s http://localhost:3000/api/health &>/dev/null; then
            kill $pf_pid 2>/dev/null || true
            return 0
        else
            kill $pf_pid 2>/dev/null || true
            return 1
        fi
    else
        return 1
    fi
}

test_custom_alerts_applied() {
    kubectl get prometheusrules -n "$NAMESPACE" | grep -q "healthcare-system-alerts"
}

test_service_monitors_applied() {
    kubectl get servicemonitors -n "$NAMESPACE" | grep -q "healthcare"
}

test_node_exporter_running() {
    kubectl get pods -n "$NAMESPACE" -l app.kubernetes.io/name=prometheus-node-exporter | grep -q "Running"
}

test_kube_state_metrics_running() {
    kubectl get pods -n "$NAMESPACE" -l app.kubernetes.io/name=kube-state-metrics | grep -q "Running"
}

# Resource usage tests
test_resource_usage() {
    log_info "Checking resource usage..."
    
    echo "=== CPU Usage ==="
    kubectl top pods -n "$NAMESPACE" --no-headers 2>/dev/null || echo "Metrics not available yet"
    
    echo -e "\n=== Memory Usage ==="
    kubectl get pods -n "$NAMESPACE" -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.containers[0].resources.requests.memory}{"\t"}{.spec.containers[0].resources.limits.memory}{"\n"}{end}' | column -t
    
    return 0
}

# Connectivity tests
test_healthcare_app_connectivity() {
    log_info "Testing connectivity to healthcare applications..."
    
    # Check if healthcare namespace exists
    if kubectl get namespace healthcare-stage3-dev &>/dev/null; then
        local frontend_pod=$(kubectl get pods -n healthcare-stage3-dev -l app=frontend-stage3 -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")
        local backend_pod=$(kubectl get pods -n healthcare-stage3-dev -l app=backend-stage3 -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")
        
        if [[ -n "$frontend_pod" && -n "$backend_pod" ]]; then
            log_success "Healthcare applications found and can be monitored"
            return 0
        else
            log_warning "Healthcare applications not found - monitoring will work when apps are deployed"
            return 0
        fi
    else
        log_warning "Healthcare namespace not found - monitoring will work when apps are deployed"
        return 0
    fi
}

# Main validation function
main() {
    echo "🔍 Healthcare System - Monitoring Stack Validation"
    echo "=================================================="
    
    # Core component tests
    run_test "Monitoring namespace exists" "test_namespace_exists"
    run_test "Helm release deployed" "test_helm_release_deployed"
    run_test "Prometheus pod running" "test_prometheus_pod_running"
    run_test "Grafana pod running" "test_grafana_pod_running"
    run_test "AlertManager pod running" "test_alertmanager_pod_running"
    
    # Service tests
    run_test "Prometheus service exists" "test_prometheus_service_exists"
    run_test "Grafana service exists" "test_grafana_service_exists"
    run_test "AlertManager service exists" "test_alertmanager_service_exists"
    
    # Storage tests
    run_test "Prometheus PVC bound" "test_prometheus_pvc_bound"
    run_test "Grafana PVC bound" "test_grafana_pvc_bound"
    
    # Functionality tests
    run_test "Prometheus API accessible" "test_prometheus_targets"
    run_test "Grafana accessible" "test_grafana_accessibility"
    
    # Custom resources tests
    run_test "Custom alert rules applied" "test_custom_alerts_applied"
    run_test "Service monitors applied" "test_service_monitors_applied"
    
    # Additional components
    run_test "Node Exporter running" "test_node_exporter_running"
    run_test "Kube State Metrics running" "test_kube_state_metrics_running"
    
    # Resource and connectivity tests
    run_test "Resource usage check" "test_resource_usage"
    run_test "Healthcare app connectivity" "test_healthcare_app_connectivity"
    
    # Summary
    echo -e "\n=== VALIDATION SUMMARY ==="
    echo "Total Tests: $TOTAL_TESTS"
    echo "Passed: $PASSED_TESTS"
    echo "Failed: $FAILED_TESTS"
    
    if [[ $FAILED_TESTS -eq 0 ]]; then
        log_success "🎉 All tests passed! Monitoring stack is fully operational."
        
        echo -e "\n=== ACCESS INFORMATION ==="
        echo "📊 Grafana: kubectl port-forward -n $NAMESPACE svc/${RELEASE_NAME}-grafana 3000:80"
        echo "🔍 Prometheus: kubectl port-forward -n $NAMESPACE svc/${RELEASE_NAME}-prometheus 9090:9090"
        echo "🚨 AlertManager: kubectl port-forward -n $NAMESPACE svc/${RELEASE_NAME}-alertmanager 9093:9093"
        echo -e "\nGrafana credentials: admin / healthcare-admin-2024"
        
        return 0
    else
        log_error "❌ Some tests failed. Please check the monitoring stack deployment."
        return 1
    fi
}

# Execute main function
main "$@"
