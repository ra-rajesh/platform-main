locals {
  full_name = "${var.param_root}/${var.app_name}/${var.env_name}/.env"

  # pick env_value first if provided, else read from file
  resolved_value = (
    var.env_value != null && trim(var.env_value) != "" ?
    var.env_value :
    (var.env_file_path != null ? file(var.env_file_path) : "")
  )
}

# simple guard: require at least one source
locals {
  _validate = length(trim(local.resolved_value)) > 0 ? 1 : (
    throw("Provide either var.env_value or var.env_file_path with non-empty content")
  )
}

resource "aws_ssm_parameter" "env" {
  name        = local.full_name
  description = "App .env for ${var.app_name} (${var.env_name})"
  type        = "SecureString"
  value       = local.resolved_value

  tags = merge(
    {
      App         = var.app_name
      Environment = var.env_name
      ManagedBy   = "Terraform"
    },
    var.tags
  )
}
