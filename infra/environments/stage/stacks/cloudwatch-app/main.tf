
module "cloudwatch_app" {
  source = "../../../../platform/container/cloudwatch"

  env_name              = var.env_name
  region                = var.region
  ssm_param_name        = var.ssm_param_name
  docker_log_group_name = var.docker_log_group_name
  log_stream_name       = var.log_stream_name
  docker_log_file_path  = var.docker_log_file_path
  tags                  = var.tags
}
