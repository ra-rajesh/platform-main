module "cloudwatch" {
  source = "../../modules/cloudwatch"

  env_name               = var.env_name
  region                 = var.region
  apps                   = var.apps
  log_group_prefix       = var.log_group_prefix
  cwagent_ssm_param_path = var.cwagent_ssm_param_path
  instance_tag_value     = var.instance_tag_value
  retention_in_days      = var.retention_in_days
  system_log_files       = var.system_log_files
  tags                   = var.tags
}
