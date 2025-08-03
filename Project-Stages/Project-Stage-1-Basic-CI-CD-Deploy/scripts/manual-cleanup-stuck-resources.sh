#!/bin/bash

echo "🔧 Manual Cleanup of Stuck CloudFormation Resources"
echo "=================================================="

REGION="us-east-1"
STACK_NAME="eksctl-healthcare-cluster-cluster"

# Specific stuck resources from your output
SUBNET_1="subnet-0fea7649875d34624"
SUBNET_2="subnet-0b63017e0a3a52699"
VPC_ID="vpc-04bba75f61f1ebd34"

echo "🎯 Target Resources to Clean Up:"
echo "   • Subnet 1: $SUBNET_1"
echo "   • Subnet 2: $SUBNET_2"
echo "   • VPC: $VPC_ID"
echo "   • Internet Gateway attached to VPC"
echo ""

# Function to check if resource exists
check_resource_exists() {
    local resource_type=$1
    local resource_id=$2
    
    case $resource_type in
        "subnet")
            aws ec2 describe-subnets --subnet-ids $resource_id --region $REGION >/dev/null 2>&1
            ;;
        "vpc")
            aws ec2 describe-vpcs --vpc-ids $resource_id --region $REGION >/dev/null 2>&1
            ;;
        "igw")
            aws ec2 describe-internet-gateways --internet-gateway-ids $resource_id --region $REGION >/dev/null 2>&1
            ;;
    esac
    return $?
}

# Function to force delete subnet dependencies
cleanup_subnet_dependencies() {
    local subnet_id=$1
    echo "🔍 Cleaning up dependencies for subnet: $subnet_id"
    
    # Check if subnet exists
    if ! check_resource_exists "subnet" $subnet_id; then
        echo "✅ Subnet $subnet_id already deleted"
        return 0
    fi
    
    # Delete any network interfaces in the subnet
    echo "   🔌 Checking for network interfaces..."
    ENI_IDS=$(aws ec2 describe-network-interfaces --region $REGION --filters "Name=subnet-id,Values=$subnet_id" --query 'NetworkInterfaces[].NetworkInterfaceId' --output text)
    
    if [ ! -z "$ENI_IDS" ]; then
        echo "   🗑️ Deleting network interfaces: $ENI_IDS"
        for ENI_ID in $ENI_IDS; do
            echo "     Deleting ENI: $ENI_ID"
            aws ec2 delete-network-interface --network-interface-id $ENI_ID --region $REGION 2>/dev/null || echo "     ENI $ENI_ID may be in use or already deleted"
        done
        echo "   ⏳ Waiting 30 seconds for ENI deletion to propagate..."
        sleep 30
    else
        echo "   ✅ No network interfaces found in subnet"
    fi
    
    # Check for any instances in the subnet
    echo "   🖥️ Checking for instances..."
    INSTANCE_IDS=$(aws ec2 describe-instances --region $REGION --filters "Name=subnet-id,Values=$subnet_id" "Name=instance-state-name,Values=running,pending,stopping,stopped" --query 'Reservations[].Instances[].InstanceId' --output text)
    
    if [ ! -z "$INSTANCE_IDS" ]; then
        echo "   🗑️ Terminating instances: $INSTANCE_IDS"
        aws ec2 terminate-instances --instance-ids $INSTANCE_IDS --region $REGION
        echo "   ⏳ Waiting for instances to terminate..."
        aws ec2 wait instance-terminated --instance-ids $INSTANCE_IDS --region $REGION
    else
        echo "   ✅ No instances found in subnet"
    fi
    
    # Try to delete the subnet
    echo "   🗑️ Attempting to delete subnet: $subnet_id"
    if aws ec2 delete-subnet --subnet-id $subnet_id --region $REGION 2>/dev/null; then
        echo "   ✅ Subnet $subnet_id deleted successfully"
        return 0
    else
        echo "   ❌ Failed to delete subnet $subnet_id"
        return 1
    fi
}

# Function to cleanup Internet Gateway
cleanup_internet_gateway() {
    local vpc_id=$1
    echo "🌍 Cleaning up Internet Gateway for VPC: $vpc_id"
    
    # Find Internet Gateway attached to VPC
    IGW_ID=$(aws ec2 describe-internet-gateways --region $REGION --filters "Name=attachment.vpc-id,Values=$vpc_id" --query 'InternetGateways[].InternetGatewayId' --output text)
    
    if [ -z "$IGW_ID" ]; then
        echo "   ✅ No Internet Gateway found attached to VPC"
        return 0
    fi
    
    echo "   🔍 Found Internet Gateway: $IGW_ID"
    
    # Detach Internet Gateway from VPC
    echo "   🔗 Detaching Internet Gateway from VPC..."
    if aws ec2 detach-internet-gateway --internet-gateway-id $IGW_ID --vpc-id $vpc_id --region $REGION 2>/dev/null; then
        echo "   ✅ Internet Gateway detached successfully"
        
        # Wait a moment for detachment to complete
        sleep 10
        
        # Delete Internet Gateway
        echo "   🗑️ Deleting Internet Gateway..."
        if aws ec2 delete-internet-gateway --internet-gateway-id $IGW_ID --region $REGION 2>/dev/null; then
            echo "   ✅ Internet Gateway deleted successfully"
            return 0
        else
            echo "   ❌ Failed to delete Internet Gateway"
            return 1
        fi
    else
        echo "   ❌ Failed to detach Internet Gateway"
        return 1
    fi
}

