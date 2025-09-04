// main.tf
// Root Terraform configuration file

terraform {
  required_version = ">= 1.0.0"
  backend "s3" {}
}

provider "aws" {
  region = var.aws_region
}
