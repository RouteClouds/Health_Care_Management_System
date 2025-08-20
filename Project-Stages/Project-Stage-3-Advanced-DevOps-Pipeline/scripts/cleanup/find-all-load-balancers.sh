#!/bin/bash

# Find All Load Balancers Script
# Comprehensive search for Classic, Application, and Network Load Balancers

REGION="${AWS_REGION:-us-east-1}"

echo "🔍 Comprehensive Load Balancer Discovery"
echo "========================================"
echo "Region: $REGION"
echo ""

# Classic Load Balancers (ELB v1)
echo "📋 Classic Load Balancers (ELB v1):"
echo "-----------------------------------"
aws elb describe-load-balancers --region "$REGION" --output table --query 'LoadBalancerDescriptions[].[LoadBalancerName,VPCId,Scheme,CreatedTime,DNSName]' 2>/dev/null || echo "No Classic Load Balancers found or access denied"

echo ""

# Application/Network Load Balancers (ELB v2)
echo "📋 Application/Network Load Balancers (ELB v2):"
echo "-----------------------------------------------"
aws elbv2 describe-load-balancers --region "$REGION" --output table --query 'LoadBalancers[].[LoadBalancerName,Type,VpcId,Scheme,CreatedTime,DNSName]' 2>/dev/null || echo "No ALB/NLB found or access denied"

echo ""

# Target Groups
echo "📋 Target Groups:"
echo "-----------------"
aws elbv2 describe-target-groups --region "$REGION" --output table --query 'TargetGroups[].[TargetGroupName,Protocol,Port,VpcId,LoadBalancerArns[0]]' 2>/dev/null || echo "No Target Groups found or access denied"

echo ""

# Load Balancer Listeners
echo "📋 Load Balancer Listeners:"
echo "---------------------------"
LB_ARNS=$(aws elbv2 describe-load-balancers --region "$REGION" --query 'LoadBalancers[].LoadBalancerArn' --output text 2>/dev/null)
if [[ -n "$LB_ARNS" && "$LB_ARNS" != "None" ]]; then
    for arn in $LB_ARNS; do
        echo "Listeners for: $arn"
        aws elbv2 describe-listeners --load-balancer-arn "$arn" --region "$REGION" --output table --query 'Listeners[].[ListenerArn,Protocol,Port,DefaultActions[0].Type]' 2>/dev/null || echo "No listeners found"
        echo ""
    done
else
    echo "No ALB/NLB ARNs found"
fi

echo ""

# Check for Kubernetes-managed load balancers
echo "📋 Kubernetes-managed Load Balancers:"
echo "-------------------------------------"
echo "Classic ELBs with k8s tags:"
aws elb describe-load-balancers --region "$REGION" --query 'LoadBalancerDescriptions[?contains(LoadBalancerName,`k8s`) || contains(LoadBalancerName,`kubernetes`)].[LoadBalancerName,VPCId,Scheme]' --output table 2>/dev/null || echo "No k8s Classic ELBs found"

echo ""
echo "ALB/NLBs with k8s tags:"
aws elbv2 describe-load-balancers --region "$REGION" --query 'LoadBalancers[?contains(LoadBalancerName,`k8s`) || contains(LoadBalancerName,`kubernetes`)].[LoadBalancerName,Type,VpcId]' --output table 2>/dev/null || echo "No k8s ALB/NLBs found"

echo ""

# Check for load balancers by tags
echo "📋 Load Balancers by Healthcare/Stage3 Tags:"
echo "--------------------------------------------"
echo "Checking for healthcare/stage3 tagged load balancers..."

# Get all ELB v2 ARNs and check their tags
ALL_LB_ARNS=$(aws elbv2 describe-load-balancers --region "$REGION" --query 'LoadBalancers[].LoadBalancerArn' --output text 2>/dev/null)
if [[ -n "$ALL_LB_ARNS" && "$ALL_LB_ARNS" != "None" ]]; then
    for arn in $ALL_LB_ARNS; do
        TAGS=$(aws elbv2 describe-tags --resource-arns "$arn" --region "$REGION" --query 'TagDescriptions[0].Tags[?contains(Value,`healthcare`) || contains(Value,`stage3`) || contains(Key,`kubernetes`) || contains(Key,`ingress`)]' --output text 2>/dev/null)
        if [[ -n "$TAGS" ]]; then
            LB_NAME=$(aws elbv2 describe-load-balancers --load-balancer-arns "$arn" --region "$REGION" --query 'LoadBalancers[0].LoadBalancerName' --output text)
            LB_TYPE=$(aws elbv2 describe-load-balancers --load-balancer-arns "$arn" --region "$REGION" --query 'LoadBalancers[0].Type' --output text)
            echo "Found tagged LB: $LB_NAME (Type: $LB_TYPE)"
            echo "Tags: $TAGS"
            echo ""
        fi
    done
else
    echo "No ALB/NLB ARNs to check for tags"
fi

echo ""
echo "✅ Load Balancer discovery completed"
