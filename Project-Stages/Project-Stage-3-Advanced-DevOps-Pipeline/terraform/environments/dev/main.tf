module "healthcare_infrastructure" {
  source = "../../modules/healthcare-platform"

  environment  = "dev"
  cluster_name = "healthcare-eks-stage3-dev"

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
