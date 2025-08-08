# 🔧 **Troubleshoot EKS Cluster Stuck in DELETE_IN_PROGRESS**
## **Complete Step-by-Step Resolution Guide**

### **📖 Document Purpose**
This document provides a complete troubleshooting guide for resolving EKS clusters stuck in `DELETE_IN_PROGRESS` or `DELETE_FAILED` status, based on a real-world resolution case.

**Problem**: EKS cluster deletion gets stuck due to dependencies like Network Load Balancers, Internet Gateways, and VPC resources that prevent CloudFormation stack deletion.

**Solution**: Manual identification and deletion of blocking resources followed by forced CloudFormation stack cleanup.

---

## **🚨 Problem Symptoms**
- EKS cluster shows `DELETE_IN_PROGRESS` for extended periods (>30 minutes)
- CloudFormation stack shows `DELETE_FAILED` with resource dependency errors
- AWS console shows cluster deletion "in progress" indefinitely
- New cluster creation fails due to resource conflicts

---

## **🔍 Step 1: Diagnose Current AWS Resources**

### **Command:**
```bash
cd /path/to/your/project/Project-Stages/Project-Stage-1-Basic-CI-CD-Deploy
./scripts/diagnose-aws-resources.sh
```

### **Expected Output:**
```
🔍 AWS Resource Diagnosis for Healthcare Cluster
================================================
📋 AWS Configuration:
{
    "UserId": "AIDA4T4OCBOQUFNR74DB4",
    "Account": "867344452513",
    "Arn": "arn:aws:iam::867344452513:user/admin-user"
}

🏥 EKS Clusters:

🔍 Healthcare Cluster Status:
✅ No EKS cluster found

☁️ CloudFormation Stacks (healthcare related):
--------------------------------------------------------------------------------------------------------------------
|                                                    ListStacks                                                    |
+-----------------------------------+--------------------------------------------------------+---------------------+
|              Created              |                         Name                           |       Status        |
+-----------------------------------+--------------------------------------------------------+---------------------+
|  2025-08-06T10:20:06.554000+00:00 |  eksctl-healthcare-cluster-cluster                     |  DELETE_IN_PROGRESS |
+-----------------------------------+--------------------------------------------------------+---------------------+

🌐 VPCs (eksctl related):
---------------------------------------------------------------------------------------------------
|                                          DescribeVpcs                                           |
+----------------+------------+-----------------------------------------+-------------------------+
|    CidrBlock   |   State    |                  Tags                   |          VpcId          |
+----------------+------------+-----------------------------------------+-------------------------+
|  192.168.0.0/16|  available |  eksctl-healthcare-cluster-cluster/VPC  |  vpc-0989092aa2948ea4b  |
+----------------+------------+-----------------------------------------+-------------------------+
```

**Key Indicators:**
- Stack status: `DELETE_IN_PROGRESS` (stuck)
- VPC still exists with eksctl tags
- No EKS cluster visible but CloudFormation stack remains

---

## **🔥 Step 2: Attempt Force Delete of Failed Stack**

### **Command:**
```bash
./scripts/force-delete-failed-stack.sh
```

### **Expected Output:**
```
🔥 Force Delete Failed CloudFormation Stack
===========================================
🔍 Checking stack status...
📋 Current stack status: DELETE_IN_PROGRESS
⏳ Stack is currently being deleted. Waiting for completion...

Waiter StackDeleteComplete failed: Waiter encountered a terminal failure state
⚠️ Stack deletion timed out or failed

📋 Current stack status:
-------------------------------------------------------------------------------------------
|                                     DescribeStacks                                      |
+------------------------------------------------------------------------+----------------+
|                                 Reason                                 |    Status      |
+------------------------------------------------------------------------+----------------+
|  The following resource(s) failed to delete: [InternetGateway, VPC].   |  DELETE_FAILED |
+------------------------------------------------------------------------+----------------+
```

**Key Finding:** Stack moved from `DELETE_IN_PROGRESS` to `DELETE_FAILED` due to Internet Gateway and VPC dependencies.

---

## **🔧 Step 3: Manual Resource Cleanup**

### **3.1: Identify Stuck Resources**

**Command:**
```bash
aws cloudformation describe-stack-resources --stack-name eksctl-healthcare-cluster-cluster --region us-east-1 --query 'StackResources[?ResourceType==`AWS::EC2::VPC` || ResourceType==`AWS::EC2::InternetGateway`].[ResourceType,PhysicalResourceId]' --output table
```

**Output:**
```
--------------------------------------------------------
|                DescribeStackResources                |
+----------------------------+-------------------------+
|  AWS::EC2::InternetGateway |  igw-0da3bdb250292e8ed  |
|  AWS::EC2::VPC             |  vpc-0989092aa2948ea4b  |
+----------------------------+-------------------------+
```

