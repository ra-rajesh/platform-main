module "ssm" {
  source = "../../modules/ssm"

  path_prefix = var.path_prefix
  values      = var.values
  overwrite   = var.overwrite
  common_tags = var.common_tags
}
