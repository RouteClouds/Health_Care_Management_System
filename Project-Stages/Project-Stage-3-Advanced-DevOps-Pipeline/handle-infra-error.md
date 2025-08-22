Run echo "🛡️ Running safety guard to prevent mass resource creation..."
🛡️ Running safety guard to prevent mass resource creation...
📊 Terraform Plan Analysis:
   Resources to CREATE: 71
   Resources to UPDATE: 0
   Resources to DELETE: 0
🎯 Safety threshold: 5 creates
🔧 Force apply override: true
✅ Safety guard passed - proceeding with deployment
📋 Resources that will be created:
module.healthcare_infrastructure.aws_db_instance.healthcare
module.healthcare_infrastructure.aws_db_subnet_group.healthcare
module.healthcare_infrastructure.aws_ecr_lifecycle_policy.backend
module.healthcare_infrastructure.aws_ecr_lifecycle_policy.frontend
module.healthcare_infrastructure.aws_s3_bucket.healthcare_assets[0]
module.healthcare_infrastructure.aws_s3_bucket_server_side_encryption_configuration.healthcare_assets
module.healthcare_infrastructure.aws_s3_bucket_versioning.healthcare_assets
module.healthcare_infrastructure.aws_security_group.rds
module.healthcare_infrastructure.module.eks.aws_cloudwatch_log_group.this[0]
module.healthcare_infrastructure.module.eks.aws_ec2_tag.cluster_primary_security_group["CostCenter"]
module.healthcare_infrastructure.module.eks.aws_ec2_tag.cluster_primary_security_group["CreatedBy"]
module.healthcare_infrastructure.module.eks.aws_ec2_tag.cluster_primary_security_group["DeploymentDate"]
module.healthcare_infrastructure.module.eks.aws_ec2_tag.cluster_primary_security_group["Environment"]
module.healthcare_infrastructure.module.eks.aws_ec2_tag.cluster_primary_security_group["ManagedBy"]
module.healthcare_infrastructure.module.eks.aws_ec2_tag.cluster_primary_security_group["Owner"]
module.healthcare_infrastructure.module.eks.aws_ec2_tag.cluster_primary_security_group["Project"]
module.healthcare_infrastructure.module.eks.aws_ec2_tag.cluster_primary_security_group["ResourceGroup"]
module.healthcare_infrastructure.module.eks.aws_ec2_tag.cluster_primary_security_group["Stage"]
module.healthcare_infrastructure.module.eks.aws_ec2_tag.cluster_primary_security_group["TerraformPath"]
module.healthcare_infrastructure.module.eks.aws_eks_cluster.this[0]
module.healthcare_infrastructure.module.eks.aws_iam_openid_connect_provider.oidc_provider[0]
module.healthcare_infrastructure.module.eks.aws_iam_policy.cluster_encryption[0]
module.healthcare_infrastructure.module.eks.aws_iam_role.this[0]
module.healthcare_infrastructure.module.eks.aws_iam_role_policy_attachment.cluster_encryption[0]
module.healthcare_infrastructure.module.eks.aws_iam_role_policy_attachment.this["AmazonEKSClusterPolicy"]
module.healthcare_infrastructure.module.eks.aws_iam_role_policy_attachment.this["AmazonEKSVPCResourceController"]
module.healthcare_infrastructure.module.eks.aws_security_group.cluster[0]
module.healthcare_infrastructure.module.eks.aws_security_group.node[0]
module.healthcare_infrastructure.module.eks.aws_security_group_rule.cluster["ingress_nodes_443"]
module.healthcare_infrastructure.module.eks.aws_security_group_rule.node["egress_all"]
module.healthcare_infrastructure.module.eks.aws_security_group_rule.node["ingress_cluster_443"]
module.healthcare_infrastructure.module.eks.aws_security_group_rule.node["ingress_cluster_4443_webhook"]
module.healthcare_infrastructure.module.eks.aws_security_group_rule.node["ingress_cluster_6443_webhook"]
module.healthcare_infrastructure.module.eks.aws_security_group_rule.node["ingress_cluster_8443_webhook"]
module.healthcare_infrastructure.module.eks.aws_security_group_rule.node["ingress_cluster_9443_webhook"]
module.healthcare_infrastructure.module.eks.aws_security_group_rule.node["ingress_cluster_kubelet"]
module.healthcare_infrastructure.module.eks.aws_security_group_rule.node["ingress_nodes_ephemeral"]
module.healthcare_infrastructure.module.eks.aws_security_group_rule.node["ingress_self_coredns_tcp"]
module.healthcare_infrastructure.module.eks.aws_security_group_rule.node["ingress_self_coredns_udp"]
module.healthcare_infrastructure.module.eks.time_sleep.this[0]
module.healthcare_infrastructure.module.vpc.aws_default_network_acl.this[0]
module.healthcare_infrastructure.module.vpc.aws_default_route_table.default[0]
module.healthcare_infrastructure.module.vpc.aws_default_security_group.this[0]
module.healthcare_infrastructure.module.vpc.aws_eip.nat[0]
module.healthcare_infrastructure.module.vpc.aws_internet_gateway.this[0]
module.healthcare_infrastructure.module.vpc.aws_nat_gateway.this[0]
module.healthcare_infrastructure.module.vpc.aws_route.private_nat_gateway[0]
module.healthcare_infrastructure.module.vpc.aws_route.public_internet_gateway[0]
module.healthcare_infrastructure.module.vpc.aws_route_table.private[0]
module.healthcare_infrastructure.module.vpc.aws_route_table.public[0]
module.healthcare_infrastructure.module.vpc.aws_route_table_association.private[0]
module.healthcare_infrastructure.module.vpc.aws_route_table_association.private[1]
module.healthcare_infrastructure.module.vpc.aws_route_table_association.private[2]
module.healthcare_infrastructure.module.vpc.aws_route_table_association.public[0]
module.healthcare_infrastructure.module.vpc.aws_route_table_association.public[1]
module.healthcare_infrastructure.module.vpc.aws_route_table_association.public[2]
module.healthcare_infrastructure.module.vpc.aws_subnet.private[0]
module.healthcare_infrastructure.module.vpc.aws_subnet.private[1]
module.healthcare_infrastructure.module.vpc.aws_subnet.private[2]
module.healthcare_infrastructure.module.vpc.aws_subnet.public[0]
module.healthcare_infrastructure.module.vpc.aws_subnet.public[1]
module.healthcare_infrastructure.module.vpc.aws_subnet.public[2]
module.healthcare_infrastructure.module.vpc.aws_vpc.this[0]
module.healthcare_infrastructure.module.eks.module.eks_managed_node_group["healthcare_nodes"].aws_eks_node_group.this[0]
module.healthcare_infrastructure.module.eks.module.eks_managed_node_group["healthcare_nodes"].aws_iam_role.this[0]
module.healthcare_infrastructure.module.eks.module.eks_managed_node_group["healthcare_nodes"].aws_iam_role_policy_attachment.this["arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"]
module.healthcare_infrastructure.module.eks.module.eks_managed_node_group["healthcare_nodes"].aws_iam_role_policy_attachment.this["arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"]
module.healthcare_infrastructure.module.eks.module.eks_managed_node_group["healthcare_nodes"].aws_iam_role_policy_attachment.this["arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"]
module.healthcare_infrastructure.module.eks.module.eks_managed_node_group["healthcare_nodes"].aws_launch_template.this[0]
module.healthcare_infrastructure.module.eks.module.kms.aws_kms_alias.this["cluster"]
module.healthcare_infrastructure.module.eks.module.kms.aws_kms_key.this[0]
27s
Run echo "🔍 Handling potential infrastructure conflicts..."
🔍 Handling potential infrastructure conflicts...
[INFO] 2025-08-22 17:25:42 - 🔧 Handling infrastructure conflicts with strategy: import
[INFO] 2025-08-22 17:25:42 - 🏥 Running infrastructure health check...
[INFO] 2025-08-22 17:25:44 - 📊 EIP Usage: 0 / 5
[INFO] 2025-08-22 17:25:46 - ℹ️ No available EIPs found - new EIPs will be created if needed
[SUCCESS] 2025-08-22 17:25:46 - ✅ Infrastructure health check completed
[INFO] 2025-08-22 17:25:46 - 📥 Using enhanced import strategy...
[INFO] 2025-08-22 17:25:46 - 📥 Enhanced pre-import with conflict resolution...
[INFO] 2025-08-22 17:25:47 - 🔍 Checking for existing KMS alias...
[INFO] 2025-08-22 17:25:47 - Attempt 1/3: aws kms list-aliases --query "Aliases[?AliasName=='alias/eks/healthcare-eks-stage3-dev']" --output text | grep -q alias/eks/healthcare-eks-stage3-dev
[SUCCESS] 2025-08-22 17:25:48 - Command succeeded on attempt 1
[INFO] 2025-08-22 17:25:48 - 📥 Importing KMS alias with retry logic...
[INFO] 2025-08-22 17:25:48 - Trying import path: module.healthcare_infrastructure.module.eks.aws_kms_alias.this["cluster"]
[INFO] 2025-08-22 17:25:48 - Attempt 1/2: terraform import "module.healthcare_infrastructure.module.eks.aws_kms_alias.this["cluster"]" alias/eks/healthcare-eks-stage3-dev
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
[WARNING] 2025-08-22 17:25:48 - Command failed, retrying in 1s...
[INFO] 2025-08-22 17:25:49 - Attempt 2/2: terraform import "module.healthcare_infrastructure.module.eks.aws_kms_alias.this["cluster"]" alias/eks/healthcare-eks-stage3-dev
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
[ERROR] 2025-08-22 17:25:49 - Command failed after 2 attempts
[WARNING] 2025-08-22 17:25:49 - Import failed for path: module.healthcare_infrastructure.module.eks.aws_kms_alias.this["cluster"]
[INFO] 2025-08-22 17:25:49 - Trying import path: module.healthcare_infrastructure.module.eks.module.kms.aws_kms_alias.this["cluster"]
[INFO] 2025-08-22 17:25:49 - Attempt 1/2: terraform import "module.healthcare_infrastructure.module.eks.module.kms.aws_kms_alias.this["cluster"]" alias/eks/healthcare-eks-stage3-dev
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
[WARNING] 2025-08-22 17:25:49 - Command failed, retrying in 1s...
[INFO] 2025-08-22 17:25:50 - Attempt 2/2: terraform import "module.healthcare_infrastructure.module.eks.module.kms.aws_kms_alias.this["cluster"]" alias/eks/healthcare-eks-stage3-dev
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
[ERROR] 2025-08-22 17:25:50 - Command failed after 2 attempts
[WARNING] 2025-08-22 17:25:50 - Import failed for path: module.healthcare_infrastructure.module.eks.module.kms.aws_kms_alias.this["cluster"]
[INFO] 2025-08-22 17:25:50 - Trying import path: module.healthcare_infrastructure.aws_kms_alias.eks
[INFO] 2025-08-22 17:25:50 - Attempt 1/2: terraform import "module.healthcare_infrastructure.aws_kms_alias.eks" alias/eks/healthcare-eks-stage3-dev
Error: resource address "module.healthcare_infrastructure.aws_kms_alias.eks" does not exist in the configuration.
Before importing this resource, please create its configuration in module.healthcare_infrastructure. For example:
resource "aws_kms_alias" "eks" {
  # (resource arguments)
}

