#!/bin/bash

# Complete Infrastructure Destruction Script
# This script destroys ALL AWS infrastructure created for Stage-3 Healthcare System

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
TERRAFORM_DIR="${PROJECT_ROOT}/terraform/environments/dev"
CLUSTER_NAME="healthcare-eks-stage3-dev"
REGION="us-east-1"

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

# Confirmation function
confirm_destruction() {
    echo "🚨 COMPLETE INFRASTRUCTURE DESTRUCTION"
    echo "======================================"
    echo
    echo "⚠️  WARNING: This will PERMANENTLY DELETE:"
    echo "   • EKS Cluster: $CLUSTER_NAME"
    echo "   • RDS Database with ALL DATA"
    echo "   • VPC and all networking components"
    echo "   • ECR repositories and container images"
    echo "   • Load balancers and security groups"
    echo "   • All persistent volumes and data"
    echo "   • IAM roles and policies"
    echo "   • ALL monitoring and logging data"
    echo
    echo "💰 This will also stop all AWS charges for these resources."
    echo
    echo "🔄 This action CANNOT be undone!"
    echo
    read -p "Type 'DESTROY' to confirm complete infrastructure destruction: " -r
    if [[ ! $REPLY == "DESTROY" ]]; then
        echo "Destruction cancelled."
        exit 0
    fi
    
    echo
    read -p "Are you absolutely sure? Type 'YES' to proceed: " -r
    if [[ ! $REPLY == "YES" ]]; then
        echo "Destruction cancelled."
        exit 0
    fi
}

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    # Check AWS CLI
    if ! command -v aws &> /dev/null; then
        log_error "AWS CLI is not installed"
        exit 1
    fi
    
    # Check Terraform
    if ! command -v terraform &> /dev/null; then
        log_error "Terraform is not installed"
        exit 1
    fi
    
    # Check kubectl
    if ! command -v kubectl &> /dev/null; then
        log_error "kubectl is not installed"
        exit 1
    fi
    
    # Check AWS credentials
    if ! aws sts get-caller-identity &> /dev/null; then
        log_error "AWS credentials not configured"
        exit 1
    fi
    
    log_success "Prerequisites check completed"
}

# Clean up Kubernetes resources first
cleanup_kubernetes_resources() {
    log_info "Cleaning up Kubernetes resources..."
    
    # Update kubeconfig
    if aws eks update-kubeconfig --region "$REGION" --name "$CLUSTER_NAME" &> /dev/null; then
        log_success "Connected to EKS cluster"
        
        # Delete all applications in healthcare namespace
        log_info "Deleting healthcare applications..."
        kubectl delete namespace healthcare-stage3-dev --ignore-not-found=true --timeout=300s || log_warning "Healthcare namespace deletion timeout"
        
        # Delete monitoring namespace
        log_info "Deleting monitoring namespace..."
        kubectl delete namespace monitoring --ignore-not-found=true --timeout=300s || log_warning "Monitoring namespace deletion timeout"
        
        # Delete ArgoCD namespace
        log_info "Deleting ArgoCD namespace..."
        kubectl delete namespace argocd --ignore-not-found=true --timeout=300s || log_warning "ArgoCD namespace deletion timeout"
        
        # Force delete any stuck namespaces
        for ns in healthcare-stage3-dev monitoring argocd; do
            if kubectl get namespace "$ns" &> /dev/null; then
                log_warning "Force deleting stuck namespace: $ns"
                kubectl patch namespace "$ns" -p '{"metadata":{"finalizers":null}}' 2>/dev/null || true
                kubectl delete namespace "$ns" --force --grace-period=0 2>/dev/null || true
            fi
        done
        
        # Delete any remaining PVCs
        log_info "Deleting any remaining PVCs..."
        kubectl delete pvc --all --all-namespaces --timeout=300s || log_warning "PVC deletion timeout"
        
        log_success "Kubernetes resources cleaned up"
    else
        log_warning "Could not connect to EKS cluster (may already be deleted)"
    fi
}

# Clean up AWS Load Balancers manually
cleanup_load_balancers() {
    log_info "Cleaning up AWS Load Balancers..."
    
    # Get all load balancers with healthcare tag
    local lbs=$(aws elbv2 describe-load-balancers --region "$REGION" --query 'LoadBalancers[?contains(LoadBalancerName, `healthcare`) || contains(LoadBalancerName, `stage3`)].LoadBalancerArn' --output text 2>/dev/null || echo "")
    
    if [[ -n "$lbs" ]]; then
        for lb in $lbs; do
            log_info "Deleting load balancer: $lb"
            aws elbv2 delete-load-balancer --load-balancer-arn "$lb" --region "$REGION" 2>/dev/null || log_warning "Failed to delete load balancer"
        done
    fi
    
    # Clean up classic load balancers too
    local classic_lbs=$(aws elb describe-load-balancers --region "$REGION" --query 'LoadBalancerDescriptions[?contains(LoadBalancerName, `healthcare`) || contains(LoadBalancerName, `stage3`)].LoadBalancerName' --output text 2>/dev/null || echo "")
    
    if [[ -n "$classic_lbs" ]]; then
        for lb in $classic_lbs; do
            log_info "Deleting classic load balancer: $lb"
            aws elb delete-load-balancer --load-balancer-name "$lb" --region "$REGION" 2>/dev/null || log_warning "Failed to delete classic load balancer"
        done
    fi
    
    log_success "Load balancers cleanup completed"
}

