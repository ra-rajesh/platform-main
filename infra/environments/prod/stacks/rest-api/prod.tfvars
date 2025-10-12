region    = "ap-south-1"
env_name  = "prod"
api_name  = "apigateway"
prod_name = "prod"

routes = {}


# keep as REGIONAL unless you have a custom edge requirement
endpoint_type = "REGIONAL"

# logging knobs (keep your previous values if you had them)
access_log_retention_days = 30
enable_execution_logs     = true
execution_metrics_enabled = true
execution_data_trace      = false

tags = {
  Environment = "prod"
  Project     = "platform-main"
  Stack       = "rest-api"
}
