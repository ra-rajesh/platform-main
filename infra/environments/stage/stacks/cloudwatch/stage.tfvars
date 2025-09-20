env_name       = "stage"
region         = "ap-south-1"
nlb_ssm_prefix = "/idlms/nlb/stage"
use_ssm = true

alert_email       = "" # e.g., "you@domain.com" (leave empty to skip email sub)
instance_name_tag = "stage-idlms-ec2"

api_name  = "idlms-api"
api_stage = "stage"

common_tags = {
  Environment = "stage"
  Project     = "IDLMS"
}

use_ssm = true
