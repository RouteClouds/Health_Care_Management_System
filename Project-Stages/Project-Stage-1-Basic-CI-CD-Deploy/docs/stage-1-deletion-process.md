# 🗑️ Stage 1 Complete Deletion Process
## Health Care Management System - Cost-Safe Resource Cleanup

### 🎯 Overview
This guide provides a comprehensive, step-by-step process to completely delete all AWS resources created during Stage 1 deployment to prevent unnecessary costs. Follow this guide carefully to ensure no resources are left running.

**⚠️ IMPORTANT**: This process will permanently delete all data and resources. Make sure you have backups if needed.

---

## 💰 Cost Impact Prevention

### **Why This Guide is Critical**
- **EKS Control Plane**: $73/month if left running
- **EC2 Worker Nodes**: $60/month for 2x t3.medium instances
- **Load Balancer**: $20/month if not deleted
- **EBS Volumes**: $10/month for persistent storage (PostgreSQL 16 data)
- **Data Transfer**: Variable costs
- **Total Potential Cost**: ~$163/month if not cleaned up

### **Deletion Order (Critical)**
1. **Applications First** - Delete pods and services
2. **Load Balancers** - Remove external access points
3. **Worker Nodes** - Terminate EC2 instances
4. **EKS Cluster** - Delete the control plane
5. **VPC Resources** - Clean up networking (if created by eksctl)
6. **IAM Roles** - Remove service roles (if created by eksctl)
7. **CloudFormation Stacks** - Verify all stacks are deleted

---

## 🚀 Quick Automated Deletion (Recommended)

### **Option 1: Use Our Cleanup Script**
```bash
# Navigate to Stage 1 directory
cd /home/ubuntu/Projects/Health_Care_Management_System/Project-Stages/Project-Stage-1-Basic-CI-CD-Deploy

# Run automated cleanup script
./scripts/cleanup.sh

# Follow the prompts and confirm deletion
# This will handle most of the cleanup automatically
```

### **Option 2: Manual Step-by-Step Process**
If you prefer manual control or the script fails, follow the detailed steps below.

---

## 📋 Manual Step-by-Step Deletion Process

### **Step 1: Verify Current Resources (5 minutes)**

#### **Check What's Currently Running**
```bash
# Check if kubectl is configured
kubectl cluster-info

# List all resources in healthcare namespace
kubectl get all -n healthcare

# Check EKS clusters
eksctl get cluster --region us-east-1

# Check EC2 instances
aws ec2 describe-instances --region us-east-1 --query 'Reservations[*].Instances[*].[InstanceId,InstanceType,State.Name,Tags[?Key==`Name`].Value|[0]]' --output table

# Check Load Balancers
aws elbv2 describe-load-balancers --region us-east-1 --query 'LoadBalancers[*].[LoadBalancerName,State.Code,Type]' --output table

# Check CloudFormation stacks
aws cloudformation list-stacks --region us-east-1 --stack-status-filter CREATE_COMPLETE UPDATE_COMPLETE --query 'StackSummaries[?contains(StackName, `eksctl`) || contains(StackName, `healthcare`)].{Name:StackName,Status:StackStatus}' --output table
```

### **Step 2: Delete Application Resources (10 minutes)**

#### **Delete Healthcare Application**
```bash
# Delete the healthcare namespace (this removes all apps, services, and volumes)
kubectl delete namespace healthcare --timeout=300s

# Verify namespace deletion
kubectl get namespaces | grep healthcare
# Should return nothing

# Wait for all resources to be fully deleted
echo "Waiting for namespace deletion to complete..."
sleep 60

# Verify no healthcare pods are running
kubectl get pods --all-namespaces | grep healthcare
# Should return nothing
```

