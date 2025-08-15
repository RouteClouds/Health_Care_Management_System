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

  tags = {
    Environment = "dev"
    Stage = "stage-3"
    Project = "healthcare-management"
  }
}
