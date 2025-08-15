#!/bin/bash

# Stage 2 - Comprehensive CloudFormation + AWS resource cleanup for EKS
# Deletes Stage-2 healthcare EKS stacks and related resources in safe order

set -euo pipefail

REGION="us-east-1"
CLUSTER_NAME="healthcare-cluster-stage2"
EKSCTL_PREFIX="eksctl-${CLUSTER_NAME}"

banner() { echo -e "\n$1\n${1//?/=}"; }
info()   { echo "ℹ️  $1"; }
ok()     { echo "✅ $1"; }
warn()   { echo "⚠️  $1"; }
err()    { echo "❌ $1"; }

require_aws() {
  if ! aws sts get-caller-identity >/dev/null 2>&1; then
    err "AWS CLI not configured or no access"; exit 1;
  fi
}

list_healthcare_stacks() {
  aws cloudformation list-stacks \
    --region "$REGION" \
    --query 'StackSummaries[?contains(StackName, `healthcare-cluster-stage2`) || contains(StackName, `eksctl-healthcare-cluster-stage2`)].StackName' \
    --output text 2>/dev/null || true
}

delete_stack_and_wait() {
  local stack_name=$1
  info "Deleting CloudFormation stack: $stack_name"
  if aws cloudformation describe-stacks --stack-name "$stack_name" --region "$REGION" >/dev/null 2>&1; then
    aws cloudformation delete-stack --stack-name "$stack_name" --region "$REGION"
    warn "Waiting for stack deletion to complete (can take 5-15 minutes)..."
    if aws cloudformation wait stack-delete-complete --stack-name "$stack_name" --region "$REGION"; then
      ok "Stack $stack_name deleted"
    else
      err "Deletion wait failed for $stack_name"
      aws cloudformation describe-stacks --stack-name "$stack_name" --region "$REGION" \
        --query 'Stacks[0].{StackStatus:StackStatus,StatusReason:StackStatusReason}' --output table || true
    fi
  else
    ok "Stack $stack_name does not exist"
  fi
}

force_delete_resources() {
  banner "🔧 Force deleting stuck resources"
  # Terminate EC2 instances with cluster tag
  local instances
  instances=$(aws ec2 describe-instances --region "$REGION" \
    --filters "Name=tag:kubernetes.io/cluster/${CLUSTER_NAME},Values=owned" \
              "Name=instance-state-name,Values=running,pending,stopping,stopped" \
    --query 'Reservations[].Instances[].InstanceId' --output text)
  if [ -n "${instances:-}" ]; then
    warn "Terminating EC2 instances: $instances"
    aws ec2 terminate-instances --instance-ids $instances --region "$REGION"
    aws ec2 wait instance-terminated --instance-ids $instances --region "$REGION" || true
    ok "Instances terminated"
  else
    ok "No EC2 instances found"
  fi

  # Delete load balancers with healthcare/k8s naming or in Stage-2 VPCs
  local vpc_ids lbs
  vpc_ids=$(aws ec2 describe-vpcs --region "$REGION" --filters "Name=tag:Name,Values=*${EKSCTL_PREFIX}*" --query 'Vpcs[].VpcId' --output text)
  if [ -n "${vpc_ids:-}" ]; then
    info "Checking LBs in VPC(s): $vpc_ids"
    lbs=$(aws elbv2 describe-load-balancers --region "$REGION" \
      --query 'LoadBalancers[?contains(`'"$vpc_ids"'`, VpcId)].LoadBalancerArn' --output text)
  else
    lbs=$(aws elbv2 describe-load-balancers --region "$REGION" \
      --query 'LoadBalancers[?contains(LoadBalancerName, `k8s`) || contains(LoadBalancerName, `healthcare`)].LoadBalancerArn' --output text)
  fi
  if [ -n "${lbs:-}" ]; then
    warn "Deleting load balancers..."
    for lb in $lbs; do info "Deleting $lb"; aws elbv2 delete-load-balancer --load-balancer-arn "$lb" --region "$REGION" || true; done
    sleep 30; ok "LB deletion initiated"
  else
    ok "No load balancers found"
  fi

  # Delete NAT Gateways tagged by eksctl
  local nat_gws
  nat_gws=$(aws ec2 describe-nat-gateways --region "$REGION" --filter "Name=tag:Name,Values=*${EKSCTL_PREFIX}*" \
    --query 'NatGateways[?State!=`deleted`].NatGatewayId' --output text)
  if [ -n "${nat_gws:-}" ]; then
    warn "Deleting NAT Gateways: $nat_gws"
    for nat in $nat_gws; do aws ec2 delete-nat-gateway --nat-gateway-id "$nat" --region "$REGION" || true; done
    sleep 60; ok "NAT GW deletion initiated"
  else
    ok "No NAT Gateways found"
  fi

  # Release Elastic IPs tagged by eksctl
  local eips
  eips=$(aws ec2 describe-addresses --region "$REGION" --filters "Name=tag:Name,Values=*${EKSCTL_PREFIX}*" \
    --query 'Addresses[].AllocationId' --output text)
  if [ -n "${eips:-}" ]; then
    warn "Releasing EIPs: $eips"
    for eip in $eips; do aws ec2 release-address --allocation-id "$eip" --region "$REGION" || true; done
    ok "EIPs released"
  else
    ok "No EIPs found"
  fi
}

