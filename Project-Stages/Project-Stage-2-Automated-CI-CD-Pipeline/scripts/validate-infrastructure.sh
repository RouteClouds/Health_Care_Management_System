#!/bin/bash

# Infrastructure Validation Script
# Healthcare Management System - Stage 2
# Validates Kubernetes infrastructure and Helm charts

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
NAMESPACE="healthcare-system"
HELM_CHART_PATH="./helm-charts/healthcare-system"
TIMEOUT=300

echo -e "${BLUE}🔍 Healthcare Infrastructure Validation${NC}"
echo -e "${BLUE}======================================${NC}\n"

# Function to print status
print_status() {
    local status=$1
    local message=$2
    
    case $status in
        "success")
            echo -e "${GREEN}✅ $message${NC}"
            ;;
        "error")
            echo -e "${RED}❌ $message${NC}"
            ;;
        "warning")
            echo -e "${YELLOW}⚠️  $message${NC}"
            ;;
        "info")
            echo -e "${BLUE}ℹ️  $message${NC}"
            ;;
    esac
}

# Function to check command availability
check_command() {
    local cmd=$1
    if command -v "$cmd" &> /dev/null; then
        print_status "success" "$cmd is available"
        return 0
    else
        print_status "error" "$cmd is not available"
        return 1
    fi
}

# Function to validate Kubernetes connection
validate_k8s_connection() {
    print_status "info" "Validating Kubernetes connection..."
    
    if kubectl cluster-info &> /dev/null; then
        print_status "success" "Kubernetes cluster is accessible"
        
        # Get cluster info
        local cluster_info=$(kubectl cluster-info | head -1)
        print_status "info" "Cluster: $cluster_info"
        
        # Check node status
        local ready_nodes=$(kubectl get nodes --no-headers | grep -c "Ready")
        local total_nodes=$(kubectl get nodes --no-headers | wc -l)
        print_status "info" "Nodes: $ready_nodes/$total_nodes Ready"
        
        return 0
    else
        print_status "error" "Cannot connect to Kubernetes cluster"
        return 1
    fi
}

# Function to validate Helm chart
validate_helm_chart() {
    print_status "info" "Validating Helm chart..."
    
    if [ ! -d "$HELM_CHART_PATH" ]; then
        print_status "error" "Helm chart directory not found: $HELM_CHART_PATH"
        return 1
    fi
    
    # Check Chart.yaml
    if [ -f "$HELM_CHART_PATH/Chart.yaml" ]; then
        print_status "success" "Chart.yaml found"
    else
        print_status "error" "Chart.yaml not found"
        return 1
    fi
    
    # Check values.yaml
    if [ -f "$HELM_CHART_PATH/values.yaml" ]; then
        print_status "success" "values.yaml found"
    else
        print_status "error" "values.yaml not found"
        return 1
    fi
    
    # Check templates directory
    if [ -d "$HELM_CHART_PATH/templates" ]; then
        local template_count=$(find "$HELM_CHART_PATH/templates" -name "*.yaml" -o -name "*.yml" | wc -l)
        print_status "success" "Templates directory found ($template_count templates)"
    else
        print_status "error" "Templates directory not found"
        return 1
    fi
    
    # Validate Helm chart syntax
    if helm lint "$HELM_CHART_PATH" &> /dev/null; then
        print_status "success" "Helm chart syntax is valid"
    else
        print_status "error" "Helm chart syntax validation failed"
        helm lint "$HELM_CHART_PATH"
        return 1
    fi
    
    return 0
}

# Function to validate environment values
validate_environment_values() {
    print_status "info" "Validating environment-specific values..."
    
    local environments=("development" "staging" "production")
    local valid_envs=0
    
    for env in "${environments[@]}"; do
        local values_file="$HELM_CHART_PATH/values/$env.yaml"
        if [ -f "$values_file" ]; then
            print_status "success" "$env environment values found"
            
            # Validate YAML syntax
            if yq eval '.' "$values_file" &> /dev/null; then
                print_status "success" "$env values YAML syntax is valid"
                ((valid_envs++))
            else
                print_status "error" "$env values YAML syntax is invalid"
            fi
        else
            print_status "warning" "$env environment values not found"
        fi
    done
    
    if [ $valid_envs -gt 0 ]; then
        print_status "success" "$valid_envs environment configurations validated"
        return 0
    else
        print_status "error" "No valid environment configurations found"
        return 1
    fi
}

# Function to validate Kubernetes manifests
validate_k8s_manifests() {
    print_status "info" "Validating Kubernetes manifests..."
    
    local manifest_dir="./k8s"
    if [ ! -d "$manifest_dir" ]; then
        print_status "error" "Kubernetes manifests directory not found: $manifest_dir"
        return 1
    fi
    
    local manifest_count=0
    local valid_manifests=0
    
    # Find all YAML files
    while IFS= read -r -d '' file; do
        ((manifest_count++))
        
        # Validate YAML syntax
        if yq eval '.' "$file" &> /dev/null; then
            ((valid_manifests++))
        else
            print_status "error" "Invalid YAML syntax in $file"
        fi
        
        # Validate Kubernetes resource
        if kubectl apply --dry-run=client -f "$file" &> /dev/null; then
            print_status "success" "$(basename "$file") is valid"
        else
            print_status "error" "$(basename "$file") validation failed"
        fi
        
    done < <(find "$manifest_dir" -name "*.yaml" -o -name "*.yml" -print0)
    
    print_status "info" "Validated $valid_manifests/$manifest_count manifest files"
    
    if [ $valid_manifests -eq $manifest_count ] && [ $manifest_count -gt 0 ]; then
        return 0
    else
        return 1
    fi
}

