#!/bin/bash

echo "🧹 CloudFormation Stack Cleanup for Healthcare Cluster"
echo "======================================================"

# Set region
REGION="us-east-1"
CLUSTER_NAME="healthcare-cluster"

# Function to delete stack and wait
delete_stack_and_wait() {
    local stack_name=$1
    echo "🗑️ Deleting CloudFormation stack: $stack_name"
    
    # Check if stack exists
    if aws cloudformation describe-stacks --stack-name "$stack_name" --region $REGION >/dev/null 2>&1; then
        echo "📋 Stack exists. Initiating deletion..."
        
        # Delete the stack
        aws cloudformation delete-stack --stack-name "$stack_name" --region $REGION
        
        echo "⏳ Waiting for stack deletion to complete..."
        echo "   This may take 5-15 minutes depending on resources..."
        
        # Wait for deletion to complete
        aws cloudformation wait stack-delete-complete --stack-name "$stack_name" --region $REGION
        
        if [ $? -eq 0 ]; then
            echo "✅ Stack $stack_name deleted successfully"
        else
            echo "❌ Stack deletion failed or timed out for $stack_name"
            echo "🔍 Checking stack status..."
            aws cloudformation describe-stacks --stack-name "$stack_name" --region $REGION --query 'Stacks[0].{StackStatus:StackStatus,StatusReason:StackStatusReason}' --output table 2>/dev/null || echo "Stack may be deleted or inaccessible"
        fi
    else
        echo "✅ Stack $stack_name does not exist or already deleted"
    fi
    echo ""
}

# Function to force delete stuck resources
force_delete_resources() {
    echo "🔧 Force deleting stuck resources..."

    # 1. Delete any remaining EC2 instances
    echo "🖥️ Checking for EC2 instances..."
    INSTANCES=$(aws ec2 describe-instances --region $REGION --filters "Name=tag:kubernetes.io/cluster/$CLUSTER_NAME,Values=owned" "Name=instance-state-name,Values=running,pending,stopping,stopped" --query 'Reservations[].Instances[].InstanceId' --output text)

    if [ ! -z "$INSTANCES" ]; then
        echo "🗑️ Terminating EC2 instances: $INSTANCES"
        aws ec2 terminate-instances --instance-ids $INSTANCES --region $REGION
        echo "⏳ Waiting for instances to terminate..."
        aws ec2 wait instance-terminated --instance-ids $INSTANCES --region $REGION
        echo "✅ Instances terminated"
    else
        echo "✅ No EC2 instances found"
    fi

    # 2. Delete any remaining load balancers
    echo "⚖️ Checking for load balancers..."
    LBS=$(aws elbv2 describe-load-balancers --region $REGION --query 'LoadBalancers[?contains(LoadBalancerName, `k8s`) || contains(LoadBalancerName, `healthcare`)].LoadBalancerArn' --output text)

    if [ ! -z "$LBS" ]; then
        echo "🗑️ Deleting load balancers..."
        for lb in $LBS; do
            echo "   Deleting: $lb"
            aws elbv2 delete-load-balancer --load-balancer-arn "$lb" --region $REGION
        done
        echo "⏳ Waiting for load balancers to be deleted..."
        sleep 30
        echo "✅ Load balancers deletion initiated"
    else
        echo "✅ No load balancers found"
    fi

    # 3. Delete NAT Gateways (these cost money and block VPC deletion)
    echo "🌐 Checking for NAT Gateways..."
    NAT_GWS=$(aws ec2 describe-nat-gateways --region $REGION --filter "Name=tag:Name,Values=*eksctl-healthcare*" --query 'NatGateways[?State!=`deleted`].NatGatewayId' --output text)

    if [ ! -z "$NAT_GWS" ]; then
        echo "🗑️ Deleting NAT Gateways: $NAT_GWS"
        for nat_gw in $NAT_GWS; do
            echo "   Deleting NAT Gateway: $nat_gw"
            aws ec2 delete-nat-gateway --nat-gateway-id "$nat_gw" --region $REGION
        done
        echo "⏳ Waiting for NAT Gateways to be deleted..."
        sleep 60
        echo "✅ NAT Gateways deletion initiated"
    else
        echo "✅ No NAT Gateways found"
    fi

    # 4. Release Elastic IPs associated with NAT Gateways
    echo "📍 Checking for Elastic IPs..."
    EIPS=$(aws ec2 describe-addresses --region $REGION --filters "Name=tag:Name,Values=*eksctl-healthcare*" --query 'Addresses[].AllocationId' --output text)

    if [ ! -z "$EIPS" ]; then
        echo "🗑️ Releasing Elastic IPs: $EIPS"
        for eip in $EIPS; do
            echo "   Releasing EIP: $eip"
            aws ec2 release-address --allocation-id "$eip" --region $REGION
        done
        echo "✅ Elastic IPs released"
    else
        echo "✅ No Elastic IPs found"
    fi

    echo ""
}

