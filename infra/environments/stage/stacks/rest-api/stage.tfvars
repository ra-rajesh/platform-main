env_name = "stage"
region   = "ap-south-1"

# Must match your NLB SSM writer
# e.g., if your NLB stack stored:
#   /platform/stage/nlb/lb_arn
#   /platform/stage/nlb/lb_dns_name
nlb_ssm_prefix = "/idlms/nlb/stage"

# Optional overrides
api_name      = "idlms-api"
stage_name    = "stage"
endpoint_type = "REGIONAL"

routes = {
  "idlms-reuse" = { port = 4000 }
  "idlms-test"  = { port = 4010 }
}

tags = { env = "stage", team = "idlms" }