#### **Verify Application Cleanup**
```bash
# Check that Load Balancers are being deleted
aws elbv2 describe-load-balancers --region us-east-1 --query 'LoadBalancers[?contains(LoadBalancerName, `healthcare`) || contains(LoadBalancerName, `frontend`)].{Name:LoadBalancerName,State:State.Code}' --output table

# Wait for Load Balancers to be deleted (this can take 5-10 minutes)
echo "Waiting for Load Balancers to be deleted..."
while aws elbv2 describe-load-balancers --region us-east-1 --query 'LoadBalancers[?contains(LoadBalancerName, `healthcare`) || contains(LoadBalancerName, `frontend`)]' --output text | grep -q .; do
    echo "Load Balancers still deleting... waiting 30 seconds"
    sleep 30
done
echo "✅ Load Balancers deleted"
```

### **Step 3: Delete EKS Cluster and Node Groups (15-20 minutes)**

#### **Delete the EKS Cluster**
```bash
# Delete the entire EKS cluster (this includes node groups)
eksctl delete cluster --name healthcare-cluster --region us-east-1 --wait

# This command will:
# - Delete all node groups
# - Terminate all EC2 instances
# - Delete the EKS control plane
# - Remove associated security groups
# - Delete CloudFormation stacks
# - Clean up VPC resources (if created by eksctl)
```

#### **Monitor Cluster Deletion**
```bash
# Monitor deletion progress (in another terminal if needed)
watch -n 30 'eksctl get cluster --region us-east-1'

# Check CloudFormation stack deletion
watch -n 30 'aws cloudformation list-stacks --region us-east-1 --stack-status-filter DELETE_IN_PROGRESS --query "StackSummaries[?contains(StackName, \`eksctl\`)].{Name:StackName,Status:StackStatus}" --output table'
```

### **Step 4: Verify EC2 Instance Termination (5 minutes)**

#### **Check EC2 Instances**
```bash
# Verify all EKS-related EC2 instances are terminated
aws ec2 describe-instances --region us-east-1 --filters "Name=tag:kubernetes.io/cluster/healthcare-cluster,Values=owned" --query 'Reservations[*].Instances[*].[InstanceId,State.Name,InstanceType]' --output table

# Check for any running instances with healthcare tags
aws ec2 describe-instances --region us-east-1 --filters "Name=instance-state-name,Values=running" --query 'Reservations[*].Instances[?Tags[?Key==`Name` && contains(Value, `healthcare`)]].[InstanceId,State.Name,Tags[?Key==`Name`].Value|[0]]' --output table

# If any instances are still running, they should be in 'shutting-down' or 'terminated' state
```

### **Step 5: Verify VPC and Security Group Cleanup (5 minutes)**

#### **Check VPC Resources**
```bash
# Check if eksctl created VPC is being deleted
aws ec2 describe-vpcs --region us-east-1 --filters "Name=tag:alpha.eksctl.io/cluster-name,Values=healthcare-cluster" --query 'Vpcs[*].[VpcId,State,Tags[?Key==`Name`].Value|[0]]' --output table

# Check security groups
aws ec2 describe-security-groups --region us-east-1 --filters "Name=tag:alpha.eksctl.io/cluster-name,Values=healthcare-cluster" --query 'SecurityGroups[*].[GroupId,GroupName,Description]' --output table

# These should be automatically deleted by eksctl
```

### **Step 6: Verify IAM Role Cleanup (5 minutes)**

#### **Check IAM Roles**
```bash
# Check for EKS-related IAM roles
aws iam list-roles --query 'Roles[?contains(RoleName, `eksctl`) || contains(RoleName, `healthcare`)].{RoleName:RoleName,CreateDate:CreateDate}' --output table

# Check for EKS service roles
aws iam list-roles --query 'Roles[?contains(RoleName, `EKS`) && contains(RoleName, `healthcare`)].{RoleName:RoleName,CreateDate:CreateDate}' --output table

# These should be automatically deleted by eksctl
```

### **Step 7: Verify CloudFormation Stack Cleanup (5 minutes)**

