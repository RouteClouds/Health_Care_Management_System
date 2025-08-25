terraform {
  backend "s3" {}
}


module "healthcare_infrastructure" {
  source = "../../modules/healthcare-platform"

  environment  = "dev"
  cluster_name = "healthcare-eks-stage3-dev"

  # First-time creation: do NOT preserve existing control plane (no cluster yet)
  # After successful creation, set preserve_existing_cluster=true and wire ARNs/SGs below
  preserve_existing_cluster = false

  # Existing cluster bindings (only needed when preserve_existing_cluster=true)
  # eks_cluster_role_arn          = "<EKS cluster role ARN>"
  # eks_cluster_kms_key_arn       = "<KMS key ARN for control plane encryption>"
  # eks_cluster_security_group_id = "<EKS cluster security group ID>"
  # eks_cluster_additional_sg_ids = ["<additional SG IDs>"]

  # Dev-specific configurations
  node_instance_types = ["t3.medium"]
  min_nodes           = 1
  max_nodes           = 3
  desired_nodes       = 2

  # Monitoring enabled
  enable_prometheus = true
  enable_grafana    = true
  enable_elk_stack  = true

  # Idempotency & safety controls
  reuse_existing_resources   = true
  force_new_resources        = false
  reuse_existing_eips        = true
  existing_eip_ids           = []     # may be populated by conflict handler
  attempt_reuse_assets_bucket = false # first run: create bucket if missing

  tags = {
    Environment = "dev"
    Stage       = "stage-3"
    Project     = "healthcare-management"
  }
}