cleanup_vpc_resources() {
  banner "🌐 VPC and networking cleanup"
  local vpcs; vpcs=$(aws ec2 describe-vpcs --region "$REGION" \
    --filters "Name=tag:Name,Values=*${EKSCTL_PREFIX}*" --query 'Vpcs[].VpcId' --output text)
  if [ -z "${vpcs:-}" ]; then ok "No eksctl Stage-2 VPCs found"; return; fi

  for VPC_ID in $vpcs; do
    info "Processing VPC: $VPC_ID"
    # ENIs
    local enis; enis=$(aws ec2 describe-network-interfaces --region "$REGION" --filters "Name=vpc-id,Values=$VPC_ID" --query 'NetworkInterfaces[].NetworkInterfaceId' --output text)
    for eni in $enis; do info "Deleting ENI: $eni"; aws ec2 delete-network-interface --network-interface-id "$eni" --region "$REGION" 2>/dev/null || true; done
    # Security Groups (non-default)
    local sgs; sgs=$(aws ec2 describe-security-groups --region "$REGION" --filters "Name=vpc-id,Values=$VPC_ID" --query 'SecurityGroups[?GroupName!=`default`].GroupId' --output text)
    for sg in $sgs; do info "Deleting SG: $sg"; aws ec2 delete-security-group --group-id "$sg" --region "$REGION" 2>/dev/null || true; done
    # Subnets
    local subnets; subnets=$(aws ec2 describe-subnets --region "$REGION" --filters "Name=vpc-id,Values=$VPC_ID" --query 'Subnets[].SubnetId' --output text)
    for sn in $subnets; do info "Deleting Subnet: $sn"; aws ec2 delete-subnet --subnet-id "$sn" --region "$REGION" 2>/dev/null || true; done
    # Internet Gateways
    local igws; igws=$(aws ec2 describe-internet-gateways --region "$REGION" --filters "Name=attachment.vpc-id,Values=$VPC_ID" --query 'InternetGateways[].InternetGatewayId' --output text)
    for igw in $igws; do info "Detaching/Deleting IGW: $igw"; aws ec2 detach-internet-gateway --internet-gateway-id "$igw" --vpc-id "$VPC_ID" --region "$REGION" 2>/dev/null || true; aws ec2 delete-internet-gateway --internet-gateway-id "$igw" --region "$REGION" 2>/dev/null || true; done
    # Route Tables (non-main)
    local rts; rts=$(aws ec2 describe-route-tables --region "$REGION" --filters "Name=vpc-id,Values=$VPC_ID" --query 'RouteTables[?Associations[0].Main!=`true`].RouteTableId' --output text)
    for rt in $rts; do info "Deleting RT: $rt"; aws ec2 delete-route-table --route-table-id "$rt" --region "$REGION" 2>/dev/null || true; done
    # Finally VPC
    info "Deleting VPC: $VPC_ID"; aws ec2 delete-vpc --vpc-id "$VPC_ID" --region "$REGION" 2>/dev/null || true
    ok "VPC $VPC_ID cleanup attempted"
  done
}