#### **Check CloudFormation Stacks**
```bash
# Check for any remaining eksctl CloudFormation stacks
aws cloudformation list-stacks --region us-east-1 --query 'StackSummaries[?contains(StackName, `eksctl-healthcare-cluster`)].{Name:StackName,Status:StackStatus,CreationTime:CreationTime}' --output table

# Check for any failed deletions
aws cloudformation list-stacks --region us-east-1 --stack-status-filter DELETE_FAILED --query 'StackSummaries[?contains(StackName, `eksctl`)].{Name:StackName,Status:StackStatus,StatusReason:StackStatusReason}' --output table
```

### **Step 8: Clean Up Local Docker Images (Optional)**

#### **Remove Local Docker Images**
```bash
# List healthcare-related Docker images
docker images | grep healthcare

# Remove healthcare images
docker images | grep healthcare | awk '{print $3}' | xargs -r docker rmi -f

# Clean up Docker system (optional)
docker system prune -f

# Clean up Docker volumes (optional)
docker volume prune -f
```

---

## ✅ Final Verification Checklist

### **Complete Deletion Verification**
```bash
echo "🔍 Final Verification Checklist"
echo "================================"

echo "1. EKS Clusters:"
eksctl get cluster --region us-east-1 || echo "✅ No EKS clusters found"

echo ""
echo "2. EC2 Instances:"
RUNNING_INSTANCES=$(aws ec2 describe-instances --region us-east-1 --filters "Name=instance-state-name,Values=running" --query 'Reservations[*].Instances[?Tags[?Key==`kubernetes.io/cluster/healthcare-cluster`]].[InstanceId]' --output text)
if [ -z "$RUNNING_INSTANCES" ]; then
    echo "✅ No healthcare-related EC2 instances running"
else
    echo "⚠️ Found running instances: $RUNNING_INSTANCES"
fi

echo ""
echo "3. Load Balancers:"
LBS=$(aws elbv2 describe-load-balancers --region us-east-1 --query 'LoadBalancers[?contains(LoadBalancerName, `healthcare`)].LoadBalancerName' --output text)
if [ -z "$LBS" ]; then
    echo "✅ No healthcare-related Load Balancers found"
else
    echo "⚠️ Found Load Balancers: $LBS"
fi

echo ""
echo "4. CloudFormation Stacks:"
STACKS=$(aws cloudformation list-stacks --region us-east-1 --stack-status-filter CREATE_COMPLETE UPDATE_COMPLETE --query 'StackSummaries[?contains(StackName, `eksctl-healthcare-cluster`)].StackName' --output text)
if [ -z "$STACKS" ]; then
    echo "✅ No eksctl CloudFormation stacks found"
else
    echo "⚠️ Found CloudFormation stacks: $STACKS"
fi

echo ""
echo "5. VPC Resources:"
VPCS=$(aws ec2 describe-vpcs --region us-east-1 --filters "Name=tag:alpha.eksctl.io/cluster-name,Values=healthcare-cluster" --query 'Vpcs[*].VpcId' --output text)
if [ -z "$VPCS" ]; then
    echo "✅ No healthcare-related VPCs found"
else
    echo "⚠️ Found VPCs: $VPCS"
fi

echo ""
echo "6. Security Groups:"
SGS=$(aws ec2 describe-security-groups --region us-east-1 --filters "Name=tag:alpha.eksctl.io/cluster-name,Values=healthcare-cluster" --query 'SecurityGroups[*].GroupId' --output text)
if [ -z "$SGS" ]; then
    echo "✅ No healthcare-related Security Groups found"
else
    echo "⚠️ Found Security Groups: $SGS"
fi

echo ""
echo "7. IAM Roles:"
ROLES=$(aws iam list-roles --query 'Roles[?contains(RoleName, `eksctl-healthcare-cluster`)].RoleName' --output text)
if [ -z "$ROLES" ]; then
    echo "✅ No healthcare-related IAM Roles found"
else
    echo "⚠️ Found IAM Roles: $ROLES"
fi

echo ""
echo "================================"
echo "🎉 Verification Complete!"
echo ""
echo "If all items show ✅, your cleanup is successful!"
echo "If any items show ⚠️, please investigate and manually delete those resources."
```

