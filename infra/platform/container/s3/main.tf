module "s3" {
  source = "../../modules/s3"

  environment            = var.environment
  name                   = var.name
  bucket_name_override   = var.bucket_name_override

  sse_algorithm          = var.sse_algorithm
  kms_key_id             = var.kms_key_id

  versioning             = var.versioning
  force_destroy          = var.force_destroy

  enable_ia_transition   = var.enable_ia_transition
  ia_after_days          = var.ia_after_days
  noncurrent_expire_days = var.noncurrent_expire_days
  expire_after_days      = var.expire_after_days

  create_ssm_params      = var.create_ssm_params
  ssm_path_prefix        = var.ssm_path_prefix

  tags                   = var.tags
}
