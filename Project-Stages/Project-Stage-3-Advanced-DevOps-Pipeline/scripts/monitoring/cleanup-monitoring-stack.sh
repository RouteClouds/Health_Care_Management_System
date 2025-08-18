#!/bin/bash

# Healthcare System - Monitoring Stack Cleanup Script v2
# Enhanced cleanup script with better error handling and verification

set -euo pipefail

# Configuration
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
    
    if ! command -v kubectl &> /dev/null; then
        log_error "kubectl is not installed or not in PATH"
        exit 1
    fi
    
    if ! command -v helm &> /dev/null; then
        log_error "helm is not installed or not in PATH"
        exit 1
    fi
    
    if ! kubectl cluster-info &> /dev/null; then
        log_error "Cannot connect to Kubernetes cluster"
        exit 1
    fi
    
    log_success "Prerequisites check completed"
}

# Clean up monitoring stack
cleanup_monitoring_stack() {
    log_info "Cleaning up monitoring stack..."
    
    # Check if namespace exists
    if ! kubectl get namespace "$NAMESPACE" &> /dev/null; then
        log_warning "Namespace $NAMESPACE does not exist"
        return 0
    fi
    
    # Uninstall Helm release
    if helm list -n "$NAMESPACE" | grep -q "$RELEASE_NAME"; then
        log_info "Uninstalling Helm release $RELEASE_NAME..."
        helm uninstall "$RELEASE_NAME" -n "$NAMESPACE" --timeout 10m || {
            log_warning "Helm uninstall failed, forcing cleanup..."
            helm uninstall "$RELEASE_NAME" -n "$NAMESPACE" --timeout 5m --no-hooks || true
        }
    else
        log_info "No Helm release found for $RELEASE_NAME"
    fi
    
    # Delete PVCs
    log_info "Deleting PVCs..."
    kubectl delete pvc --all -n "$NAMESPACE" --timeout 5m || {
        log_warning "PVC deletion failed, forcing cleanup..."
        kubectl delete pvc --all -n "$NAMESPACE" --force --grace-period=0 || true
    }
    
    # Delete stuck pods
    log_info "Checking for stuck pods..."
    STUCK_PODS=$(kubectl get pods -n "$NAMESPACE" --field-selector=status.phase=Pending -o name 2>/dev/null || true)
    if [ -n "$STUCK_PODS" ]; then
        log_warning "Found stuck pods, forcing deletion..."
        echo "$STUCK_PODS" | xargs kubectl delete --force --grace-period=0 || true
    fi
    
    # Delete stuck PVCs
    log_info "Checking for stuck PVCs..."
    STUCK_PVC=$(kubectl get pvc -n "$NAMESPACE" --field-selector=status.phase=Pending -o name 2>/dev/null || true)
    if [ -n "$STUCK_PVC" ]; then
        log_warning "Found stuck PVCs, forcing deletion..."
        echo "$STUCK_PVC" | xargs kubectl delete --force --grace-period=0 || true
    fi
    
    # Delete all remaining resources in namespace
    log_info "Deleting all remaining resources in namespace..."
    kubectl delete all --all -n "$NAMESPACE" --timeout 5m || true
    kubectl delete servicemonitor --all -n "$NAMESPACE" --timeout 2m || true
    kubectl delete prometheusrule --all -n "$NAMESPACE" --timeout 2m || true
    kubectl delete configmap --all -n "$NAMESPACE" --timeout 2m || true
    kubectl delete secret --all -n "$NAMESPACE" --timeout 2m || true
    
    # Delete namespace
    log_info "Deleting namespace $NAMESPACE..."
    kubectl delete namespace "$NAMESPACE" --timeout 5m || {
        log_warning "Namespace deletion failed, forcing cleanup..."
        kubectl delete namespace "$NAMESPACE" --force --grace-period=0 || true
    }
    
    # Wait for cleanup
    log_info "Waiting for cleanup to complete..."
    sleep 30
    
    log_success "Monitoring stack cleanup completed"
}

# Force cleanup stuck resources
force_cleanup_stuck_resources() {
    log_info "Force cleaning up stuck resources..."
    
    # Force delete any remaining pods
    kubectl get pods -n "$NAMESPACE" -o name 2>/dev/null | xargs kubectl delete --force --grace-period=0 || true
    
    # Force delete any remaining PVCs
    kubectl get pvc -n "$NAMESPACE" -o name 2>/dev/null | xargs kubectl delete --force --grace-period=0 || true
    
    # Force delete any remaining services
    kubectl get services -n "$NAMESPACE" -o name 2>/dev/null | xargs kubectl delete --force --grace-period=0 || true
    
    # Force delete any remaining deployments
    kubectl get deployments -n "$NAMESPACE" -o name 2>/dev/null | xargs kubectl delete --force --grace-period=0 || true
    
    # Force delete any remaining statefulsets
    kubectl get statefulsets -n "$NAMESPACE" -o name 2>/dev/null | xargs kubectl delete --force --grace-period=0 || true
    
    log_success "Force cleanup completed"
}

# Check cleanup status
check_cleanup_status() {
    log_info "Checking cleanup status..."
    
    # Check if namespace still exists
    if kubectl get namespace "$NAMESPACE" &> /dev/null; then
        log_warning "Namespace $NAMESPACE still exists"
        return 1
    fi
    
    # Check if any resources remain
    REMAINING_RESOURCES=$(kubectl get all -n "$NAMESPACE" 2>/dev/null | wc -l || echo "0")
    if [ "$REMAINING_RESOURCES" -gt 0 ]; then
        log_warning "Some resources still exist in namespace"
        return 1
    fi
    
    log_success "Cleanup verification completed - all resources removed"
    return 0
}

# Recovery function
recover_from_failed_deployment() {
    log_info "Recovering from failed deployment..."
    
    # Clean up existing resources
    cleanup_monitoring_stack
    
    # Wait for cleanup
    sleep 60
    
    # Check if cleanup was successful
    if ! check_cleanup_status; then
        log_warning "Cleanup may not be complete, attempting force cleanup..."
        force_cleanup_stuck_resources
        sleep 30
    fi
    
    log_success "Recovery completed, ready for fresh deployment"
}

# Main execution
main() {
    echo "🧹 Healthcare System - Monitoring Stack Cleanup"
    echo "================================================"
    echo
    
    check_prerequisites
    
    # Check command line arguments
    case "${1:-cleanup}" in
        "cleanup")
            cleanup_monitoring_stack
            ;;
        "force")
            force_cleanup_stuck_resources
            ;;
        "recover")
            recover_from_failed_deployment
            ;;
        "check")
            check_cleanup_status
            ;;
        *)
            echo "Usage: $0 {cleanup|force|recover|check}"
            echo "  cleanup  - Normal cleanup of monitoring stack"
            echo "  force    - Force cleanup of stuck resources"
            echo "  recover  - Recover from failed deployment"
            echo "  check    - Check cleanup status"
            exit 1
            ;;
    esac
    
    echo
    log_success "Cleanup operation completed!"
    echo
    echo "Next steps:"
    echo "1. Wait a few minutes for all resources to be fully cleaned up"
    echo "2. Run the fixed deployment script: ./deploy-prometheus-stack-fixed.sh"
    echo "3. Monitor the deployment for any issues"
    echo
}

# Execute main function
main "$@"