Error: Terraform exited with code 1.
[WARNING] 2025-08-22 17:25:50 - Command failed, retrying in 1s...
[INFO] 2025-08-22 17:25:51 - Attempt 2/2: terraform import "module.healthcare_infrastructure.aws_kms_alias.eks" alias/eks/healthcare-eks-stage3-dev
Error: resource address "module.healthcare_infrastructure.aws_kms_alias.eks" does not exist in the configuration.
Before importing this resource, please create its configuration in module.healthcare_infrastructure. For example:
resource "aws_kms_alias" "eks" {
  # (resource arguments)
}

Error: Terraform exited with code 1.
[ERROR] 2025-08-22 17:25:51 - Command failed after 2 attempts
[WARNING] 2025-08-22 17:25:51 - Import failed for path: module.healthcare_infrastructure.aws_kms_alias.eks
[WARNING] 2025-08-22 17:25:51 - ⚠️ KMS alias import failed for all paths - may need manual intervention
[INFO] 2025-08-22 17:25:51 - 🔍 Checking for existing CloudWatch log group...
[INFO] 2025-08-22 17:25:51 - Attempt 1/3: aws logs describe-log-groups --log-group-name-prefix "/aws/eks/healthcare-eks-stage3-dev" --query 'logGroups[0].logGroupName' --output text 2>/dev/null | grep -q '/aws/eks/healthcare-eks-stage3-dev'
[SUCCESS] 2025-08-22 17:25:52 - Command succeeded on attempt 1
[INFO] 2025-08-22 17:25:52 - 📥 Importing CloudWatch log group with retry logic...
[INFO] 2025-08-22 17:25:52 - Trying import path: module.healthcare_infrastructure.module.eks.aws_cloudwatch_log_group.this[0]
[INFO] 2025-08-22 17:25:52 - Attempt 1/2: terraform import "module.healthcare_infrastructure.module.eks.aws_cloudwatch_log_group.this[0]" "/aws/eks/healthcare-eks-stage3-dev/cluster"
module.healthcare_infrastructure.module.eks.data.aws_partition.current: Reading...
module.healthcare_infrastructure.module.eks.module.eks_managed_node_group["healthcare_nodes"].data.aws_caller_identity.current: Reading...
module.healthcare_infrastructure.module.eks.module.eks_managed_node_group["healthcare_nodes"].data.aws_partition.current: Reading...
module.healthcare_infrastructure.module.eks.data.aws_caller_identity.current: Reading...
module.healthcare_infrastructure.module.eks.module.kms.data.aws_caller_identity.current[0]: Reading...
module.healthcare_infrastructure.data.aws_caller_identity.current: Reading...
module.healthcare_infrastructure.data.aws_ecr_repository.frontend: Reading...
module.healthcare_infrastructure.module.eks.module.kms.data.aws_partition.current[0]: Reading...
module.healthcare_infrastructure.data.aws_ecr_repository.backend: Reading...
module.healthcare_infrastructure.data.aws_availability_zones.available: Reading...
module.healthcare_infrastructure.module.eks.data.aws_partition.current: Read complete after 0s [id=aws]
module.healthcare_infrastructure.module.eks.module.eks_managed_node_group["healthcare_nodes"].data.aws_partition.current: Read complete after 0s [id=aws]
module.healthcare_infrastructure.module.eks.module.kms.data.aws_partition.current[0]: Read complete after 0s [id=aws]
module.healthcare_infrastructure.module.eks.aws_cloudwatch_log_group.this[0]: Importing from ID "/aws/eks/healthcare-eks-stage3-dev/cluster"...
module.healthcare_infrastructure.module.eks.module.eks_managed_node_group["healthcare_nodes"].data.aws_iam_policy_document.assume_role_policy[0]: Reading...
module.healthcare_infrastructure.module.eks.aws_cloudwatch_log_group.this[0]: Import prepared!
  Prepared aws_cloudwatch_log_group for import
