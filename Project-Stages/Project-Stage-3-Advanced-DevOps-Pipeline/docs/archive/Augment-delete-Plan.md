# 🗑️ **Augment Comprehensive AWS Resources Cleanup Plan**

## **📋 Overview**

This document provides a systematic plan to clean up ALL AWS resources created during multiple pipeline runs, including orphaned resources from failed deployments. The goal is to eliminate duplicate resources and reduce AWS costs.

## **🔍 Current Resource Inventory**

### **Identified Duplicate/Orphaned Resources:**
1. **🔗 Load Balancers**: 2 load balancers (1 Classic, 1 Network) - **Should be 1 Application Load Balancer**
2. **🌐 VPCs**: 2 VPCs with same name - **Should be 1 VPC**
3. **🏠 Subnets**: 12 subnets (6 public, 6 private) - **Should be 6 total (3 public, 3 private)**
4. **🚪 NAT Gateways**: 6 NAT Gateways - **Should be 3 NAT Gateways**
5. **🌍 Internet Gateways**: 2 Internet Gateways - **Should be 1 Internet Gateway**
6. **🗄️ RDS Instances**: Potentially multiple database instances
7. **📦 ECR Repositories**: Potentially duplicate repositories
8. **🔐 Security Groups**: Multiple security groups from failed deployments
9. **🏷️ EKS Clusters**: Potentially multiple clusters or stuck resources

## **💰 Cost Impact**

**High-Cost Resources to Clean Up Immediately:**
- **NAT Gateways**: ~$45/month each (6 × $45 = $270/month)
- **Load Balancers**: ~$16-25/month each
- **RDS Instances**: ~$20-100/month each depending on size
- **EKS Clusters**: ~$72/month each for control plane

**Estimated Monthly Savings**: $400-600/month after cleanup

## **🎯 Cleanup Strategy**

### **Phase 1: Immediate High-Cost Resource Cleanup**
### **Phase 2: Systematic Resource Discovery**
### **Phase 3: Terraform-Managed Resource Cleanup**
### **Phase 4: Manual Orphaned Resource Cleanup**
### **Phase 5: Verification and Cost Monitoring**

---

## **📋 Phase 1: Immediate High-Cost Resource Cleanup**

### **🚨 CRITICAL: Stop Charges Immediately**

```bash
# 1. Delete Extra NAT Gateways (Keep only 3)
echo "🚪 Cleaning up extra NAT Gateways..."
aws ec2 describe-nat-gateways --region us-east-1 --query 'NatGateways[?State==`available`].[NatGatewayId,SubnetId,Tags[?Key==`Name`].Value|[0]]' --output table

# Identify and delete extra NAT Gateways (keep only 1 per AZ)
# MANUAL STEP: Review output and delete extras
# aws ec2 delete-nat-gateway --nat-gateway-id nat-xxxxxxxxx --region us-east-1

# 2. Delete Extra Load Balancers
echo "🔗 Cleaning up extra Load Balancers..."
# Classic Load Balancers
aws elb describe-load-balancers --region us-east-1 --query 'LoadBalancerDescriptions[?contains(LoadBalancerName,`healthcare`) || contains(LoadBalancerName,`stage3`)].[LoadBalancerName,CreatedTime]' --output table

# Application/Network Load Balancers
aws elbv2 describe-load-balancers --region us-east-1 --query 'LoadBalancers[?contains(LoadBalancerName,`healthcare`) || contains(LoadBalancerName,`stage3`)].[LoadBalancerName,Type,CreatedTime]' --output table

# 3. Delete Extra RDS Instances
echo "🗄️ Checking RDS instances..."
aws rds describe-db-instances --region us-east-1 --query 'DBInstances[?contains(DBInstanceIdentifier,`healthcare`) || contains(DBInstanceIdentifier,`stage3`)].[DBInstanceIdentifier,DBInstanceStatus,Engine]' --output table
```

---

## **📋 Phase 2: Systematic Resource Discovery**

### **🔍 Comprehensive Resource Audit Script**

