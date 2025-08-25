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
      log "Attempting terraform import for EKS cluster..."
      terraform import "module.healthcare_infrastructure.module.eks.aws_eks_cluster.this[0]" "$CLUSTER_NAME" || true
    elif [[ "$FAIL_FAST" == "true" ]]; then
      log "Conflict: EKS cluster exists. Set AUTO_IMPORT=true to import or delete the cluster."
      return 2
    fi
  else
    log "EKS cluster not found: $CLUSTER_NAME"
  fi
}

# Check DB subnet groups
check_db_subnet_groups() {
  local name_prefix="${CLUSTER_NAME}-db-subnet-group"
  local names
  names=$(aws rds describe-db-subnet-groups --region "$REGION" --query "DBSubnetGroups[?starts_with(DBSubnetGroupName, '\\`${name_prefix}\\`')].[DBSubnetGroupName,VpcId]" --output text || true)
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

main() {
  check_eks || exit $?
  check_db_subnet_groups || true
  check_vpc || true
  log "Preflight checks completed."
}

main "$@"