# Function to clean up VPC and networking resources
cleanup_vpc_resources() {
    echo "🌐 Comprehensive VPC and Networking Cleanup"
    echo "==========================================="

    # Find VPCs created by eksctl for healthcare cluster
    VPC_IDS=$(aws ec2 describe-vpcs --region $REGION --filters "Name=tag:Name,Values=*eksctl-healthcare*" --query 'Vpcs[].VpcId' --output text)

    if [ -z "$VPC_IDS" ]; then
        echo "✅ No eksctl-healthcare VPCs found"
        return
    fi

    for VPC_ID in $VPC_IDS; do
        echo "🔍 Processing VPC: $VPC_ID"

        # 1. Delete all ENIs (Elastic Network Interfaces) in the VPC
        echo "   🔌 Deleting ENIs..."
        ENI_IDS=$(aws ec2 describe-network-interfaces --region $REGION --filters "Name=vpc-id,Values=$VPC_ID" --query 'NetworkInterfaces[].NetworkInterfaceId' --output text)
        for ENI_ID in $ENI_IDS; do
            echo "     Deleting ENI: $ENI_ID"
            aws ec2 delete-network-interface --network-interface-id "$ENI_ID" --region $REGION 2>/dev/null || echo "     ENI $ENI_ID may be in use or already deleted"
        done

        # 2. Delete all Security Groups (except default)
        echo "   🔒 Deleting Security Groups..."
        SG_IDS=$(aws ec2 describe-security-groups --region $REGION --filters "Name=vpc-id,Values=$VPC_ID" --query 'SecurityGroups[?GroupName!=`default`].GroupId' --output text)
        for SG_ID in $SG_IDS; do
            echo "     Deleting Security Group: $SG_ID"
            aws ec2 delete-security-group --group-id "$SG_ID" --region $REGION 2>/dev/null || echo "     SG $SG_ID may have dependencies or already deleted"
        done

        # 3. Delete all Subnets
        echo "   🏠 Deleting Subnets..."
        SUBNET_IDS=$(aws ec2 describe-subnets --region $REGION --filters "Name=vpc-id,Values=$VPC_ID" --query 'Subnets[].SubnetId' --output text)
        for SUBNET_ID in $SUBNET_IDS; do
            echo "     Deleting Subnet: $SUBNET_ID"
            aws ec2 delete-subnet --subnet-id "$SUBNET_ID" --region $REGION 2>/dev/null || echo "     Subnet $SUBNET_ID may have dependencies or already deleted"
        done

        # 4. Detach and Delete Internet Gateways
        echo "   🌍 Deleting Internet Gateways..."
        IGW_IDS=$(aws ec2 describe-internet-gateways --region $REGION --filters "Name=attachment.vpc-id,Values=$VPC_ID" --query 'InternetGateways[].InternetGatewayId' --output text)
        for IGW_ID in $IGW_IDS; do
            echo "     Detaching and deleting IGW: $IGW_ID"
            aws ec2 detach-internet-gateway --internet-gateway-id "$IGW_ID" --vpc-id "$VPC_ID" --region $REGION 2>/dev/null
            aws ec2 delete-internet-gateway --internet-gateway-id "$IGW_ID" --region $REGION 2>/dev/null || echo "     IGW $IGW_ID may already be deleted"
        done

        # 5. Delete Route Tables (except main)
        echo "   🛣️ Deleting Route Tables..."
        RT_IDS=$(aws ec2 describe-route-tables --region $REGION --filters "Name=vpc-id,Values=$VPC_ID" --query 'RouteTables[?Associations[0].Main!=`true`].RouteTableId' --output text)
        for RT_ID in $RT_IDS; do
            echo "     Deleting Route Table: $RT_ID"
            aws ec2 delete-route-table --route-table-id "$RT_ID" --region $REGION 2>/dev/null || echo "     Route Table $RT_ID may have dependencies or already deleted"
        done

        # 6. Finally, delete the VPC
        echo "   🗑️ Deleting VPC: $VPC_ID"
        aws ec2 delete-vpc --vpc-id "$VPC_ID" --region $REGION 2>/dev/null || echo "     VPC $VPC_ID may have dependencies or already deleted"

        echo "   ✅ VPC $VPC_ID cleanup completed"
    done

    echo ""
}

