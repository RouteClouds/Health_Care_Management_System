#!/bin/bash

# Stage 2 - Force delete a failed CloudFormation stack for the Stage-2 EKS cluster
set -euo pipefail

REGION="us-east-1"
STACK_NAME="eksctl-healthcare-cluster-stage2-cluster"

echo "🔥 Force Delete Failed CloudFormation Stack (Stage-2)"
echo "===================================================="

echo "🔍 Checking stack status..."
STACK_STATUS=$(aws cloudformation describe-stacks --stack-name "$STACK_NAME" --region "$REGION" --query 'Stacks[0].StackStatus' --output text 2>/dev/null || true)

if [ -z "$STACK_STATUS" ] || [ "$STACK_STATUS" = "None" ]; then
  echo "✅ Stack $STACK_NAME does not exist or is already deleted"
  exit 0
fi

echo "📋 Current stack status: $STACK_STATUS"

if [ "$STACK_STATUS" = "DELETE_FAILED" ]; then
  echo "🚨 Stack is in DELETE_FAILED state - this can block new cluster creation"
  echo ""
  echo "📋 Resources in the failed stack (that failed to delete):"
  aws cloudformation describe-stack-resources --stack-name "$STACK_NAME" --region "$REGION" \
    --query 'StackResources[?ResourceStatus==`DELETE_FAILED`].{Type:ResourceType,Id:PhysicalResourceId,Status:ResourceStatus,Reason:ResourceStatusReason}' --output table || true
  echo ""
  echo "⚠️  This operation will attempt to remove the stack record, optionally retaining failed resources."
  read -p "Type 'yes' to force delete the failed stack (retain failed resources): " confirm
  if [ "$confirm" = "yes" ]; then
    echo "🗑️ Initiating stack deletion with resource retention (failed resources only)..."
    failed_logical_ids=$(aws cloudformation describe-stack-resources --stack-name "$STACK_NAME" --region "$REGION" \
      --query 'StackResources[?ResourceStatus==`DELETE_FAILED`].LogicalResourceId' --output text | tr '\t' ' ')
    if [ -n "$failed_logical_ids" ]; then
      aws cloudformation delete-stack --stack-name "$STACK_NAME" --region "$REGION" --retain-resources $failed_logical_ids || true
    else
      aws cloudformation delete-stack --stack-name "$STACK_NAME" --region "$REGION" || true
    fi
    echo "⏳ Waiting for stack deletion to complete..."
    if aws cloudformation wait stack-delete-complete --stack-name "$STACK_NAME" --region "$REGION"; then
      echo "✅ Stack successfully deleted!"
    else
      echo "⚠️ Stack deletion may have timed out, checking status..."
      FINAL_STATUS=$(aws cloudformation describe-stacks --stack-name "$STACK_NAME" --region "$REGION" --query 'Stacks[0].StackStatus' --output text 2>/dev/null || true)
      if [ -z "$FINAL_STATUS" ] || [ "$FINAL_STATUS" = "None" ]; then
        echo "✅ Stack is now deleted (no longer exists)"
      else
        echo "❌ Stack still exists with status: $FINAL_STATUS"
      fi
    fi
  else
    echo "❌ Stack deletion cancelled by user"; exit 1
  fi
elif [ "$STACK_STATUS" = "DELETE_IN_PROGRESS" ]; then
  echo "⏳ Stack is currently being deleted. Waiting for completion..."
  if aws cloudformation wait stack-delete-complete --stack-name "$STACK_NAME" --region "$REGION"; then
    echo "✅ Stack deletion completed successfully"
  else
    echo "⚠️ Waiter failed. Re-run this script after diagnosing blocking resources."
  fi
else
  echo "🔧 Stack status is $STACK_STATUS - attempting normal deletion..."
  read -p "Type 'yes' to delete this stack: " confirm
  if [ "$confirm" = "yes" ]; then
    aws cloudformation delete-stack --stack-name "$STACK_NAME" --region "$REGION" || true
    echo "⏳ Waiting for deletion to complete..."
    aws cloudformation wait stack-delete-complete --stack-name "$STACK_NAME" --region "$REGION" || true
  else
    echo "❌ Stack deletion cancelled by user"; exit 1
  fi
fi

echo ""
echo "🔍 Final verification..."
if aws cloudformation describe-stacks --stack-name "$STACK_NAME" --region "$REGION" >/dev/null 2>&1; then
  echo "❌ Stack still exists. Check AWS Console for remaining issues."
  aws cloudformation describe-stacks --stack-name "$STACK_NAME" --region "$REGION" --query 'Stacks[0].{Status:StackStatus,Reason:StackStatusReason}' --output table || true
else
  echo "✅ SUCCESS: Stack $STACK_NAME is now completely deleted"
  echo "🚀 You can now create a new cluster: ./deployment/create-eks-cluster.sh"
fi

