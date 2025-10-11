locals {
  tags = merge(
    {
      "user:Project" = "Platform-Main"
      "user:Env"     = var.env_name
      "user:Stack"   = "ecr"
      "Project"      = "platform-main"
      "Environment"  = var.env_name
    },
    var.tags
  )
}

# --- Create one ECR repo per entry in var.repositories (key => repo name) ---
module "repo" {
  source = "../../modules/ecr"

  for_each = var.repositories

  name                  = each.value
  image_tag_mutability  = var.image_tag_mutability
  scan_on_push          = var.scan_on_push
  encryption_type       = var.encryption_type
  lifecycle_policy_json = var.lifecycle_policy_json
  tags                  = local.tags
}

# --- Helpful local to expose a compact map of repo info back to the stack ---
locals {
  repo_info = {
    for k, m in module.repo : k => {
      name = m.repository_name
      url  = m.repository_url
      arn  = m.repository_arn
    }
  }
}
