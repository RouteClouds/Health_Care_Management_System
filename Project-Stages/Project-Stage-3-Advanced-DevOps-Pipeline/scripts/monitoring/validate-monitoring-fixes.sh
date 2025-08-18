#!/bin/bash

# Validation Script for Monitoring Fixes
# This script validates that the monitoring stack can be deployed successfully

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
MONITORING_DIR="${PROJECT_ROOT}/monitoring"

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
        log_error "❌ Insufficient CPU: Required ${REQUIRED_CPU}m, Available ${AVAILABLE_CPU}m"
        return 1
    fi
    
    if [ $AVAILABLE_MEMORY -lt $REQUIRED_MEMORY ]; then
        log_error "❌ Insufficient Memory: Required ${REQUIRED_MEMORY}Ki, Available ${AVAILABLE_MEMORY}Ki"
        return 1
    fi
    
    log_success "✅ Cluster has sufficient resources for monitoring stack"
    return 0
}

# Check file existence
check_files() {
    log_info "Checking required files..."
    
    # Check optimized values file
    VALUES_FILE="${MONITORING_DIR}/prometheus/values-optimized.yaml"
    if [[ -f "$VALUES_FILE" ]]; then
        log_success "✅ Optimized values file exists: $VALUES_FILE"
    else
        log_error "❌ Optimized values file not found: $VALUES_FILE"
        return 1
    fi
    
    # Check fixed deployment script
    DEPLOY_SCRIPT="${SCRIPT_DIR}/deploy-prometheus-stack-fixed.sh"
    if [[ -f "$DEPLOY_SCRIPT" ]]; then
        log_success "✅ Fixed deployment script exists: $DEPLOY_SCRIPT"
    else
        log_error "❌ Fixed deployment script not found: $DEPLOY_SCRIPT"
        return 1
    fi
    
    # Check cleanup script
    CLEANUP_SCRIPT="${SCRIPT_DIR}/cleanup-monitoring-stack.sh"
    if [[ -f "$CLEANUP_SCRIPT" ]]; then
        log_success "✅ Cleanup script exists: $CLEANUP_SCRIPT"
    else
        log_error "❌ Cleanup script not found: $CLEANUP_SCRIPT"
        return 1
    fi
    
    return 0
}

# Check script permissions
check_permissions() {
    log_info "Checking script permissions..."
    
    # Check deployment script permissions
    if [[ -x "${SCRIPT_DIR}/deploy-prometheus-stack-fixed.sh" ]]; then
        log_success "✅ Deployment script is executable"
    else
        log_error "❌ Deployment script is not executable"
        return 1
    fi
    
    # Check cleanup script permissions
    if [[ -x "${SCRIPT_DIR}/cleanup-monitoring-stack.sh" ]]; then
        log_success "✅ Cleanup script is executable"
    else
        log_error "❌ Cleanup script is not executable"
        return 1
    fi
    
    return 0
}

# Validate Helm chart values
validate_helm_values() {
    log_info "Validating Helm chart values..."
    
    VALUES_FILE="${MONITORING_DIR}/prometheus/values-optimized.yaml"
    
    # Check if values file is valid YAML
    if python3 -c "import yaml; yaml.safe_load(open('$VALUES_FILE'))" 2>/dev/null; then
        log_success "✅ Values file is valid YAML"
    else
        log_error "❌ Values file is not valid YAML"
        return 1
    fi
    
    # Check resource requirements
    PROMETHEUS_CPU=$(grep -A 5 "prometheus:" "$VALUES_FILE" | grep "cpu:" | head -1 | awk '{print $2}' | sed 's/"//g')
    PROMETHEUS_MEMORY=$(grep -A 5 "prometheus:" "$VALUES_FILE" | grep "memory:" | head -1 | awk '{print $2}' | sed 's/"//g')
    
    log_info "Prometheus CPU request: $PROMETHEUS_CPU"
    log_info "Prometheus Memory request: $PROMETHEUS_MEMORY"
    
    # Validate resource values are reasonable
    if [[ "$PROMETHEUS_CPU" == "250m" ]]; then
        log_success "✅ Prometheus CPU request is optimized"
    else
        log_warning "⚠️ Prometheus CPU request may not be optimized: $PROMETHEUS_CPU"
    fi
    
    if [[ "$PROMETHEUS_MEMORY" == "512Mi" ]]; then
        log_success "✅ Prometheus Memory request is optimized"
    else
        log_warning "⚠️ Prometheus Memory request may not be optimized: $PROMETHEUS_MEMORY"
    fi
    
    return 0
}

