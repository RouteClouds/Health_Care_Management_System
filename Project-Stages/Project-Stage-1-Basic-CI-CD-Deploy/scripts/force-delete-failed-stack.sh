#!/bin/bash

echo "🔥 Force Delete Failed CloudFormation Stack"
echo "==========================================="

REGION="us-east-1"
STACK_NAME="eksctl-healthcare-cluster-cluster"

echo "🔍 Checking stack status..."
STACK_STATUS=$(aws cloudformation describe-stacks --stack-name "$STACK_NAME" --region $REGION --query 'Stacks[0].StackStatus' --output text 2>/dev/null)

if [ $? -ne 0 ]; then
    echo "✅ Stack $STACK_NAME does not exist or is already deleted"
    exit 0
fi

echo "📋 Current stack status: $STACK_STATUS"

if [ "$STACK_STATUS" = "DELETE_FAILED" ]; then
    echo "🚨 Stack is in DELETE_FAILED state - this is blocking new cluster creation"
    echo ""
    
    echo "🔍 Checking for resources that might be blocking deletion..."
    
    # Get stack resources that failed to delete
    echo "📋 Resources in the failed stack:"
    aws cloudformation describe-stack-resources --stack-name "$STACK_NAME" --region $REGION --query 'StackResources[?ResourceStatus==`DELETE_FAILED`].{Type:ResourceType,Id:PhysicalResourceId,Status:ResourceStatus,Reason:ResourceStatusReason}' --output table
    
    echo ""
    echo "🔧 Attempting to force delete the stack..."
    echo "⚠️  This will skip resource deletion and remove the stack record"
    
    read -p "Do you want to force delete the failed stack? (type 'yes' to confirm): " confirm
    
    if [ "$confirm" = "yes" ]; then
        echo "🗑️ Force deleting stack: $STACK_NAME"
        
        # Try to delete with retain resources option first
        echo "📋 Step 1: Attempting to delete stack while retaining resources..."
        aws cloudformation delete-stack --stack-name "$STACK_NAME" --region $REGION --retain-resources $(aws cloudformation describe-stack-resources --stack-name "$STACK_NAME" --region $REGION --query 'StackResources[?ResourceStatus==`DELETE_FAILED`].LogicalResourceId' --output text | tr '\t' ' ')
        
        if [ $? -eq 0 ]; then
            echo "✅ Stack deletion initiated with resource retention"
            echo "⏳ Waiting for stack deletion to complete..."
            
            # Wait for deletion
            aws cloudformation wait stack-delete-complete --stack-name "$STACK_NAME" --region $REGION
            
            if [ $? -eq 0 ]; then
                echo "✅ Stack successfully deleted!"
            else
                echo "⚠️ Stack deletion may have timed out, checking status..."
                FINAL_STATUS=$(aws cloudformation describe-stacks --stack-name "$STACK_NAME" --region $REGION --query 'Stacks[0].StackStatus' --output text 2>/dev/null)
                if [ $? -ne 0 ]; then
                    echo "✅ Stack is now deleted (no longer exists)"
                else
                    echo "❌ Stack still exists with status: $FINAL_STATUS"
                fi
            fi
        else
            echo "❌ Failed to initiate stack deletion"
        fi
    else
        echo "❌ Stack deletion cancelled by user"
        exit 1
    fi
    
elif [ "$STACK_STATUS" = "DELETE_IN_PROGRESS" ]; then
    echo "⏳ Stack is currently being deleted. Waiting for completion..."
    aws cloudformation wait stack-delete-complete --stack-name "$STACK_NAME" --region $REGION
    
    if [ $? -eq 0 ]; then
        echo "✅ Stack deletion completed successfully"
    else
        echo "⚠️ Stack deletion timed out or failed"
    fi
    
else
    echo "🔧 Stack status is $STACK_STATUS - attempting normal deletion..."
    
    read -p "Do you want to delete this stack? (type 'yes' to confirm): " confirm
    
    if [ "$confirm" = "yes" ]; then
        aws cloudformation delete-stack --stack-name "$STACK_NAME" --region $REGION
        
        if [ $? -eq 0 ]; then
            echo "✅ Stack deletion initiated"
            echo "⏳ Waiting for deletion to complete..."
            aws cloudformation wait stack-delete-complete --stack-name "$STACK_NAME" --region $REGION
            
            if [ $? -eq 0 ]; then
                echo "✅ Stack deleted successfully"
            else
                echo "⚠️ Stack deletion may have failed or timed out"
            fi
        else
            echo "❌ Failed to initiate stack deletion"
        fi
    else
        echo "❌ Stack deletion cancelled by user"
        exit 1
    fi
fi

echo ""
echo "🔍 Final verification..."
FINAL_CHECK=$(aws cloudformation describe-stacks --stack-name "$STACK_NAME" --region $REGION 2>/dev/null)

if [ $? -ne 0 ]; then
    echo "✅ SUCCESS: Stack $STACK_NAME is now completely deleted"
    echo "🚀 You can now create a new cluster: ./create-eks-cluster.sh"
else
    echo "❌ Stack still exists. Manual intervention may be required."
    echo "🔧 Try the following:"
    echo "1. Check AWS CloudFormation console for specific errors"
    echo "2. Manually delete stuck resources from AWS console"
    echo "3. Contact AWS support for assistance"
    echo ""
    echo "📋 Current stack status:"
    aws cloudformation describe-stacks --stack-name "$STACK_NAME" --region $REGION --query 'Stacks[0].{Status:StackStatus,Reason:StackStatusReason}' --output table
fi

echo ""
echo "🔍 Checking for any remaining healthcare-related stacks..."
aws cloudformation list-stacks --region $REGION --query 'StackSummaries[?contains(StackName, `healthcare`) || contains(StackName, `eksctl-healthcare`)].{Name:StackName,Status:StackStatus}' --output table
