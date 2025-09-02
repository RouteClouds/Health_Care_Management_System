# 🧹 **Stage-3 Cleanup Scripts Documentation**

## **📋 Available Cleanup Scripts**

### **🔍 audit-aws-resources.sh** - Resource Discovery and Cost Analysis
**Purpose**: Comprehensive audit of all AWS resources related to healthcare/stage3 projects.

**Features:**
- ✅ **Complete Resource Inventory**: VPCs, Subnets, NAT Gateways, Load Balancers, RDS, EKS, ECR
- ✅ **Cost Analysis**: Estimates monthly costs for high-cost resources
- ✅ **Detailed Reporting**: Saves comprehensive audit report with timestamps
- ✅ **Multiple Resource Types**: Covers all AWS services used by the project

**Usage:**
```bash
./scripts/cleanup/audit-aws-resources.sh
# Expected savings identification: $400-600/month
```

### **🧹 cleanup-orphaned-resources.sh** - Orphaned Resources Cleanup
**Purpose**: Removes AWS resources not managed by Terraform that were created during failed pipeline runs.

**Features:**
- ✅ **High-Cost Resource Focus**: Prioritizes NAT Gateways, RDS, Load Balancers
- ✅ **Safe Deletion**: Multiple confirmation steps and error handling
- ✅ **Comprehensive Coverage**: Cleans VPCs, Subnets, Security Groups, ECR repositories
- ✅ **Cost Savings**: Can save $400-600/month in AWS costs

**Usage:**
```bash
./scripts/cleanup/cleanup-orphaned-resources.sh
# Requires confirmation: Type 'CLEANUP' to proceed
```

### **🎯 comprehensive-cleanup-orchestrator.sh** - Smart Cleanup Orchestrator
**Purpose**: Intelligent cleanup orchestrator based on audit findings and Cursor delete plan best practices.

**Features:**
- ✅ **Multiple Modes**: audit, duplicates, complete
- ✅ **Dependency-Aware**: Follows proper deletion order
- ✅ **Cost-Optimized**: Targets highest-cost resources first
- ✅ **Dry Run Support**: Test before actual deletion
- ✅ **Smart Detection**: Identifies active vs duplicate resources

**Usage:**
```bash
# Discover current resources and costs
./scripts/cleanup/comprehensive-cleanup-orchestrator.sh audit

# Remove duplicates (saves ~$135/month)
./scripts/cleanup/comprehensive-cleanup-orchestrator.sh duplicates true   # dry run
./scripts/cleanup/comprehensive-cleanup-orchestrator.sh duplicates false  # live run

# Complete destruction (saves ~$450/month)
./scripts/cleanup/comprehensive-cleanup-orchestrator.sh complete false
```

### **🔧 enhanced-duplicate-cleanup.sh** - Smart Duplicate VPC Cleanup
**Purpose**: Removes duplicate VPCs while preserving the active EKS cluster VPC.

**Features:**
- ✅ **EKS-Aware**: Automatically identifies and preserves active VPC
- ✅ **Dependency Order**: NAT Gateways → Load Balancers → Security Groups → Subnets → VPC
- ✅ **High Savings**: Removes 3 duplicate NAT Gateways (~$135/month savings)
- ✅ **Wait Mechanisms**: Proper waiting for long-running deletions
- ✅ **Dry Run Support**: Test mode available

**Usage:**
```bash
./scripts/cleanup/enhanced-duplicate-cleanup.sh true   # dry run
./scripts/cleanup/enhanced-duplicate-cleanup.sh false  # live deletion
```

### **🗄️ cleanup-s3-buckets.sh** - S3 Buckets Cleanup
**Purpose**: Handles multiple Terraform state buckets and assets bucket cleanup.

**Features:**
- ✅ **State Backup**: Automatically backs up Terraform state before deletion
- ✅ **Smart Detection**: Identifies Terraform state vs assets buckets
- ✅ **Safe Deletion**: Multiple confirmations and error handling
- ✅ **Audit-Based**: Targets specific buckets found in audit

**Usage:**
```bash
./scripts/cleanup/cleanup-s3-buckets.sh true   # dry run
./scripts/cleanup/cleanup-s3-buckets.sh false  # live deletion
```

