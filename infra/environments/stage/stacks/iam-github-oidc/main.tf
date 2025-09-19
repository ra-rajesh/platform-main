terraform {
  required_version = ">= 1.5.0"
  required_providers { aws = { source = "hashicorp/aws", version = ">= 5.0" } }
}

# OIDC provider (created if missing)
resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

# Trust only your repo and branch (EDIT OWNER/REPO/BRANCH BELOW)
data "aws_iam_policy_document" "gha_trust" {
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
    # LIMIT to your repo + branch
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:OWNER/REPO:ref:refs/heads/BRANCH"]
    }
  }
}

# Minimal deploy role: SSM SendCommand + describe + S3 read artifacts
resource "aws_iam_role" "gha_role" {
  name               = "stage-gha-oidc"
  assume_role_policy = data.aws_iam_policy_document.gha_trust.json
}

data "aws_iam_policy_document" "gha_inline" {
  statement {
    effect  = "Allow"
    actions = [
      "ec2:DescribeInstances",
      "ssm:SendCommand",
      "ssm:ListCommandInvocations",
      "ssm:GetCommandInvocation",
      "ssm:DescribeInstanceInformation"
    ]
    resources = ["*"]
  }

  # read artifacts bucket (EDIT to match your bucket)
  statement {
    effect  = "Allow"
    actions = ["s3:ListBucket"]
    resources = ["arn:aws:s3:::idlms-terraform-stage-website-built-artifact-592776312448"]
  }
  statement {
    effect  = "Allow"
    actions = ["s3:GetObject"]
    resources = ["arn:aws:s3:::idlms-terraform-stage-website-built-artifact-592776312448/*"]
  }
}

resource "aws_iam_policy" "gha_policy" {
  name   = "stage-gha-artifacts-ssm"
  policy = data.aws_iam_policy_document.gha_inline.json
}

resource "aws_iam_role_policy_attachment" "gha_attach" {
  role       = aws_iam_role.gha_role.name
  policy_arn = aws_iam_policy.gha_policy.arn
}

output "gha_role_arn" {
  value = aws_iam_role.gha_role.arn
}
