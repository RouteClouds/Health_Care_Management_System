#!/bin/bash

# Stage 2 - Diagnose AWS resources related to the healthcare Stage-2 EKS cluster
# Safe, read-only discovery. Does not delete anything.

REGION="us-east-1"
CLUSTER_NAME="healthcare-cluster-stage2"
EKSCTL_PREFIX="eksctl-${CLUSTER_NAME}"

set -e

echo "🔍 AWS Resource Diagnosis for Stage-2 Healthcare Cluster"
echo "========================================================="

# Check AWS CLI configuration
echo "📋 AWS Configuration:"
aws sts get-caller-identity 2>/dev/null || { echo "❌ AWS CLI not configured or no access"; exit 1; }
echo ""

# Check EKS clusters
echo "🏥 All EKS Clusters (region: ${REGION}):"
aws eks list-clusters --region ${REGION} --query 'clusters' --output table 2>/dev/null || echo "❌ No access to EKS or no clusters"
echo ""

# Check specific Stage-2 cluster
echo "🔍 Stage-2 Cluster Status (${CLUSTER_NAME}):"
if aws eks describe-cluster --name ${CLUSTER_NAME} --region ${REGION} >/dev/null 2>&1; then
  echo "⚠️ Cluster still exists!"
  aws eks describe-cluster --name ${CLUSTER_NAME} --region ${REGION} --query 'cluster.{Name:name,Status:status,Version:version,Endpoint:endpoint}' --output table
else
  echo "✅ No EKS cluster found"
fi
echo ""

# CloudFormation stacks (specific to Stage-2)
echo "☁️ CloudFormation Stacks (Stage-2 related):"
aws cloudformation list-stacks \
  --region ${REGION} \
  --query 'StackSummaries[?contains(StackName, `healthcare-cluster-stage2`) || contains(StackName, `eksctl-healthcare-cluster-stage2`)].{Name:StackName,Status:StackStatus,Created:CreationTime}' \
  --output table 2>/dev/null || echo "❌ No access to CloudFormation"
echo ""

# Identify VPCs created by eksctl for Stage-2
echo "🌐 VPCs (eksctl Stage-2 related):"
VPC_TABLE=$(aws ec2 describe-vpcs --region ${REGION} \
  --filters "Name=tag:Name,Values=*${EKSCTL_PREFIX}*" \
  --query 'Vpcs[].{VpcId:VpcId,State:State,CidrBlock:CidrBlock,Name:Tags[?Key==`Name`].Value|[0]}' \
  --output table 2>/dev/null || true)
if [ -z "${VPC_TABLE}" ]; then
  echo "✅ No eksctl Stage-2 VPCs found"
else
  echo "${VPC_TABLE}"
fi
echo ""

# Gather VPC IDs for downstream queries
VPC_IDS=$(aws ec2 describe-vpcs --region ${REGION} \
  --filters "Name=tag:Name,Values=*${EKSCTL_PREFIX}*" \
  --query 'Vpcs[].VpcId' --output text 2>/dev/null || true)

# EC2 instances tagged to the Stage-2 cluster
echo "💻 EC2 Instances (tagged to ${CLUSTER_NAME}):"
aws ec2 describe-instances --region ${REGION} \
  --filters "Name=tag:kubernetes.io/cluster/${CLUSTER_NAME},Values=owned" \
            "Name=instance-state-name,Values=running,pending,stopping,stopped" \
  --query 'Reservations[].Instances[].{InstanceId:InstanceId,State:State.Name,Type:InstanceType,LaunchTime:LaunchTime}' \
  --output table 2>/dev/null || echo "✅ No EC2 instances found"
echo ""

# Load Balancers in Stage-2 VPCs
if [ -n "${VPC_IDS}" ]; then
  echo "⚖️ Load Balancers within Stage-2 VPC(s): ${VPC_IDS}"
  aws elbv2 describe-load-balancers --region ${REGION} \
    --query 'LoadBalancers[?contains(`'"${VPC_IDS}"'`, VpcId)].{Name:LoadBalancerName,State:State.Code,Type:Type,VpcId:VpcId}' \
    --output table 2>/dev/null || echo "✅ No load balancers found"
else
  echo "⚖️ Load Balancers: (no Stage-2 VPCs detected, skipping VPC-filtered query)"
  aws elbv2 describe-load-balancers --region ${REGION} \
    --query 'LoadBalancers[?contains(LoadBalancerName, `k8s`) || contains(LoadBalancerName, `healthcare`)].{Name:LoadBalancerName,State:State.Code,Type:Type}' \
    --output table 2>/dev/null || echo "✅ No load balancers found"
fi
echo ""

# Security Groups related to Stage-2 VPCs
echo "🔒 Security Groups (Stage-2 VPCs):"
if [ -n "${VPC_IDS}" ]; then
  for VPC_ID in ${VPC_IDS}; do
    echo "VPC: ${VPC_ID}"
    aws ec2 describe-security-groups --region ${REGION} \
      --filters "Name=vpc-id,Values=${VPC_ID}" \
      --query 'SecurityGroups[].{GroupId:GroupId,GroupName:GroupName,Description:Description}' \
      --output table 2>/dev/null || echo "(none)"
  done
else
  echo "✅ No Stage-2 VPCs found"
fi
echo ""

# NAT Gateways tied to Stage-2 naming
echo "🌐 NAT Gateways (Stage-2 related):"
aws ec2 describe-nat-gateways --region ${REGION} \
  --filter "Name=tag:Name,Values=*${EKSCTL_PREFIX}*" \
  --query 'NatGateways[?State!=`deleted`].{NatGatewayId:NatGatewayId,State:State,SubnetId:SubnetId,VpcId:VpcId}' \
  --output table 2>/dev/null || echo "✅ No NAT Gateways found"
echo ""

# Summary
echo "🎯 Summary"
echo "=========="
echo "• Region: ${REGION}"
echo "• Target Cluster: ${CLUSTER_NAME}"
echo "• eksctl prefix: ${EKSCTL_PREFIX}"
echo ""
echo "Next steps:"
echo "1) If CloudFormation stacks exist, run: ./cleanup-cloudformation.sh"
echo "2) If a stack is DELETE_FAILED, run:     ./force-delete-failed-stack.sh"
echo "3) If resources remain stuck, run:       ./manual-cleanup-stuck-resources.sh"

