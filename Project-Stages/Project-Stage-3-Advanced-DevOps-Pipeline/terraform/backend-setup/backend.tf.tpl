terraform {
  backend "s3" {
    bucket         = "${bucket_name}"
    key            = "stage3/terraform.tfstate"
    region         = "${region}"
    dynamodb_table = "${dynamodb_table}"
    encrypt        = true
  }
}
