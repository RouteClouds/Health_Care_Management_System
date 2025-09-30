#!/bin/bash

# AWS Resources Audit Script
# Discovers all healthcare/stage3 related resources across AWS services

set -euo pipefail

REGION="${AWS_REGION:-us-east-1}"
OUTPUT_FILE="aws-resources-audit-$(date +%Y%m%d-%H%M%S).txt"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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

echo "🔍 AWS Resources Audit - $(date)" | tee "$OUTPUT_FILE"
echo "================================================" | tee -a "$OUTPUT_FILE"
echo "Region: $REGION" | tee -a "$OUTPUT_FILE"
echo "" | tee -a "$OUTPUT_FILE"

log_info "Starting comprehensive AWS resources audit..."

# Function to safely run AWS commands
run_aws_command() {
    local service="$1"
    local description="$2"
    local command="$3"
    
    log_info "Checking $description..."
    echo -e "\n📋 $description:" | tee -a "$OUTPUT_FILE"
    
    if eval "$command" >> "$OUTPUT_FILE" 2>&1; then
        log_success "$description check completed"
    else
        log_warning "$description check failed or no resources found"
        echo "No resources found or access denied" | tee -a "$OUTPUT_FILE"
    fi
}

# VPCs (list all; include Name if present)
run_aws_command "ec2" "VPCs" \
    "aws ec2 describe-vpcs --region '$REGION' --query 'Vpcs[].{VpcId:VpcId,Name:to_string(Tags[?Key==\`Name\`].Value|[0]),State:State,CidrBlock:CidrBlock}' --output table"

# Subnets (list all; include Name if present)
run_aws_command "ec2" "Subnets" \
    "aws ec2 describe-subnets --region '$REGION' --query 'Subnets[].{SubnetId:SubnetId,VpcId:VpcId,AvailabilityZone:AvailabilityZone,CidrBlock:CidrBlock,Name:to_string(Tags[?Key==\`Name\`].Value|[0])}' --output table"

# NAT Gateways
run_aws_command "ec2" "NAT Gateways" \
    "aws ec2 describe-nat-gateways --region '$REGION' --query 'NatGateways[?State==\`available\`].[NatGatewayId,VpcId,SubnetId,State,Tags[?Key==\`Name\`].Value|[0]]' --output table"

# Internet Gateways
run_aws_command "ec2" "Internet Gateways" \
    "aws ec2 describe-internet-gateways --region '$REGION' --query 'InternetGateways[].[InternetGatewayId,Attachments[0].VpcId,Attachments[0].State,Tags[?Key==\`Name\`].Value|[0]]' --output table"

# Classic Load Balancers
run_aws_command "elb" "Classic Load Balancers" \
    "aws elb describe-load-balancers --region '$REGION' --query 'LoadBalancerDescriptions[?contains(LoadBalancerName,\`healthcare\`) || contains(LoadBalancerName,\`stage3\`)].[LoadBalancerName,VPCId,Scheme,CreatedTime]' --output table"

# Application/Network Load Balancers
run_aws_command "elbv2" "Application/Network Load Balancers" \
    "aws elbv2 describe-load-balancers --region '$REGION' --query 'LoadBalancers[?contains(LoadBalancerName,\`healthcare\`) || contains(LoadBalancerName,\`stage3\`)].[LoadBalancerName,Type,VpcId,Scheme,CreatedTime]' --output table"

# EKS Clusters
run_aws_command "eks" "EKS Clusters" \
    "aws eks list-clusters --region '$REGION' --query 'clusters[?contains(@,\`healthcare\`) || contains(@,\`stage3\`)]' --output table"

# RDS Instances
run_aws_command "rds" "RDS Instances" \
    "aws rds describe-db-instances --region '$REGION' --query 'DBInstances[?contains(DBInstanceIdentifier,\`healthcare\`) || contains(DBInstanceIdentifier,\`stage3\`)].[DBInstanceIdentifier,DBInstanceStatus,Engine,DBInstanceClass,AllocatedStorage,MultiAZ]' --output table"

# ECR Repositories
run_aws_command "ecr" "ECR Repositories" \
    "aws ecr describe-repositories --region '$REGION' --query 'repositories[?contains(repositoryName,\`healthcare\`) || contains(repositoryName,\`stage3\`)].[repositoryName,createdAt,repositoryUri]' --output table"

# Security Groups
run_aws_command "ec2" "Security Groups" \
    "aws ec2 describe-security-groups --region '$REGION' --query 'SecurityGroups[?contains(GroupName,\`healthcare\`) || contains(GroupName,\`stage3\`) || contains(Description,\`healthcare\`) || contains(Description,\`stage3\`)].[GroupId,GroupName,VpcId,Description]' --output table"

# Route Tables (list all; include Name if present)
run_aws_command "ec2" "Route Tables" \
    "aws ec2 describe-route-tables --region '$REGION' --query 'RouteTables[].{RouteTableId:RouteTableId,VpcId:VpcId,Name:to_string(Tags[?Key==\`Name\`].Value|[0])}' --output table"

# Elastic IPs
run_aws_command "ec2" "Elastic IPs" \
    "aws ec2 describe-addresses --region '$REGION' --query 'Addresses[?contains(Tags[?Key==\`Name\`].Value|[0],\`healthcare\`) || contains(Tags[?Key==\`Name\`].Value|[0],\`stage3\`)].[AllocationId,PublicIp,AssociationId,Tags[?Key==\`Name\`].Value|[0]]' --output table"

