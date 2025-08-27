#!/usr/bin/env bash
set -euo pipefail

# Rebuild Stage-3 infrastructure end-to-end in an idempotent, CI/CD-friendly way
# - Validates that destruction is complete
# - Creates/initializes Terraform backend (S3 + DynamoDB) if missing
# - Provisions infrastructure via Terraform (VPC, EKS, RDS)
# - Sets up ALB Controller IAM (policy, role, IRSA) with explicit inline permissions
# - Deploys AWS Load Balancer Controller via Helm
# - Applies GitOps manifests (Ingress with ingressClassName: alb) and verifies ALB hostname
# - Validates end-to-end app health (database: connected)
#
# Usage:
#   ./scripts/deployment/rebuild-stage3.sh [--ci]
#
# Notes:
# - Requires AWS CLI, Terraform, kubectl, helm, eksctl
# - Uses region from $AWS_REGION or defaults to us-east-1

REGION=${AWS_REGION:-us-east-1}
CLUSTER_NAME="healthcare-eks-stage3-dev"
NAMESPACE="healthcare-stage3-dev"
TF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../terraform/environments/dev" && pwd)"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CI_MODE="false"

if [[ "${1:-}" == "--ci" ]]; then
  CI_MODE="true"
fi

BLUE='\033[0;34m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
log_info(){ echo -e "${BLUE}[INFO]${NC} $*"; }
log_ok(){ echo -e "${GREEN}[OK]${NC} ✅ $*"; }
log_warn(){ echo -e "${YELLOW}[WARN]${NC} ⚠️  $*"; }
log_err(){ echo -e "${RED}[ERR]${NC} ❌ $*"; }

require() {
  if ! command -v "$1" >/dev/null 2>&1; then
    log_err "Missing required command: $1"
    exit 1
  fi
}

for cmd in aws terraform kubectl helm eksctl jq; do require "$cmd"; done

account_id() { aws sts get-caller-identity --query Account --output text; }
bucket_name() { echo "healthcare-terraform-state-stage3-$(account_id)"; }
ddb_table() { echo "healthcare-terraform-locks-stage3"; }

exists_cluster() {
  aws eks describe-cluster --name "$CLUSTER_NAME" --region "$REGION" >/dev/null 2>&1
}

exists_rds() {
  aws rds describe-db-instances --db-instance-identifier "${CLUSTER_NAME}-db" --region "$REGION" >/dev/null 2>&1
}

has_stage3_albs() {
  aws elbv2 describe-load-balancers --region "$REGION" \
    --query 'LoadBalancers[?contains(DNSName, `elb.amazonaws.com`) && (contains(LoadBalancerName, `healthcare`) || contains(LoadBalancerName, `stage3`))].LoadBalancerArn' \
    --output text 2>/dev/null | grep -q . || return 1
}

pre_rebuild_validation() {
  log_info "Pre-rebuild validation: ensuring infrastructure is fully destroyed"
  local found=0
  if exists_cluster; then log_warn "EKS cluster still exists: $CLUSTER_NAME"; found=1; fi
  if exists_rds; then log_warn "RDS instance still exists: ${CLUSTER_NAME}-db"; found=1; fi
  if has_stage3_albs; then log_warn "ALBs still present for stage3/healthcare"; found=1; fi
  local vpcs
  vpcs=$(aws ec2 describe-vpcs --region "$REGION" --query 'Vpcs[?contains(Tags[?Key==`Name`].Value|[0], `stage3`) || contains(VpcId, ``)].VpcId' --output text 2>/dev/null || true)
  if [[ -n "$vpcs" ]]; then log_warn "Candidate VPCs still present: $vpcs"; found=1; fi

  if [[ "$found" -eq 1 ]]; then
    if [[ "$CI_MODE" == "true" ]]; then
      log_warn "CI mode: aborting rebuild because infra not fully destroyed"
      exit 1
    else
      log_err "Destruction not complete. Run: ./scripts/cleanup/destroy-complete-infrastructure.sh"
      exit 1
    fi
  fi
  log_ok "Destruction verified: safe to rebuild"
}

ensure_backend() {
  local bucket="$(bucket_name)"; local table="$(ddb_table)"
  log_info "Ensuring Terraform backend S3 bucket exists: $bucket"
  if ! aws s3api head-bucket --bucket "$bucket" 2>/dev/null; then
    if [[ "$REGION" == "us-east-1" ]]; then
      aws s3api create-bucket --bucket "$bucket" >/dev/null
    else
      aws s3api create-bucket --bucket "$bucket" --create-bucket-configuration LocationConstraint="$REGION" >/dev/null
    fi
    log_ok "Created bucket: $bucket"
  else
    log_ok "Bucket exists: $bucket"
  fi
  log_info "Ensuring DynamoDB table exists: $table"
  if ! aws dynamodb describe-table --table-name "$table" --region "$REGION" >/dev/null 2>&1; then
    aws dynamodb create-table --table-name "$table" \
      --attribute-definitions AttributeName=LockID,AttributeType=S \
      --key-schema AttributeName=LockID,KeyType=HASH \
      --billing-mode PAY_PER_REQUEST --region "$REGION" >/dev/null
    log_ok "Created DynamoDB table: $table"
    log_info "Waiting for DynamoDB table to be ACTIVE..."
    aws dynamodb wait table-exists --table-name "$table" --region "$REGION"
  else
    log_ok "DynamoDB table exists: $table"
  fi
}

