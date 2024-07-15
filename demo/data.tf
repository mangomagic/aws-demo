#
# Demo App
#
# Data Sources
#
data "aws_availability_zones" "zones" {}

data "aws_ami" "ubuntu" {
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  most_recent = true
  owners      = ["099720109477"]
}

data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "s3_data_access" {
  // Demo, if S3 bucket is encrypted then a KMS policy would also be required
  statement {
    sid       = "S3DataAccess"
    actions   = ["s3:GetObject"]
    resources = [format("arn:aws:s3:::%s/*", local.s3_data_bucket_name)]
  }
}