# Function to cleanup VPC
cleanup_vpc() {
    local vpc_id=$1
    echo "🌐 Cleaning up VPC: $vpc_id"
    
    # Check if VPC exists
    if ! check_resource_exists "vpc" $vpc_id; then
        echo "✅ VPC $vpc_id already deleted"
        return 0
    fi
    
    # Delete any remaining route tables (except main)
    echo "   🛣️ Cleaning up route tables..."
    RT_IDS=$(aws ec2 describe-route-tables --region $REGION --filters "Name=vpc-id,Values=$vpc_id" --query 'RouteTables[?Associations[0].Main!=`true`].RouteTableId' --output text)
    
    for RT_ID in $RT_IDS; do
        echo "     Deleting route table: $RT_ID"
        aws ec2 delete-route-table --route-table-id $RT_ID --region $REGION 2>/dev/null || echo "     Route table $RT_ID may have dependencies"
    done
    
    # Delete any remaining security groups (except default)
    echo "   🔒 Cleaning up security groups..."
    SG_IDS=$(aws ec2 describe-security-groups --region $REGION --filters "Name=vpc-id,Values=$vpc_id" --query 'SecurityGroups[?GroupName!=`default`].GroupId' --output text)
    
    for SG_ID in $SG_IDS; do
        echo "     Deleting security group: $SG_ID"
        aws ec2 delete-security-group --group-id $SG_ID --region $REGION 2>/dev/null || echo "     Security group $SG_ID may have dependencies"
    done
    
    # Try to delete the VPC
    echo "   🗑️ Attempting to delete VPC: $vpc_id"
    if aws ec2 delete-vpc --vpc-id $vpc_id --region $REGION 2>/dev/null; then
        echo "   ✅ VPC $vpc_id deleted successfully"
        return 0
    else
        echo "   ❌ Failed to delete VPC $vpc_id"
        return 1
    fi
}

# Main cleanup process
echo "🚀 Starting manual cleanup process..."
echo ""

read -p "⚠️ This will forcefully delete AWS resources. Are you sure? (type 'yes' to confirm): " confirm

if [ "$confirm" != "yes" ]; then
    echo "❌ Cleanup cancelled by user"
    exit 1
fi

echo ""
echo "🔧 Step 1: Cleaning up subnet dependencies..."
cleanup_subnet_dependencies $SUBNET_1
cleanup_subnet_dependencies $SUBNET_2

echo ""
echo "🔧 Step 2: Cleaning up Internet Gateway..."
cleanup_internet_gateway $VPC_ID

echo ""
echo "🔧 Step 3: Cleaning up VPC..."
cleanup_vpc $VPC_ID

echo ""
echo "🔧 Step 4: Attempting to delete CloudFormation stack again..."
aws cloudformation delete-stack --stack-name $STACK_NAME --region $REGION

echo "⏳ Waiting for stack deletion to complete..."
aws cloudformation wait stack-delete-complete --stack-name $STACK_NAME --region $REGION

# Final verification
echo ""
echo "🔍 Final verification..."
if aws cloudformation describe-stacks --stack-name $STACK_NAME --region $REGION >/dev/null 2>&1; then
    echo "❌ Stack still exists. Check AWS Console for remaining issues."
    echo ""
    echo "📋 Current stack status:"
    aws cloudformation describe-stacks --stack-name $STACK_NAME --region $REGION --query 'Stacks[0].{Status:StackStatus,Reason:StackStatusReason}' --output table
else
    echo "✅ SUCCESS: CloudFormation stack has been completely deleted!"
    echo ""
    echo "🎉 All resources cleaned up successfully!"
    echo "🚀 You can now create a new cluster: ./create-eks-cluster.sh"
fi

echo ""
echo "🔍 Checking for any remaining healthcare-related stacks..."
aws cloudformation list-stacks --region $REGION --query 'StackSummaries[?contains(StackName, `healthcare`) || contains(StackName, `eksctl-healthcare`)].{Name:StackName,Status:StackStatus}' --output table
