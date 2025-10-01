env_name = "stage"
region   = "ap-south-1"

api_name    = "idlms-api"
stage_name  = "stage"
description = "IDLMS REST API for stage"

# must match your NLB SSM path from the NLB stack
nlb_ssm_prefix = "/idlms/nlb/stage"

routes = {
  "idlms-app"    = { port = 4000, health_path = "/health" }
  "vitalreg-app" = { port = 4010, health_path = "/health" }
}

# keep as REGIONAL unless you have a custom edge requirement
endpoint_type = "REGIONAL"

# logging knobs (keep your previous values if you had them)
access_log_retention_days = 30
enable_execution_logs     = true
execution_metrics_enabled = true
execution_data_trace      = false

tags = {
  Environment = "stage"
  Project     = "IDLMS"
  Stack       = "rest-api"
}
