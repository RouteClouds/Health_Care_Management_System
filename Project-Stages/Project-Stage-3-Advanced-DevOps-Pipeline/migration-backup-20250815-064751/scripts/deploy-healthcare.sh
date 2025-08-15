#!/bin/bash

# Healthcare System Deployment Script
# Stage 2 Enhanced Infrastructure
# Automated deployment with Helm charts

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Determine script location and set paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STAGE_DIR="$(dirname "$SCRIPT_DIR")"

# Default configuration
ENVIRONMENT="development"
NAMESPACE="healthcare-system"
HELM_CHART_PATH="$STAGE_DIR/helm-charts/healthcare-system"
RELEASE_NAME="healthcare-system"
TIMEOUT="600s"
DRY_RUN=false
FORCE=false
SKIP_VALIDATION=false

# Function to print usage
usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Deploy Healthcare Management System to Kubernetes

OPTIONS:
    -e, --environment ENV    Target environment (development|staging|production) [default: development]
    -n, --namespace NS       Kubernetes namespace [default: healthcare-system]
    -r, --release NAME       Helm release name [default: healthcare-system]
    -t, --timeout DURATION   Deployment timeout [default: 600s]
    -d, --dry-run           Perform dry-run deployment
    -f, --force             Force deployment (upgrade if exists)
    -s, --skip-validation   Skip pre-deployment validation
    -h, --help              Show this help message

EXAMPLES:
    $0                                          # Deploy to development
    $0 -e production -f                         # Force deploy to production
    $0 -e staging -d                           # Dry-run deploy to staging
    $0 -e development -n healthcare-dev        # Deploy to custom namespace

EOF
}

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

# Function to validate prerequisites
validate_prerequisites() {
    print_status "info" "Validating prerequisites..."
    
    # Check required commands
    local required_commands=("kubectl" "helm" "yq")
    for cmd in "${required_commands[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            print_status "error" "$cmd is required but not installed"
            exit 1
        fi
    done
    
    # Check Kubernetes connection
    if ! kubectl cluster-info &> /dev/null; then
        print_status "error" "Cannot connect to Kubernetes cluster"
        exit 1
    fi
    
    # Check Helm chart exists
    if [ ! -d "$HELM_CHART_PATH" ]; then
        print_status "error" "Helm chart not found: $HELM_CHART_PATH"
        exit 1
    fi
    
    # Check environment values file
    local values_file="$HELM_CHART_PATH/values/$ENVIRONMENT.yaml"
    if [ ! -f "$values_file" ]; then
        print_status "error" "Environment values file not found: $values_file"
        exit 1
    fi
    
    print_status "success" "Prerequisites validated"
}

# Function to create namespace if it doesn't exist
create_namespace() {
    print_status "info" "Checking namespace: $NAMESPACE"
    
    if kubectl get namespace "$NAMESPACE" &> /dev/null; then
        print_status "success" "Namespace '$NAMESPACE' already exists"
    else
        print_status "info" "Creating namespace: $NAMESPACE"
        kubectl create namespace "$NAMESPACE"
        
        # Add labels
        kubectl label namespace "$NAMESPACE" \
            app.kubernetes.io/name=healthcare-system \
            app.kubernetes.io/instance="$RELEASE_NAME" \
            environment="$ENVIRONMENT" \
            --overwrite
        
        print_status "success" "Namespace '$NAMESPACE' created"
    fi
}