### **3.2: Check for Network Load Balancers**

**Command:**
```bash
aws elbv2 describe-load-balancers --region us-east-1 --query 'LoadBalancers[?VpcId==`vpc-0989092aa2948ea4b`].[LoadBalancerArn,LoadBalancerName,State.Code]' --output table
```

**Output:**
```
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
|                                                                          DescribeLoadBalancers                                                                         |
+-------------------------------------------------------------------------------------------------------------------------+-----------------------------------+----------+
|  arn:aws:elasticloadbalancing:us-east-1:867344452513:loadbalancer/net/a851dc9a70919474798abee44eb203f9/eea0fd42d3c38091 |  a851dc9a70919474798abee44eb203f9 |  active  |
+-------------------------------------------------------------------------------------------------------------------------+-----------------------------------+----------+
```

**Critical Finding:** Active Network Load Balancer is preventing Internet Gateway detachment.

### **3.3: Delete Network Load Balancer**

**Command:**
```bash
aws elbv2 delete-load-balancer --load-balancer-arn "arn:aws:elasticloadbalancing:us-east-1:867344452513:loadbalancer/net/a851dc9a70919474798abee44eb203f9/eea0fd42d3c38091" --region us-east-1
```

**Output:**
```
(No output - successful deletion)
```

### **3.4: Detach Internet Gateway**

**Command:**
```bash
# Wait 30 seconds for NLB cleanup, then detach IGW
sleep 30 && aws ec2 detach-internet-gateway --internet-gateway-id igw-0da3bdb250292e8ed --vpc-id vpc-0989092aa2948ea4b --region us-east-1
```

**Output:**
```
(No output - successful detachment)
```

### **3.5: Delete Internet Gateway**

**Command:**
```bash
aws ec2 delete-internet-gateway --internet-gateway-id igw-0da3bdb250292e8ed --region us-east-1
```

**Output:**
```
(No output - successful deletion)
```

### **3.6: Check for Remaining Subnets**

**Command:**
```bash
aws ec2 describe-subnets --region us-east-1 --filters "Name=vpc-id,Values=vpc-0989092aa2948ea4b" --query 'Subnets[*].[SubnetId,State]' --output table
```

**Output:**
```
-------------------------------------------
|             DescribeSubnets             |
+---------------------------+-------------+
|  subnet-07edb69b721efe5a6 |  available  |
|  subnet-0aa046b2b6d77b50f |  available  |
+---------------------------+-------------+
```

### **3.7: Attempt to Delete Subnets**

**Command:**
```bash
aws ec2 delete-subnet --subnet-id subnet-07edb69b721efe5a6 --region us-east-1
aws ec2 delete-subnet --subnet-id subnet-0aa046b2b6d77b50f --region us-east-1
```

**Output:**
```
An error occurred (InvalidSubnetID.NotFound) when calling the DeleteSubnet operation: The subnet ID 'subnet-07edb69b721efe5a6' does not exist
An error occurred (InvalidSubnetID.NotFound) when calling the DeleteSubnet operation: The subnet ID 'subnet-0aa046b2b6d77b50f' does not exist
```

**Note:** Subnets were already deleted automatically.

### **3.8: Delete VPC**

**Command:**
```bash
aws ec2 delete-vpc --vpc-id vpc-0989092aa2948ea4b --region us-east-1
```

**Output:**
```
An error occurred (InvalidVpcID.NotFound) when calling the DeleteVpc operation: The vpc ID 'vpc-0989092aa2948ea4b' does not exist
```

**Note:** VPC was already deleted automatically after IGW removal.

---

## **🧹 Step 4: Force Delete CloudFormation Stack**

### **Command:**
```bash
aws cloudformation delete-stack --stack-name eksctl-healthcare-cluster-cluster --region us-east-1
```

**Output:**
```
(No output - successful deletion initiation)
```

---

## **✅ Step 5: Final Verification**

### **5.1: Verify Complete Cleanup**

**Command:**
```bash
./scripts/verify-complete-cleanup.sh
```

**Output:**
```
✅ Complete Cleanup Verification for Healthcare Cluster
======================================================
🧹 Verifying complete cleanup of healthcare cluster resources...

🔍 Checking EKS Cluster...
✅ EKS Cluster: Clean (no response)

🔍 Checking CloudFormation Stacks...
✅ CloudFormation Stacks: Clean (no resources found)

🔍 Checking EC2 Instances...
✅ EC2 Instances: Clean (no resources found)

🔍 Checking Load Balancers...
✅ Load Balancers: Clean (no resources found)

🔍 Checking Security Groups...
✅ Security Groups: Clean (no resources found)

🔍 Checking VPCs...
✅ VPCs: Clean (no resources found)

⚠️ kubectl context still exists for healthcare cluster
   Run: kubectl config delete-context <context-name>
```

