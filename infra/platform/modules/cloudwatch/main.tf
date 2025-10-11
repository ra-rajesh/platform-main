terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = { source = "hashicorp/aws", version = ">= 5.0" }
  }
}
locals {
  tags = merge({
    "Environment"  = var.env_name
    "Project"      = "platform_main"
    "user:Project" = "platform_main"
    "user:Env"     = var.env_name
    "user:Stack"   = "cloudwatch"
  }, var.tags)

  instance_name    = coalesce(var.instance_tag_value, "${var.env_name}-compute")
  system_log_group = "/${var.env_name}/platform_main/ec2/${local.instance_name}/system"

  cwagent_config = {
    logs = {
      logs_collected = {
        files = {
          collect_list = [
            for f in var.system_log_files : {
              file_path       = f
              log_group_name  = local.system_log_group
              log_stream_name = "{instance_id}"
            }
          ]
        }
      }
    }
    metrics = {
      append_dimensions = {
        AutoScalingGroupName = "$${aws:AutoScalingGroupName}"
        InstanceId           = "$${aws:InstanceId}"
      }
      metrics_collected = {
        cpu = {
          resources                   = ["*"]
          measurement                 = ["cpu_usage_idle", "cpu_usage_iowait", "cpu_usage_user", "cpu_usage_system"]
          totalcpu                    = true
          metrics_collection_interval = 60
        }
        mem = {
          measurement                 = ["mem_used_percent"]
          metrics_collection_interval = 60
        }
        disk = {
          resources                   = ["*"]
          measurement                 = ["used_percent"]
          metrics_collection_interval = 60
        }
        netstat = { metrics_collection_interval = 60 }
      }
    }
  }
}


# Per-app log groups for container stdout/stderr
resource "aws_cloudwatch_log_group" "app" {
  for_each          = toset(var.apps)
  name              = "${var.log_group_prefix}/${each.key}/app"
  retention_in_days = var.retention_in_days
  tags              = local.tags
}

# EC2 system log group (for syslog/auth.log via agent)
resource "aws_cloudwatch_log_group" "system" {
  name              = local.system_log_group
  retention_in_days = var.retention_in_days
  tags              = local.tags
}

# CloudWatch Agent config stored in SSM (your EC2 user-data fetches from here)
resource "aws_ssm_parameter" "cwagent_config" {
  name      = var.cwagent_ssm_param_path
  type      = "String"
  overwrite = true
  value     = jsonencode(local.cwagent_config)
}