# Function to validate deployment configuration
validate_deployment() {
    if [ "$SKIP_VALIDATION" = true ]; then
        print_status "warning" "Skipping deployment validation"
        return 0
    fi
    
    print_status "info" "Validating deployment configuration..."
    
    # Run infrastructure validation script
    local validation_script="$SCRIPT_DIR/validate-infrastructure.sh"
    if [ -f "$validation_script" ]; then
        if "$validation_script"; then
            print_status "success" "Infrastructure validation passed"
        else
            print_status "error" "Infrastructure validation failed"
            exit 1
        fi
    else
        print_status "warning" "Infrastructure validation script not found at: $validation_script"
    fi
    
    # Validate Helm chart
    if helm lint "$HELM_CHART_PATH" &> /dev/null; then
        print_status "success" "Helm chart validation passed"
    else
        print_status "error" "Helm chart validation failed"
        helm lint "$HELM_CHART_PATH"
        exit 1
    fi
    
    # Template and validate manifests
    local temp_file="/tmp/healthcare-manifests-$$.yaml"
    if helm template "$RELEASE_NAME" "$HELM_CHART_PATH" \
        --values "$HELM_CHART_PATH/values/$ENVIRONMENT.yaml" \
        --namespace "$NAMESPACE" > "$temp_file"; then
        
        if kubectl apply --dry-run=client -f "$temp_file" &> /dev/null; then
            print_status "success" "Manifest validation passed"
        else
            print_status "error" "Manifest validation failed"
            rm -f "$temp_file"
            exit 1
        fi
        
        rm -f "$temp_file"
    else
        print_status "error" "Helm templating failed"
        exit 1
    fi
}

# Function to deploy with Helm
deploy_helm_chart() {
    print_status "info" "Deploying Healthcare Management System..."
    
    local helm_args=(
        "$RELEASE_NAME"
        "$HELM_CHART_PATH"
        "--namespace" "$NAMESPACE"
        "--values" "$HELM_CHART_PATH/values/$ENVIRONMENT.yaml"
        "--timeout" "$TIMEOUT"
        "--wait"
        "--wait-for-jobs"
    )
    
    # Add dry-run flag if specified
    if [ "$DRY_RUN" = true ]; then
        helm_args+=("--dry-run")
        print_status "info" "Performing dry-run deployment"
    fi
    
    # Check if release exists
    if helm list -n "$NAMESPACE" | grep -q "$RELEASE_NAME"; then
        if [ "$FORCE" = true ] || [ "$DRY_RUN" = true ]; then
            print_status "info" "Upgrading existing release: $RELEASE_NAME"
            helm upgrade "${helm_args[@]}"
        else
            print_status "error" "Release '$RELEASE_NAME' already exists. Use --force to upgrade"
            exit 1
        fi
    else
        print_status "info" "Installing new release: $RELEASE_NAME"
        helm install "${helm_args[@]}"
    fi
    
    if [ "$DRY_RUN" = false ]; then
        print_status "success" "Deployment completed successfully"
    else
        print_status "success" "Dry-run completed successfully"
    fi
}

# Function to verify deployment
verify_deployment() {
    if [ "$DRY_RUN" = true ]; then
        return 0
    fi
    
    print_status "info" "Verifying deployment..."
    
    # Check Helm release status
    local release_status=$(helm status "$RELEASE_NAME" -n "$NAMESPACE" -o json | jq -r '.info.status')
    if [ "$release_status" = "deployed" ]; then
        print_status "success" "Helm release status: $release_status"
    else
        print_status "error" "Helm release status: $release_status"
        return 1
    fi
    
    # Check pod status
    print_status "info" "Checking pod status..."
    local ready_pods=0
    local total_pods=0
    
    while IFS= read -r line; do
        if [[ $line =~ ^[^[:space:]]+[[:space:]]+([0-9]+)/([0-9]+) ]]; then
            local pod_ready=${BASH_REMATCH[1]}
            local pod_total=${BASH_REMATCH[2]}
            ready_pods=$((ready_pods + pod_ready))
            total_pods=$((total_pods + pod_total))
        fi
    done < <(kubectl get pods -n "$NAMESPACE" --no-headers 2>/dev/null || true)
    
    if [ $total_pods -gt 0 ]; then
        print_status "info" "Pods ready: $ready_pods/$total_pods"
        if [ $ready_pods -eq $total_pods ]; then
            print_status "success" "All pods are ready"
        else
            print_status "warning" "Some pods are not ready yet"
        fi
    else
        print_status "warning" "No pods found in namespace"
    fi
    
    # Check service status
    local service_count=$(kubectl get services -n "$NAMESPACE" --no-headers 2>/dev/null | wc -l || echo "0")
    if [ $service_count -gt 0 ]; then
        print_status "success" "Services created: $service_count"
    else
        print_status "warning" "No services found"
    fi
    
    # Check ingress status
    local ingress_count=$(kubectl get ingress -n "$NAMESPACE" --no-headers 2>/dev/null | wc -l || echo "0")
    if [ $ingress_count -gt 0 ]; then
        print_status "success" "Ingress resources created: $ingress_count"
    else
        print_status "info" "No ingress resources found"
    fi
}