### **5.2: Clean kubectl Contexts**

**Command:**
```bash
kubectl config get-contexts | grep healthcare
```

**Output:**
```
          admin-user@healthcare-cluster.us-east-1.eksctl.io               healthcare-cluster.us-east-1.eksctl.io                          admin-user@healthcare-cluster.us-east-1.eksctl.io               
*         arn:aws:eks:us-east-1:867344452513:cluster/healthcare-cluster   arn:aws:eks:us-east-1:867344452513:cluster/healthcare-cluster   arn:aws:eks:us-east-1:867344452513:cluster/healthcare-cluster   
```

**Command:**
```bash
kubectl config delete-context admin-user@healthcare-cluster.us-east-1.eksctl.io
kubectl config delete-context arn:aws:eks:us-east-1:867344452513:cluster/healthcare-cluster
```

**Output:**
```
deleted context admin-user@healthcare-cluster.us-east-1.eksctl.io from /home/ubuntu/.kube/config
warning: this removed your active context, use "kubectl config use-context" to select a different one
deleted context arn:aws:eks:us-east-1:867344452513:cluster/healthcare-cluster from /home/ubuntu/.kube/config
```

### **5.3: Final Verification**

**Command:**
```bash
aws eks list-clusters --region us-east-1
```

**Output:**
```json
{
    "clusters": []
}
```

**Command:**
```bash
aws cloudformation list-stacks --region us-east-1 --stack-status-filter DELETE_FAILED DELETE_IN_PROGRESS | grep healthcare
```

**Output:**
```
(No output - no stuck stacks)
```

---

## **🎯 Common Root Causes & Solutions**

### **Root Cause 1: Network Load Balancer Dependencies**
**Problem**: Active NLBs prevent Internet Gateway detachment
**Solution**: Delete NLB first, wait 30 seconds, then proceed with IGW deletion

### **Root Cause 2: Elastic IP Associations**
**Problem**: EIPs associated with resources prevent deletion
**Solution**:
```bash
# Check for associated EIPs
aws ec2 describe-addresses --region us-east-1 --query 'Addresses[?AssociationId!=null].[PublicIp,AllocationId,AssociationId]' --output table

# Disassociate and release if found
aws ec2 disassociate-address --association-id <association-id> --region us-east-1
aws ec2 release-address --allocation-id <allocation-id> --region us-east-1
```

### **Root Cause 3: Network Interface Dependencies**
**Problem**: ENIs attached to resources prevent deletion
**Solution**:
```bash
# Check for network interfaces in VPC
aws ec2 describe-network-interfaces --region us-east-1 --filters "Name=vpc-id,Values=<vpc-id>" --query 'NetworkInterfaces[*].[NetworkInterfaceId,Status,Description]' --output table

# Delete network interfaces if safe
aws ec2 delete-network-interface --network-interface-id <eni-id> --region us-east-1
```

### **Root Cause 4: Security Group Dependencies**
**Problem**: Security groups with dependencies prevent VPC deletion
**Solution**:
```bash
# List non-default security groups
aws ec2 describe-security-groups --region us-east-1 --filters "Name=vpc-id,Values=<vpc-id>" --query 'SecurityGroups[?GroupName!=`default`].[GroupId,GroupName]' --output table

# Delete security groups (except default)
aws ec2 delete-security-group --group-id <sg-id> --region us-east-1
```

---

## **🚨 Emergency Procedures**

### **When Standard Scripts Fail**

#### **Option 1: Use Enhanced Cleanup Scripts**
```bash
# Run comprehensive diagnosis
./scripts/diagnose-aws-resources.sh

# Try manual cleanup of stuck resources
./scripts/manual-cleanup-stuck-resources.sh

# Force delete failed CloudFormation stacks
./scripts/force-delete-failed-stack.sh

# Clean up CloudFormation stacks
./scripts/cleanup-cloudformation.sh

# Final verification
./scripts/verify-complete-cleanup.sh
```

#### **Option 2: AWS Console Manual Deletion**
1. **AWS CloudFormation Console**:
   - Navigate to CloudFormation → Stacks
   - Find stuck stack → Actions → Delete Stack
   - If deletion fails, note the failing resources

2. **AWS EC2 Console**:
   - Delete Load Balancers (EC2 → Load Balancers)
   - Detach and delete Internet Gateways (VPC → Internet Gateways)
   - Delete NAT Gateways (VPC → NAT Gateways)
   - Delete VPC (VPC → Your VPCs)

