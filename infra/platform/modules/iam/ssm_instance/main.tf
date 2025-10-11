terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# ---------- Locals (single source of truth) ----------
locals {
  role_name        = coalesce(var.existing_role_name, try(aws_iam_role.this[0].name, null), var.name)
  instance_profile = coalesce(var.existing_instance_profile_name, try(aws_iam_instance_profile.this[0].name, null), "${var.name}-instance-profile")
  s3_bucket_arn    = try(regex("^arn:aws:s3:::[^/]+", var.s3_backup_arn), null)
}

# ---------- Role (create or reuse) ----------
resource "aws_iam_role" "this" {
  count              = var.existing_role_name == null ? 1 : 0
  name               = "${var.name}-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  tags               = var.tags
}

data "aws_iam_role" "existing" {
  count = var.existing_role_name == null ? 0 : 1
  name  = var.existing_role_name
}

# ---------- Instance Profile (create or reuse) ----------
resource "aws_iam_instance_profile" "this" {
  count = var.existing_instance_profile_name == null ? 1 : 0
  name  = "${var.name}-instance-profile"
  role  = local.role_name
  tags  = var.tags
}

data "aws_iam_instance_profile" "existing" {
  count = var.existing_instance_profile_name == null ? 0 : 1
  name  = var.existing_instance_profile_name
}

# ---------- REQUIRED managed policy attachments ----------
resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = local.role_name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "cloudwatch_agent" {
  role       = local.role_name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# ---------- SSM Parameter read (AWS-managed) ----------
# (Previously a custom policy - replaced to avoid iam:CreatePolicy)
resource "aws_iam_role_policy_attachment" "ssm_readonly" {
  role       = local.role_name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
}

# ---------- ECR pull (AWS-managed) ----------
resource "aws_iam_role_policy_attachment" "ecr_readonly" {
  count      = var.enable_ecr_pull ? 1 : 0
  role       = local.role_name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# ---------- Describe helpers (AWS-managed) ----------
resource "aws_iam_role_policy_attachment" "ec2_readonly" {
  count      = var.enable_describe_helpers ? 1 : 0
  role       = local.role_name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "elb_readonly" {
  count      = var.enable_describe_helpers ? 1 : 0
  role       = local.role_name
  policy_arn = "arn:aws:iam::aws:policy/ElasticLoadBalancingReadOnly"
}

# ---------- S3 docker-backup read ----------
resource "aws_iam_role_policy_attachment" "s3_readonly" {
  count      = var.s3_backup_arn == "" ? 0 : 1
  role       = local.role_name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}
