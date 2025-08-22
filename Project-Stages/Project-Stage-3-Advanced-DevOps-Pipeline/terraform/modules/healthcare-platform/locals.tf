# Local values for consistent naming and tagging
locals {
  # Common tags applied to all resources
  common_tags = merge(var.tags, {
    Project       = "healthcare-management"
    Stage         = "stage-3"
    Environment   = var.environment
    ManagedBy     = "terraform"
    CreatedBy     = "stage3-pipeline"
    ResourceGroup = "healthcare-stage3-${var.environment}"
    
    # Add deployment metadata
    DeploymentDate = formatdate("YYYY-MM-DD", timestamp())
    TerraformPath  = "stage3/environments/${var.environment}"
    
    # Cost tracking
    CostCenter = "healthcare-platform"
    Owner      = "devops-team"
  })
  
  # Deterministic naming convention
  resource_prefix = "healthcare-${var.environment}-stage3"
  
  # Resource naming patterns
  cluster_name = var.cluster_name
  vpc_name     = "${var.cluster_name}-vpc"
  db_name      = "${var.cluster_name}-database"
  
  # S3 bucket names (must be globally unique)
  assets_bucket_name = "healthcare-assets-stage3-${var.environment}-${data.aws_caller_identity.current.account_id}"
  
  # Security group naming
  eks_sg_name = "${local.resource_prefix}-eks-sg"
  rds_sg_name = "${local.resource_prefix}-rds-sg"
  alb_sg_name = "${local.resource_prefix}-alb-sg"
}