module.healthcare_infrastructure.module.eks.module.eks_managed_node_group["healthcare_nodes"].data.aws_iam_policy_document.assume_role_policy[0]: Read complete after 0s [id=2560088296]
module.healthcare_infrastructure.module.eks.data.aws_iam_policy_document.assume_role_policy[0]: Reading...
module.healthcare_infrastructure.module.eks.aws_cloudwatch_log_group.this[0]: Refreshing state... [id=/aws/eks/healthcare-eks-stage3-dev/cluster]
module.healthcare_infrastructure.module.eks.data.aws_iam_policy_document.assume_role_policy[0]: Read complete after 0s [id=2764486067]
module.healthcare_infrastructure.module.eks.module.eks_managed_node_group["healthcare_nodes"].data.aws_caller_identity.current: Read complete after 0s [id=867344452513]
module.healthcare_infrastructure.data.aws_caller_identity.current: Read complete after 0s [id=867344452513]
module.healthcare_infrastructure.module.eks.data.aws_caller_identity.current: Read complete after 0s [id=867344452513]
module.healthcare_infrastructure.module.eks.data.aws_iam_session_context.current: Reading...
module.healthcare_infrastructure.module.eks.data.aws_iam_session_context.current: Read complete after 0s [id=arn:aws:iam::867344452513:user/admin-user]
module.healthcare_infrastructure.module.eks.module.kms.data.aws_caller_identity.current[0]: Read complete after 0s [id=867344452513]
module.healthcare_infrastructure.data.aws_availability_zones.available: Read complete after 0s [id=us-east-1]
module.healthcare_infrastructure.data.aws_ecr_repository.frontend: Read complete after 0s [id=healthcare-frontend-stage3]
module.healthcare_infrastructure.data.aws_ecr_repository.backend: Read complete after 0s [id=healthcare-backend-stage3]

