terraform {
  required_version = ">= 1.0.0"
  backend "s3" {
    bucket         = "your-bucket-name"
    key            = "path/to/terraform.tfstate"
    region         = "your-region"
    dynamodb_table = "your-lock-table" # optional, for locking
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
}