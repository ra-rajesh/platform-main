locals {
  log_group_prefix = "/${var.env_name}/platform_main/apps"
  tags = {
    Environment = var.env_name
    Project     = "platform_main"
    Stack       = "cloudwatch"
  }
}

module "cloudwatch" {
  source = "../../../../platform/container/cloudwatch"

  env_name               = var.env_name
  region                 = var.region
  apps                   = var.apps
  log_group_prefix       = local.log_group_prefix
  cwagent_ssm_param_path = var.cwagent_ssm_param_path
  instance_tag_value     = "${var.env_name}-compute"
  retention_in_days      = var.retention_in_days
  tags                   = local.tags
  system_log_files       = ["/var/log/syslog", "/var/log/auth.log"]
}
