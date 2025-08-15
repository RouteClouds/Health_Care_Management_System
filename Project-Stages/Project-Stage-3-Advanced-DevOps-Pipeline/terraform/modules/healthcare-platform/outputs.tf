# Healthcare Platform Module Outputs

# VPC Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnets
}

# EKS Outputs
output "cluster_id" {
  description = "EKS cluster ID"
  value       = module.eks.cluster_id
}

output "cluster_arn" {
  description = "EKS cluster ARN"
  value       = module.eks.cluster_arn
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = module.eks.cluster_security_group_id
}

output "cluster_iam_role_name" {
  description = "IAM role name associated with EKS cluster"
  value       = module.eks.cluster_iam_role_name
}

output "cluster_iam_role_arn" {
  description = "IAM role ARN associated with EKS cluster"
  value       = module.eks.cluster_iam_role_arn
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = module.eks.cluster_certificate_authority_data
}

output "cluster_primary_security_group_id" {
  description = "Cluster security group that was created by Amazon EKS for the cluster"
  value       = module.eks.cluster_primary_security_group_id
}

output "node_groups" {
  description = "EKS node groups"
  value       = module.eks.eks_managed_node_groups
}

# RDS Outputs
output "db_instance_endpoint" {
  description = "RDS instance endpoint"
  value       = aws_db_instance.healthcare.endpoint
  sensitive   = true
}

output "db_instance_name" {
  description = "RDS instance name"
  value       = aws_db_instance.healthcare.db_name
}

output "db_instance_username" {
  description = "RDS instance root username"
  value       = aws_db_instance.healthcare.username
  sensitive   = true
}

output "db_instance_port" {
  description = "RDS instance port"
  value       = aws_db_instance.healthcare.port
}

output "db_subnet_group_name" {
  description = "RDS subnet group name"
  value       = aws_db_subnet_group.healthcare.name
}

output "db_parameter_group_name" {
  description = "RDS parameter group name"
  value       = aws_db_instance.healthcare.parameter_group_name
}

# ECR Outputs
output "ecr_repository_frontend_url" {
  description = "URL of the frontend ECR repository"
  value       = data.aws_ecr_repository.frontend.repository_url
}

output "ecr_repository_backend_url" {
  description = "URL of the backend ECR repository"
  value       = data.aws_ecr_repository.backend.repository_url
}

output "ecr_repository_frontend_arn" {
  description = "ARN of the frontend ECR repository"
  value       = data.aws_ecr_repository.frontend.arn
}

output "ecr_repository_backend_arn" {
  description = "ARN of the backend ECR repository"
  value       = data.aws_ecr_repository.backend.arn
}

# S3 Outputs
output "s3_bucket_healthcare_assets_id" {
  description = "Name of the healthcare assets S3 bucket"
  value       = aws_s3_bucket.healthcare_assets.id
}

output "s3_bucket_healthcare_assets_arn" {
  description = "ARN of the healthcare assets S3 bucket"
  value       = aws_s3_bucket.healthcare_assets.arn
}

output "s3_bucket_healthcare_assets_domain_name" {
  description = "Domain name of the healthcare assets S3 bucket"
  value       = aws_s3_bucket.healthcare_assets.bucket_domain_name
}

# General Outputs
output "aws_caller_identity_account_id" {
  description = "AWS Account ID"
  value       = data.aws_caller_identity.current.account_id
}

output "aws_caller_identity_arn" {
  description = "AWS caller identity ARN"
  value       = data.aws_caller_identity.current.arn
}

output "aws_region" {
  description = "AWS region"
  value       = data.aws_availability_zones.available.id
}

output "availability_zones" {
  description = "List of availability zones"
  value       = data.aws_availability_zones.available.names
}
