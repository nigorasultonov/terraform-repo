terraform {
  backend "s3" {
    bucket         = "devops.tf-bucket"
    key            = "Terraform/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform_lock"
  }
}
