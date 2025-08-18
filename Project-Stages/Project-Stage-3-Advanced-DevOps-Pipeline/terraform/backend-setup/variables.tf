# Variables for Terraform Backend Setup

variable "aws_region" {
  description = "AWS region for backend resources"
  type        = string
  default     = "us-east-1"
}

variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table for state locking"
  type        = string
  default     = "healthcare-terraform-locks-stage3"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "healthcare-management"
}

variable "stage" {
  description = "Stage/environment name"
  type        = string
  default     = "stage-3"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}
