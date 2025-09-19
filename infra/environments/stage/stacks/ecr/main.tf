module "ecr" {
  source = "../../../../platform/container/ecr"

  env_name             = var.env_name
  repositories         = var.repositories
  prefix_with_env      = var.prefix_with_env
  image_tag_mutability = var.image_tag_mutability
  scan_on_push         = var.scan_on_push
  force_delete         = var.force_delete
  tags                 = var.tags
}

# Publish repo details to SSM so IDLMS CI can discover by logical name.
locals {
  _repo_indexes = { for idx, name in var.repositories : name => idx }
}

resource "aws_ssm_parameter" "repo_url" {
  for_each = local._repo_indexes
  name     = "/idlms/ecr/${var.env_name}/${each.key}/repository_url"
  type     = "String"
  value    = module.ecr.repository_urls[each.value]
}

resource "aws_ssm_parameter" "repo_arn" {
  for_each = local._repo_indexes
  name     = "/idlms/ecr/${var.env_name}/${each.key}/repository_arn"
  type     = "String"
  value    = module.ecr.repository_arns[each.value]
}

resource "aws_ssm_parameter" "repo_name" {
  for_each = local._repo_indexes
  name     = "/idlms/ecr/${var.env_name}/${each.key}/repository_name"
  type     = "String"
  value    = module.ecr.repository_names[each.value]
}
