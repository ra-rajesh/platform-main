env_name = "stage"
region   = "ap-south-1"
nlb_name = "stage-platform-main-nlb"

network_state_key = "stage/platform-main/network/terraform.tfstate"
compute_state_key = "stage/platform-main/compute/terraform.tfstate"

# NLB config
ports = []

internal   = true
ssm_prefix = "/platform-main/nlb/stage"

common_tags = {
  Environment = "stage"
  Project     = "platform-main"
}
