# Terraform Backend Setup for Stage-3
# This configuration creates the S3 bucket and DynamoDB table required for Terraform backend

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = "dev"
      Project     = "healthcare-management"
      Stage       = "stage-3"
      ManagedBy   = "terraform"
      Purpose     = "backend-setup"
    }
  }
}

# Get current AWS account ID
data "aws_caller_identity" "current" {}

# Generate random suffix for unique bucket naming
resource "random_integer" "bucket_suffix" {
  min = 1000
  max = 9999
}

# S3 bucket for Terraform state
resource "aws_s3_bucket" "terraform_state" {
  bucket = "healthcare-terraform-state-stage3-${data.aws_caller_identity.current.account_id}-${random_integer.bucket_suffix.result}"

  tags = {
    Name        = "Healthcare Terraform State - Stage 3"
    Description = "Stores Terraform state files for Stage-3 infrastructure"
  }
}

# S3 bucket versioning
resource "aws_s3_bucket_versioning" "terraform_state_versioning" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 bucket encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state_encryption" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# S3 bucket public access block
resource "aws_s3_bucket_public_access_block" "terraform_state_pab" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# DynamoDB table for state locking
resource "aws_dynamodb_table" "terraform_locks" {
  name           = var.dynamodb_table_name
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "Healthcare Terraform Locks - Stage 3"
    Description = "Provides state locking for Terraform operations"
  }

  # Lifecycle management to handle existing resources
  lifecycle {
    ignore_changes = [
      # Ignore changes to these attributes if resource already exists
      billing_mode,
      hash_key,
      attribute
    ]
  }
}

# Output the bucket name for use in backend configuration
output "s3_bucket_name" {
  description = "Name of the S3 bucket for Terraform state"
  value       = aws_s3_bucket.terraform_state.bucket
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table for state locking"
  value       = aws_dynamodb_table.terraform_locks.name
}

output "aws_region" {
  description = "AWS region where resources are created"
  value       = var.aws_region
}

output "aws_account_id" {
  description = "AWS Account ID"
  value       = data.aws_caller_identity.current.account_id
}

output "backend_configuration" {
  description = "Backend configuration for use in other Terraform configurations"
  value = {
    bucket         = aws_s3_bucket.terraform_state.bucket
    key            = "stage3/terraform.tfstate"
    region         = var.aws_region
    dynamodb_table = aws_dynamodb_table.terraform_locks.name
    encrypt        = true
  }
}

# Create a backend configuration file
resource "local_file" "backend_config" {
  content = templatefile("${path.module}/backend.tf.tpl", {
    bucket_name    = aws_s3_bucket.terraform_state.bucket
    region         = var.aws_region
    dynamodb_table = aws_dynamodb_table.terraform_locks.name
  })
  filename = "${path.module}/../backend.tf"
}

# Create backend configuration for environments/dev
resource "local_file" "dev_backend_config" {
  content = templatefile("${path.module}/providers.tf.tpl", {
    bucket_name    = aws_s3_bucket.terraform_state.bucket
    region         = var.aws_region
    dynamodb_table = aws_dynamodb_table.terraform_locks.name
  })
  filename = "${path.module}/../environments/dev/providers.tf"
}
