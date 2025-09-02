terraform {
  backend "s3" {}
}


module "healthcare_infrastructure" {
  source = "../../modules/healthcare-platform"

  environment  = "dev"
  cluster_name = "healthcare-eks-stage3-dev"

  # Preserve existing control plane once created to avoid replacement/duplication
  preserve_existing_cluster = true

  # Existing cluster bindings (only needed when preserve_existing_cluster=true)
  # eks_cluster_role_arn          = "<EKS cluster role ARN>"
  # eks_cluster_kms_key_arn       = "<KMS key ARN for control plane encryption>"
  # eks_cluster_security_group_id = "<EKS cluster security group ID>"
  # eks_cluster_additional_sg_ids = ["<additional SG IDs>"]

  # Existing cluster bindings (safe defaults; can be overridden via tfvars if needed)
  eks_cluster_role_arn          = ""
  eks_cluster_kms_key_arn       = ""
  eks_cluster_security_group_id = ""
  eks_cluster_additional_sg_ids = []

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
