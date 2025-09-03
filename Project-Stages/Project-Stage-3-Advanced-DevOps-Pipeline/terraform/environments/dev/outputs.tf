# Re-expose module outputs at the environment root so `terraform output` works in CI

output "cluster_id" {
  description = "EKS cluster ID"
  value       = module.healthcare_infrastructure.cluster_id
}

output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.healthcare_infrastructure.cluster_endpoint
}

output "db_instance_endpoint" {
  description = "RDS endpoint"
  value       = module.healthcare_infrastructure.db_instance_endpoint
  sensitive   = true
}