```bash
#!/bin/bash
# Resource Discovery Script

REGION="us-east-1"
OUTPUT_FILE="aws-resources-audit-$(date +%Y%m%d-%H%M%S).txt"

echo "🔍 AWS Resources Audit - $(date)" > "$OUTPUT_FILE"
echo "================================================" >> "$OUTPUT_FILE"

# VPCs
echo -e "\n🌐 VPCs:" >> "$OUTPUT_FILE"
aws ec2 describe-vpcs --region "$REGION" --query 'Vpcs[?contains(Tags[?Key==`Name`].Value|[0],`healthcare`) || contains(Tags[?Key==`Name`].Value|[0],`stage3`)].[VpcId,Tags[?Key==`Name`].Value|[0],State]' --output table >> "$OUTPUT_FILE"

# Subnets
echo -e "\n🏠 Subnets:" >> "$OUTPUT_FILE"
aws ec2 describe-subnets --region "$REGION" --query 'Subnets[?contains(Tags[?Key==`Name`].Value|[0],`healthcare`) || contains(Tags[?Key==`Name`].Value|[0],`stage3`)].[SubnetId,VpcId,AvailabilityZone,Tags[?Key==`Name`].Value|[0]]' --output table >> "$OUTPUT_FILE"

# NAT Gateways
echo -e "\n🚪 NAT Gateways:" >> "$OUTPUT_FILE"
aws ec2 describe-nat-gateways --region "$REGION" --query 'NatGateways[?State==`available`].[NatGatewayId,VpcId,SubnetId,State,Tags[?Key==`Name`].Value|[0]]' --output table >> "$OUTPUT_FILE"

# Internet Gateways
echo -e "\n🌍 Internet Gateways:" >> "$OUTPUT_FILE"
aws ec2 describe-internet-gateways --region "$REGION" --query 'InternetGateways[].[InternetGatewayId,Attachments[0].VpcId,Attachments[0].State,Tags[?Key==`Name`].Value|[0]]' --output table >> "$OUTPUT_FILE"

# Load Balancers
echo -e "\n🔗 Classic Load Balancers:" >> "$OUTPUT_FILE"
aws elb describe-load-balancers --region "$REGION" --query 'LoadBalancerDescriptions[?contains(LoadBalancerName,`healthcare`) || contains(LoadBalancerName,`stage3`)].[LoadBalancerName,VPCId,Scheme,CreatedTime]' --output table >> "$OUTPUT_FILE"

echo -e "\n🔗 Application/Network Load Balancers:" >> "$OUTPUT_FILE"
aws elbv2 describe-load-balancers --region "$REGION" --query 'LoadBalancers[?contains(LoadBalancerName,`healthcare`) || contains(LoadBalancerName,`stage3`)].[LoadBalancerName,Type,VpcId,Scheme,CreatedTime]' --output table >> "$OUTPUT_FILE"

# EKS Clusters
echo -e "\n🏷️ EKS Clusters:" >> "$OUTPUT_FILE"
aws eks list-clusters --region "$REGION" --query 'clusters[?contains(@,`healthcare`) || contains(@,`stage3`)]' --output table >> "$OUTPUT_FILE"

# RDS Instances
echo -e "\n🗄️ RDS Instances:" >> "$OUTPUT_FILE"
aws rds describe-db-instances --region "$REGION" --query 'DBInstances[?contains(DBInstanceIdentifier,`healthcare`) || contains(DBInstanceIdentifier,`stage3`)].[DBInstanceIdentifier,DBInstanceStatus,Engine,DBInstanceClass,AllocatedStorage]' --output table >> "$OUTPUT_FILE"

# ECR Repositories
echo -e "\n📦 ECR Repositories:" >> "$OUTPUT_FILE"
aws ecr describe-repositories --region "$REGION" --query 'repositories[?contains(repositoryName,`healthcare`) || contains(repositoryName,`stage3`)].[repositoryName,createdAt,repositoryUri]' --output table >> "$OUTPUT_FILE"

# Security Groups
echo -e "\n🔐 Security Groups:" >> "$OUTPUT_FILE"
aws ec2 describe-security-groups --region "$REGION" --query 'SecurityGroups[?contains(GroupName,`healthcare`) || contains(GroupName,`stage3`) || contains(Description,`healthcare`) || contains(Description,`stage3`)].[GroupId,GroupName,VpcId,Description]' --output table >> "$OUTPUT_FILE"

echo "✅ Audit completed. Results saved to: $OUTPUT_FILE"
cat "$OUTPUT_FILE"
```

---

## **📋 Phase 3: Enhanced Terraform Cleanup**

### **🔧 Enhanced Terraform Destroy Process**

