#!/bin/bash

echo "🏗️ Infrastructure Validation Script"
echo "=================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Configuration
AWS_REGION="us-east-1"
CLUSTER_NAME="healthcare-eks-stage3-dev"
NAMESPACE="healthcare-stage3-dev"

# Validation counters
TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0

validate_check() {
    TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
    if [ $1 -eq 0 ]; then
        PASSED_CHECKS=$((PASSED_CHECKS + 1))
        log_success "$2"
    else
        FAILED_CHECKS=$((FAILED_CHECKS + 1))
        log_error "$2"
    fi
}

log_info "Starting infrastructure validation..."

# 1. Validate AWS CLI and credentials
log_info "1. Validating AWS credentials..."
aws sts get-caller-identity > /dev/null 2>&1
validate_check $? "AWS credentials are valid"

# 2. Validate EKS cluster
log_info "2. Validating EKS cluster..."
aws eks describe-cluster --name $CLUSTER_NAME --region $AWS_REGION > /dev/null 2>&1
validate_check $? "EKS cluster '$CLUSTER_NAME' exists and is accessible"

# 3. Validate kubectl configuration
log_info "3. Validating kubectl configuration..."
kubectl cluster-info > /dev/null 2>&1
validate_check $? "kubectl is configured and can access cluster"

# 4. Validate EKS node groups
log_info "4. Validating EKS node groups..."
NODE_GROUPS=$(aws eks list-nodegroups --cluster-name $CLUSTER_NAME --region $AWS_REGION --query 'nodegroups' --output text)
if [ -n "$NODE_GROUPS" ]; then
    validate_check 0 "EKS node groups are configured: $NODE_GROUPS"
else
    validate_check 1 "No EKS node groups found"
fi

# 5. Validate nodes are ready
log_info "5. Validating Kubernetes nodes..."
READY_NODES=$(kubectl get nodes --no-headers | grep -c "Ready")
TOTAL_NODES=$(kubectl get nodes --no-headers | wc -l)
if [ $READY_NODES -eq $TOTAL_NODES ] && [ $TOTAL_NODES -gt 0 ]; then
    validate_check 0 "All $TOTAL_NODES Kubernetes nodes are Ready"
else
    validate_check 1 "Node status issue: $READY_NODES/$TOTAL_NODES nodes Ready"
fi

# 6. Validate RDS database
log_info "6. Validating RDS database..."
RDS_INSTANCES=$(aws rds describe-db-instances --region $AWS_REGION --query 'DBInstances[?contains(DBInstanceIdentifier, `healthcare-eks-stage3-dev-db`)].DBInstanceStatus' --output text)
if echo "$RDS_INSTANCES" | grep -q "available"; then
    validate_check 0 "RDS database is available"
else
    validate_check 1 "RDS database is not available or not found"
fi

# 7. Validate ECR repositories
log_info "7. Validating ECR repositories..."
FRONTEND_REPO=$(aws ecr describe-repositories --repository-names healthcare-frontend-stage3 --region $AWS_REGION 2>/dev/null)
BACKEND_REPO=$(aws ecr describe-repositories --repository-names healthcare-backend-stage3 --region $AWS_REGION 2>/dev/null)

if [ -n "$FRONTEND_REPO" ]; then
    validate_check 0 "ECR frontend repository exists"
else
    validate_check 1 "ECR frontend repository not found"
fi

if [ -n "$BACKEND_REPO" ]; then
    validate_check 0 "ECR backend repository exists"
else
    validate_check 1 "ECR backend repository not found"
fi

# 8. Validate namespace
log_info "8. Validating Kubernetes namespace..."
kubectl get namespace $NAMESPACE > /dev/null 2>&1
validate_check $? "Namespace '$NAMESPACE' exists"

# 9. Validate load balancer
log_info "9. Validating load balancer..."
LB_STATUS=$(kubectl get service frontend-stage3-svc -n $NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null)
if [ -n "$LB_STATUS" ]; then
    validate_check 0 "Load balancer is configured: $LB_STATUS"
else
    validate_check 1 "Load balancer not found or not ready"
fi

# 10. Validate security groups
log_info "10. Validating security groups..."
SECURITY_GROUPS=$(aws ec2 describe-security-groups --filters "Name=group-name,Values=*healthcare*" --region $AWS_REGION --query 'SecurityGroups[].GroupId' --output text)
if [ -n "$SECURITY_GROUPS" ]; then
    validate_check 0 "Security groups are configured"
else
    validate_check 1 "No healthcare-related security groups found"
fi

# 11. Validate VPC and subnets
log_info "11. Validating VPC and subnets..."
VPC_ID=$(aws eks describe-cluster --name $CLUSTER_NAME --region $AWS_REGION --query 'cluster.resourcesVpcConfig.vpcId' --output text 2>/dev/null)
if [ -n "$VPC_ID" ] && [ "$VPC_ID" != "None" ]; then
    validate_check 0 "VPC is configured: $VPC_ID"
else
    validate_check 1 "VPC configuration not found"
fi

# 12. Validate IAM roles
log_info "12. Validating IAM roles..."
CLUSTER_ROLE=$(aws eks describe-cluster --name $CLUSTER_NAME --region $AWS_REGION --query 'cluster.roleArn' --output text 2>/dev/null)
if [ -n "$CLUSTER_ROLE" ] && [ "$CLUSTER_ROLE" != "None" ]; then
    validate_check 0 "EKS cluster IAM role is configured"
else
    validate_check 1 "EKS cluster IAM role not found"
fi

# Summary
echo ""
echo "=================================="
echo "📊 Infrastructure Validation Summary"
echo "=================================="
echo "Total Checks: $TOTAL_CHECKS"
echo "Passed: $PASSED_CHECKS"
echo "Failed: $FAILED_CHECKS"

if [ $FAILED_CHECKS -eq 0 ]; then
    log_success "🎉 All infrastructure validation checks passed!"
    echo ""
    echo "✅ Infrastructure is ready for application deployment"
    exit 0
else
    log_error "❌ $FAILED_CHECKS infrastructure validation checks failed"
    echo ""
    echo "🔧 Please fix the failed checks before proceeding with deployment"
    exit 1
fi
