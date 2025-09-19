terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

# Look up existing if provided
data "aws_iam_role" "existing" {
  count = var.existing_role_name == null ? 0 : 1
  name  = var.existing_role_name
}

data "aws_iam_instance_profile" "existing" {
  count = var.existing_instance_profile_name == null ? 0 : 1
  name  = var.existing_instance_profile_name
}

# Create only when not reusing
data "aws_iam_policy_document" "assume_role" {
  count = var.existing_role_name == null ? 1 : 0

  statement {
    effect = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "this" {
  count              = var.existing_role_name == null ? 1 : 0
  name               = "${var.name}-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role[0].json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  count      = var.existing_role_name == null ? 1 : 0
  role       = aws_iam_role.this[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "this" {
  count = var.existing_instance_profile_name == null ? 1 : 0
  name  = "${var.name}-instance-profile"
  role  = var.existing_role_name == null ? aws_iam_role.this[0].name : data.aws_iam_role.existing[0].name
  tags  = var.tags
}
