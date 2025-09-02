2025-08-22 19:17:27 - Command failed, retrying in 2s...
[INFO] 2025-08-22 19:17:29 - Attempt 2/3: aws rds describe-db-subnet-groups --db-subnet-group-name "healthcare-eks-stage3-dev-db-subnet-group-867344452513" >/dev/null 2>&1
[WARNING] 2025-08-22 19:17:30 - Command failed, retrying in 4s...
[INFO] 2025-08-22 19:17:34 - Attempt 3/3: aws rds describe-db-subnet-groups --db-subnet-group-name "healthcare-eks-stage3-dev-db-subnet-group-867344452513" >/dev/null 2>&1
[ERROR] 2025-08-22 19:17:35 - Command failed after 3 attempts
[INFO] 2025-08-22 19:17:35 - ℹ️ No existing RDS subnet group found - will be created
 Warning: Argument is deprecated
│ 
│   with module.healthcare_infrastructure.module.eks.aws_iam_role.this[0],
│   on .terraform/modules/healthcare_infrastructure.eks/main.tf line 293, in resource "aws_iam_role" "this":
│  293: resource "aws_iam_role" "this" {
│ 
│ inline_policy is deprecated. Use the aws_iam_role_policy resource instead.
│ If Terraform should exclusively manage all inline policy associations (the
│ current behavior of this argument), use the aws_iam_role_policies_exclusive
│ resource as well.
╵
╷
│ Error: creating EKS Cluster (healthcare-eks-stage3-dev): operation error EKS: CreateCluster, https response error StatusCode: 409, RequestID: 5bc9e807-e97c-4910-aa5f-01f47b1f934d, ResourceInUseException: Cluster already exists with name: healthcare-eks-stage3-dev
│ 
│   with module.healthcare_infrastructure.module.eks.aws_eks_cluster.this[0],
│   on .terraform/modules/healthcare_infrastructure.eks/main.tf line 25, in resource "aws_eks_cluster" "this":
│   25: resource "aws_eks_cluster" "this" {
│ 
╵
Error: Terraform exited with code 1.
Error: Process completed with exit code 1.

