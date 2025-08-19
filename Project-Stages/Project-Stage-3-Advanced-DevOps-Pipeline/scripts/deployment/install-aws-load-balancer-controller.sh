#!/bin/bash

# AWS Load Balancer Controller Installation Script
# Ensures Application Load Balancer (ALB) support for Kubernetes Ingress

set -euo pipefail

CLUSTER_NAME="${1:-healthcare-eks-stage3-dev}"
REGION="${AWS_REGION:-us-east-1}"
NAMESPACE="kube-system"

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

log_info "🔧 Installing AWS Load Balancer Controller for ALB support..."
log_info "Cluster: $CLUSTER_NAME"
log_info "Region: $REGION"

# Check if kubectl is available
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
log_info "🔍 Checking cluster connectivity..."
if ! kubectl cluster-info &> /dev/null; then
    log_error "Cannot connect to Kubernetes cluster"
    exit 1
fi
log_success "Connected to cluster"

# Get AWS Account ID
log_info "🔍 Getting AWS Account ID..."
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
if [[ -z "$AWS_ACCOUNT_ID" ]]; then
    log_error "Failed to get AWS Account ID"
    exit 1
fi
log_success "AWS Account ID: $AWS_ACCOUNT_ID"

# Check if AWS Load Balancer Controller is already installed
log_info "🔍 Checking if AWS Load Balancer Controller is already installed..."
if kubectl get deployment aws-load-balancer-controller -n $NAMESPACE &> /dev/null; then
    log_warning "AWS Load Balancer Controller is already installed"
    
    # Check if it's running
    READY_REPLICAS=$(kubectl get deployment aws-load-balancer-controller -n $NAMESPACE -o jsonpath='{.status.readyReplicas}' 2>/dev/null || echo "0")
    if [[ "$READY_REPLICAS" -gt 0 ]]; then
        log_success "AWS Load Balancer Controller is running ($READY_REPLICAS replicas ready)"
        log_info "✅ ALB support is already available"
        exit 0
    else
        log_warning "AWS Load Balancer Controller exists but not ready, reinstalling..."
        kubectl delete deployment aws-load-balancer-controller -n $NAMESPACE || true
    fi
fi

# Create IAM service account for AWS Load Balancer Controller
log_info "🔐 Creating IAM service account for AWS Load Balancer Controller..."

# Download IAM policy
log_info "📥 Downloading AWS Load Balancer Controller IAM policy..."
curl -o iam_policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.7.2/docs/install/iam_policy.json

# Create IAM policy
log_info "🔐 Creating IAM policy..."
POLICY_ARN="arn:aws:iam::${AWS_ACCOUNT_ID}:policy/AWSLoadBalancerControllerIAMPolicy"

# Check if policy already exists
if aws iam get-policy --policy-arn "$POLICY_ARN" &> /dev/null; then
    log_warning "IAM policy already exists: $POLICY_ARN"
else
    aws iam create-policy \
        --policy-name AWSLoadBalancerControllerIAMPolicy \
        --policy-document file://iam_policy.json
    log_success "Created IAM policy: $POLICY_ARN"
fi

# Clean up downloaded file
rm -f iam_policy.json

# Create service account with IAM role
log_info "🔐 Creating service account with IAM role..."
eksctl create iamserviceaccount \
  --cluster="$CLUSTER_NAME" \
  --namespace="$NAMESPACE" \
  --name=aws-load-balancer-controller \
  --role-name AmazonEKSLoadBalancerControllerRole \
  --attach-policy-arn="$POLICY_ARN" \
  --approve \
  --region="$REGION" \
  --override-existing-serviceaccounts || {
    log_warning "Service account creation failed or already exists, continuing..."
}

# Add EKS Helm repository
log_info "📦 Adding EKS Helm repository..."
helm repo add eks https://aws.github.io/eks-charts
helm repo update

# Install AWS Load Balancer Controller
log_info "🚀 Installing AWS Load Balancer Controller..."
helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n $NAMESPACE \
  --set clusterName="$CLUSTER_NAME" \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller \
  --set region="$REGION" \
  --set vpcId=$(aws eks describe-cluster --name "$CLUSTER_NAME" --region "$REGION" --query "cluster.resourcesVpcConfig.vpcId" --output text) \
  --wait

# Verify installation
log_info "🔍 Verifying AWS Load Balancer Controller installation..."
kubectl wait --for=condition=available --timeout=300s deployment/aws-load-balancer-controller -n $NAMESPACE

# Check controller status
READY_REPLICAS=$(kubectl get deployment aws-load-balancer-controller -n $NAMESPACE -o jsonpath='{.status.readyReplicas}')
DESIRED_REPLICAS=$(kubectl get deployment aws-load-balancer-controller -n $NAMESPACE -o jsonpath='{.spec.replicas}')

if [[ "$READY_REPLICAS" == "$DESIRED_REPLICAS" && "$READY_REPLICAS" -gt 0 ]]; then
    log_success "✅ AWS Load Balancer Controller is running ($READY_REPLICAS/$DESIRED_REPLICAS replicas ready)"
else
    log_error "❌ AWS Load Balancer Controller is not ready ($READY_REPLICAS/$DESIRED_REPLICAS replicas ready)"
    exit 1
fi

# Verify controller logs
log_info "📋 Checking controller logs for any errors..."
kubectl logs deployment/aws-load-balancer-controller -n $NAMESPACE --tail=10 | grep -i error || log_success "No errors found in controller logs"

log_success "🎉 AWS Load Balancer Controller installation completed!"
log_info "✅ Application Load Balancer (ALB) support is now available"
log_info "🔗 Ingress resources with 'kubernetes.io/ingress.class: alb' will create ALBs"

# Display configuration summary
echo ""
echo "📋 Configuration Summary:"
echo "========================"
echo "🏷️ Cluster: $CLUSTER_NAME"
echo "🌍 Region: $REGION"
echo "🔐 AWS Account: $AWS_ACCOUNT_ID"
echo "📦 Controller: aws-load-balancer-controller"
echo "🏠 Namespace: $NAMESPACE"
echo "✅ Status: Ready"
echo ""
echo "💡 To create an Application Load Balancer, use Ingress with:"
echo "   annotations:"
echo "     kubernetes.io/ingress.class: alb"
echo "     alb.ingress.kubernetes.io/scheme: internet-facing"
echo "     alb.ingress.kubernetes.io/target-type: ip"
