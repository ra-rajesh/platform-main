module "ecr" {
  source = "../../../../platform/container/ecr"

  env_name             = var.env_name
  repositories         = var.repositories
  prefix_with_env      = var.prefix_with_env
  image_tag_mutability = var.image_tag_mutability
  scan_on_push         = var.scan_on_push
  force_delete         = var.force_delete
  tags                 = var.tags

  # Be explicit: never publish to SSM
  ssm_prefix = ""
}
