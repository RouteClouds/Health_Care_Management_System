29s
Run echo "🔍 Handling potential infrastructure conflicts..."
🔍 Handling potential infrastructure conflicts...
[INFO] 2025-08-22 17:53:20 - 🔧 Handling infrastructure conflicts with strategy: import
[INFO] 2025-08-22 17:53:20 - 🏥 Running infrastructure health check...
[INFO] 2025-08-22 17:53:22 - 📊 EIP Usage: 0 / 5
[INFO] 2025-08-22 17:53:24 - ℹ️ No available EIPs found - new EIPs will be created if needed
[SUCCESS] 2025-08-22 17:53:24 - ✅ Infrastructure health check completed
[INFO] 2025-08-22 17:53:24 - 📥 Using enhanced import strategy...
[INFO] 2025-08-22 17:53:24 - 📥 Enhanced pre-import with conflict resolution...
[INFO] 2025-08-22 17:53:24 - 🔍 Checking for existing KMS alias...
[INFO] 2025-08-22 17:53:24 - Attempt 1/3: aws kms list-aliases --query "Aliases[?AliasName=='alias/eks/healthcare-eks-stage3-dev']" --output text | grep -q alias/eks/healthcare-eks-stage3-dev
[SUCCESS] 2025-08-22 17:53:26 - Command succeeded on attempt 1
[INFO] 2025-08-22 17:53:26 - 📥 Importing KMS alias with retry logic...
[INFO] 2025-08-22 17:53:26 - Trying import path: module.healthcare_infrastructure.module.eks.aws_kms_alias.this["cluster"]
[INFO] 2025-08-22 17:53:26 - Attempt 1/2: terraform import module.healthcare_infrastructure.module.eks.aws_kms_alias.this["cluster"] alias/eks/healthcare-eks-stage3-dev
Error: resource address "module.healthcare_infrastructure.module.eks.aws_kms_alias.this[\"cluster\"]" does not exist in the configuration.
Before importing this resource, please create its configuration in module.healthcare_infrastructure.module.eks. For example:
resource "aws_kms_alias" "this" {
  # (resource arguments)
}

Error: Terraform exited with code 1.
[WARNING] 2025-08-22 17:53:26 - Command failed, retrying in 1s...
[INFO] 2025-08-22 17:53:27 - Attempt 2/2: terraform import module.healthcare_infrastructure.module.eks.aws_kms_alias.this["cluster"] alias/eks/healthcare-eks-stage3-dev
Error: resource address "module.healthcare_infrastructure.module.eks.aws_kms_alias.this[\"cluster\"]" does not exist in the configuration.
Before importing this resource, please create its configuration in module.healthcare_infrastructure.module.eks. For example:
resource "aws_kms_alias" "this" {
  # (resource arguments)
}

Error: Terraform exited with code 1.
[ERROR] 2025-08-22 17:53:27 - Command failed after 2 attempts
[WARNING] 2025-08-22 17:53:27 - Import failed for path: module.healthcare_infrastructure.module.eks.aws_kms_alias.this["cluster"]
[INFO] 2025-08-22 17:53:27 - Trying import path: module.healthcare_infrastructure.module.eks.module.kms.aws_kms_alias.this["cluster"]
[INFO] 2025-08-22 17:53:27 - Attempt 1/2: terraform import module.healthcare_infrastructure.module.eks.module.kms.aws_kms_alias.this["cluster"] alias/eks/healthcare-eks-stage3-dev
module.healthcare_infrastructure.data.aws_availability_zones.available: Reading...
module.healthcare_infrastructure.module.eks.module.eks_managed_node_group["healthcare_nodes"].data.aws_caller_identity.current: Reading...
module.healthcare_infrastructure.data.aws_caller_identity.current: Reading...
module.healthcare_infrastructure.module.eks.data.aws_partition.current: Reading...
module.healthcare_infrastructure.module.eks.module.eks_managed_node_group["healthcare_nodes"].data.aws_partition.current: Reading...
module.healthcare_infrastructure.module.eks.module.kms.data.aws_caller_identity.current[0]: Reading...
module.healthcare_infrastructure.module.eks.module.kms.data.aws_partition.current[0]: Reading...
module.healthcare_infrastructure.module.eks.data.aws_caller_identity.current: Reading...
module.healthcare_infrastructure.data.aws_ecr_repository.backend: Reading...
module.healthcare_infrastructure.data.aws_ecr_repository.frontend: Reading...

[INFO] 2025-08-22 17:53:47 - Attempt 3/3: aws s3api head-bucket --bucket "healthcare-assets-stage3-dev-867344452513" 2>/dev/null
[ERROR] 2025-08-22 17:53:48 - Command failed after 3 attempts
[INFO] 2025-08-22 17:53:48 - ℹ️ No existing S3 assets bucket found - will be created
[SUCCESS] 2025-08-22 17:53:48 - ✅ Enhanced pre-import completed
[SUCCESS] 2025-08-22 17:53:48 - ✅ Infrastructure conflict handling completed
 Error: updating RDS DB Subnet Group (healthcare-eks-stage3-dev-db-subnet-group): operation error RDS: ModifyDBSubnetGroup, https response error StatusCode: 400, RequestID: f060e470-413d-44c8-829d-bef1f8265a79, api error InvalidParameterValue: The new Subnets are not in the same Vpc as the existing subnet group
│ 
│   with module.healthcare_infrastructure.aws_db_subnet_group.healthcare,
│   on ../../modules/healthcare-platform/main.tf line 102, in resource "aws_db_subnet_group" "healthcare":
│  102: resource "aws_db_subnet_group" "healthcare" {
│ 
╵
Error: Terraform exited with code 1.
Error: Process completed with exit code 1.