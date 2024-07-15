#
# Demo App
#
# Networking - VPC, Security Groups
#

module "subnet_addrs" {
  source = "hashicorp/subnets/cidr"

  base_cidr_block = local.vpc_cidr

  #
  # Using new_bits = 2, e.g. for 10.0.0.0/16 each subnet is /19
  #
  networks = [
    {
      name     = "public_1"
      new_bits = 3
    },
    {
      name     = "public_2"
      new_bits = 3
    },
    {
      name     = "private_1"
      new_bits = 3
    },
    {
      name     = "private_2"
      new_bits = 3
    },
    #
    # Note: append new subnets here - inserting or changing order of subnets above will require VPC deletion
    #
  ]
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 2.0"

  name = local.name
  cidr = module.subnet_addrs.base_cidr_block

  azs = [
    data.aws_availability_zones.zones.names[0],
    data.aws_availability_zones.zones.names[1],
  ]

  public_subnets = [
    module.subnet_addrs.network_cidr_blocks["public_1"],
    module.subnet_addrs.network_cidr_blocks["public_2"],
  ]
  private_subnets = [
    module.subnet_addrs.network_cidr_blocks["private_1"],
    module.subnet_addrs.network_cidr_blocks["private_2"],
  ]

  enable_nat_gateway = true
  single_nat_gateway = true

  # VPCEs to enable Session Manager access to private subnets
  enable_ec2messages_endpoint             = true
  enable_ssm_endpoint                     = true
  enable_ssmmessages_endpoint             = true
  enable_s3_endpoint                      = true
  ssm_endpoint_security_group_ids         = [module.security_group_vpce.this_security_group_id]
  ssmmessages_endpoint_security_group_ids = [module.security_group_vpce.this_security_group_id]
  ec2messages_endpoint_security_group_ids = [module.security_group_vpce.this_security_group_id]

  tags = local.tags
  vpc_endpoint_tags = {
    "Name" = format("%s-vpce", local.name)
  }
}

module "security_group_alb" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 3.0"

  name        = format("%s-alb-webserver", local.name)
  description = format("Security group for %s ALB", local.name)
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = local.ip_whitelist
  ingress_rules       = ["https-443-tcp", "http-80-tcp"]
  egress_rules        = ["all-all"]

  tags = local.tags
}

module "security_group_ec2" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 3.0"

  name        = format("%s-ec2-webserver", local.name)
  description = format("Security group for %s EC2", local.name)
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = [
    module.subnet_addrs.network_cidr_blocks["public_1"],
    module.subnet_addrs.network_cidr_blocks["public_2"],
  ]
  ingress_rules = ["http-80-tcp", "all-icmp"] # Demo, should use https
  egress_rules  = ["all-all"]

  tags = local.tags
}

module "security_group_vpce" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 3.0"

  name        = format("%s-vpce", local.name)
  description = format("Security group for %s Interface VPCEs", local.name)
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = [module.subnet_addrs.base_cidr_block]
  ingress_rules       = ["https-443-tcp"]
  egress_rules        = ["all-all"]

  tags = local.tags
}