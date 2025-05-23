#
# Demo App
#
# Terraform and provider config
#
terraform {
  required_version = "~> 1.0"

  required_providers {
    aws = {
      version = "~> 4.0"
      source  = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = var.region
}
