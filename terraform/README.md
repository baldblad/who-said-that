# Terraform Infrastructure

This directory contains Terraform code for AWS resources.

## Structure
- `main.tf`: Root configuration
- `variables.tf`: Input variables
- `outputs.tf`: Output values
- `modules/`: Reusable modules
- `environments/`: Environment-specific configs (e.g., dev, prod)
- `scripts/`: Helper scripts

## State Backend
Terraform state is stored in an S3 bucket (see `main.tf`).

## Deployment
Use GitHub Actions to run `terraform plan` and `terraform apply`.