# Function to perform final verification
final_verification() {
    echo "🔍 Final Verification of Resource Cleanup"
    echo "========================================"

    local cleanup_success=true

    # Check EKS cluster
    if aws eks describe-cluster --name $CLUSTER_NAME --region $REGION >/dev/null 2>&1; then
        echo "❌ EKS cluster still exists"
        cleanup_success=false
    else
        echo "✅ EKS cluster: Deleted"
    fi

    # Check CloudFormation stacks
    REMAINING_STACKS=$(aws cloudformation list-stacks --region $REGION --query 'StackSummaries[?contains(StackName, `healthcare`) || contains(StackName, `eksctl-healthcare`)].StackName' --output text)
    if [ ! -z "$REMAINING_STACKS" ]; then
        echo "❌ CloudFormation stacks still exist: $REMAINING_STACKS"
        cleanup_success=false
    else
        echo "✅ CloudFormation stacks: All deleted"
    fi

    # Check EC2 instances
    REMAINING_INSTANCES=$(aws ec2 describe-instances --region $REGION --filters "Name=tag:kubernetes.io/cluster/$CLUSTER_NAME,Values=owned" "Name=instance-state-name,Values=running,pending,stopping,stopped" --query 'Reservations[].Instances[].InstanceId' --output text)
    if [ ! -z "$REMAINING_INSTANCES" ]; then
        echo "❌ EC2 instances still exist: $REMAINING_INSTANCES"
        cleanup_success=false
    else
        echo "✅ EC2 instances: All terminated"
    fi

    # Check Load Balancers
    REMAINING_LBS=$(aws elbv2 describe-load-balancers --region $REGION --query 'LoadBalancers[?contains(LoadBalancerName, `k8s`) || contains(LoadBalancerName, `healthcare`)].LoadBalancerName' --output text)
    if [ ! -z "$REMAINING_LBS" ]; then
        echo "❌ Load balancers still exist: $REMAINING_LBS"
        cleanup_success=false
    else
        echo "✅ Load balancers: All deleted"
    fi

    # Check NAT Gateways
    REMAINING_NATS=$(aws ec2 describe-nat-gateways --region $REGION --filter "Name=tag:Name,Values=*eksctl-healthcare*" --query 'NatGateways[?State!=`deleted`].NatGatewayId' --output text)
    if [ ! -z "$REMAINING_NATS" ]; then
        echo "❌ NAT Gateways still exist: $REMAINING_NATS"
        cleanup_success=false
    else
        echo "✅ NAT Gateways: All deleted"
    fi

    # Check VPCs
    REMAINING_VPCS=$(aws ec2 describe-vpcs --region $REGION --filters "Name=tag:Name,Values=*eksctl-healthcare*" --query 'Vpcs[].VpcId' --output text)
    if [ ! -z "$REMAINING_VPCS" ]; then
        echo "❌ VPCs still exist: $REMAINING_VPCS"
        cleanup_success=false
    else
        echo "✅ VPCs: All deleted"
    fi

    # Check Security Groups
    REMAINING_SGS=$(aws ec2 describe-security-groups --region $REGION --filters "Name=group-name,Values=*eksctl-healthcare*" --query 'SecurityGroups[].GroupId' --output text)
    if [ ! -z "$REMAINING_SGS" ]; then
        echo "❌ Security Groups still exist: $REMAINING_SGS"
        cleanup_success=false
    else
        echo "✅ Security Groups: All deleted"
    fi

    # Check Subnets
    REMAINING_SUBNETS=$(aws ec2 describe-subnets --region $REGION --filters "Name=tag:Name,Values=*eksctl-healthcare*" --query 'Subnets[].SubnetId' --output text)
    if [ ! -z "$REMAINING_SUBNETS" ]; then
        echo "❌ Subnets still exist: $REMAINING_SUBNETS"
        cleanup_success=false
    else
        echo "✅ Subnets: All deleted"
    fi

    # Check Internet Gateways
    REMAINING_IGWS=$(aws ec2 describe-internet-gateways --region $REGION --filters "Name=tag:Name,Values=*eksctl-healthcare*" --query 'InternetGateways[].InternetGatewayId' --output text)
    if [ ! -z "$REMAINING_IGWS" ]; then
        echo "❌ Internet Gateways still exist: $REMAINING_IGWS"
        cleanup_success=false
    else
        echo "✅ Internet Gateways: All deleted"
    fi

    # Check Route Tables
    REMAINING_RTS=$(aws ec2 describe-route-tables --region $REGION --filters "Name=tag:Name,Values=*eksctl-healthcare*" --query 'RouteTables[].RouteTableId' --output text)
    if [ ! -z "$REMAINING_RTS" ]; then
        echo "❌ Route Tables still exist: $REMAINING_RTS"
        cleanup_success=false
    else
        echo "✅ Route Tables: All deleted"
    fi

    echo ""
    echo "📊 FINAL CLEANUP STATUS"
    echo "======================"

    if [ "$cleanup_success" = true ]; then
        echo "🎉 SUCCESS: All healthcare cluster resources have been completely removed!"
        echo ""
        echo "✅ Verified clean resources:"
        echo "   • EKS cluster"
        echo "   • CloudFormation stacks"
        echo "   • EC2 instances"
        echo "   • Load balancers"
        echo "   • NAT Gateways"
        echo "   • VPCs and networking"
        echo "   • Security groups"
        echo "   • Subnets"
        echo "   • Internet gateways"
        echo "   • Route tables"
        echo ""
        echo "💰 Cost Impact: $0.00/hour (no active resources)"
        echo "🚀 Ready to create new cluster: ./create-eks-cluster.sh"
    else
        echo "❌ INCOMPLETE: Some resources still exist and need manual cleanup"
        echo ""
        echo "🔧 Manual cleanup required for remaining resources listed above"
        echo "⚠️ Do not create a new cluster until all resources are cleaned up"
        echo ""
        echo "💡 Suggested actions:"
        echo "1. Wait 5-10 minutes for AWS to complete deletions"
        echo "2. Re-run this script: ./cleanup-cloudformation.sh"
        echo "3. Check AWS Console for stuck resources"
        echo "4. Contact AWS support if resources remain stuck"
    fi

    return $cleanup_success
}

