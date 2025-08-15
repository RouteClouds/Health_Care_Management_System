module "healthcare_infrastructure" {
  source = "../../modules/healthcare-platform"

  environment = "staging"
  cluster_name = "healthcare-eks-stage3-staging"

  # Staging-specific configurations
  node_instance_types = ["t3.large"]
  min_nodes = 2
  max_nodes = 5
  desired_nodes = 3

  # Monitoring enabled
  enable_prometheus = true
  enable_grafana = true
  enable_elk_stack = true

  tags = {
    Environment = "staging"
    Stage = "stage-3"
    Project = "healthcare-management"
  }
}
