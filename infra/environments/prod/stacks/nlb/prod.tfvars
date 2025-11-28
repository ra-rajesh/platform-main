env_name    = "prod"
region      = "ap-south-1"
nlb_name = "prod-nlb"

network_state_key = "prod/platform-main/network/terraform.tfstate"
compute_state_key = "prod/platform-main/compute/terraform.tfstate"

# NLB config
ports = []

internal   = true
ssm_prefix = "/platform-main/nlb/prod"

common_tags = {
  Environment = "prod"
  Project     = "platform-main"
}
