#!/bin/bash

echo "✅ Complete Cleanup Verification for Healthcare Cluster"
echo "======================================================"

REGION="us-east-1"
CLUSTER_NAME="healthcare-cluster"
ALL_CLEAN=true

# Function to check and report status
check_resource() {
    local resource_name=$1
    local check_command=$2
    local expected_result=$3
    
    echo "🔍 Checking $resource_name..."
    
    result=$(eval "$check_command" 2>/dev/null)
    
    if [ "$expected_result" = "empty" ]; then
        if [ -z "$result" ] || [ "$result" = "[]" ] || [ "$result" = "None" ]; then
            echo "✅ $resource_name: Clean (no resources found)"
        else
            echo "❌ $resource_name: Resources still exist"
            echo "   Found: $result"
            ALL_CLEAN=false
        fi
    elif [ "$expected_result" = "not_found" ]; then
        if echo "$result" | grep -q "does not exist\|not found\|No cluster found"; then
            echo "✅ $resource_name: Clean (not found)"
        elif [ -z "$result" ]; then
            echo "✅ $resource_name: Clean (no response)"
        else
            echo "❌ $resource_name: Still exists"
            echo "   Found: $result"
            ALL_CLEAN=false
        fi
    fi
    echo ""
}

echo "🧹 Verifying complete cleanup of healthcare cluster resources..."
echo ""

# 1. Check EKS cluster
check_resource "EKS Cluster" \
    "aws eks describe-cluster --name $CLUSTER_NAME --region $REGION --query 'cluster.name' --output text" \
    "not_found"

# 2. Check CloudFormation stacks
check_resource "CloudFormation Stacks" \
    "aws cloudformation list-stacks --region $REGION --query 'StackSummaries[?contains(StackName, \`healthcare\`) || contains(StackName, \`eksctl-healthcare\`)].StackName' --output text" \
    "empty"

# 3. Check EC2 instances
check_resource "EC2 Instances" \
    "aws ec2 describe-instances --region $REGION --filters 'Name=tag:kubernetes.io/cluster/$CLUSTER_NAME,Values=owned' 'Name=instance-state-name,Values=running,pending,stopping,stopped' --query 'Reservations[].Instances[].InstanceId' --output text" \
    "empty"

# 4. Check Load Balancers
check_resource "Load Balancers" \
    "aws elbv2 describe-load-balancers --region $REGION --query 'LoadBalancers[?contains(LoadBalancerName, \`k8s\`) || contains(LoadBalancerName, \`healthcare\`)].LoadBalancerName' --output text" \
    "empty"

# 5. Check Security Groups
check_resource "Security Groups" \
    "aws ec2 describe-security-groups --region $REGION --filters 'Name=group-name,Values=*eksctl-healthcare*' --query 'SecurityGroups[].GroupName' --output text" \
    "empty"

# 6. Check VPCs
check_resource "VPCs" \
    "aws ec2 describe-vpcs --region $REGION --filters 'Name=tag:Name,Values=*eksctl-healthcare*' --query 'Vpcs[].VpcId' --output text" \
    "empty"

# 7. Check NAT Gateways
check_resource "NAT Gateways" \
    "aws ec2 describe-nat-gateways --region $REGION --filter 'Name=tag:Name,Values=*eksctl-healthcare*' --query 'NatGateways[?State!=\`deleted\`].NatGatewayId' --output text" \
    "empty"

# 8. Check Internet Gateways
check_resource "Internet Gateways" \
    "aws ec2 describe-internet-gateways --region $REGION --filters 'Name=tag:Name,Values=*eksctl-healthcare*' --query 'InternetGateways[].InternetGatewayId' --output text" \
    "empty"

# 9. Check Route Tables
check_resource "Route Tables" \
    "aws ec2 describe-route-tables --region $REGION --filters 'Name=tag:Name,Values=*eksctl-healthcare*' --query 'RouteTables[].RouteTableId' --output text" \
    "empty"

# 10. Check Subnets
check_resource "Subnets" \
    "aws ec2 describe-subnets --region $REGION --filters 'Name=tag:Name,Values=*eksctl-healthcare*' --query 'Subnets[].SubnetId' --output text" \
    "empty"

# 11. Check Elastic IPs
check_resource "Elastic IPs" \
    "aws ec2 describe-addresses --region $REGION --filters 'Name=tag:Name,Values=*eksctl-healthcare*' --query 'Addresses[].AllocationId' --output text" \
    "empty"

# 12. Check Network ACLs
check_resource "Network ACLs" \
    "aws ec2 describe-network-acls --region $REGION --filters 'Name=tag:Name,Values=*eksctl-healthcare*' --query 'NetworkAcls[].NetworkAclId' --output text" \
    "empty"

# 13. Check Network Interfaces
check_resource "Network Interfaces" \
    "aws ec2 describe-network-interfaces --region $REGION --filters 'Name=tag:Name,Values=*eksctl-healthcare*' --query 'NetworkInterfaces[].NetworkInterfaceId' --output text" \
    "empty"

