env_name = "stage"
region   = "ap-south-1"

tf_state_bucket = "stage-btl-idlms-repo-backend-api-tfstate-592776312448"
tf_state_region = "ap-south-1"

network_state_key = "stage/network/terraform.tfstate"
compute_state_key = "stage/compute/terraform.tfstate"

# NLB config
ports = [4000, 4010]

internal = true

# ssm_prefix = "/idlms/nlb/stage"
ssm_prefix = ""
common_tags = {
  Environment = "stage"
  Project     = "IDLMS"
}
