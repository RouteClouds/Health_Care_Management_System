#!/bin/bash

# Stage 2 - Manual cleanup helper for stuck resources blocking EKS deletion
# Adapted from Stage-1 manual cleanup for Stage-2 naming and flow

set -euo pipefail

REGION="us-east-1"
CLUSTER_NAME="healthcare-cluster-stage2"
EKSCTL_PREFIX="eksctl-${CLUSTER_NAME}"

# Optionally allow overrides
while [[ $# -gt 0 ]]; do
  case $1 in
    --region) REGION="$2"; shift 2;;
    --cluster) CLUSTER_NAME="$2"; EKSCTL_PREFIX="eksctl-${CLUSTER_NAME}"; shift 2;;
    --help|-h) echo "Usage: $0 [--region us-east-1] [--cluster healthcare-cluster-stage2]"; exit 0;;
    *) echo "Unknown arg: $1"; exit 1;;
  esac
done

info(){ echo "ℹ️  $1"; }
ok(){ echo "✅ $1"; }
warn(){ echo "⚠️  $1"; }
err(){ echo "❌ $1"; }

check_exists_subnet(){ aws ec2 describe-subnets --subnet-ids "$1" --region "$REGION" >/dev/null 2>&1; }
check_exists_vpc(){ aws ec2 describe-vpcs --vpc-ids "$1" --region "$REGION" >/dev/null 2>&1; }
check_exists_igw(){ aws ec2 describe-internet-gateways --internet-gateway-ids "$1" --region "$REGION" >/dev/null 2>&1; }

cleanup_subnet_dependencies(){
  local subnet_id=$1
  info "Cleaning dependencies for subnet: $subnet_id"
  if ! check_exists_subnet "$subnet_id"; then ok "Subnet $subnet_id already deleted"; return 0; fi
  local enis; enis=$(aws ec2 describe-network-interfaces --region "$REGION" --filters "Name=subnet-id,Values=$subnet_id" --query 'NetworkInterfaces[].NetworkInterfaceId' --output text)
  if [ -n "${enis:-}" ]; then
    warn "Deleting ENIs: $enis"
    for eni in $enis; do aws ec2 delete-network-interface --network-interface-id "$eni" --region "$REGION" 2>/dev/null || true; done
    sleep 30
  else ok "No ENIs in subnet"; fi
  local inst; inst=$(aws ec2 describe-instances --region "$REGION" --filters "Name=subnet-id,Values=$subnet_id" "Name=instance-state-name,Values=running,pending,stopping,stopped" --query 'Reservations[].Instances[].InstanceId' --output text)
  if [ -n "${inst:-}" ]; then
    warn "Terminating instances: $inst"
    aws ec2 terminate-instances --instance-ids $inst --region "$REGION" || true
    aws ec2 wait instance-terminated --instance-ids $inst --region "$REGION" || true
  else ok "No instances in subnet"; fi
  if aws ec2 delete-subnet --subnet-id "$subnet_id" --region "$REGION" 2>/dev/null; then ok "Subnet $subnet_id deleted"; else err "Failed to delete subnet $subnet_id"; fi
}

cleanup_internet_gateway(){
  local vpc_id=$1
  info "Cleaning Internet Gateway for VPC: $vpc_id"
  local igw_id; igw_id=$(aws ec2 describe-internet-gateways --region "$REGION" --filters "Name=attachment.vpc-id,Values=$vpc_id" --query 'InternetGateways[].InternetGatewayId' --output text)
  if [ -z "${igw_id:-}" ]; then ok "No IGW attached"; return 0; fi
  info "Found IGW: $igw_id"
  if aws ec2 detach-internet-gateway --internet-gateway-id "$igw_id" --vpc-id "$vpc_id" --region "$REGION" 2>/dev/null; then
    ok "IGW detached"; sleep 10; aws ec2 delete-internet-gateway --internet-gateway-id "$igw_id" --region "$REGION" 2>/dev/null && ok "IGW deleted" || warn "IGW delete may have already completed"
  else
    err "Failed to detach IGW"; return 1
  fi
}

cleanup_vpc(){
  local vpc_id=$1
  info "Cleaning VPC: $vpc_id"
  if ! check_exists_vpc "$vpc_id"; then ok "VPC $vpc_id already deleted"; return 0; fi
  # Route tables (non-main)
  local rts; rts=$(aws ec2 describe-route-tables --region "$REGION" --filters "Name=vpc-id,Values=$vpc_id" --query 'RouteTables[?Associations[0].Main!=`true`].RouteTableId' --output text)
  for rt in $rts; do info "Deleting RT: $rt"; aws ec2 delete-route-table --route-table-id "$rt" --region "$REGION" 2>/dev/null || true; done
  # Security groups (non-default)
  local sgs; sgs=$(aws ec2 describe-security-groups --region "$REGION" --filters "Name=vpc-id,Values=$vpc_id" --query 'SecurityGroups[?GroupName!=`default`].GroupId' --output text)
  for sg in $sgs; do info "Deleting SG: $sg"; aws ec2 delete-security-group --group-id "$sg" --region "$REGION" 2>/dev/null || true; done
  if aws ec2 delete-vpc --vpc-id "$vpc_id" --region "$REGION" 2>/dev/null; then ok "VPC $vpc_id deleted"; else err "Failed to delete VPC $vpc_id"; fi
}

main(){
  echo "🔧 Manual Cleanup of Stuck Resources (Stage-2)"
  echo "============================================="
  read -p "⚠️ This will forcefully delete AWS resources. Type 'yes' to continue: " confirm
  [ "$confirm" = "yes" ] || { echo "❌ Cancelled"; exit 1; }

  # Identify Stage-2 VPC(s) by tag/naming
  local vpcs; vpcs=$(aws ec2 describe-vpcs --region "$REGION" --filters "Name=tag:Name,Values=*${EKSCTL_PREFIX}*" --query 'Vpcs[].VpcId' --output text)
  if [ -z "${vpcs:-}" ]; then ok "No Stage-2 VPCs found"; exit 0; fi
  echo "📋 VPCs to process: $vpcs"

  for VPC_ID in $vpcs; do
    # Delete LBs in this VPC
    local lbs; lbs=$(aws elbv2 describe-load-balancers --region "$REGION" --query 'LoadBalancers[?VpcId==`'"$VPC_ID"'`].LoadBalancerArn' --output text)
    if [ -n "${lbs:-}" ]; then
      warn "Deleting LBs in $VPC_ID..."
      for lb in $lbs; do aws elbv2 delete-load-balancer --load-balancer-arn "$lb" --region "$REGION" || true; done
      sleep 30
    fi

    # Subnets in VPC
    local subnets; subnets=$(aws ec2 describe-subnets --region "$REGION" --filters "Name=vpc-id,Values=$VPC_ID" --query 'Subnets[].SubnetId' --output text)
    for sn in $subnets; do cleanup_subnet_dependencies "$sn"; done

    # IGW then VPC
    cleanup_internet_gateway "$VPC_ID" || true
    cleanup_vpc "$VPC_ID" || true
  done

  echo ""
  echo "🔍 Final verification"
  aws eks list-clusters --region "$REGION" --output table
  aws cloudformation list-stacks --region "$REGION" --query 'StackSummaries[?contains(StackName, `healthcare-cluster-stage2`) || contains(StackName, `eksctl-healthcare-cluster-stage2`)].{Name:StackName,Status:StackStatus}' --output table || true
}

main "$@"

