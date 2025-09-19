module "cloudwatch" {
  source = "../../../../platform/container/cloudwatch"

  env_name = var.env_name
  region   = var.region

  nlb_ssm_prefix = var.nlb_ssm_prefix

  rest_state_bucket = var.rest_state_bucket
  rest_state_region = var.rest_state_region
  rest_state_key    = var.rest_state_key

  port          = var.port
  alarm_actions = var.alarm_actions

  tags = merge({ Environment = var.env_name, Project = "IDLMS" }, var.tags)
}

output "dashboard_name" { value = module.cloudwatch.dashboard_name }
