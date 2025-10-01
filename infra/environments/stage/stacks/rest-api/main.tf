module "rest_api" {
  source = "../../../../platform/container/rest-api"

  env_name    = var.env_name
  region      = var.region
  api_name    = var.api_name
  stage_name  = var.stage_name
  description = var.description

  # reads NLB attributes (dns, zone id, listener arns, etc.) via SSM
  nlb_ssm_prefix = var.nlb_ssm_prefix

  # path -> port mapping (and optional health_path)
  routes = var.routes

  endpoint_type = var.endpoint_type

  access_log_retention_days = var.access_log_retention_days
  enable_execution_logs     = var.enable_execution_logs
  execution_metrics_enabled = var.execution_metrics_enabled
  execution_data_trace      = var.execution_data_trace

  tags = var.tags
}
