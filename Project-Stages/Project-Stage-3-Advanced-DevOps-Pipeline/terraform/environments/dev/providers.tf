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

  backend "s3" {
    bucket         = "healthcare-terraform-state-stage3-867344452513"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "healthcare-terraform-locks-stage3"
    encrypt        = true
  }
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