---

## 🆘 Troubleshooting Failed Deletions

### **If EKS Cluster Deletion Fails**
```bash
# Force delete node groups first
eksctl delete nodegroup --cluster healthcare-cluster --name healthcare-nodes --region us-east-1 --wait

# Then delete cluster
eksctl delete cluster --name healthcare-cluster --region us-east-1 --wait

# If still fails, check CloudFormation console for detailed errors
```

### **If CloudFormation Stack Deletion Fails**
```bash
# Check stack events for errors
aws cloudformation describe-stack-events --stack-name eksctl-healthcare-cluster-cluster --region us-east-1 --query 'StackEvents[?ResourceStatus==`DELETE_FAILED`].[LogicalResourceId,ResourceStatusReason]' --output table

# Manual deletion may be required for specific resources
```

### **If Load Balancers Won't Delete**
```bash
# List target groups
aws elbv2 describe-target-groups --region us-east-1 --query 'TargetGroups[?contains(TargetGroupName, `healthcare`)].TargetGroupArn' --output text

# Delete target groups manually if needed
aws elbv2 delete-target-group --target-group-arn <TARGET_GROUP_ARN>

# Then delete load balancer
aws elbv2 delete-load-balancer --load-balancer-arn <LOAD_BALANCER_ARN>
```

---

## 💰 Cost Monitoring After Deletion

### **Verify No Ongoing Charges**
```bash
# Check AWS Cost Explorer (requires permissions)
aws ce get-cost-and-usage \
  --time-period Start=2024-07-29,End=2024-07-30 \
  --granularity DAILY \
  --metrics BlendedCost \
  --group-by Type=DIMENSION,Key=SERVICE \
  --filter file://cost-filter.json

# Monitor your AWS billing dashboard for 24-48 hours
echo "📊 Monitor your AWS billing dashboard for the next 24-48 hours"
echo "🔗 https://console.aws.amazon.com/billing/home#/bills"
```

### **Set Up Billing Alerts (Recommended)**
```bash
# Create a billing alarm to catch any unexpected charges
aws cloudwatch put-metric-alarm \
  --alarm-name "Healthcare-Unexpected-Charges" \
  --alarm-description "Alert if healthcare project incurs unexpected charges" \
  --metric-name EstimatedCharges \
  --namespace AWS/Billing \
  --statistic Maximum \
  --period 86400 \
  --threshold 10.0 \
  --comparison-operator GreaterThanThreshold \
  --dimensions Name=Currency,Value=USD \
  --evaluation-periods 1 \
  --alarm-actions arn:aws:sns:us-east-1:YOUR-ACCOUNT-ID:billing-alerts
```

---

## 🎯 Success Confirmation

### **✅ Deletion Success Indicators**
- [ ] No EKS clusters listed in `eksctl get cluster`
- [ ] No running EC2 instances with healthcare tags
- [ ] No Load Balancers with healthcare names
- [ ] No CloudFormation stacks with eksctl-healthcare prefix
- [ ] No VPCs with healthcare cluster tags
- [ ] No Security Groups with healthcare cluster tags
- [ ] No IAM Roles with eksctl-healthcare prefix
- [ ] AWS billing shows no ongoing EKS/EC2 charges

### **🎉 Cleanup Complete!**

If all checklist items are verified, your Stage 1 resources have been successfully deleted and you should not incur any further costs from this deployment.

**Your AWS account is now clean and cost-optimized!** 💰✨

---

## 📞 Support

If you encounter issues during deletion:
1. Check the troubleshooting section above
2. Review AWS CloudFormation console for detailed error messages
3. Contact AWS Support if resources are stuck in deletion
4. Monitor billing dashboard for 48 hours to ensure no charges

**Remember**: It's better to double-check than to incur unexpected costs!
