module "rest_api" {
  source = "../../../../platform/container/rest-api"

  env_name    = var.env_name
  region      = var.region
  api_name    = var.api_name
  stage_name  = var.stage_name
  description = var.description

  nlb_ssm_prefix = var.nlb_ssm_prefix
  port           = var.port
  endpoint_type  = var.endpoint_type

  access_log_retention_days = var.access_log_retention_days
  enable_execution_logs     = var.enable_execution_logs

  tags = var.tags
}

output "rest_api_id" { value = module.rest_api.rest_api_id }
output "invoke_url" { value = module.rest_api.invoke_url }
output "vpc_link_id" { value = module.rest_api.vpc_link_id }
output "access_log_group" { value = module.rest_api.access_log_group }
output "stage_name" { value = module.rest_api.stage_name }