Import successful!
The resources that were imported are shown above. These resources are now in
your Terraform state and will henceforth be managed by Terraform.

[SUCCESS] 2025-08-22 17:25:56 - Command succeeded on attempt 1
[SUCCESS] 2025-08-22 17:25:56 - ✅ CloudWatch log group imported via path: module.healthcare_infrastructure.module.eks.aws_cloudwatch_log_group.this[0]
[INFO] 2025-08-22 17:25:56 - 🔍 Checking for existing RDS subnet group...
[INFO] 2025-08-22 17:25:56 - Attempt 1/3: aws rds describe-db-subnet-groups --db-subnet-group-name "healthcare-eks-stage3-dev-db-subnet-group" >/dev/null 2>&1
[SUCCESS] 2025-08-22 17:25:57 - Command succeeded on attempt 1
[INFO] 2025-08-22 17:25:57 - 📥 Importing RDS subnet group with retry logic...
[INFO] 2025-08-22 17:25:57 - Attempt 1/2: terraform import module.healthcare_infrastructure.aws_db_subnet_group.healthcare "healthcare-eks-stage3-dev-db-subnet-group"
module.healthcare_infrastructure.data.aws_ecr_repository.frontend: Reading...
module.healthcare_infrastructure.module.eks.module.kms.data.aws_caller_identity.current[0]: Reading...
module.healthcare_infrastructure.module.eks.module.kms.data.aws_partition.current[0]: Reading...
module.healthcare_infrastructure.module.eks.data.aws_caller_identity.current: Reading...
module.healthcare_infrastructure.module.eks.data.aws_partition.current: Reading...
module.healthcare_infrastructure.module.eks.module.eks_managed_node_group["healthcare_nodes"].data.aws_caller_identity.current: Reading...
module.healthcare_infrastructure.data.aws_caller_identity.current: Reading...
module.healthcare_infrastructure.module.eks.module.eks_managed_node_group["healthcare_nodes"].data.aws_partition.current: Reading...
module.healthcare_infrastructure.data.aws_ecr_repository.backend: Reading...
module.healthcare_infrastructure.module.eks.module.eks_managed_node_group["healthcare_nodes"].data.aws_partition.current: Read complete after 0s [id=aws]
module.healthcare_infrastructure.module.eks.data.aws_partition.current: Read complete after 0s [id=aws]
module.healthcare_infrastructure.module.eks.module.kms.data.aws_partition.current[0]: Read complete after 0s [id=aws]
module.healthcare_infrastructure.data.aws_availability_zones.available: Reading...
module.healthcare_infrastructure.module.eks.module.eks_managed_node_group["healthcare_nodes"].data.aws_iam_policy_document.assume_role_policy[0]: Reading...
module.healthcare_infrastructure.module.eks.module.eks_managed_node_group["healthcare_nodes"].data.aws_iam_policy_document.assume_role_policy[0]: Read complete after 0s [id=2560088296]
module.healthcare_infrastructure.module.eks.data.aws_iam_policy_document.assume_role_policy[0]: Reading...
module.healthcare_infrastructure.module.eks.data.aws_iam_policy_document.assume_role_policy[0]: Read complete after 0s [id=2764486067]
module.healthcare_infrastructure.module.eks.module.eks_managed_node_group["healthcare_nodes"].data.aws_caller_identity.current: Read complete after 0s [id=867344452513]
module.healthcare_infrastructure.module.eks.data.aws_caller_identity.current: Read complete after 0s [id=867344452513]
module.healthcare_infrastructure.module.eks.data.aws_iam_session_context.current: Reading...
module.healthcare_infrastructure.module.eks.data.aws_iam_session_context.current: Read complete after 0s [id=arn:aws:iam::867344452513:user/admin-user]
module.healthcare_infrastructure.data.aws_caller_identity.current: Read complete after 0s [id=867344452513]
module.healthcare_infrastructure.module.eks.module.kms.data.aws_caller_identity.current[0]: Read complete after 0s [id=867344452513]
module.healthcare_infrastructure.data.aws_availability_zones.available: Read complete after 0s [id=us-east-1]
module.healthcare_infrastructure.aws_db_subnet_group.healthcare: Importing from ID "healthcare-eks-stage3-dev-db-subnet-group"...
module.healthcare_infrastructure.aws_db_subnet_group.healthcare: Import prepared!
  Prepared aws_db_subnet_group for import