```bash
#!/bin/bash
# Enhanced Terraform Cleanup

TERRAFORM_DIR="terraform/environments/dev"
BACKEND_DIR="terraform/backend-setup"

echo "🔧 Enhanced Terraform Cleanup Process"

# 1. Clean up main infrastructure
if [[ -d "$TERRAFORM_DIR" ]]; then
    echo "🏗️ Destroying main infrastructure..."
    cd "$TERRAFORM_DIR"
    
    # Initialize and destroy
    terraform init
    terraform plan -destroy -out=destroy.tfplan
    terraform apply destroy.tfplan
    
    # Clean up state files
    rm -f terraform.tfstate*
    rm -f destroy.tfplan
    rm -rf .terraform/
    
    cd ../../..
fi

# 2. Clean up backend resources
if [[ -d "$BACKEND_DIR" ]]; then
    echo "🗄️ Destroying backend resources..."
    cd "$BACKEND_DIR"
    
    # Get bucket name before destroying
    BUCKET_NAME=$(terraform output -raw s3_bucket_name 2>/dev/null || echo "")
    
    # Empty S3 bucket first
    if [[ -n "$BUCKET_NAME" ]]; then
        echo "🗑️ Emptying S3 bucket: $BUCKET_NAME"
        aws s3 rm "s3://$BUCKET_NAME" --recursive --region us-east-1 || true
    fi
    
    # Destroy backend
    terraform init
    terraform plan -destroy -out=backend-destroy.tfplan
    terraform apply backend-destroy.tfplan
    
    # Clean up
    rm -f terraform.tfstate*
    rm -f backend-destroy.tfplan
    rm -rf .terraform/
    
    cd ../..
fi

echo "✅ Terraform cleanup completed"
```

---

## **📋 Phase 4: Manual Orphaned Resource Cleanup**

### **🧹 Systematic Manual Cleanup Script**

