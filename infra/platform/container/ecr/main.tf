locals {
  repo_names = var.prefix_with_env ? [for r in var.repositories : "${var.env_name}-${r}"] : var.repositories
}

module "repo" {
  for_each = toset(local.repo_names)
  source   = "../../modules/ecr"

  name                 = each.value
  image_tag_mutability = var.image_tag_mutability
  scan_on_push         = var.scan_on_push
  force_delete         = var.force_delete
  tags                 = merge(var.tags, { Environment = var.env_name })
}

locals {
  repository_urls = [for n in local.repo_names : module.repo[n].repository_url]
  repository_arns = [for n in local.repo_names : module.repo[n].repository_arn]
}

# Map logical repo -> actual repo name (with env prefix if enabled)
locals {
  repo_map = {
    for idx, logical in var.repositories :
    logical => local.repo_names[idx]
  }
}

# When ssm_prefix is set, publish per-repo details using logical names for the key
resource "aws_ssm_parameter" "repo_url" {
  for_each = var.ssm_prefix == "" ? {} : { for n in var.repositories : n => n }
  name  = "${var.ssm_prefix}/${each.key}/repository_url"
  type  = "String"
  value = module.repo[local.repo_map[each.key]].repository_url
}

resource "aws_ssm_parameter" "repo_arn" {
  for_each = var.ssm_prefix == "" ? {} : { for n in var.repositories : n => n }
  name  = "${var.ssm_prefix}/${each.key}/repository_arn"
  type  = "String"
  value = module.repo[local.repo_map[each.key]].repository_arn
}

resource "aws_ssm_parameter" "repo_name" {
  for_each = var.ssm_prefix == "" ? {} : { for n in var.repositories : n => n }
  name  = "${var.ssm_prefix}/${each.key}/repository_name"
  type  = "String"
  value = local.repo_map[each.key]
}