# 14. Check Auto Scaling Groups
check_resource "Auto Scaling Groups" \
    "aws autoscaling describe-auto-scaling-groups --region $REGION --query 'AutoScalingGroups[?contains(AutoScalingGroupName, \`eksctl-healthcare\`)].AutoScalingGroupName' --output text" \
    "empty"

# 15. Check Launch Templates
check_resource "Launch Templates" \
    "aws ec2 describe-launch-templates --region $REGION --query 'LaunchTemplates[?contains(LaunchTemplateName, \`eksctl-healthcare\`)].LaunchTemplateName' --output text" \
    "empty"

# 16. Check IAM Roles
echo "🔍 Checking IAM Roles..."
IAM_ROLES=$(aws iam list-roles --query 'Roles[?contains(RoleName, `eksctl-healthcare`)].RoleName' --output text 2>/dev/null)
if [ ! -z "$IAM_ROLES" ]; then
    echo "⚠️ IAM Roles still exist: $IAM_ROLES"
    echo "   These may need manual cleanup"
    ALL_CLEAN=false
else
    echo "✅ IAM Roles: Clean (no eksctl-healthcare roles found)"
fi
echo ""

# 17. Check kubectl context
echo "🔍 Checking kubectl context..."
kubectl config get-contexts | grep healthcare >/dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "⚠️ kubectl context still exists for healthcare cluster"
    echo "   Run: kubectl config delete-context <context-name>"
    ALL_CLEAN=false
else
    echo "✅ kubectl context: Clean (no healthcare context found)"
fi
echo ""

# 18. Check for any remaining costs
echo "💰 Checking for potential cost-generating resources..."
echo "🔍 Scanning for any missed resources that could incur charges..."

# Check for any running instances regardless of tags
RUNNING_INSTANCES=$(aws ec2 describe-instances --region $REGION --filters "Name=instance-state-name,Values=running" --query 'Reservations[].Instances[?contains(to_string(Tags), `healthcare`) || contains(to_string(Tags), `eksctl`)].InstanceId' --output text 2>/dev/null)
if [ ! -z "$RUNNING_INSTANCES" ]; then
    echo "⚠️ Found running instances that may be related: $RUNNING_INSTANCES"
    ALL_CLEAN=false
else
    echo "✅ No suspicious running instances found"
fi

# Check for any load balancers that might have been missed
ALL_LBS=$(aws elbv2 describe-load-balancers --region $REGION --query 'LoadBalancers[].LoadBalancerName' --output text 2>/dev/null)
if echo "$ALL_LBS" | grep -q "k8s\|healthcare\|eksctl"; then
    echo "⚠️ Found load balancers that may be related: $(echo $ALL_LBS | grep -E 'k8s|healthcare|eksctl')"
    ALL_CLEAN=false
else
    echo "✅ No suspicious load balancers found"
fi

# Check for any NAT gateways that might incur costs
ALL_NATS=$(aws ec2 describe-nat-gateways --region $REGION --query 'NatGateways[?State!=`deleted`].NatGatewayId' --output text 2>/dev/null)
if [ ! -z "$ALL_NATS" ]; then
    echo "⚠️ Found NAT Gateways (check if related to healthcare): $ALL_NATS"
    echo "   NAT Gateways cost ~$45/month each"
fi

echo ""

# Final summary
echo "📊 Cleanup Verification Summary"
echo "==============================="

if [ "$ALL_CLEAN" = true ]; then
    echo "🎉 SUCCESS: Complete cleanup verified!"
    echo ""
    echo "✅ All healthcare cluster resources have been successfully removed:"
    echo "   • EKS cluster deleted"
    echo "   • CloudFormation stacks deleted"
    echo "   • EC2 instances terminated"
    echo "   • Load balancers deleted"
    echo "   • VPC and networking resources deleted"
    echo "   • Security groups deleted"
    echo ""
    echo "🚀 You can now safely create a new cluster:"
    echo "   ./create-eks-cluster.sh"
    echo ""
    echo "💰 Cost Impact: $0.00/hour (no active resources)"
else
    echo "❌ INCOMPLETE: Some resources still exist"
    echo ""
    echo "🔧 Recommended actions:"
    echo "1. Review the resources listed above"
    echo "2. Run manual cleanup if needed:"
    echo "   • Delete remaining CloudFormation stacks manually"
    echo "   • Terminate EC2 instances manually"
    echo "   • Delete VPC and networking resources manually"
    echo "3. Re-run this verification: ./verify-complete-cleanup.sh"
    echo "4. Contact AWS support if resources are stuck"
    echo ""
    echo "⚠️ Do not create a new cluster until all resources are cleaned up"
fi

echo ""
echo "🔗 Useful commands for manual cleanup:"
echo "• List all stacks: aws cloudformation list-stacks --region $REGION"
echo "• Delete specific stack: aws cloudformation delete-stack --stack-name <stack-name> --region $REGION"
echo "• List EC2 instances: aws ec2 describe-instances --region $REGION"
echo "• Terminate instance: aws ec2 terminate-instances --instance-ids <instance-id> --region $REGION"
