terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.20"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }

  # Backend configuration is set dynamically by the pipeline
  # The pipeline discovers existing backend bucket or creates new one
  # This ensures idempotent behavior across multiple pipeline runs
}

provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Environment = "dev"
      Project     = "healthcare-management"
      Stage       = "stage-3"
      ManagedBy   = "terraform"
    }
  }
}

# Kubernetes provider configuration
# Minimal configuration to avoid dependency cycles during initial deployment
provider "kubernetes" {
  # Use empty configuration during initial deployment
  # This will be properly configured after EKS cluster is created
}