# Main cleanup process
echo "🔍 Checking for healthcare-related CloudFormation stacks..."

# Get all healthcare-related stacks
STACKS=$(aws cloudformation list-stacks --region $REGION --query 'StackSummaries[?contains(StackName, `healthcare`) || contains(StackName, `eksctl-healthcare`)].StackName' --output text)

if [ -z "$STACKS" ]; then
    echo "✅ No healthcare-related CloudFormation stacks found"
else
    echo "📋 Found the following stacks to delete:"
    for stack in $STACKS; do
        echo "   • $stack"
    done
    echo ""
    
    read -p "⚠️ Do you want to delete these CloudFormation stacks? (type 'yes' to confirm): " confirm
    
    if [ "$confirm" = "yes" ]; then
        # Delete nodegroup stack first (if exists)
        for stack in $STACKS; do
            if [[ $stack == *"nodegroup"* ]]; then
                delete_stack_and_wait "$stack"
            fi
        done
        
        # Then delete cluster stack
        for stack in $STACKS; do
            if [[ $stack == *"cluster"* ]] && [[ $stack != *"nodegroup"* ]]; then
                delete_stack_and_wait "$stack"
            fi
        done
        
        # Delete any other remaining stacks
        for stack in $STACKS; do
            if [[ $stack != *"nodegroup"* ]] && [[ $stack != *"cluster"* ]]; then
                delete_stack_and_wait "$stack"
            fi
        done
        
        echo "🔧 Checking for any stuck resources..."
        force_delete_resources

        echo "🌐 Performing comprehensive VPC cleanup..."
        cleanup_vpc_resources

        echo "⏳ Waiting for all deletions to propagate..."
        sleep 30

        echo "🔍 Performing final verification..."
        if final_verification; then
            echo ""
            echo "🎉 COMPLETE SUCCESS: All resources cleaned up!"
            echo "🚀 Ready to create new cluster: ./create-eks-cluster.sh"
        else
            echo ""
            echo "⚠️ Some resources still exist. Please check the output above."
            echo "💡 You may need to wait longer or perform manual cleanup."
        fi
        
    else
        echo "❌ Cleanup cancelled by user"
    fi
fi

echo ""
echo "🔍 Current CloudFormation stacks:"
aws cloudformation list-stacks --region $REGION --query 'StackSummaries[?contains(StackName, `healthcare`) || contains(StackName, `eksctl-healthcare`)].{Name:StackName,Status:StackStatus}' --output table 2>/dev/null || echo "No stacks found or no access"
