locals {
  tags = merge(
    {
      "user:Project" = "Platform-Main"
      "user:Env"     = var.env_name
      "user:Stack"   = "ecr"
      "Environment"  = var.env_name
    },
    var.tags
  )
}

module "ecr" {
  source = "../../../../platform/container/ecr"

  env_name = var.env_name
  region   = var.region

  repositories          = var.repositories
  image_tag_mutability  = var.image_tag_mutability
  scan_on_push          = var.scan_on_push
  encryption_type       = var.encryption_type
  lifecycle_policy_json = var.lifecycle_policy_json

  ssm_prefix = var.ssm_prefix
  tags       = local.tags
}
