# NOTE: Do NOT add a terraform { required_providers } block here.
# You already have versions.tf defining it. Duplicating will error.

provider "aws" {
  region = var.region
}

data "aws_caller_identity" "current" {}

locals {
  # Single-line ternary to avoid parser issues
  bucket_name = var.artifact_bucket_name_override != "" ? var.artifact_bucket_name_override : "${var.env_name}-idlms-artifacts-${data.aws_caller_identity.current.account_id}"

  tags = merge({
    "user:Project" = "IDLMS"
    "user:Env"     = var.env_name
    "user:Stack"   = "s3-artifacts"
    "ManagedBy"    = "terraform"
  }, var.common_tags)
}

resource "aws_s3_bucket" "artifact" {
  bucket        = local.bucket_name
  force_destroy = true
  tags          = local.tags
}

resource "aws_s3_bucket_versioning" "v" {
  bucket = aws_s3_bucket.artifact.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "sse" {
  bucket = aws_s3_bucket.artifact.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "pab" {
  bucket                  = aws_s3_bucket.artifact.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_ssm_parameter" "bucket_name" {
  name      = "${var.ssm_prefix}/${var.env_name}/bucket_name"
  type      = "String"
  value     = aws_s3_bucket.artifact.bucket
  overwrite = true
}

resource "aws_ssm_parameter" "default_key" {
  name      = "${var.ssm_prefix}/${var.env_name}/default_key"
  type      = "String"
  value     = "releases/"
  overwrite = true
}
data "aws_iam_policy_document" "artifact_bucket_extra" { #=> Remove this later i add for idlms-testyes
  statement {
    sid    = "AllowGitHubOIDCToPutObjects"
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetObject"
    ]
    resources = [
      "${aws_s3_bucket.artifact.arn}/deploy/stage/*"
    ]
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::592776312448:role/github-oidc-idlms-test"
      ]
    }
  }
}

resource "aws_s3_bucket_policy" "artifact_policy" {
  bucket = aws_s3_bucket.artifact.id
  policy = data.aws_iam_policy_document.artifact_bucket_extra.json
}
