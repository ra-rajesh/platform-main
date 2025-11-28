region     = "ap-south-1"
env_name   = "stage"
api_name   = "apigateway"
stage_name = "stage"

routes        = {}
endpoint_type = "REGIONAL"

create_stage_and_deployment = true
seed_stage_with_mock        = true
seed_path                   = "health"
enable_execution_logs       = true
execution_metrics_enabled   = true
execution_data_trace        = false

# retention for both access + execution log groups
access_log_retention_days = 30

# nlb_ssm_prefix = "/platform-main/nlb"

tags = {
  Environment = "stage"
  Project     = "platform-main"
  Stack       = "rest-api"
}
