env_name    = "dev"
region      = "ap-south-1"
nlb_name = "dev-nlb"

network_state_key = "dev/platform-main/network/terraform.tfstate"
compute_state_key = "dev/platform-main/compute/terraform.tfstate"

# NLB config
ports = []

internal   = true
ssm_prefix = "/platform-main/nlb/dev"

common_tags = {
  Environment = "dev"
  Project     = "platform-main"
}