# S3 Buckets (healthcare/stage3 related)
run_aws_command "s3" "S3 Buckets" \
    "aws s3api list-buckets --query 'Buckets[?contains(Name,\`healthcare\`) || contains(Name,\`stage3\`)].[Name,CreationDate]' --output table"

# RDS DB Subnet Groups (names, VPCs, subnets)
run_aws_command "rds" "RDS DB Subnet Groups" \
    "aws rds describe-db-subnet-groups --region '$REGION' --query 'DBSubnetGroups[?contains(DBSubnetGroupName,\`healthcare\`) || contains(DBSubnetGroupName,\`stage3\`)].[DBSubnetGroupName,VpcId,join(\`,\`, Subnets[].SubnetIdentifier)]' --output table"

# CloudFormation Stacks
run_aws_command "cloudformation" "CloudFormation Stacks" \
    "aws cloudformation list-stacks --region '$REGION' --stack-status-filter CREATE_COMPLETE UPDATE_COMPLETE --query 'StackSummaries[?contains(StackName,\`healthcare\`) || contains(StackName,\`stage3\`) || contains(StackName,\`eks\`)].[StackName,StackStatus,CreationTime]' --output table"

# Cost Summary
echo -e "\n💰 COST ANALYSIS:" | tee -a "$OUTPUT_FILE"
echo "==================" | tee -a "$OUTPUT_FILE"

# Count high-cost resources
NAT_COUNT=$(aws ec2 describe-nat-gateways --region "$REGION" --query 'NatGateways[?State==`available`]' --output text 2>/dev/null | wc -l || echo "0")
RDS_COUNT=$(aws rds describe-db-instances --region "$REGION" --query 'DBInstances[?contains(DBInstanceIdentifier,`healthcare`) || contains(DBInstanceIdentifier,`stage3`)]' --output text 2>/dev/null | wc -l || echo "0")
EKS_COUNT=$(aws eks list-clusters --region "$REGION" --query 'clusters[?contains(@,`healthcare`) || contains(@,`stage3`)]' --output text 2>/dev/null | wc -l || echo "0")
CLB_COUNT=$(aws elb describe-load-balancers --region "$REGION" --query 'LoadBalancerDescriptions[?contains(LoadBalancerName,`healthcare`) || contains(LoadBalancerName,`stage3`)]' --output text 2>/dev/null | wc -l || echo "0")
ALB_COUNT=$(aws elbv2 describe-load-balancers --region "$REGION" --query 'LoadBalancers[?contains(LoadBalancerName,`healthcare`) || contains(LoadBalancerName,`stage3`)]' --output text 2>/dev/null | wc -l || echo "0")

echo "🚪 NAT Gateways: $NAT_COUNT (~\$45/month each = \$$(( NAT_COUNT * 45 ))/month)" | tee -a "$OUTPUT_FILE"
echo "🗄️ RDS Instances: $RDS_COUNT (~\$20-100/month each)" | tee -a "$OUTPUT_FILE"
echo "🏷️ EKS Clusters: $EKS_COUNT (~\$72/month each = \$$(( EKS_COUNT * 72 ))/month)" | tee -a "$OUTPUT_FILE"
echo "🔗 Classic LBs: $CLB_COUNT (~\$18/month each = \$$(( CLB_COUNT * 18 ))/month)" | tee -a "$OUTPUT_FILE"
echo "🔗 ALB/NLBs: $ALB_COUNT (~\$16-25/month each)" | tee -a "$OUTPUT_FILE"

ESTIMATED_MONTHLY=$(( (NAT_COUNT * 45) + (EKS_COUNT * 72) + (CLB_COUNT * 18) + (RDS_COUNT * 30) + (ALB_COUNT * 20) ))
echo "" | tee -a "$OUTPUT_FILE"
echo "💰 Estimated Monthly Cost: ~\$${ESTIMATED_MONTHLY}" | tee -a "$OUTPUT_FILE"

echo "" | tee -a "$OUTPUT_FILE"
echo "✅ Audit completed: $(date)" | tee -a "$OUTPUT_FILE"
echo "📄 Full report saved to: $OUTPUT_FILE" | tee -a "$OUTPUT_FILE"

log_success "Audit completed successfully!"
log_info "Report saved to: $OUTPUT_FILE"
log_warning "Estimated monthly cost: ~\$${ESTIMATED_MONTHLY}"

# Display summary
echo ""
echo "📊 RESOURCE SUMMARY:"
echo "===================="
echo "🚪 NAT Gateways: $NAT_COUNT"
echo "🗄️ RDS Instances: $RDS_COUNT"
echo "🏷️ EKS Clusters: $EKS_COUNT"
echo "🔗 Load Balancers: $((CLB_COUNT + ALB_COUNT))"
echo "💰 Est. Monthly Cost: ~\$${ESTIMATED_MONTHLY}"
echo ""
echo "📋 Next steps:"
echo "1. Review the detailed report: $OUTPUT_FILE"
echo "2. Run cleanup scripts to reduce costs"
echo "3. Monitor AWS Cost Explorer for actual savings"
