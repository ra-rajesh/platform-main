terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# Docker logs log group
resource "aws_cloudwatch_log_group" "docker" {
  name              = var.docker_log_group_name
  retention_in_days = 30
  tags              = merge({ Environment = var.env_name }, var.tags)
}

# CloudWatch Agent configuration (used only if you set ssm_param_name != "")
locals {
  cwagent_config = {
    logs = {
      logs_collected = {
        files = {
          collect_list = [
            {
              file_path       = var.docker_log_file_path
              log_group_name  = var.docker_log_group_name
              log_stream_name = var.log_stream_name
              timezone        = "UTC"
            }
          ]
        }
      }
    }
    metrics = {
      append_dimensions = {}
    }
  }
}

# Optional SSM parameter for the cwagent config (disabled when ssm_param_name = "")
resource "aws_ssm_parameter" "agent_config" {
  count       = var.ssm_param_name == "" ? 0 : 1
  name        = var.ssm_param_name
  description = "CloudWatch Agent config for ${var.env_name}"
  type        = "String"
  value       = jsonencode(local.cwagent_config)
  overwrite   = true
  tags        = merge({ Environment = var.env_name }, var.tags)
}

output "docker_log_group_name" {
  value = aws_cloudwatch_log_group.docker.name
}

output "ssm_param_name" {
  value = var.ssm_param_name
}