module.healthcare_infrastructure.aws_db_subnet_group.healthcare: Refreshing state... [id=healthcare-eks-stage3-dev-db-subnet-group]
module.healthcare_infrastructure.data.aws_ecr_repository.frontend: Read complete after 0s [id=healthcare-frontend-stage3]
module.healthcare_infrastructure.data.aws_ecr_repository.backend: Read complete after 0s [id=healthcare-backend-stage3]

Import successful!
The resources that were imported are shown above. These resources are now in
your Terraform state and will henceforth be managed by Terraform.

[SUCCESS] 2025-08-22 17:26:00 - Command succeeded on attempt 1
[SUCCESS] 2025-08-22 17:26:00 - ✅ RDS subnet group imported successfully
[INFO] 2025-08-22 17:26:00 - 🔍 Checking for existing S3 assets bucket...
[INFO] 2025-08-22 17:26:00 - Attempt 1/3: aws s3api head-bucket --bucket "healthcare-assets-stage3-dev-867344452513" 2>/dev/null
[WARNING] 2025-08-22 17:26:01 - Command failed, retrying in 2s...
[INFO] 2025-08-22 17:26:03 - Attempt 2/3: aws s3api head-bucket --bucket "healthcare-assets-stage3-dev-867344452513" 2>/dev/null
[WARNING] 2025-08-22 17:26:04 - Command failed, retrying in 4s...
[INFO] 2025-08-22 17:26:08 - Attempt 3/3: aws s3api head-bucket --bucket "healthcare-assets-stage3-dev-867344452513" 2>/dev/null
[ERROR] 2025-08-22 17:26:08 - Command failed after 3 attempts
[INFO] 2025-08-22 17:26:08 - ℹ️ No existing S3 assets bucket found - will be created
[SUCCESS] 2025-08-22 17:26:08 - ✅ Enhanced pre-import completed
[SUCCESS] 2025-08-22 17:26:08 - ✅ Infrastructure conflict handling completed
1s
Run echo "🚀 Deploying infrastructure with conflict resolution..."
🚀 Deploying infrastructure with conflict resolution...
📋 EKS cluster will be created
📋 RDS instance will be created
📋 VPC and networking will be created (single NAT Gateway)
🔧 Applying Terraform plan with conflict resolution...
╷
│ Error: Saved plan is stale
│ 
│ The given plan file can no longer be applied because the state was changed
│ by another operation after the plan was created.
╵
Error: Terraform exited with code 1.
Error: Process completed with exit code 1.
