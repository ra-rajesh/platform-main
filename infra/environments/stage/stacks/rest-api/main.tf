module "rest_api" {
  source = "../../../../platform/container/rest-api"

  env_name    = var.env_name
  region      = var.region
  api_name    = var.api_name
  stage_name  = var.stage_name
  description = var.description

  nlb_ssm_prefix = var.nlb_ssm_prefix
  endpoint_type  = var.endpoint_type

  routes = var.routes

  access_log_retention_days = var.access_log_retention_days
  enable_execution_logs     = var.enable_execution_logs

  execution_metrics_enabled = var.execution_metrics_enabled
  execution_data_trace      = var.execution_data_trace

  tags = var.tags
}