```bash
#!/bin/bash
# Manual Orphaned Resources Cleanup

REGION="us-east-1"

echo "🧹 Manual Orphaned Resources Cleanup"

# 1. Delete Orphaned Load Balancers
cleanup_load_balancers() {
    echo "🔗 Cleaning up orphaned load balancers..."

    # Classic Load Balancers
    CLASSIC_LBS=$(aws elb describe-load-balancers --region "$REGION" --query 'LoadBalancerDescriptions[?contains(LoadBalancerName,`healthcare`) || contains(LoadBalancerName,`stage3`)].LoadBalancerName' --output text)

    for lb in $CLASSIC_LBS; do
        echo "Deleting Classic LB: $lb"
        aws elb delete-load-balancer --load-balancer-name "$lb" --region "$REGION" || echo "Failed to delete $lb"
    done

    # Application/Network Load Balancers
    ALB_ARNS=$(aws elbv2 describe-load-balancers --region "$REGION" --query 'LoadBalancers[?contains(LoadBalancerName,`healthcare`) || contains(LoadBalancerName,`stage3`)].LoadBalancerArn' --output text)

    for arn in $ALB_ARNS; do
        echo "Deleting ALB/NLB: $arn"
        aws elbv2 delete-load-balancer --load-balancer-arn "$arn" --region "$REGION" || echo "Failed to delete $arn"
    done
}

# 2. Delete Orphaned NAT Gateways
cleanup_nat_gateways() {
    echo "🚪 Cleaning up orphaned NAT Gateways..."

    # Get all NAT Gateways in healthcare VPCs
    NAT_GWS=$(aws ec2 describe-nat-gateways --region "$REGION" --query 'NatGateways[?State==`available`].NatGatewayId' --output text)

    for nat in $NAT_GWS; do
        # Check if it's in a healthcare VPC
        VPC_ID=$(aws ec2 describe-nat-gateways --nat-gateway-ids "$nat" --region "$REGION" --query 'NatGateways[0].VpcId' --output text)
        VPC_NAME=$(aws ec2 describe-vpcs --vpc-ids "$VPC_ID" --region "$REGION" --query 'Vpcs[0].Tags[?Key==`Name`].Value|[0]' --output text 2>/dev/null || echo "")

        if [[ "$VPC_NAME" == *"healthcare"* || "$VPC_NAME" == *"stage3"* ]]; then
            echo "Deleting NAT Gateway: $nat (VPC: $VPC_NAME)"
            aws ec2 delete-nat-gateway --nat-gateway-id "$nat" --region "$REGION" || echo "Failed to delete $nat"
        fi
    done
}

# 3. Delete Orphaned RDS Instances
cleanup_rds_instances() {
    echo "🗄️ Cleaning up orphaned RDS instances..."

    RDS_INSTANCES=$(aws rds describe-db-instances --region "$REGION" --query 'DBInstances[?contains(DBInstanceIdentifier,`healthcare`) || contains(DBInstanceIdentifier,`stage3`)].DBInstanceIdentifier' --output text)

    for db in $RDS_INSTANCES; do
        echo "Deleting RDS instance: $db"
        # Skip final snapshot for cleanup
        aws rds delete-db-instance --db-instance-identifier "$db" --skip-final-snapshot --region "$REGION" || echo "Failed to delete $db"
    done
}

# 4. Delete Orphaned ECR Repositories
cleanup_ecr_repositories() {
    echo "📦 Cleaning up orphaned ECR repositories..."

    ECR_REPOS=$(aws ecr describe-repositories --region "$REGION" --query 'repositories[?contains(repositoryName,`healthcare`) || contains(repositoryName,`stage3`)].repositoryName' --output text)

    for repo in $ECR_REPOS; do
        echo "Deleting ECR repository: $repo"
        aws ecr delete-repository --repository-name "$repo" --force --region "$REGION" || echo "Failed to delete $repo"
    done
}

# 5. Delete Orphaned Security Groups
cleanup_security_groups() {
    echo "🔐 Cleaning up orphaned security groups..."

    # Get all healthcare/stage3 security groups
    SG_IDS=$(aws ec2 describe-security-groups --region "$REGION" --query 'SecurityGroups[?contains(GroupName,`healthcare`) || contains(GroupName,`stage3`) || contains(Description,`healthcare`) || contains(Description,`stage3`)].GroupId' --output text)

    for sg in $SG_IDS; do
        # Skip default security groups
        SG_NAME=$(aws ec2 describe-security-groups --group-ids "$sg" --region "$REGION" --query 'SecurityGroups[0].GroupName' --output text)
        if [[ "$SG_NAME" != "default" ]]; then
            echo "Deleting Security Group: $sg ($SG_NAME)"
            aws ec2 delete-security-group --group-id "$sg" --region "$REGION" || echo "Failed to delete $sg (may have dependencies)"
        fi
    done
}

# 6. Delete Orphaned VPCs and Subnets
cleanup_vpcs() {
    echo "🌐 Cleaning up orphaned VPCs..."

    # Get healthcare VPCs
    VPC_IDS=$(aws ec2 describe-vpcs --region "$REGION" --query 'Vpcs[?contains(Tags[?Key==`Name`].Value|[0],`healthcare`) || contains(Tags[?Key==`Name`].Value|[0],`stage3`)].VpcId' --output text)

    for vpc in $VPC_IDS; do
        VPC_NAME=$(aws ec2 describe-vpcs --vpc-ids "$vpc" --region "$REGION" --query 'Vpcs[0].Tags[?Key==`Name`].Value|[0]' --output text)
        echo "Processing VPC: $vpc ($VPC_NAME)"

        # Delete subnets first
        SUBNET_IDS=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$vpc" --region "$REGION" --query 'Subnets[].SubnetId' --output text)
        for subnet in $SUBNET_IDS; do
            echo "  Deleting subnet: $subnet"
            aws ec2 delete-subnet --subnet-id "$subnet" --region "$REGION" || echo "  Failed to delete subnet $subnet"
        done

        # Detach and delete internet gateway
        IGW_ID=$(aws ec2 describe-internet-gateways --filters "Name=attachment.vpc-id,Values=$vpc" --region "$REGION" --query 'InternetGateways[0].InternetGatewayId' --output text)
        if [[ "$IGW_ID" != "None" && -n "$IGW_ID" ]]; then
            echo "  Detaching and deleting IGW: $IGW_ID"
            aws ec2 detach-internet-gateway --internet-gateway-id "$IGW_ID" --vpc-id "$vpc" --region "$REGION" || true
            aws ec2 delete-internet-gateway --internet-gateway-id "$IGW_ID" --region "$REGION" || echo "  Failed to delete IGW $IGW_ID"
        fi

        # Delete VPC
        echo "  Deleting VPC: $vpc"
        aws ec2 delete-vpc --vpc-id "$vpc" --region "$REGION" || echo "  Failed to delete VPC $vpc"
    done
}

# Execute cleanup functions
echo "🚨 Starting manual cleanup process..."
echo "⚠️  This will delete resources that may not be managed by Terraform"
read -p "Continue? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    cleanup_load_balancers
    sleep 30  # Wait for LB deletion
    cleanup_nat_gateways
    sleep 60  # Wait for NAT GW deletion
    cleanup_rds_instances
    cleanup_ecr_repositories
    cleanup_security_groups
    sleep 30  # Wait for SG deletion
    cleanup_vpcs
    echo "✅ Manual cleanup completed"
else
    echo "Manual cleanup cancelled"
fi
```

