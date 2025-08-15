module "healthcare_infrastructure" {
  source = "../../modules/healthcare-platform"

  environment = "prod"
  cluster_name = "healthcare-eks-stage3-prod"

  # Production-specific configurations
  node_instance_types = ["t3.xlarge", "t3.large"]
  min_nodes = 3
  max_nodes = 10
  desired_nodes = 5

  # Monitoring enabled
  enable_prometheus = true
  enable_grafana = true
  enable_elk_stack = true

  # Production-specific features
  enable_backup = true
  enable_monitoring_alerts = true
  enable_log_retention = true

  tags = {
    Environment = "prod"
    Stage = "stage-3"
    Project = "healthcare-management"
    CriticalityLevel = "high"
  }
}
