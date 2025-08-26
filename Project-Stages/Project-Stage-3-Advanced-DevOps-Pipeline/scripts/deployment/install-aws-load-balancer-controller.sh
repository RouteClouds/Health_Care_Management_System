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
    log_warning "AWS Load Balancer Controller deployment already exists"
    # Check if it's running
    READY_REPLICAS=$(kubectl get deployment aws-load-balancer-controller -n $NAMESPACE -o jsonpath='{.status.readyReplicas}' 2>/dev/null || echo "0")
    if [[ "$READY_REPLICAS" -gt 0 ]]; then
        log_success "AWS Load Balancer Controller is running ($READY_REPLICAS replicas ready)"
        log_info "ℹ️ Ensuring IAM policy/IRSA are correct and chart is up-to-date..."
        # Do NOT exit here; continue to ensure IAM policy, IRSA, and helm chart are correct
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

# Create or update IAM policy
log_info "🔐 Ensuring IAM policy is up-to-date..."
POLICY_ARN="arn:aws:iam::${AWS_ACCOUNT_ID}:policy/AWSLoadBalancerControllerIAMPolicy"

if aws iam get-policy --policy-arn "$POLICY_ARN" &> /dev/null; then
    log_warning "IAM policy already exists: $POLICY_ARN"
    log_info "🔄 Updating IAM policy document to latest upstream (setting new default version)"

    # Prune non-default versions if at version limit
    VERSION_COUNT=$(aws iam list-policy-versions --policy-arn "$POLICY_ARN" --query 'Versions | length(@)' --output text)
    if [[ "$VERSION_COUNT" -ge 5 ]]; then
      log_info "🧹 Pruning non-default policy versions to allow update..."
      NON_DEFAULT_VERSIONS=$(aws iam list-policy-versions --policy-arn "$POLICY_ARN" --query 'Versions[?IsDefaultVersion==`false`].VersionId' --output text | tr '\t' '\n')
      for VID in $NON_DEFAULT_VERSIONS; do
        aws iam delete-policy-version --policy-arn "$POLICY_ARN" --version-id "$VID" || true
        VERSION_COUNT=$(aws iam list-policy-versions --policy-arn "$POLICY_ARN" --query 'Versions | length(@)' --output text)
        [[ "$VERSION_COUNT" -lt 5 ]] && break || true
      done
    fi

    aws iam create-policy-version \
      --policy-arn "$POLICY_ARN" \
      --policy-document file://iam_policy.json \
      --set-as-default
    log_success "✅ IAM policy updated to latest and set as default"
else
    log_info "🆕 Creating IAM policy..."
    aws iam create-policy \
        --policy-name AWSLoadBalancerControllerIAMPolicy \
        --policy-document file://iam_policy.json
    log_success "Created IAM policy: $POLICY_ARN"
fi

# Clean up downloaded file
rm -f iam_policy.json

# Associate OIDC provider for IRSA (idempotent)
log_info "🔐 Ensuring OIDC provider is associated with the EKS cluster..."
eksctl utils associate-iam-oidc-provider --cluster="$CLUSTER_NAME" --region="$REGION" --approve || true

# Complete IAM cleanup and recreation to fix persistent AccessDenied errors
log_info "🔐 Performing complete IAM cleanup and recreation..."

# Step 1: Delete existing controller deployment to stop using old credentials
log_info "🗑️ Deleting existing controller deployment..."
kubectl delete deployment aws-load-balancer-controller -n "$NAMESPACE" || true

# Step 2: Delete existing service account and wait for complete cleanup
log_info "🗑️ Deleting existing service account and IAM role..."
eksctl delete iamserviceaccount \
  --cluster="$CLUSTER_NAME" \
  --namespace="$NAMESPACE" \
  --name=aws-load-balancer-controller \
  --region="$REGION" \
  --wait || true

# Step 3: Manually delete IAM role if it still exists (force cleanup)
log_info "🧹 Ensuring IAM role is completely removed..."
ROLE_NAME="AmazonEKSLoadBalancerControllerRole"
if aws iam get-role --role-name "$ROLE_NAME" >/dev/null 2>&1; then
  log_info "🗑️ Manually deleting IAM role: $ROLE_NAME"
  # Detach policies first
  aws iam list-attached-role-policies --role-name "$ROLE_NAME" --query 'AttachedPolicies[].PolicyArn' --output text | \
    xargs -I {} aws iam detach-role-policy --role-name "$ROLE_NAME" --policy-arn {} || true
  # Delete role
  aws iam delete-role --role-name "$ROLE_NAME" || true
fi

# Step 4: Wait for AWS IAM propagation
log_info "⏳ Waiting for AWS IAM propagation (60 seconds)..."
sleep 60