---

## **📋 Phase 5: Verification and Cost Monitoring**

### **✅ Post-Cleanup Verification**

```bash
#!/bin/bash
# Post-Cleanup Verification Script

REGION="us-east-1"

echo "✅ Post-Cleanup Verification"
echo "============================"

# Check remaining resources
echo "🔍 Checking for remaining healthcare/stage3 resources..."

# VPCs
VPC_COUNT=$(aws ec2 describe-vpcs --region "$REGION" --query 'Vpcs[?contains(Tags[?Key==`Name`].Value|[0],`healthcare`) || contains(Tags[?Key==`Name`].Value|[0],`stage3`)]' --output text | wc -l)
echo "🌐 Remaining VPCs: $VPC_COUNT"

# Load Balancers
CLB_COUNT=$(aws elb describe-load-balancers --region "$REGION" --query 'LoadBalancerDescriptions[?contains(LoadBalancerName,`healthcare`) || contains(LoadBalancerName,`stage3`)]' --output text | wc -l)
ALB_COUNT=$(aws elbv2 describe-load-balancers --region "$REGION" --query 'LoadBalancers[?contains(LoadBalancerName,`healthcare`) || contains(LoadBalancerName,`stage3`)]' --output text | wc -l)
echo "🔗 Remaining Classic LBs: $CLB_COUNT"
echo "🔗 Remaining ALB/NLBs: $ALB_COUNT"

# NAT Gateways
NAT_COUNT=$(aws ec2 describe-nat-gateways --region "$REGION" --query 'NatGateways[?State==`available`]' --output text | wc -l)
echo "🚪 Remaining NAT Gateways: $NAT_COUNT"

# RDS Instances
RDS_COUNT=$(aws rds describe-db-instances --region "$REGION" --query 'DBInstances[?contains(DBInstanceIdentifier,`healthcare`) || contains(DBInstanceIdentifier,`stage3`)]' --output text | wc -l)
echo "🗄️ Remaining RDS Instances: $RDS_COUNT"

# EKS Clusters
EKS_COUNT=$(aws eks list-clusters --region "$REGION" --query 'clusters[?contains(@,`healthcare`) || contains(@,`stage3`)]' --output text | wc -l)
echo "🏷️ Remaining EKS Clusters: $EKS_COUNT"

# ECR Repositories
ECR_COUNT=$(aws ecr describe-repositories --region "$REGION" --query 'repositories[?contains(repositoryName,`healthcare`) || contains(repositoryName,`stage3`)]' --output text | wc -l)
echo "📦 Remaining ECR Repositories: $ECR_COUNT"

echo ""
echo "💰 Expected monthly cost reduction: $400-600"
echo "📊 Monitor AWS Cost Explorer for actual savings"
echo ""

if [[ $VPC_COUNT -eq 0 && $CLB_COUNT -eq 0 && $ALB_COUNT -eq 0 && $NAT_COUNT -eq 0 && $RDS_COUNT -eq 0 && $EKS_COUNT -eq 0 ]]; then
    echo "🎉 SUCCESS: All healthcare/stage3 resources have been cleaned up!"
else
    echo "⚠️  Some resources remain. Manual review may be needed."
fi
```

---

## **🔧 Load Balancer Configuration Fix**

### **Issue**: Using Classic/Network Load Balancers instead of Application Load Balancer

### **Solution**: Configure AWS Load Balancer Controller for ALB

**Files to modify:**
1. `gitops/environments/dev/frontend.yaml` - Change service to use ALB
2. Add AWS Load Balancer Controller to cluster
3. Use Ingress instead of LoadBalancer service type

**Implementation in next steps...**

---

## **📋 Execution Order**

1. **🚨 IMMEDIATE**: Run Phase 1 to stop high-cost resources
2. **📊 AUDIT**: Run Phase 2 resource discovery
3. **🔧 TERRAFORM**: Run Phase 3 enhanced Terraform cleanup
4. **🧹 MANUAL**: Run Phase 4 manual orphaned cleanup
5. **✅ VERIFY**: Run Phase 5 verification
6. **🔧 FIX**: Implement ALB configuration
7. **📊 MONITOR**: Set up cost alerts for future

**Estimated Time**: 2-4 hours
**Expected Savings**: $400-600/month
