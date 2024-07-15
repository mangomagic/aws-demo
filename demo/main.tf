#
# Demo App
#
# Terraform and provider config
#
terraform {
  required_version = "~> 0.15.0"

  required_providers {
    aws = {
      version = "~> 3.0"
      source  = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = var.region
}