# Step 5: Verify complete cleanup
log_info "🔍 Verifying complete cleanup..."
for i in {1..30}; do
  if ! kubectl get serviceaccount aws-load-balancer-controller -n "$NAMESPACE" >/dev/null 2>&1 && \
     ! aws iam get-role --role-name "$ROLE_NAME" >/dev/null 2>&1; then
    log_success "✅ Complete cleanup verified"
    break
  fi
  log_info "⏳ Waiting for complete cleanup... (attempt $i/30)"
  sleep 2
done

# Step 6: Create fresh service account with updated IAM policy
log_info "🔧 Creating fresh service account with updated IAM policy..."
eksctl create iamserviceaccount \
  --cluster="$CLUSTER_NAME" \
  --namespace="$NAMESPACE" \
  --name=aws-load-balancer-controller \
  --role-name="$ROLE_NAME" \
  --attach-policy-arn="$POLICY_ARN" \
  --approve \
  --region="$REGION" || {
    log_error "Service account creation failed"
    exit 1
}

# Step 7: Verify service account and IAM role are ready
log_info "🔍 Verifying service account and IAM role are ready..."
kubectl wait --for=condition=ready serviceaccount/aws-load-balancer-controller -n "$NAMESPACE" --timeout=60s || true
if aws iam get-role --role-name "$ROLE_NAME" >/dev/null 2>&1; then
  log_success "✅ IAM role created successfully"
  log_info "🔐 Attaching inline policy for missing DescribeListenerAttributes permissions..."
  cat > /tmp/alb_extra_policy.json <<'EOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "elasticloadbalancing:DescribeListenerAttributes",
        "elasticloadbalancing:DescribeListeners",
        "elasticloadbalancing:DescribeLoadBalancerAttributes"
      ],
      "Resource": "*"
    }
  ]
}
EOF
  aws iam put-role-policy \
    --role-name "$ROLE_NAME" \
    --policy-name "ALBControllerExtraPermissions" \
    --policy-document file:///tmp/alb_extra_policy.json || true
else
  log_error "❌ IAM role creation failed"
  exit 1
fi

# Add EKS Helm repository
log_info "📦 Adding EKS Helm repository..."
helm repo add eks https://aws.github.io/eks-charts
helm repo update

# Install AWS Load Balancer Controller with fresh IAM credentials
log_info "🚀 Installing AWS Load Balancer Controller with fresh IAM credentials..."

# Install with extended timeout and retry logic
log_info "📦 Installing Helm chart with extended timeout..."
if ! helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n $NAMESPACE \
  --set clusterName="$CLUSTER_NAME" \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller \
  --set region="$REGION" \
  --set vpcId=$(aws eks describe-cluster --name "$CLUSTER_NAME" --region "$REGION" --query "cluster.resourcesVpcConfig.vpcId" --output text) \
  --wait \
  --timeout=600s; then

  log_warning "⚠️ Helm install failed, attempting retry..."
  sleep 10
  helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller \
    -n $NAMESPACE \
    --set clusterName="$CLUSTER_NAME" \
    --set serviceAccount.create=false \
    --set serviceAccount.name=aws-load-balancer-controller \
    --set region="$REGION" \
    --set vpcId=$(aws eks describe-cluster --name "$CLUSTER_NAME" --region "$REGION" --query "cluster.resourcesVpcConfig.vpcId" --output text) \
    --wait \
    --timeout=600s || {
      log_error "❌ Helm install failed after retry"
      exit 1
    }
fi

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

# Verify controller permissions and wait for it to be fully operational
log_info "🔐 Verifying controller IAM permissions and functionality..."

# Wait for controller pods to be fully ready
log_info "⏳ Waiting for controller pods to be fully ready..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=aws-load-balancer-controller -n "$NAMESPACE" --timeout=300s

# Test IAM permissions by checking if we can describe load balancers
log_info "🧪 Testing IAM permissions..."
if aws elbv2 describe-load-balancers --region "$REGION" >/dev/null 2>&1; then
  log_success "✅ Basic ELB permissions working"
else
  log_warning "⚠️ Basic ELB permissions may be missing"
fi

# Check controller logs for any immediate errors
log_info "📋 Checking controller logs for errors..."
CONTROLLER_POD=$(kubectl get pods -n "$NAMESPACE" -l app.kubernetes.io/name=aws-load-balancer-controller -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")
if [[ -n "$CONTROLLER_POD" ]]; then
  log_info "📋 Recent controller logs:"
  kubectl logs "$CONTROLLER_POD" -n "$NAMESPACE" --tail=10 | grep -E "(error|Error|ERROR)" || log_success "No errors found in recent logs"
else
  log_warning "⚠️ Could not find controller pod for log checking"
fi

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