---

# AWS Infrastructure Cleanup Script Documentation (Legacy)

## Overview

The `cleanup-existing-resources.sh` script provides comprehensive cleanup of AWS infrastructure resources, specifically designed to handle complex dependencies and long-running deletions common in EKS-based deployments.

## Features

### ✅ **Comprehensive Resource Support**
- **EKS Infrastructure**: Complete cluster and node group cleanup
- **RDS Resources**: Database instances and subnet groups
- **Storage**: S3 buckets with content cleanup
- **Monitoring**: CloudWatch log groups
- **Security**: KMS keys and aliases

### ✅ **Smart Dependency Management**
- **Proper Order**: Deletes resources in correct dependency sequence
- **Wait Mechanisms**: Handles long-running deletions (EKS: 10-15 min)
- **Error Recovery**: Comprehensive error handling and reporting
- **Progress Tracking**: Real-time status updates with time tracking

### ✅ **Safety Features**
- **Verification**: Confirms resource existence before deletion
- **Logging**: Detailed colored output for all operations
- **Error Reporting**: Clear error messages and recovery suggestions
- **Dry-Run Support**: Can be extended for preview mode

## Usage

### Basic Usage
```bash
# Run cleanup for healthcare project
./scripts/cleanup/cleanup-existing-resources.sh
```

### Expected Output
```
🧹 Cleanup Existing Resources for Stage-3
==========================================
[INFO] Using AWS Account: 867344452513
[INFO] Using AWS Region: us-east-1

[SUCCESS] ✅ Deleted S3 bucket: healthcare-assets-stage3-dev-867344452513
[SUCCESS] ✅ Deleted RDS database: healthcare-eks-stage3-dev-db
[SUCCESS] ✅ Deleted DB subnet group: healthcare-eks-stage3-dev-db-subnet-group
[SUCCESS] ✅ Deleted EKS node group: healthcare-nodes-20250815134807061900000016
[SUCCESS] ✅ Deleted EKS cluster: healthcare-eks-stage3-dev
[SUCCESS] ✅ Deleted CloudWatch log group: /aws/eks/healthcare-eks-stage3-dev/cluster
[SUCCESS] ✅ Deleted KMS alias: alias/eks/healthcare-eks-stage3-dev

🎉 All conflicting resources cleaned up successfully!
```

## Customization for Other Projects

### Configuration Section
Modify the configuration variables at the top of the script:

```bash
# Configuration (modify for your project)
AWS_REGION="${AWS_REGION:-us-east-1}"
CLUSTER_NAME="your-cluster-name"
KMS_ALIAS="alias/eks/your-cluster-name"
LOG_GROUP="/aws/eks/your-cluster-name/cluster"
DB_SUBNET_GROUP="your-db-subnet-group-name"
S3_BUCKET="your-s3-bucket-name"
```

### Example Configurations

#### **Web Application Project**
```bash
CLUSTER_NAME="webapp-prod-cluster"
KMS_ALIAS="alias/eks/webapp-prod"
LOG_GROUP="/aws/eks/webapp-prod-cluster/cluster"
DB_SUBNET_GROUP="webapp-prod-db-subnet-group"
S3_BUCKET="webapp-assets-prod-123456789"
```

#### **Microservices Project**
```bash
CLUSTER_NAME="microservices-dev"
KMS_ALIAS="alias/eks/microservices-dev"
LOG_GROUP="/aws/eks/microservices-dev/cluster"
DB_SUBNET_GROUP="microservices-dev-db-subnet-group"
S3_BUCKET="microservices-storage-dev-123456789"
```

## Resource Cleanup Order

The script follows this dependency-aware cleanup order:

1. **Application Resources** (S3 buckets)
2. **Database Resources** (RDS instances → DB subnet groups)
3. **Compute Resources** (EKS node groups → EKS cluster)
4. **Monitoring Resources** (CloudWatch log groups)
5. **Security Resources** (KMS aliases → KMS keys)

## Time Expectations