final_verification() {
  banner "🔍 Final verification"
  local success=true
  if aws eks describe-cluster --name "$CLUSTER_NAME" --region "$REGION" >/dev/null 2>&1; then err "EKS cluster still exists"; success=false; else ok "EKS cluster: Deleted"; fi
  local stacks; stacks=$(list_healthcare_stacks)
  if [ -n "${stacks:-}" ]; then err "Stacks still exist: $stacks"; success=false; else ok "CloudFormation stacks: All deleted"; fi
  local inst; inst=$(aws ec2 describe-instances --region "$REGION" --filters "Name=tag:kubernetes.io/cluster/${CLUSTER_NAME},Values=owned" "Name=instance-state-name,Values=running,pending,stopping,stopped" --query 'Reservations[].Instances[].InstanceId' --output text)
  if [ -n "${inst:-}" ]; then err "EC2 instances still exist: $inst"; success=false; else ok "EC2 instances: All terminated"; fi
  local lbs; lbs=$(aws elbv2 describe-load-balancers --region "$REGION" --query 'LoadBalancers[?contains(LoadBalancerName, `k8s`) || contains(LoadBalancerName, `healthcare`)].LoadBalancerName' --output text)
  if [ -n "${lbs:-}" ]; then err "Load balancers still exist: $lbs"; success=false; else ok "Load balancers: All deleted"; fi
  local nats; nats=$(aws ec2 describe-nat-gateways --region "$REGION" --filter "Name=tag:Name,Values=*${EKSCTL_PREFIX}*" --query 'NatGateways[?State!=`deleted`].NatGatewayId' --output text)
  if [ -n "${nats:-}" ]; then err "NAT GWs still exist: $nats"; success=false; else ok "NAT Gateways: All deleted"; fi
  local vpcs; vpcs=$(aws ec2 describe-vpcs --region "$REGION" --filters "Name=tag:Name,Values!*${EKSCTL_PREFIX}*" --query 'Vpcs[].VpcId' --output text) # placeholder
  vpcs=$(aws ec2 describe-vpcs --region "$REGION" --filters "Name=tag:Name,Values=*${EKSCTL_PREFIX}*" --query 'Vpcs[].VpcId' --output text)
  if [ -n "${vpcs:-}" ]; then err "VPCs still exist: $vpcs"; success=false; else ok "VPCs: All deleted"; fi
  local sgs; sgs=$(aws ec2 describe-security-groups --region "$REGION" --filters "Name=group-name,Values=*${EKSCTL_PREFIX}*" --query 'SecurityGroups[].GroupId' --output text)
  if [ -n "${sgs:-}" ]; then err "Security groups still exist: $sgs"; success=false; else ok "Security groups: All deleted"; fi
  [ "$success" = true ]
}

main() {
  banner "🧹 Stage-2 CloudFormation Cleanup"
  require_aws
  info "Region: $REGION | Cluster: $CLUSTER_NAME"

  local stacks; stacks=$(list_healthcare_stacks)
  if [ -z "${stacks:-}" ]; then ok "No Stage-2 healthcare CloudFormation stacks found"; else
    echo "📋 Stacks to consider:"; for s in $stacks; do echo " • $s"; done; echo
    read -p "Type 'yes' to delete these stacks in dependency-safe order: " confirm
    if [ "$confirm" = "yes" ]; then
      # delete nodegroup stacks first
      for s in $stacks; do [[ $s == *"nodegroup"* ]] && delete_stack_and_wait "$s"; done
      # then cluster stack(s)
      for s in $stacks; do [[ $s == *"cluster"* && $s != *"nodegroup"* ]] && delete_stack_and_wait "$s"; done
      # others
      for s in $stacks; do [[ $s != *"nodegroup"* && $s != *"cluster"* ]] && delete_stack_and_wait "$s"; done

      force_delete_resources
      cleanup_vpc_resources
      warn "Waiting for deletions to propagate..."; sleep 30
      if final_verification; then
        ok "COMPLETE SUCCESS: All Stage-2 resources cleaned up."
      else
        warn "INCOMPLETE: Some resources remain. Re-run or perform manual cleanup."
      fi
    else
      err "Cleanup cancelled by user"; exit 1
    fi
  fi

  banner "🔍 Current healthcare-related stacks"
  aws cloudformation list-stacks --region "$REGION" \
    --query 'StackSummaries[?contains(StackName, `healthcare`) || contains(StackName, `eksctl-healthcare`)].{Name:StackName,Status:StackStatus}' \
    --output table 2>/dev/null || true
}

main "$@"

