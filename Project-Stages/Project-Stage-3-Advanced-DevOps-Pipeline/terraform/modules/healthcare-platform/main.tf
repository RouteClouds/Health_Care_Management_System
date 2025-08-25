# Healthcare Platform Infrastructure Module
# Stage-3 Advanced DevOps Pipeline

# Data sources
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_caller_identity" "current" {}

# VPC Module
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.cluster_name}-vpc"
  cidr = var.vpc_cidr

  azs             = slice(data.aws_availability_zones.available.names, 0, 3)
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway = true
  single_nat_gateway = true  # 🔧 CRITICAL FIX: Use single NAT Gateway to avoid EIP limit
  enable_vpn_gateway = false
  enable_dns_hostnames = true
  enable_dns_support = true

  # EIP reuse configuration to prevent EIP limit issues
  # Only reuse when EIP IDs are provided; otherwise let module allocate a new EIP
  reuse_nat_ips       = var.reuse_existing_eips && length(var.existing_eip_ids) > 0
  external_nat_ip_ids = var.existing_eip_ids

  # EKS specific tags
  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }

  tags = merge(local.common_tags, {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  })
}

# EKS Cluster
module "eks" {
  source = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  # If preserving existing control plane, do not create cluster; only manage node groups and data lookups
  create = var.preserve_existing_cluster ? false : true

  cluster_name    = var.cluster_name
  cluster_version = var.kubernetes_version

  # Preserve existing cluster by referencing its exact settings when not creating
  create_iam_role              = var.preserve_existing_cluster ? false : true
  iam_role_arn                 = var.preserve_existing_cluster ? var.eks_cluster_role_arn : null
  cluster_enabled_log_types    = ["api", "audit", "authenticator"]
  create_cloudwatch_log_group  = var.preserve_existing_cluster ? false : true
  cluster_encryption_config = {
    resources        = ["secrets"]
    provider_key_arn = var.preserve_existing_cluster ? var.eks_cluster_kms_key_arn : null
  }
  create_kms_key               = var.preserve_existing_cluster ? false : true

  # VPC and networking must match existing cluster
  vpc_id                         = module.vpc.vpc_id
  subnet_ids                     = module.vpc.private_subnets
  cluster_endpoint_public_access = true

  # If the cluster already exists, attach its existing SGs rather than creating new ones
  create_cluster_security_group = var.preserve_existing_cluster ? false : true
  cluster_security_group_id     = var.preserve_existing_cluster ? var.eks_cluster_security_group_id : null
  cluster_additional_security_group_ids = var.preserve_existing_cluster ? var.eks_cluster_additional_sg_ids : []

  # EKS Managed Node Groups
  eks_managed_node_groups = {
    healthcare_nodes = {
      name = "healthcare-nodes"

      instance_types = var.node_instance_types
      capacity_type  = "ON_DEMAND"

      min_size     = var.min_nodes
      max_size     = var.max_nodes
      desired_size = var.desired_nodes

      # Launch template configuration
      launch_template_tags = local.common_tags

      # Node group scaling configuration
      update_config = {
        max_unavailable_percentage = 25
      }

      labels = {
        Environment = var.environment
        NodeGroup = "healthcare-nodes"
      }

      taints = []

      tags = local.common_tags
    }
  }

  # Cluster access configuration
  # Disable aws-auth ConfigMap management to avoid connection issues during initial deployment
  manage_aws_auth_configmap = false
  create_aws_auth_configmap = false

  tags = local.common_tags
}

# RDS Database
resource "aws_db_subnet_group" "healthcare" {
  name       = "${var.cluster_name}-db-subnet-group-${data.aws_caller_identity.current.account_id}"
  subnet_ids = module.vpc.private_subnets

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(local.common_tags, {
    Name = "${var.cluster_name}-db-subnet-group-${data.aws_caller_identity.current.account_id}"
  })
}

resource "aws_security_group" "rds" {
  name_prefix = "${var.cluster_name}-rds-"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${var.cluster_name}-rds-sg"
  })
}

resource "aws_db_instance" "healthcare" {
  identifier = "${var.cluster_name}-db"

  engine         = "postgres"
  engine_version = var.postgres_version
  instance_class = var.db_instance_class

  allocated_storage     = var.db_allocated_storage
  max_allocated_storage = var.db_max_allocated_storage
  storage_encrypted     = true

  db_name  = "healthcare_stage3_db"
  username = "healthcare_stage3_user"
  password = var.db_password

  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.healthcare.name

  backup_retention_period = var.environment == "prod" ? 7 : 1
  backup_window          = "03:00-04:00"
  maintenance_window     = "sun:04:00-sun:05:00"

  skip_final_snapshot = var.environment != "prod"
  deletion_protection = var.environment == "prod"

  tags = merge(local.common_tags, {
    Name = "${var.cluster_name}-database"
  })
}

# ECR Repositories - Use existing repositories created by setup script
data "aws_ecr_repository" "frontend" {
  name = "healthcare-frontend-stage3"
}

data "aws_ecr_repository" "backend" {
  name = "healthcare-backend-stage3"
}

# ECR Lifecycle Policies - Only create if repositories don't have policies
resource "aws_ecr_lifecycle_policy" "frontend" {
  repository = data.aws_ecr_repository.frontend.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 30 images"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["v"]
          countType     = "imageCountMoreThan"
          countNumber   = 30
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

resource "aws_ecr_lifecycle_policy" "backend" {
  repository = data.aws_ecr_repository.backend.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 30 images"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["v"]
          countType     = "imageCountMoreThan"
          countNumber   = 30
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

# S3 Bucket for Application Assets - Idempotent Pattern
# Try to use existing bucket first (optional)
data "aws_s3_bucket" "existing_assets" {
  # Only attempt data source lookup when explicitly enabled and reuse is desired
  count  = var.attempt_reuse_assets_bucket && var.reuse_existing_resources && !var.force_new_resources ? 1 : 0
  bucket = local.assets_bucket_name
}

# Determine if existing bucket is discoverable
locals {
  assets_bucket_exists = var.reuse_existing_resources && !var.force_new_resources && try(length(data.aws_s3_bucket.existing_assets) > 0, false)
}

# Create bucket only if existing one not found or reuse is disabled
resource "aws_s3_bucket" "healthcare_assets" {
  count  = local.assets_bucket_exists ? 0 : 1
  bucket = local.assets_bucket_name

  lifecycle {
    prevent_destroy = true
  }

  tags = merge(local.common_tags, {
    Name        = "Healthcare Assets Bucket - Stage 3"
    Description = "Stores healthcare application assets"
    Purpose     = "application-assets"
  })
}

# Use existing or new bucket
locals {
  assets_bucket_id  = local.assets_bucket_exists ? data.aws_s3_bucket.existing_assets[0].id  : aws_s3_bucket.healthcare_assets[0].id
  assets_bucket_arn = local.assets_bucket_exists ? data.aws_s3_bucket.existing_assets[0].arn : aws_s3_bucket.healthcare_assets[0].arn
}

# Bucket versioning (apply to existing or new bucket)
resource "aws_s3_bucket_versioning" "healthcare_assets" {
  bucket = local.assets_bucket_id
  versioning_configuration {
    status = "Enabled"
  }

  depends_on = [aws_s3_bucket.healthcare_assets]
}

# Bucket encryption (apply to existing or new bucket)
resource "aws_s3_bucket_server_side_encryption_configuration" "healthcare_assets" {
  bucket = local.assets_bucket_id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }

  depends_on = [aws_s3_bucket.healthcare_assets]
}
