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
    bucket         = "${bucket_name}"
    key            = "dev/terraform.tfstate"
    region         = "${region}"
    dynamodb_table = "${dynamodb_table}"
    encrypt        = true
  }
}

provider "aws" {
  region = "${region}"

  default_tags {
    tags = {
      Environment = "dev"
      Project     = "healthcare-management"
      Stage       = "stage-3"
      ManagedBy   = "terraform"
    }
  }
}
