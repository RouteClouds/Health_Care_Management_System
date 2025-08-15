terraform {
  backend "s3" {
    bucket         = "healthcare-terraform-state-stage3-867344452513"
    key            = "stage3/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "healthcare-terraform-locks-stage3"
    encrypt        = true
  }
}
