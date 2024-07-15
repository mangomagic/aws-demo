#
# Demo App
#
# EC2 for web application with asg
#
module "autoscaling" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "~> 4.0"

  name                     = local.name
  image_id                 = data.aws_ami.ubuntu.id
  instance_type            = local.ec2_type
  iam_instance_profile_arn = aws_iam_instance_profile.ec2_profile.arn

  root_block_device = [
    {
      volume_size = local.vol_size
      volume_type = "gp2"
      encrypted   = true # Should consider a CMK KMS key for enhanced security
    }
  ]

  # Launch template
  lt_name                = local.name
  description            = format("Launch template for %s", local.name)
  use_lt                 = true
  create_lt              = true
  update_default_version = true
  user_data_base64       = base64encode(data.template_file.user_data.rendered)

  vpc_zone_identifier = module.vpc.private_subnets
  security_groups     = [module.security_group_ec2.this_security_group_id]
  min_size            = 0
  max_size            = 1
  desired_capacity    = 1
  health_check_type   = "EC2"

  target_group_arns = module.alb.target_group_arns

  tags_as_map = local.tags
}

resource "aws_iam_role" "ec2_role" {
  name               = format("%s-ec2-role", local.name)
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
  tags               = local.tags
}

resource "aws_iam_policy" "s3_data_access" {
  name   = format("%s-s3-data-access", local.name)
  policy = data.aws_iam_policy_document.s3_data_access.json
}

resource "aws_iam_role_policy_attachment" "s3_data_access" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.s3_data_access.arn
}

resource "aws_iam_role_policy_attachment" "config_attach" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "ec2_attach" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "cloudwatch_attach" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = format("%s-ec2-profile", local.name)
  role = aws_iam_role.ec2_role.name
}