provision_infra() {
  log_info "Provisioning infrastructure via Terraform"
  pushd "$TF_DIR" >/dev/null
  terraform init -reconfigure \
    -backend-config="bucket=$(bucket_name)" \
    -backend-config="key=stage3/dev/terraform.tfstate" \
    -backend-config="region=$REGION" \
    -backend-config="dynamodb_table=$(ddb_table)" \
    -backend-config="encrypt=true"
  terraform apply -auto-approve
  popd >/dev/null
  log_ok "Terraform apply complete"
}

setup_alb_controller_iam() {
  log_info "Setting up ALB Controller IAM (policy, role, IRSA)"
  # Upstream IAM policy
  local policy_json="/tmp/aws-load-balancer-controller-iam-policy.json"
  curl -fsSL https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json -o "$policy_json"
  # Create or get policy ARN
  local policy_name="AWSLoadBalancerControllerIAMPolicy"
  local policy_arn
  policy_arn=$(aws iam list-policies --scope Local --query "Policies[?PolicyName=='$policy_name'].Arn" --output text 2>/dev/null || true)
  if [[ -z "$policy_arn" ]]; then
    policy_arn=$(aws iam create-policy --policy-name "$policy_name" --policy-document file://"$policy_json" --query Policy.Arn --output text)
    log_ok "Created IAM policy: $policy_name"
  else
    log_ok "IAM policy exists: $policy_name"
  fi

  # Ensure OIDC provider (eksctl will create if missing)
  # Create IRSA and role via eksctl
  eksctl create iamserviceaccount \
    --cluster="$CLUSTER_NAME" \
    --namespace=kube-system \
    --name=aws-load-balancer-controller \
    --role-name AmazonEKSLoadBalancerControllerRole \
    --attach-policy-arn="$policy_arn" \
    --approve \
    --region="$REGION" \
    --override-existing-serviceaccounts || true

  # Attach explicit inline policy to fix DescribeListenerAttributes
  cat >/tmp/alb_extra_policy.json <<'EOF'
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
    --role-name AmazonEKSLoadBalancerControllerRole \
    --policy-name ALBControllerExtraPermissions \
    --policy-document file:///tmp/alb_extra_policy.json || true

  log_info "Waiting 60s for IAM propagation..."
  sleep 60
  log_ok "ALB Controller IAM configured"
}

install_alb_controller() {
  log_info "Installing AWS Load Balancer Controller"
  kubectl create namespace kube-system --dry-run=client -o yaml | kubectl apply -f - >/dev/null 2>&1 || true
  helm repo add eks https://aws.github.io/eks-charts >/dev/null 2>&1 || true
  helm repo update >/dev/null 2>&1 || true
  helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller \
    -n kube-system \
    --set clusterName="$CLUSTER_NAME" \
    --set serviceAccount.create=false \
    --set serviceAccount.name=aws-load-balancer-controller \
    --set region="$REGION" \
    --wait --timeout=600s
  kubectl wait --for=condition=available deployment/aws-load-balancer-controller -n kube-system --timeout=600s
  log_ok "ALB Controller installed"
}

deploy_app_and_ingress() {
  log_info "Applying GitOps manifests"
  kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -
  kubectl apply -n "$NAMESPACE" -f "$ROOT_DIR/gitops/environments/dev/" >/dev/null
  log_info "Waiting for Ingress Address (ALB hostname)"
  local i=0; local max=20; local sleep_s=30; local host=""
  while [[ $i -lt $max ]]; do
    host=$(kubectl get ingress healthcare-stage3-ingress -n "$NAMESPACE" -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || true)
    if [[ -n "$host" ]]; then break; fi
    log_info "Attempt $((i+1))/$max: Ingress Address not ready yet; sleeping ${sleep_s}s"
    sleep $sleep_s; i=$((i+1))
  done
  if [[ -z "$host" ]]; then
    log_err "Ingress did not receive an ALB hostname in time"
    kubectl describe ingress healthcare-stage3-ingress -n "$NAMESPACE" || true
    kubectl logs -n kube-system deployment/aws-load-balancer-controller --tail=200 || true
    exit 1
  fi
  echo "$host" > /tmp/stage3_alb_hostname.txt
  log_ok "Ingress ALB hostname: $host"
}

validate_end_to_end() {
  local host; host=$(cat /tmp/stage3_alb_hostname.txt)
  log_info "Validating backend health via ALB"
  local resp
  resp=$(curl -s "http://${host}/api/health" || echo "CURL_FAILED")
  echo "Health response: $resp"
  if echo "$resp" | jq -e '.database == "connected"' >/dev/null 2>&1; then
    log_ok "Database connection successful via /api/health"
  else
    log_err "Health check failed"
    local pod
    pod=$(kubectl get pods -n "$NAMESPACE" -l app=healthcare-backend-stage3 -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || true)
    if [[ -n "$pod" ]]; then kubectl logs -n "$NAMESPACE" "$pod" --tail=200 || true; fi
    exit 1
  fi
  log_info "Validating frontend root"
  local code
  code=$(curl -s -o /dev/null -w "%{http_code}" "http://${host}/")
  if [[ "$code" =~ ^2|3 ]]; then
    log_ok "Frontend reachable (HTTP $code)"
  else
    log_warn "Frontend returned HTTP $code"
  fi
}

main() {
  log_info "Stage-3 rebuild starting (region: $REGION)"
  pre_rebuild_validation
  ensure_backend
  provision_infra
  setup_alb_controller_iam
  install_alb_controller
  deploy_app_and_ingress
  validate_end_to_end
  log_ok "Stage-3 rebuild completed successfully"
}

main "$@"

