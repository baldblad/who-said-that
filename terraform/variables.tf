variable "google_client_id" {
  description = "Google OAuth client ID for Cognito federation."
  type        = string
}

variable "google_client_secret" {
  description = "Google OAuth client secret for Cognito federation."
  type        = string
}

variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table for processed chats."
  type        = string
  default = "processed_chats"
}
// variables.tf
// Input variables for Terraform

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "eu-east-1"
}

variable "environment" {
  description = "Deployment environment (e.g., dev, prod)"
  type        = string  
}
