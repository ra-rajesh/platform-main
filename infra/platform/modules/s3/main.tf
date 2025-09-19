locals {
  bucket_name = coalesce(var.bucket_name_override, "${var.environment}-${var.name}")

  base_tags = merge(
    {
      Environment = var.environment
      Name        = local.bucket_name
    },
    var.tags
  )
}

resource "aws_s3_bucket" "this" {
  bucket        = local.bucket_name
  force_destroy = var.force_destroy
  tags          = local.base_tags
}

# Ownership controls: modern default (no ACLs). Safer for most cases.
resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# Block all public access
resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Default encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.sse_algorithm
      kms_master_key_id = var.sse_algorithm == "aws:kms" ? var.kms_key_id : null
    }
  }
}

# Versioning
resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id
  versioning_configuration {
    status = var.versioning ? "Enabled" : "Suspended"
  }
}

# Lifecycle (optional rules)
resource "aws_s3_bucket_lifecycle_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  dynamic "rule" {
    for_each = var.enable_ia_transition ? [1] : []
    content {
      id     = "transition-to-ia"
      status = "Enabled"

      transition {
        days          = var.ia_after_days
        storage_class = "STANDARD_IA"
      }
      noncurrent_version_transition {
        noncurrent_days = var.ia_after_days
        storage_class   = "STANDARD_IA"
      }
    }
  }

  dynamic "rule" {
    for_each = var.noncurrent_expire_days > 0 ? [1] : []
    content {
      id     = "expire-noncurrent"
      status = "Enabled"

      noncurrent_version_expiration {
        noncurrent_days = var.noncurrent_expire_days
      }
    }
  }

  dynamic "rule" {
    for_each = var.expire_after_days > 0 ? [1] : []
    content {
      id     = "expire-current"
      status = "Enabled"
      expiration {
        days = var.expire_after_days
      }
    }
  }
}

# Optional SSM parameters for reuse
resource "aws_ssm_parameter" "bucket_name" {
  count     = var.create_ssm_params ? 1 : 0
  name      = "${var.ssm_path_prefix}/${var.environment}/s3/${var.name}/bucket_name"
  type      = "String"
  value     = aws_s3_bucket.this.bucket
  overwrite = true
  tags      = var.tags
}

resource "aws_ssm_parameter" "bucket_arn" {
  count     = var.create_ssm_params ? 1 : 0
  name      = "${var.ssm_path_prefix}/${var.environment}/s3/${var.name}/bucket_arn"
  type      = "String"
  value     = aws_s3_bucket.this.arn
  overwrite = true
  tags      = var.tags
}
