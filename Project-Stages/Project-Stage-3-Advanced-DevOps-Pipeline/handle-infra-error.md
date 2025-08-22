Deploy Infrastructure
Handle Infrastructure conflicts
Run echo "🔍 Handling potential infrastructure conflicts..."
🔍 Handling potential infrastructure conflicts...
[INFO] 2025-08-22 16:21:46 - 🔧 Handling infrastructure conflicts with strategy: import
[INFO] 2025-08-22 16:21:46 - 🏥 Running infrastructure health check...
[INFO] 2025-08-22 16:21:48 - 📊 EIP Usage: 0 / 5

An error occurred (InvalidParameterValue) when calling the DescribeAddresses operation: The filter 'association.association-id' is invalid
[INFO] 2025-08-22 16:21:49 - ℹ️ No available EIPs found - new EIPs will be created if needed
[SUCCESS] 2025-08-22 16:21:49 - ✅ Infrastructure health check completed
[INFO] 2025-08-22 16:21:49 - 📥 Using enhanced import strategy...
[INFO] 2025-08-22 16:21:49 - 📥 Enhanced pre-import with conflict resolution...
[INFO] 2025-08-22 16:21:50 - 🔍 Checking for existing KMS alias...
[INFO] 2025-08-22 16:21:50 - Attempt 1/3: aws kms list-aliases --query "Aliases[?AliasName=='alias/eks/healthcare-eks-stage3-dev']" --output text | grep -q alias/eks/healthcare-eks-stage3-dev
[SUCCESS] 2025-08-22 16:21:51 - Command succeeded on attempt 1
[INFO] 2025-08-22 16:21:51 - 📥 Importing KMS alias with retry logic...
[INFO] 2025-08-22 16:21:51 - Trying import path: module.healthcare_infrastructure.module.eks.aws_kms_alias.this["cluster"]
[INFO] 2025-08-22 16:21:51 - Attempt 1/2: terraform import "module.healthcare_infrastructure.module.eks.aws_kms_alias.this["cluster"]" alias/eks/healthcare-eks-stage3-dev
╷
│ Error: Index value required
│ 
│   on <import-address> line 1:
│    1: module.healthcare_infrastructure.module.eks.aws_kms_alias.this[cluster]
│ 
│ Index brackets must contain either a literal number or a literal string.
╵

For information on valid syntax, see:
https://www.terraform.io/docs/cli/state/resource-addressing.html
Error: Terraform exited with code 1.
[WARNING] 2025-08-22 16:21:51 - Command failed, retrying in 1s...
[INFO] 2025-08-22 16:21:52 - Attempt 2/2: terraform import "module.healthcare_infrastructure.module.eks.aws_kms_alias.this["cluster"]" alias/eks/healthcare-eks-stage3-dev
╷
│ Error: Index value required
│ 
│   on <import-address> line 1:
│    1: module.healthcare_infrastructure.module.eks.aws_kms_alias.this[cluster]
│ 
│ Index brackets must contain either a literal number or a literal string.
╵

For information on valid syntax, see:
https://www.terraform.io/docs/cli/state/resource-addressing.html
Error: Terraform exited with code 1.
[ERROR] 2025-08-22 16:21:52 - Command failed after 2 attempts
[WARNING] 2025-08-22 16:21:52 - Import failed for path: module.healthcare_infrastructure.module.eks.aws_kms_alias.this["cluster"]
[INFO] 2025-08-22 16:21:52 - Trying import path: module.healthcare_infrastructure.module.eks.module.kms.aws_kms_alias.this["cluster"]
[INFO] 2025-08-22 16:21:52 - Attempt 1/2: terraform import "module.healthcare_infrastructure.module.eks.module.kms.aws_kms_alias.this["cluster"]" alias/eks/healthcare-eks-stage3-dev
╷
│ Error: Index value required
│ 
│   on <import-address> line 1:
│    1: module.healthcare_infrastructure.module.eks.module.kms.aws_kms_alias.this[cluster]
│ 
│ Index brackets must contain either a literal number or a literal string.
╵

