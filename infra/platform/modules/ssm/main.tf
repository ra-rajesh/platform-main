terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.11"
    }
  }
}

# Trim and drop empty strings so SSM PutParameter doesn't error
locals {
  values_trimmed  = { for k, v in var.values : k => trimspace(v) }
  values_nonempty = { for k, v in local.values_trimmed : k => v if length(v) > 0 }
}

resource "aws_ssm_parameter" "kv" {
  for_each       = local.values_nonempty
  name           = "${var.path_prefix}/${each.key}"
  type           = "String"
  insecure_value = each.value
  overwrite      = var.overwrite
  tags           = var.tags

  lifecycle {
    ignore_changes = [insecure_value]
  }
}
