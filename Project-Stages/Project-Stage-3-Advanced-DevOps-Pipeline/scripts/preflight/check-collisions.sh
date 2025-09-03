#!/usr/bin/env bash
set -euo pipefail

REGION=${AWS_REGION:-us-east-1}
AUTO_IMPORT=${AUTO_IMPORT:-false}
FAIL_FAST=${FAIL_FAST:-true}
CLUSTER_NAME=${CLUSTER_NAME:-healthcare-eks-stage3-dev}
ACCOUNT_ID=${ACCOUNT_ID:-867344452513}

log() { echo -e "[preflight] $*"; }

# Check EKS cluster
check_eks() {
  if aws eks describe-cluster --name "$CLUSTER_NAME" --region "$REGION" >/dev/null 2>&1; then
    log "EKS cluster exists: $CLUSTER_NAME"
    if [[ "$AUTO_IMPORT" == "true" ]]; then
      log "Attempting terraform import for EKS cluster (skip if already in state)..."
      # Only import if no EKS cluster resource is in state under any address
      if ! (terraform state list 2>/dev/null || true) | grep -q "aws_eks_cluster\.this\[0\]"; then
        terraform import "module.healthcare_infrastructure.module.eks.aws_eks_cluster.this[0]" "$CLUSTER_NAME" || true
      else
        log "EKS cluster already in Terraform state; skipping import"
      fi
    elif [[ "$FAIL_FAST" == "true" ]]; then
      # EKS cluster existing is not a hard conflict when preservation is enabled in Terraform.
      # We do not fail here; we only fail-fast on genuine duplicates (e.g., duplicate VPCs).
      log "EKS exists and AUTO_IMPORT=false; continuing (cluster will be preserved/imported later if needed)."
      return 0
    fi
  else
    log "EKS cluster not found: $CLUSTER_NAME"
  fi
}

# Check DB subnet groups
check_db_subnet_groups() {
  local name_prefix="${CLUSTER_NAME}-db-subnet-group"
  local names
  names=$(aws rds describe-db-subnet-groups \
    --region "$REGION" \
    --query "DBSubnetGroups[?contains(DBSubnetGroupName, '${name_prefix}')].[DBSubnetGroupName,VpcId]" \
    --output text 2>/dev/null || true)
  if [[ -n "$names" ]]; then
    log "Found DB subnet groups:\n$names"
  else
    log "No DB subnet groups found for prefix: $name_prefix"
  fi
}

# Check VPC by Name tag
check_vpc() {
  local vpcs
  vpcs=$(aws ec2 describe-vpcs --region "$REGION" --filters "Name=tag:Name,Values=*${CLUSTER_NAME}-vpc*" --query 'Vpcs[].[VpcId,Tags[?Key==`Name`].Value|[0]]' --output text || true)
  if [[ -n "$vpcs" ]]; then
    log "Found VPCs:\n$vpcs"
  else
    log "No VPCs found with Name like *${CLUSTER_NAME}-vpc*"
  fi
}

# Detect duplicate VPCs and decide exit code
check_vpc_duplicates_and_decide() {
  local vpc_count
  vpc_count=$(aws ec2 describe-vpcs --region "$REGION" \
    --filters "Name=tag:Name,Values=${CLUSTER_NAME}-vpc" \
    --query 'length(Vpcs)' --output text 2>/dev/null || echo 0)

  if [[ "$vpc_count" == "0" ]]; then
    log "VPC count=0 for Name=${CLUSTER_NAME}-vpc — ok (Terraform may create it)."
    return 0
  elif [[ "$vpc_count" == "1" ]]; then
    log "VPC count=1 for Name=${CLUSTER_NAME}-vpc — ok (expected normal state)."
    return 0
  else
    log "Duplicate VPCs detected: count=$vpc_count for Name=${CLUSTER_NAME}-vpc"
    if [[ "$FAIL_FAST" == "true" ]]; then
      log "FAIL_FAST=true — failing preflight to prevent further duplication."
      return 2
    else
      log "FAIL_FAST=false — continuing, but duplicates exist (risky)."
      return 0
    fi
  fi
}

main() {
  check_eks || exit $?
  check_db_subnet_groups || true
  check_vpc || true
  check_vpc_duplicates_and_decide || exit $?
  log "Preflight checks completed."
}

main "$@"

