#
# Demo App
#
# Variables - local and input
#
locals {
  name        = format("%s-%s", var.project, local.environment)
  environment = terraform.workspace

  # Config
  vpc_cidr            = lookup(var.config, local.environment)["vpc_cidr"]
  ec2_type            = lookup(var.config, local.environment)["ec2_type"]
  vol_size            = lookup(var.config, local.environment)["vol_size"]
  ip_whitelist        = lookup(var.config, local.environment)["ip_whitelist"]
  s3_data_bucket_name = lookup(var.config, local.environment)["s3_data_bucket_name"]

  tags = merge(
    {
      project   = var.project
      env       = local.environment
      terraform = "true"
    },
    var.tags
  )
}

variable "project" {
  description = "Project name"
  type        = string
  default     = "demo-app"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-1"
}

variable "config" {

  // Demo, we may want to inject configuration for real-world CI projects

  description = "Configuration per environment workspace map"

  type = map(object({
    vpc_cidr            = string
    ec2_type            = string
    vol_size            = number
    ip_whitelist        = list(string)
    s3_data_bucket_name = string
  }))

  default = {
    "dev" = {
      vpc_cidr            = "10.0.0.0/16"
      ec2_type            = "t3a.small"
      vol_size            = 15
      ip_whitelist        = ["0.0.0.0/0"]
      s3_data_bucket_name = "demo-app-data"
    },
    "prod" = {
      vpc_cidr            = "172.16.0.0/16"
      ec2_type            = "t3a.small"
      vol_size            = 15
      ip_whitelist        = ["0.0.0.0/0"]
      s3_data_bucket_name = "demo-app-data"
    }
  }
}

variable "tags" {
  description = "AWS resource tags"
  type        = map(string)
  default     = {}
}