env_name = "stage"
region   = "ap-south-1"

tf_state_bucket = "stage-btl-idlms-backend-api-tfstate-881490099206"
tf_state_region = "ap-south-1"

network_state_key = "stage/network/terraform.tfstate"
compute_state_key = "stage/compute/terraform.tfstate"

# NLB config
ports = [4000, 4001, 4002, 4010]

internal = true

# Publish NLB details to SSM
ssm_prefix = "/idlms/nlb/stage"

common_tags = {
  Environment = "stage"
  Project     = "IDLMS"
}