3. **AWS EKS Console**:
   - Navigate to EKS → Clusters
   - Delete cluster if still visible

#### **Option 3: AWS CLI Force Deletion**
```bash
# Get all resources in the stack
aws cloudformation describe-stack-resources --stack-name <stack-name> --region us-east-1

# Delete resources manually in reverse dependency order:
# 1. Load Balancers
# 2. NAT Gateways
# 3. Internet Gateways
# 4. Route Tables (non-main)
# 5. Subnets
# 6. Security Groups (non-default)
# 7. VPC
# 8. CloudFormation Stack
```

---

## **⚠️ Prevention Best Practices**

### **1. Proper Cleanup Procedures**
- Always use `eksctl delete cluster` instead of manual deletion
- Wait for complete deletion before creating new clusters
- Monitor CloudFormation stack status during deletion

### **2. Resource Tagging**
- Ensure all resources have proper eksctl tags
- Use consistent naming conventions
- Tag resources for easy identification

### **3. Regular Monitoring**
```bash
# Set up regular cleanup verification
crontab -e
# Add: 0 2 * * * /path/to/verify-complete-cleanup.sh
```

### **4. Cost Monitoring**
```bash
# Check for unexpected charges
aws ce get-cost-and-usage --time-period Start=2025-08-06,End=2025-08-07 --granularity DAILY --metrics BlendedCost
```

---

## **📋 Quick Reference Commands**

### **Diagnosis Commands**
```bash
# Check EKS clusters
aws eks list-clusters --region us-east-1

# Check CloudFormation stacks
aws cloudformation list-stacks --region us-east-1 --stack-status-filter DELETE_FAILED DELETE_IN_PROGRESS

# Check VPCs with eksctl tags
aws ec2 describe-vpcs --region us-east-1 --filters "Name=tag:eksctl.cluster.k8s.io/v1alpha1/cluster-name,Values=*"

# Check Load Balancers
aws elbv2 describe-load-balancers --region us-east-1
```

### **Cleanup Commands**
```bash
# Delete Load Balancer
aws elbv2 delete-load-balancer --load-balancer-arn <arn> --region us-east-1

# Detach Internet Gateway
aws ec2 detach-internet-gateway --internet-gateway-id <igw-id> --vpc-id <vpc-id> --region us-east-1

# Delete Internet Gateway
aws ec2 delete-internet-gateway --internet-gateway-id <igw-id> --region us-east-1

# Delete VPC
aws ec2 delete-vpc --vpc-id <vpc-id> --region us-east-1

# Delete CloudFormation Stack
aws cloudformation delete-stack --stack-name <stack-name> --region us-east-1
```

### **Verification Commands**
```bash
# Verify no EKS clusters
aws eks list-clusters --region us-east-1

# Verify no stuck stacks
aws cloudformation list-stacks --region us-east-1 --stack-status-filter DELETE_FAILED DELETE_IN_PROGRESS

# Clean kubectl contexts
kubectl config get-contexts | grep <cluster-name>
kubectl config delete-context <context-name>
```

---

## **📞 When to Contact AWS Support**

Contact AWS Support if:
- Resources remain stuck after manual deletion attempts
- CloudFormation stacks show `DELETE_FAILED` with no clear error message
- AWS console shows conflicting resource states
- Billing continues despite apparent resource deletion
- Resources are in an inconsistent state across services

**Support Case Information to Provide:**
- AWS Account ID
- Region
- Cluster name and CloudFormation stack names
- Timeline of deletion attempts
- Error messages from AWS CLI/Console
- Output from diagnosis scripts

---

## **✅ Success Indicators**

### **Complete Cleanup Achieved When:**
- ✅ `aws eks list-clusters` returns empty array
- ✅ No CloudFormation stacks with `DELETE_FAILED` or `DELETE_IN_PROGRESS`
- ✅ No VPCs with eksctl tags
- ✅ No Load Balancers in the VPC
- ✅ kubectl contexts cleaned up
- ✅ No ongoing AWS charges for deleted resources

### **Safe to Proceed When:**
- All verification commands return clean results
- AWS billing shows no charges for deleted resources
- New cluster creation succeeds without conflicts

---

## **📋 Document Information**

**Created**: August 6, 2025
**Based on**: Real troubleshooting case - healthcare-cluster deletion
**AWS Region**: us-east-1
**Cluster Type**: eksctl-managed EKS cluster
**Resolution Time**: ~45 minutes

**🎉 This guide successfully resolved a stuck EKS cluster deletion and can be used as a template for similar issues.**