For information on valid syntax, see:
https://www.terraform.io/docs/cli/state/resource-addressing.html
Error: Terraform exited with code 1.
[WARNING] 2025-08-22 16:21:52 - Command failed, retrying in 1s...
[INFO] 2025-08-22 16:21:53 - Attempt 2/2: terraform import "module.healthcare_infrastructure.module.eks.module.kms.aws_kms_alias.this["cluster"]" alias/eks/healthcare-eks-stage3-dev
╷
│ Error: Index value required
│ 
│   on <import-address> line 1:
│    1: module.healthcare_infrastructure.module.eks.module.kms.aws_kms_alias.this[cluster]
│ 
│ Index brackets must contain either a literal number or a literal string.
╵

For information on valid syntax, see:
https://www.terraform.io/docs/cli/state/resource-addressing.html
Error: Terraform exited with code 1.
[ERROR] 2025-08-22 16:21:53 - Command failed after 2 attempts
[WARNING] 2025-08-22 16:21:53 - Import failed for path: module.healthcare_infrastructure.module.eks.module.kms.aws_kms_alias.this["cluster"]
[INFO] 2025-08-22 16:21:53 - Trying import path: module.healthcare_infrastructure.aws_kms_alias.eks
[INFO] 2025-08-22 16:21:53 - Attempt 1/2: terraform import "module.healthcare_infrastructure.aws_kms_alias.eks" alias/eks/healthcare-eks-stage3-dev
╷
│ Error: Import to non-existent module
│ 
│ module.healthcare_infrastructure is not defined in the configuration.
│ Please add configuration for this module before importing into it.
╵

Error: Terraform exited with code 1.
[WARNING] 2025-08-22 16:21:53 - Command failed, retrying in 1s...
[INFO] 2025-08-22 16:21:54 - Attempt 2/2: terraform import "module.healthcare_infrastructure.aws_kms_alias.eks" alias/eks/healthcare-eks-stage3-dev
╷
│ Error: Import to non-existent module
│ 
│ module.healthcare_infrastructure is not defined in the configuration.
│ Please add configuration for this module before importing into it.
╵

Error: Terraform exited with code 1.
[ERROR] 2025-08-22 16:21:55 - Command failed after 2 attempts
[WARNING] 2025-08-22 16:21:55 - Import failed for path: module.healthcare_infrastructure.aws_kms_alias.eks
[WARNING] 2025-08-22 16:21:55 - ⚠️ KMS alias import failed for all paths - may need manual intervention
[INFO] 2025-08-22 16:21:55 - 🔍 Checking for existing CloudWatch log group...
[INFO] 2025-08-22 16:21:55 - Attempt 1/3: aws logs describe-log-groups --log-group-name-prefix "/aws/eks/healthcare-eks-stage3-dev" --query 'logGroups[0].logGroupName' --output text 2>/dev/null | grep -q '/aws/eks/healthcare-eks-stage3-dev'
[SUCCESS] 2025-08-22 16:21:55 - Command succeeded on attempt 1
[INFO] 2025-08-22 16:21:55 - 📥 Importing CloudWatch log group with retry logic...
[INFO] 2025-08-22 16:21:55 - Trying import path: module.healthcare_infrastructure.module.eks.aws_cloudwatch_log_group.this[0]
[INFO] 2025-08-22 16:21:55 - Attempt 1/2: terraform import "module.healthcare_infrastructure.module.eks.aws_cloudwatch_log_group.this[0]" "/aws/eks/healthcare-eks-stage3-dev/cluster"
╷
│ Error: Import to non-existent module
│ 
│ module.healthcare_infrastructure.module.eks is not defined in the
│ configuration. Please add configuration for this module before importing
│ into it.
╵

Error: Terraform exited with code 1.
[WARNING] 2025-08-22 16:21:55 - Command failed, retrying in 1s...
[INFO] 2025-08-22 16:21:56 - Attempt 2/2: terraform import "module.healthcare_infrastructure.module.eks.aws_cloudwatch_log_group.this[0]" "/aws/eks/healthcare-eks-stage3-dev/cluster"
╷
│ Error: Import to non-existent module
│ 
│ module.healthcare_infrastructure.module.eks is not defined in the
│ configuration. Please add configuration for this module before importing
│ into it.
╵