# Run Terraform destroy
run_terraform_destroy() {
    log_info "Running Terraform destroy..."
    
    if [[ ! -d "$TERRAFORM_DIR" ]]; then
        log_error "Terraform directory not found: $TERRAFORM_DIR"
        exit 1
    fi
    
    cd "$TERRAFORM_DIR"
    
    # Initialize Terraform
    log_info "Initializing Terraform..."
    terraform init
    
    # Show what will be destroyed
    log_info "Planning destruction..."
    terraform plan -destroy -out=destroy.tfplan
    
    # Apply destruction
    log_info "Applying destruction plan..."
    terraform apply destroy.tfplan
    
    # Clean up plan file
    rm -f destroy.tfplan
    
    log_success "Terraform destroy completed"
}

# Clean up any remaining AWS resources
cleanup_remaining_resources() {
    log_info "Cleaning up any remaining AWS resources..."
    
    # Clean up ECR repositories
    log_info "Cleaning up ECR repositories..."
    local ecr_repos=$(aws ecr describe-repositories --region "$REGION" --query 'repositories[?contains(repositoryName, `healthcare`) || contains(repositoryName, `stage3`)].repositoryName' --output text 2>/dev/null || echo "")
    
    if [[ -n "$ecr_repos" ]]; then
        for repo in $ecr_repos; do
            log_info "Deleting ECR repository: $repo"
            aws ecr delete-repository --repository-name "$repo" --region "$REGION" --force 2>/dev/null || log_warning "Failed to delete ECR repository"
        done
    fi
    
    # Clean up any remaining security groups
    log_info "Cleaning up security groups..."
    local sgs=$(aws ec2 describe-security-groups --region "$REGION" --query 'SecurityGroups[?contains(GroupName, `healthcare`) || contains(GroupName, `stage3`)].GroupId' --output text 2>/dev/null || echo "")
    
    if [[ -n "$sgs" ]]; then
        for sg in $sgs; do
            log_info "Attempting to delete security group: $sg"
            aws ec2 delete-security-group --group-id "$sg" --region "$REGION" 2>/dev/null || log_warning "Could not delete security group (may have dependencies)"
        done
    fi
    
    log_success "Remaining resources cleanup completed"
}

# Verify destruction
verify_destruction() {
    log_info "Verifying infrastructure destruction..."
    
    local issues_found=false
    
    # Check EKS cluster
    if aws eks describe-cluster --name "$CLUSTER_NAME" --region "$REGION" &> /dev/null; then
        log_error "❌ EKS cluster still exists"
        issues_found=true
    else
        log_success "✅ EKS cluster destroyed"
    fi
    
    # Check RDS instances
    local rds_instances=$(aws rds describe-db-instances --region "$REGION" --query 'DBInstances[?contains(DBInstanceIdentifier, `healthcare`) || contains(DBInstanceIdentifier, `stage3`)].DBInstanceIdentifier' --output text 2>/dev/null || echo "")
    if [[ -n "$rds_instances" ]]; then
        log_error "❌ RDS instances still exist: $rds_instances"
        issues_found=true
    else
        log_success "✅ RDS instances destroyed"
    fi
    
    # Check VPCs
    local vpcs=$(aws ec2 describe-vpcs --region "$REGION" --query 'Vpcs[?Tags[?Key==`Name` && (contains(Value, `healthcare`) || contains(Value, `stage3`))]].VpcId' --output text 2>/dev/null || echo "")
    if [[ -n "$vpcs" ]]; then
        log_error "❌ VPCs still exist: $vpcs"
        issues_found=true
    else
        log_success "✅ VPCs destroyed"
    fi
    
    # Check ECR repositories
    local ecr_repos=$(aws ecr describe-repositories --region "$REGION" --query 'repositories[?contains(repositoryName, `healthcare`) || contains(repositoryName, `stage3`)].repositoryName' --output text 2>/dev/null || echo "")
    if [[ -n "$ecr_repos" ]]; then
        log_warning "⚠️  ECR repositories still exist: $ecr_repos"
    else
        log_success "✅ ECR repositories destroyed"
    fi
    
    if [[ "$issues_found" == "false" ]]; then
        log_success "🎉 Infrastructure destruction verification completed successfully!"
    else
        log_warning "⚠️  Some resources may still exist. Check AWS console for manual cleanup."
    fi
}

# Main execution
main() {
    echo "🚨 Healthcare System - Complete Infrastructure Destruction"
    echo "========================================================="
    
    confirm_destruction
    check_prerequisites
    cleanup_kubernetes_resources
    cleanup_load_balancers
    run_terraform_destroy
    cleanup_remaining_resources
    verify_destruction
    
    echo
    log_success "🎉 Complete infrastructure destruction completed!"
    echo
    echo "💰 All AWS resources have been destroyed and billing should stop."
    echo "🔄 You can recreate the infrastructure anytime using the deployment scripts."
    echo
    echo "📋 Summary of destroyed resources:"
    echo "   • EKS Cluster and all workloads"
    echo "   • RDS Database and all data"
    echo "   • VPC and networking components"
    echo "   • Load balancers and security groups"
    echo "   • ECR repositories and container images"
    echo "   • IAM roles and policies"
    echo "   • All persistent storage and data"
}

# Execute main function
main "$@"
