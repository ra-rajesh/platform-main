data "terraform_remote_state" "nlb" {
  backend = "s3"
  config = {
    bucket = var.tf_state_bucket
    key    = var.nlb_state_key
    region = var.tf_state_region
  }
}

module "rest_api" {
  source      = "../../../../platform/container/rest-api"
  env_name    = var.env_name
  region      = var.region
  api_name    = var.api_name
  stage_name  = var.stage_name
  description = var.description

  # Pass NLB directly
  nlb_arn      = data.terraform_remote_state.nlb.outputs.lb_arn
  nlb_dns_name = data.terraform_remote_state.nlb.outputs.lb_dns_name

  routes        = var.routes
  endpoint_type = var.endpoint_type

  enable_execution_logs     = var.enable_execution_logs
  execution_metrics_enabled = var.execution_metrics_enabled
  execution_data_trace      = var.execution_data_trace
  access_log_retention_days = var.access_log_retention_days
  tags                      = var.tags
}
