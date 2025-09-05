// variables.tf
// Input variables for Terraform

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "aws_state_bucket" {
  description = "S3 bucket for storing Terraform state"
  type        = string
}
