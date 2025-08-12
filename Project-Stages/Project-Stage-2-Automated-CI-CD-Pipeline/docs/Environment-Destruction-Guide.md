# Environment Destruction Guide

## Overview
This guide provides step-by-step instructions for completely destroying the Healthcare Management System infrastructure, including Kubernetes pods, EKS cluster, and all AWS resources.

## ⚠️ **IMPORTANT WARNING**
**This process is IRREVERSIBLE and will permanently delete:**
- All Kubernetes pods and services
- EKS cluster and node groups
- Load balancers and networking resources
- Database data (if using persistent volumes)
- All AWS infrastructure created for this project

**Make sure you have:**
- ✅ Backed up any important data
- ✅ Confirmed you want to destroy everything
- ✅ Proper AWS credentials configured
- ✅ kubectl access to the cluster

---

## Table of Contents
1. [Quick Destruction (Automated)](#quick-destruction-automated)
2. [Step-by-Step Manual Destruction](#step-by-step-manual-destruction)
3. [Verification Steps](#verification-steps)
4. [Troubleshooting](#troubleshooting)
5. [Cost Cleanup Verification](#cost-cleanup-verification)

---

## Quick Destruction (Automated)

### Option 1: Using Terraform Destroy (Recommended)

If you used Terraform to create the infrastructure:

```bash
# Navigate to terraform directory
cd Project-Stages/Project-Stage-2-Automated-CI-CD-Pipeline/terraform

# Destroy all infrastructure
terraform destroy -auto-approve

# Clean up terraform state
rm -rf .terraform
rm terraform.tfstate*
```

### Option 2: Using AWS CLI and kubectl

```bash
# Set your cluster name
export CLUSTER_NAME="healthcare-eks-cluster"
export REGION="us-east-1"

# Delete all Kubernetes resources
kubectl delete all --all -n healthcare
kubectl delete namespace healthcare

# Delete EKS cluster
aws eks delete-cluster --name $CLUSTER_NAME --region $REGION

# Wait for cluster deletion (this may take 10-15 minutes)
aws eks wait cluster-deleted --name $CLUSTER_NAME --region $REGION
```

---

## Step-by-Step Manual Destruction

### Step 1: Delete Kubernetes Applications

**1.1 Delete Healthcare Application Pods and Services**
```bash
# Check current resources
kubectl get all -n healthcare

# Delete all resources in healthcare namespace
kubectl delete all --all -n healthcare

# Expected output:
# pod "healthcare-backend-xxx" deleted
# pod "healthcare-frontend-xxx" deleted
# pod "postgres-db-xxx" deleted
# service "backend-service" deleted
# service "frontend-service" deleted
# service "postgres-service" deleted
# deployment.apps "healthcare-backend" deleted
# deployment.apps "healthcare-frontend" deleted
# deployment.apps "postgres-db" deleted
```

**1.2 Delete Persistent Volumes and Claims**
```bash
# Check for persistent volumes
kubectl get pv,pvc -n healthcare

# Delete persistent volume claims
kubectl delete pvc --all -n healthcare

# Delete persistent volumes (if any)
kubectl delete pv --all
```

**1.3 Delete ConfigMaps and Secrets**
```bash
# Delete configmaps
kubectl delete configmap --all -n healthcare

# Delete secrets
kubectl delete secret --all -n healthcare
```

**1.4 Delete Namespace**
```bash
# Delete the healthcare namespace
kubectl delete namespace healthcare

# Verify namespace deletion
kubectl get namespaces | grep healthcare
# Should return no results
```

### Step 2: Delete Load Balancers and Services

**2.1 Check for Load Balancers**
```bash
# List all services with external IPs
kubectl get services --all-namespaces -o wide

# Delete any remaining services with LoadBalancer type
kubectl delete service <service-name> -n <namespace>
```

**2.2 Verify AWS Load Balancers are Deleted**
```bash
# Check for remaining load balancers
aws elbv2 describe-load-balancers --region us-east-1

# Check for classic load balancers
aws elb describe-load-balancers --region us-east-1
```

### Step 3: Delete EKS Node Groups

**3.1 List Node Groups**
```bash
# List all node groups
aws eks describe-nodegroup --cluster-name healthcare-eks-cluster --nodegroup-name healthcare-nodes --region us-east-1

# Delete node group
aws eks delete-nodegroup \
  --cluster-name healthcare-eks-cluster \
  --nodegroup-name healthcare-nodes \
  --region us-east-1
```

**3.2 Wait for Node Group Deletion**
```bash
# Monitor deletion progress
aws eks describe-nodegroup \
  --cluster-name healthcare-eks-cluster \
  --nodegroup-name healthcare-nodes \
  --region us-east-1

# Wait until you get "ResourceNotFoundException"
```

### Step 4: Delete EKS Cluster

**4.1 Delete the Cluster**
```bash
# Delete EKS cluster
aws eks delete-cluster --name healthcare-eks-cluster --region us-east-1

# Expected output:
# {
#     "cluster": {
#         "name": "healthcare-eks-cluster",
#         "status": "DELETING"
#     }
# }
```

**4.2 Monitor Cluster Deletion**
```bash
# Check deletion status
aws eks describe-cluster --name healthcare-eks-cluster --region us-east-1

# Wait for deletion (10-15 minutes)
aws eks wait cluster-deleted --name healthcare-eks-cluster --region us-east-1
```

### Step 5: Delete VPC and Networking Resources

**5.1 Find VPC ID**
```bash
# Find the VPC created for EKS
aws ec2 describe-vpcs \
  --filters "Name=tag:Name,Values=*healthcare*" \
  --region us-east-1 \
  --query 'Vpcs[*].[VpcId,Tags[?Key==`Name`].Value|[0]]' \
  --output table
```

**5.2 Delete VPC Resources**
```bash
# Set VPC ID (replace with your actual VPC ID)
export VPC_ID="vpc-xxxxxxxxx"

# Delete NAT Gateways
aws ec2 describe-nat-gateways \
  --filter "Name=vpc-id,Values=$VPC_ID" \
  --region us-east-1 \
  --query 'NatGateways[*].NatGatewayId' \
  --output text | xargs -I {} aws ec2 delete-nat-gateway --nat-gateway-id {} --region us-east-1

# Delete Internet Gateway
IGW_ID=$(aws ec2 describe-internet-gateways \
  --filters "Name=attachment.vpc-id,Values=$VPC_ID" \
  --region us-east-1 \
  --query 'InternetGateways[0].InternetGatewayId' \
  --output text)

aws ec2 detach-internet-gateway --internet-gateway-id $IGW_ID --vpc-id $VPC_ID --region us-east-1
aws ec2 delete-internet-gateway --internet-gateway-id $IGW_ID --region us-east-1

# Delete Subnets
aws ec2 describe-subnets \
  --filters "Name=vpc-id,Values=$VPC_ID" \
  --region us-east-1 \
  --query 'Subnets[*].SubnetId' \
  --output text | xargs -I {} aws ec2 delete-subnet --subnet-id {} --region us-east-1

# Delete Route Tables (except main)
aws ec2 describe-route-tables \
  --filters "Name=vpc-id,Values=$VPC_ID" "Name=association.main,Values=false" \
  --region us-east-1 \
  --query 'RouteTables[*].RouteTableId' \
  --output text | xargs -I {} aws ec2 delete-route-table --route-table-id {} --region us-east-1

# Delete Security Groups (except default)
aws ec2 describe-security-groups \
  --filters "Name=vpc-id,Values=$VPC_ID" \
  --region us-east-1 \
  --query 'SecurityGroups[?GroupName!=`default`].GroupId' \
  --output text | xargs -I {} aws ec2 delete-security-group --group-id {} --region us-east-1

# Delete VPC
aws ec2 delete-vpc --vpc-id $VPC_ID --region us-east-1
```

### Step 6: Delete IAM Roles and Policies

**6.1 Delete EKS Service Role**
```bash
# Detach policies from EKS cluster role
aws iam detach-role-policy \
  --role-name healthcare-eks-cluster-role \
  --policy-arn arn:aws:iam::aws:policy/AmazonEKSClusterPolicy

# Delete the role
aws iam delete-role --role-name healthcare-eks-cluster-role
```

**6.2 Delete Node Group Role**
```bash
# Detach policies from node group role
aws iam detach-role-policy \
  --role-name healthcare-eks-nodegroup-role \
  --policy-arn arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy

aws iam detach-role-policy \
  --role-name healthcare-eks-nodegroup-role \
  --policy-arn arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy

aws iam detach-role-policy \
  --role-name healthcare-eks-nodegroup-role \
  --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly

# Delete the role
aws iam delete-role --role-name healthcare-eks-nodegroup-role
```

---

## Verification Steps

### Verify Complete Destruction

**1. Check Kubernetes Resources**
```bash
# Should return "No resources found"
kubectl get all --all-namespaces | grep healthcare
```

**2. Check AWS EKS**
```bash
# Should return empty or error
aws eks list-clusters --region us-east-1
```

**3. Check EC2 Instances**
```bash
# Should show no EKS-related instances
aws ec2 describe-instances \
  --filters "Name=tag:kubernetes.io/cluster/healthcare-eks-cluster,Values=owned" \
  --region us-east-1
```

**4. Check Load Balancers**
```bash
# Should return empty
aws elbv2 describe-load-balancers --region us-east-1 | grep healthcare
```

**5. Check VPC**
```bash
# Should not show healthcare VPC
aws ec2 describe-vpcs --region us-east-1 | grep healthcare
```

---

## Troubleshooting

### Common Issues and Solutions

**Issue 1: "Cannot delete VPC - has dependencies"**
```bash
# Find and delete remaining ENIs
aws ec2 describe-network-interfaces \
  --filters "Name=vpc-id,Values=$VPC_ID" \
  --region us-east-1 \
  --query 'NetworkInterfaces[*].NetworkInterfaceId' \
  --output text | xargs -I {} aws ec2 delete-network-interface --network-interface-id {} --region us-east-1
```

**Issue 2: "LoadBalancer still exists"**
```bash
# Force delete load balancer
aws elbv2 delete-load-balancer --load-balancer-arn <arn> --region us-east-1
```

**Issue 3: "Node group deletion stuck"**
```bash
# Check Auto Scaling Groups
aws autoscaling describe-auto-scaling-groups \
  --region us-east-1 | grep healthcare

# Force delete ASG if needed
aws autoscaling delete-auto-scaling-group \
  --auto-scaling-group-name <asg-name> \
  --force-delete \
  --region us-east-1
```

---

## Cost Cleanup Verification

### Final Cost Check

**1. AWS Cost Explorer**
- Go to AWS Console → Cost Management → Cost Explorer
- Filter by service: EKS, EC2, VPC, ELB
- Verify no ongoing charges

**2. AWS CLI Cost Check**
```bash
# Check for running instances
aws ec2 describe-instances \
  --filters "Name=instance-state-name,Values=running" \
  --region us-east-1 \
  --query 'Reservations[*].Instances[*].[InstanceId,InstanceType,State.Name]' \
  --output table

# Check for load balancers
aws elbv2 describe-load-balancers --region us-east-1 --output table
```

**3. Set up Billing Alerts**
```bash
# Create billing alarm (optional)
aws cloudwatch put-metric-alarm \
  --alarm-name "Healthcare-Project-Cleanup-Verification" \
  --alarm-description "Verify no charges after cleanup" \
  --metric-name EstimatedCharges \
  --namespace AWS/Billing \
  --statistic Maximum \
  --period 86400 \
  --threshold 1.0 \
  --comparison-operator GreaterThanThreshold \
  --region us-east-1
```

---

## Summary Checklist

Before considering the environment fully destroyed, verify:

- [ ] All Kubernetes pods and services deleted
- [ ] Healthcare namespace deleted
- [ ] EKS cluster deleted
- [ ] Node groups deleted
- [ ] Load balancers deleted
- [ ] VPC and networking resources deleted
- [ ] IAM roles and policies deleted
- [ ] No running EC2 instances related to the project
- [ ] No ongoing AWS charges
- [ ] kubectl context cleaned up

**Final Command to Clean kubectl Context:**
```bash
# Remove cluster from kubectl config
kubectl config delete-cluster healthcare-eks-cluster
kubectl config delete-context healthcare-eks-cluster
kubectl config unset users.healthcare-eks-cluster
```

---

*This guide ensures complete cleanup of all resources to avoid unexpected AWS charges.*