# Function to validate monitoring setup
validate_monitoring() {
    print_status "info" "Validating monitoring configuration..."
    
    local monitoring_dir="./k8s/monitoring"
    if [ ! -d "$monitoring_dir" ]; then
        print_status "error" "Monitoring directory not found: $monitoring_dir"
        return 1
    fi
    
    # Check for Prometheus configuration
    if [ -f "$monitoring_dir/prometheus-config.yaml" ]; then
        print_status "success" "Prometheus configuration found"
    else
        print_status "error" "Prometheus configuration not found"
        return 1
    fi
    
    # Check for Prometheus deployment
    if [ -f "$monitoring_dir/prometheus-deployment.yaml" ]; then
        print_status "success" "Prometheus deployment found"
    else
        print_status "error" "Prometheus deployment not found"
        return 1
    fi
    
    return 0
}

# Function to validate namespace
validate_namespace() {
    print_status "info" "Validating namespace configuration..."
    
    # Check if namespace exists
    if kubectl get namespace "$NAMESPACE" &> /dev/null; then
        print_status "success" "Namespace '$NAMESPACE' exists"
    else
        print_status "warning" "Namespace '$NAMESPACE' does not exist (will be created during deployment)"
    fi
    
    return 0
}

# Function to validate storage classes
validate_storage() {
    print_status "info" "Validating storage configuration..."
    
    # Check for gp3 storage class (AWS EKS)
    if kubectl get storageclass gp3 &> /dev/null; then
        print_status "success" "gp3 storage class is available"
    else
        print_status "warning" "gp3 storage class not found (using default)"
    fi
    
    # Check for default storage class
    local default_sc=$(kubectl get storageclass -o jsonpath='{.items[?(@.metadata.annotations.storageclass\.kubernetes\.io/is-default-class=="true")].metadata.name}')
    if [ -n "$default_sc" ]; then
        print_status "success" "Default storage class: $default_sc"
    else
        print_status "warning" "No default storage class found"
    fi
    
    return 0
}

# Function to validate ingress controller
validate_ingress() {
    print_status "info" "Validating ingress configuration..."
    
    # Check for NGINX ingress controller
    if kubectl get pods -n ingress-nginx -l app.kubernetes.io/name=ingress-nginx &> /dev/null; then
        print_status "success" "NGINX ingress controller is running"
    else
        print_status "warning" "NGINX ingress controller not found"
    fi
    
    # Check for ingress class
    if kubectl get ingressclass nginx &> /dev/null; then
        print_status "success" "nginx ingress class is available"
    else
        print_status "warning" "nginx ingress class not found"
    fi
    
    return 0
}

# Function to run dry-run deployment
validate_deployment() {
    print_status "info" "Running dry-run deployment validation..."
    
    # Template the Helm chart
    if helm template healthcare-test "$HELM_CHART_PATH" --values "$HELM_CHART_PATH/values/development.yaml" > /tmp/healthcare-manifests.yaml; then
        print_status "success" "Helm chart templating successful"
    else
        print_status "error" "Helm chart templating failed"
        return 1
    fi
    
    # Validate the templated manifests
    if kubectl apply --dry-run=client -f /tmp/healthcare-manifests.yaml &> /dev/null; then
        print_status "success" "Dry-run deployment validation passed"
    else
        print_status "error" "Dry-run deployment validation failed"
        return 1
    fi
    
    # Clean up
    rm -f /tmp/healthcare-manifests.yaml
    
    return 0
}

# Main validation function
main() {
    local exit_code=0
    
    echo -e "${BLUE}📋 Checking Prerequisites${NC}"
    echo "================================"
    
    # Check required commands
    check_command "kubectl" || exit_code=1
    check_command "helm" || exit_code=1
    check_command "yq" || exit_code=1
    
    echo ""
    
    if [ $exit_code -ne 0 ]; then
        print_status "error" "Prerequisites check failed"
        exit 1
    fi
    
    echo -e "${BLUE}🔍 Infrastructure Validation${NC}"
    echo "================================"
    
    # Run validations
    validate_k8s_connection || exit_code=1
    echo ""
    
    validate_namespace || exit_code=1
    echo ""
    
    validate_storage || exit_code=1
    echo ""
    
    validate_ingress || exit_code=1
    echo ""
    
    validate_helm_chart || exit_code=1
    echo ""
    
    validate_environment_values || exit_code=1
    echo ""
    
    validate_k8s_manifests || exit_code=1
    echo ""
    
    validate_monitoring || exit_code=1
    echo ""
    
    validate_deployment || exit_code=1
    echo ""
    
    # Summary
    echo -e "${BLUE}📊 Validation Summary${NC}"
    echo "====================="
    
    if [ $exit_code -eq 0 ]; then
        print_status "success" "All infrastructure validations passed!"
        print_status "info" "Infrastructure is ready for deployment"
    else
        print_status "error" "Some validations failed"
        print_status "info" "Please fix the issues above before deployment"
    fi
    
    exit $exit_code
}

# Run main function
main "$@"
