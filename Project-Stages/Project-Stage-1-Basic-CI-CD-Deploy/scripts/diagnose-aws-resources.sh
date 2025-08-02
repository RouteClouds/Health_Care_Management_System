#!/bin/bash

echo "🔍 AWS Resource Diagnosis for Healthcare Cluster"
echo "================================================"

# Check AWS CLI configuration
echo "📋 AWS Configuration:"
aws sts get-caller-identity 2>/dev/null || echo "❌ AWS CLI not configured or no access"
echo ""

# Check EKS clusters
echo "🏥 EKS Clusters:"
aws eks list-clusters --region us-east-1 --query 'clusters' --output table 2>/dev/null || echo "❌ No access to EKS or no clusters"
echo ""

# Check specific healthcare cluster
echo "🔍 Healthcare Cluster Status:"
aws eks describe-cluster --name healthcare-cluster --region us-east-1 2>/dev/null && echo "⚠️ Cluster still exists!" || echo "✅ No EKS cluster found"
echo ""

# Check CloudFormation stacks
echo "☁️ CloudFormation Stacks (healthcare related):"
aws cloudformation list-stacks --region us-east-1 --query 'StackSummaries[?contains(StackName, `healthcare`) || contains(StackName, `eksctl-healthcare`)].{Name:StackName,Status:StackStatus,Created:CreationTime}' --output table 2>/dev/null || echo "❌ No access to CloudFormation"
echo ""

# Check EC2 instances
echo "💻 EC2 Instances (healthcare related):"
aws ec2 describe-instances --region us-east-1 --filters "Name=tag:kubernetes.io/cluster/healthcare-cluster,Values=owned" --query 'Reservations[].Instances[].{InstanceId:InstanceId,State:State.Name,Type:InstanceType,LaunchTime:LaunchTime}' --output table 2>/dev/null || echo "❌ No access to EC2 or no instances"
echo ""

# Check Load Balancers
echo "⚖️ Load Balancers (healthcare/k8s related):"
aws elbv2 describe-load-balancers --region us-east-1 --query 'LoadBalancers[?contains(LoadBalancerName, `healthcare`) || contains(LoadBalancerName, `k8s`)].{Name:LoadBalancerName,State:State.Code,Type:Type}' --output table 2>/dev/null || echo "❌ No access to ELB or no load balancers"
echo ""

# Check VPCs
echo "🌐 VPCs (eksctl related):"
aws ec2 describe-vpcs --region us-east-1 --filters "Name=tag:Name,Values=*eksctl-healthcare*" --query 'Vpcs[].{VpcId:VpcId,State:State,CidrBlock:CidrBlock,Tags:Tags[?Key==`Name`].Value|[0]}' --output table 2>/dev/null || echo "❌ No access to VPC or no VPCs"
echo ""

# Check Security Groups
echo "🔒 Security Groups (eksctl related):"
aws ec2 describe-security-groups --region us-east-1 --filters "Name=group-name,Values=*eksctl-healthcare*" --query 'SecurityGroups[].{GroupId:GroupId,GroupName:GroupName,Description:Description}' --output table 2>/dev/null || echo "❌ No access to Security Groups or none found"
echo ""

echo "🎯 Summary:"
echo "=========="
echo "If you see CloudFormation stacks with 'eksctl-healthcare' in the name,"
echo "these need to be deleted before creating a new cluster."
echo ""
echo "Next steps:"
echo "1. Delete CloudFormation stacks: ./cleanup-cloudformation.sh"
echo "2. Verify all resources deleted: ./verify-complete-cleanup.sh"
echo "3. Create new cluster: ./create-eks-cluster.sh"