# Check current monitoring status
check_current_status() {
    log_info "Checking current monitoring status..."
    
    # Check if monitoring namespace exists
    if kubectl get namespace monitoring &> /dev/null; then
        log_warning "⚠️ Monitoring namespace already exists"
        
        # Check pod status
        PENDING_PODS=$(kubectl get pods -n monitoring --field-selector=status.phase=Pending -o name 2>/dev/null | wc -l || echo "0")
        if [ "$PENDING_PODS" -gt 0 ]; then
            log_error "❌ Found $PENDING_PODS pending pods in monitoring namespace"
            log_info "💡 Run cleanup script: ./cleanup-monitoring-stack.sh recover"
            return 1
        fi
        
        # Check PVC status
        PENDING_PVC=$(kubectl get pvc -n monitoring --field-selector=status.phase=Pending -o name 2>/dev/null | wc -l || echo "0")
        if [ "$PENDING_PVC" -gt 0 ]; then
            log_error "❌ Found $PENDING_PVC pending PVCs in monitoring namespace"
            log_info "💡 Run cleanup script: ./cleanup-monitoring-stack.sh recover"
            return 1
        fi
        
        log_success "✅ Monitoring namespace exists and no stuck resources"
    else
        log_success "✅ Monitoring namespace does not exist (ready for deployment)"
    fi
    
    return 0
}

# Main validation
main() {
    echo "🔍 Healthcare System - Monitoring Fixes Validation"
    echo "=================================================="
    echo
    
    # Validation counters
    TOTAL_CHECKS=0
    PASSED_CHECKS=0
    FAILED_CHECKS=0
    
    # Run all validations
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    if check_cluster_resources; then
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
    else
        FAILED_CHECKS=$((FAILED_CHECKS + 1))
    fi
    
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    if check_files; then
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
    else
        FAILED_CHECKS=$((FAILED_CHECKS + 1))
    fi
    
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    if check_permissions; then
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
    else
        FAILED_CHECKS=$((FAILED_CHECKS + 1))
    fi
    
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    if validate_helm_values; then
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
    else
        FAILED_CHECKS=$((FAILED_CHECKS + 1))
    fi
    
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    if check_current_status; then
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
    else
        FAILED_CHECKS=$((FAILED_CHECKS + 1))
    fi
    
    # Summary
    echo
    echo "=================================================="
    echo "📊 VALIDATION SUMMARY"
    echo "=================================================="
    echo "Total Checks: $TOTAL_CHECKS"
    echo "Passed: $PASSED_CHECKS"
    echo "Failed: $FAILED_CHECKS"
    echo
    
    if [ $FAILED_CHECKS -eq 0 ]; then
        log_success "🎉 All validations passed! Ready to deploy monitoring stack."
        echo
        echo "🚀 Next Steps:"
        echo "1. Run the fixed deployment: ./deploy-prometheus-stack-fixed.sh"
        echo "2. Monitor the deployment progress"
        echo "3. Access Grafana dashboard once deployed"
        echo
    else
        log_error "❌ Some validations failed. Please fix the issues before deploying."
        echo
        echo "🔧 Recommended Actions:"
        if [ $FAILED_CHECKS -gt 0 ]; then
            echo "1. Check cluster resources and scale up if needed"
            echo "2. Ensure all required files exist and are accessible"
            echo "3. Run cleanup if needed: ./cleanup-monitoring-stack.sh recover"
            echo "4. Fix any permission issues with scripts"
        fi
        echo
        exit 1
    fi
}

# Execute main function
main "$@"


