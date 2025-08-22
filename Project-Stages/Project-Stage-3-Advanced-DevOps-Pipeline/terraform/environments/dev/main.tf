module "healthcare_infrastructure" {
  source = "../../modules/healthcare-platform"

  environment = "dev"
  cluster_name = "healthcare-eks-stage3-dev"

  # Development-specific configurations
  node_instance_types = ["t3.medium"]
  min_nodes = 1
  max_nodes = 3
  desired_nodes = 2

  # Monitoring enabled
  enable_prometheus = true
  enable_grafana = true
  enable_elk_stack = true

  # Idempotency controls
  reuse_existing_resources = true
  force_new_resources = false

  # EIP reuse configuration
  reuse_existing_eips = true
  existing_eip_ids = []  # Will be populated by pipeline discovery

  # S3 assets bucket behavior
  # Default: Create bucket if not exist (safe for first runs)
  attempt_reuse_assets_bucket = false

  tags = {
    Environment = "dev"
    Stage = "stage-3"
    Project = "healthcare-management"
  }
}

# Outputs for pipeline validation
output "cluster_id" {
  description = "EKS cluster ID"
  value       = module.healthcare_infrastructure.cluster_id
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.healthcare_infrastructure.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = module.healthcare_infrastructure.cluster_security_group_id
}

output "db_instance_endpoint" {
  description = "RDS instance endpoint"
  value       = module.healthcare_infrastructure.db_instance_endpoint
  sensitive   = true
}

output "db_instance_port" {
  description = "RDS instance port"
  value       = module.healthcare_infrastructure.db_instance_port
}

output "ecr_repository_frontend_url" {
  description = "URL of the frontend ECR repository"
  value       = module.healthcare_infrastructure.ecr_repository_frontend_url
}

output "ecr_repository_backend_url" {
  description = "URL of the backend ECR repository"
  value       = module.healthcare_infrastructure.ecr_repository_backend_url
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = module.healthcare_infrastructure.vpc_id
}

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.healthcare_infrastructure.private_subnets
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.healthcare_infrastructure.public_subnets
}
