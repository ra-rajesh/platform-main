# NOTE: Do NOT add a terraform { required_providers } block here.
# You already have versions.tf defining it. Duplicating will error.

provider "aws" {
  region = var.region
}

data "aws_caller_identity" "current" {}

locals {
  # Use override if provided; else build a default name
  bucket_name   = var.artifact_bucket_name_override != "" ? var.artifact_bucket_name_override : "${var.env_name}-idlms-artifacts-${data.aws_caller_identity.current.account_id}"
  create_bucket = var.artifact_bucket_name_override == ""  # create only when no override

  tags = merge({
    "user:Project" = "IDLMS"
    "user:Env"     = var.env_name
    "user:Stack"   = "s3-artifacts"
    "ManagedBy"    = "terraform"
  }, var.common_tags)
}

# Create path
resource "aws_s3_bucket" "artifact" {
  count         = local.create_bucket ? 1 : 0
  bucket        = local.bucket_name
  force_destroy = true
  tags          = local.tags
}

resource "aws_s3_bucket_versioning" "v" {
  count  = local.create_bucket ? 1 : 0
  bucket = aws_s3_bucket.artifact[0].id
  versioning_configuration { status = "Enabled" }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "sse" {
  count  = local.create_bucket ? 1 : 0
  bucket = aws_s3_bucket.artifact[0].id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "pab" {
  count                   = local.create_bucket ? 1 : 0
  bucket                  = aws_s3_bucket.artifact[0].id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Reuse path
data "aws_s3_bucket" "artifact_existing" {
  count  = local.create_bucket ? 0 : 1
  bucket = local.bucket_name
}

# Unified handles for bucket id/arn/name (works in both paths)
locals {
  bucket_id   = local.create_bucket ? aws_s3_bucket.artifact[0].id   : data.aws_s3_bucket.artifact_existing[0].id
  bucket_arn  = local.create_bucket ? aws_s3_bucket.artifact[0].arn  : data.aws_s3_bucket.artifact_existing[0].arn
}

# SSM params (always write)
resource "aws_ssm_parameter" "bucket_name" {
  name      = "${var.ssm_prefix}/${var.env_name}/bucket_name"
  type      = "String"
  value     = local.bucket_name
  overwrite = true
}

resource "aws_ssm_parameter" "default_key" {
  name      = "${var.ssm_prefix}/${var.env_name}/default_key"
  type      = "String"
  value     = "releases/"
  overwrite = true
}

# Bucket policy for GitHub OIDC role (kept, but made env-aware)
data "aws_iam_policy_document" "artifact_bucket_extra" {
  statement {
    sid     = "AllowGitHubOIDCToPutObjects"
    effect  = "Allow"
    actions = ["s3:PutObject", "s3:GetObject"]

    resources = ["${local.bucket_arn}/deploy/${var.env_name}/*"]

    principals {
      type        = "AWS"
      identifiers = [
        "arn:aws:iam::592776312448:role/github-oidc-idlms-test"
      ]
    }
  }
}

resource "aws_s3_bucket_policy" "artifact_policy" {
  bucket = local.bucket_id
  policy = data.aws_iam_policy_document.artifact_bucket_extra.json
}
