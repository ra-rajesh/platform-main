terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}


resource "aws_ssm_parameter" "this" {
  for_each = var.values

  name        = "${var.path_prefix}/${each.key}"
  type        = "String"
  value       = each.value
  overwrite   = var.overwrite
  description = "Published by Terraform"
  tags        = var.common_tags
}
