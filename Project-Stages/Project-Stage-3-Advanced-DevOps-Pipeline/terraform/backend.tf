# Backend configuration will be dynamically configured by the pipeline
# This file serves as a template - actual values are set during terraform init
terraform {
  backend "s3" {
    # Bucket name will be set dynamically by pipeline based on existing bucket discovery
    # Pattern: healthcare-terraform-state-stage3-{account-id}-{suffix}
    # Key: dev/terraform.tfstate (consistent across all environments)
    # Region: us-east-1
    # DynamoDB Table: healthcare-terraform-locks-stage3
    # Encrypt: true
  }
}
