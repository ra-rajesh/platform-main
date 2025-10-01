locals {
  apps_map = {
    for a in var.apps :
    a.name => {
      port = a.port
      env  = merge(var.shared_defaults, a.env)
    }
  }

  rendered_env = {
    for name, cfg in local.apps_map :
    name => join("\n", concat(
      [
        "APP_NAME=${name}",
        "APP_PORT=${cfg.port}",
      ],
      var.build_tag != null ? ["BUILD_TAG=${var.build_tag}"] : [],
      [for k in sort(keys(cfg.env)) : "${k}=${cfg.env[k]}"]
    ))
  }
}

resource "aws_ssm_parameter" "app_env" {
  for_each    = local.rendered_env
  name        = "${var.param_root}/${each.key}/${var.env_name}/.env"
  description = "App .env for ${each.key} (${var.env_name})"
  type        = "SecureString"
  value       = each.value
  tier        = "Standard"
  key_id      = var.kms_key_id
  tags = merge(
    {
      App         = each.key
      Environment = var.env_name
      ManagedBy   = "Terraform"
      Project     = "IDLMS"
    },
    var.common_tags
  )
}