# Function to show deployment information
show_deployment_info() {
    if [ "$DRY_RUN" = true ]; then
        return 0
    fi
    
    echo ""
    print_status "info" "Deployment Information"
    echo "======================"
    
    # Helm release info
    echo -e "${BLUE}Helm Release:${NC}"
    helm list -n "$NAMESPACE" | grep "$RELEASE_NAME" || true
    echo ""
    
    # Pod status
    echo -e "${BLUE}Pods:${NC}"
    kubectl get pods -n "$NAMESPACE" -o wide || true
    echo ""
    
    # Service status
    echo -e "${BLUE}Services:${NC}"
    kubectl get services -n "$NAMESPACE" || true
    echo ""
    
    # Ingress status
    echo -e "${BLUE}Ingress:${NC}"
    kubectl get ingress -n "$NAMESPACE" || true
    echo ""
    
    # Get application URLs
    local frontend_url=$(kubectl get ingress -n "$NAMESPACE" -o jsonpath='{.items[?(@.metadata.name=="healthcare-system-frontend")].spec.rules[0].host}' 2>/dev/null || echo "")
    local backend_url=$(kubectl get ingress -n "$NAMESPACE" -o jsonpath='{.items[?(@.metadata.name=="healthcare-system-backend")].spec.rules[0].host}' 2>/dev/null || echo "")
    
    if [ -n "$frontend_url" ]; then
        print_status "info" "Frontend URL: https://$frontend_url"
    fi
    
    if [ -n "$backend_url" ]; then
        print_status "info" "Backend API URL: https://$backend_url"
    fi
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -e|--environment)
            ENVIRONMENT="$2"
            shift 2
            ;;
        -n|--namespace)
            NAMESPACE="$2"
            shift 2
            ;;
        -r|--release)
            RELEASE_NAME="$2"
            shift 2
            ;;
        -t|--timeout)
            TIMEOUT="$2"
            shift 2
            ;;
        -d|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -f|--force)
            FORCE=true
            shift
            ;;
        -s|--skip-validation)
            SKIP_VALIDATION=true
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

# Validate environment
if [[ ! "$ENVIRONMENT" =~ ^(development|staging|production)$ ]]; then
    print_status "error" "Invalid environment: $ENVIRONMENT"
    print_status "info" "Valid environments: development, staging, production"
    exit 1
fi

# Main deployment process
main() {
    echo -e "${BLUE}🚀 Healthcare Management System Deployment${NC}"
    echo -e "${BLUE}===========================================${NC}"
    echo ""
    echo -e "${BLUE}Configuration:${NC}"
    echo "  Environment: $ENVIRONMENT"
    echo "  Namespace: $NAMESPACE"
    echo "  Release: $RELEASE_NAME"
    echo "  Timeout: $TIMEOUT"
    echo "  Dry Run: $DRY_RUN"
    echo "  Force: $FORCE"
    echo ""
    
    # Execute deployment steps
    validate_prerequisites
    echo ""
    
    create_namespace
    echo ""
    
    validate_deployment
    echo ""
    
    deploy_helm_chart
    echo ""
    
    verify_deployment
    echo ""
    
    show_deployment_info
    
    if [ "$DRY_RUN" = false ]; then
        print_status "success" "Healthcare Management System deployed successfully!"
        print_status "info" "Environment: $ENVIRONMENT"
        print_status "info" "Namespace: $NAMESPACE"
    else
        print_status "success" "Dry-run deployment validation completed!"
    fi
}

# Run main function
main