| Resource Type | Typical Deletion Time |
|---------------|----------------------|
| S3 Bucket | 1-2 minutes |
| RDS Database | 2-5 minutes |
| DB Subnet Group | Immediate |
| EKS Node Groups | 5-10 minutes |
| EKS Cluster | 10-15 minutes |
| CloudWatch Logs | Immediate |
| KMS Alias/Key | Immediate |


## Guided removal of duplicate VPC (opt-in)

A duplicate VPC may exist (e.g., `vpc-0bdb999074380c528` with Name `healthcare-eks-stage3-dev-vpc`). Use the guided script to safely remove a stale duplicate VPC.

Prerequisites:
- Ensure no resources depend on the VPC (ALBs, ENIs, DB subnet groups). The script will check and abort if dependencies exist.
- Set AWS credentials and region in your environment.

Commands:
```bash
cd Project-Stages/Project-Stage-3-Advanced-DevOps-Pipeline/scripts/cleanup
chmod +x guided-remove-duplicate-vpc.sh
AWS_REGION=us-east-1 CLUSTER_NAME=healthcare-eks-stage3-dev \
  ./guided-remove-duplicate-vpc.sh vpc-0bdb999074380c528
```

The script is opt-in and requires typing a confirmation phrase before deleting resources.

**Total Time**: 20-35 minutes for complete infrastructure

## Error Handling

### Common Scenarios
- **Resource Not Found**: Script continues with next resource
- **Dependency Conflicts**: Proper order prevents most conflicts
- **Timeout Issues**: Configurable wait times with progress updates
- **Permission Errors**: Clear error messages with suggested fixes

### Recovery Options
- **Partial Failure**: Script reports which resources failed
- **Manual Cleanup**: Provides commands for manual intervention
- **Retry Logic**: Can be run multiple times safely

## Prerequisites

### AWS CLI Configuration
```bash
# Verify AWS CLI is configured
aws sts get-caller-identity

# Set region if needed
export AWS_REGION=us-east-1
```

### Required Permissions
The script requires permissions for:
- EKS cluster and node group management
- RDS instance and subnet group management
- S3 bucket operations
- CloudWatch log group management
- KMS key and alias management

## Integration with CI/CD

### Pre-Deployment Cleanup
```bash
# Add to pipeline before Terraform apply
./scripts/cleanup/cleanup-existing-resources.sh
terraform plan
terraform apply
```

### Post-Failure Cleanup
```bash
# Add to pipeline failure handling
if [ $? -ne 0 ]; then
    echo "Deployment failed, cleaning up resources..."
    ./scripts/cleanup/cleanup-existing-resources.sh
fi
```

## Advantages Over Manual Cleanup

### ✅ **Efficiency**
- Automated dependency resolution
- Parallel deletion where safe
- No manual command sequencing

### ✅ **Reliability**
- Consistent execution every time
- Proper error handling
- Comprehensive verification

### ✅ **Maintainability**
- Single script to maintain
- Easy to adapt for new projects
- Version controlled with infrastructure

### ✅ **Safety**
- Prevents common deletion mistakes
- Handles edge cases gracefully
- Provides clear feedback

## Future Enhancements

### Potential Improvements
- **Dry-run mode**: Preview what would be deleted
- **Selective cleanup**: Choose specific resource types
- **Backup creation**: Create snapshots before deletion
- **Multi-region support**: Handle resources across regions
- **Configuration file**: External config instead of script variables

### Extension Points
- Additional AWS services (Lambda, API Gateway, etc.)
- Custom resource types
- Integration with Terraform state
- Slack/email notifications

## Support and Troubleshooting

### Common Issues
1. **Permission Denied**: Check AWS credentials and IAM permissions
2. **Resource Still Exists**: Wait longer for AWS eventual consistency
3. **Dependency Errors**: Check for resources not handled by script

### Getting Help
- Check the main TROUBLESHOOTING.md for detailed resolution steps
- Review AWS CloudTrail for detailed API call logs
- Use AWS CLI with `--debug` flag for verbose output

---

**Created for**: Healthcare Management System Stage-3
**Adaptable for**: Any EKS-based AWS infrastructure project
**Maintenance**: Update resource names and dependencies as needed