Error: Terraform exited with code 1.
[ERROR] 2025-08-22 16:21:57 - Command failed after 2 attempts
[WARNING] 2025-08-22 16:21:57 - Import failed for path: module.healthcare_infrastructure.module.eks.aws_cloudwatch_log_group.this[0]
[INFO] 2025-08-22 16:21:57 - Trying import path: module.healthcare_infrastructure.module.eks.aws_cloudwatch_log_group.cluster[0]
[INFO] 2025-08-22 16:21:57 - Attempt 1/2: terraform import "module.healthcare_infrastructure.module.eks.aws_cloudwatch_log_group.cluster[0]" "/aws/eks/healthcare-eks-stage3-dev/cluster"
╷
│ Error: Import to non-existent module
│ 
│ module.healthcare_infrastructure.module.eks is not defined in the
│ configuration. Please add configuration for this module before importing
│ into it.
╵

Error: Terraform exited with code 1.
[WARNING] 2025-08-22 16:21:57 - Command failed, retrying in 1s...
[INFO] 2025-08-22 16:21:58 - Attempt 2/2: terraform import "module.healthcare_infrastructure.module.eks.aws_cloudwatch_log_group.cluster[0]" "/aws/eks/healthcare-eks-stage3-dev/cluster"
╷
│ Error: Import to non-existent module
│ 
│ module.healthcare_infrastructure.module.eks is not defined in the
│ configuration. Please add configuration for this module before importing
│ into it.
╵

Error: Terraform exited with code 1.
[ERROR] 2025-08-22 16:21:58 - Command failed after 2 attempts
[WARNING] 2025-08-22 16:21:58 - Import failed for path: module.healthcare_infrastructure.module.eks.aws_cloudwatch_log_group.cluster[0]
[WARNING] 2025-08-22 16:21:58 - ⚠️ CloudWatch log group import failed for all paths
[INFO] 2025-08-22 16:21:58 - 🔍 Checking for existing RDS subnet group...
[INFO] 2025-08-22 16:21:58 - Attempt 1/3: aws rds describe-db-subnet-groups --db-subnet-group-name "healthcare-eks-stage3-dev-db-subnet-group" >/dev/null 2>&1
[SUCCESS] 2025-08-22 16:21:59 - Command succeeded on attempt 1
[INFO] 2025-08-22 16:21:59 - 📥 Importing RDS subnet group with retry logic...
[INFO] 2025-08-22 16:21:59 - Attempt 1/2: terraform import module.healthcare_infrastructure.aws_db_subnet_group.healthcare "healthcare-eks-stage3-dev-db-subnet-group"
╷
│ Error: Import to non-existent module
│ 
│ module.healthcare_infrastructure is not defined in the configuration.
│ Please add configuration for this module before importing into it.
╵

Error: Terraform exited with code 1.
[WARNING] 2025-08-22 16:21:59 - Command failed, retrying in 1s...
[INFO] 2025-08-22 16:22:00 - Attempt 2/2: terraform import module.healthcare_infrastructure.aws_db_subnet_group.healthcare "healthcare-eks-stage3-dev-db-subnet-group"
╷
│ Error: Import to non-existent module
│ 
│ module.healthcare_infrastructure is not defined in the configuration.
│ Please add configuration for this module before importing into it.
╵

Error: Terraform exited with code 1.
[ERROR] 2025-08-22 16:22:00 - Command failed after 2 attempts
[WARNING] 2025-08-22 16:22:00 - ⚠️ RDS subnet group import failed - may need manual intervention
[INFO] 2025-08-22 16:22:00 - 🔍 Checking for existing S3 assets bucket...
[INFO] 2025-08-22 16:22:00 - Attempt 1/3: aws s3api head-bucket --bucket "healthcare-assets-stage3-dev-867344452513" 2>/dev/null
[WARNING] 2025-08-22 16:22:01 - Command failed, retrying in 2s...
[INFO] 2025-08-22 16:22:03 - Attempt 2/3: aws s3api head-bucket --bucket "healthcare-assets-stage3-dev-867344452513" 2>/dev/null
[WARNING] 2025-08-22 16:22:03 - Command failed, retrying in 4s...
[INFO] 2025-08-22 16:22:07 - Attempt 3/3: aws s3api head-bucket --bucket "healthcare-assets-stage3-dev-867344452513" 2>/dev/null
[ERROR] 2025-08-22 16:22:08 - Command failed after 3 attempts
[INFO] 2025-08-22 16:22:08 - ℹ️ No existing S3 assets bucket found - will be created
[SUCCESS] 2025-08-22 16:22:08 - ✅ Enhanced pre-import completed
[SUCCESS] 2025-08-22 16:22:08 - ✅ Infrastructure conflict handling completed