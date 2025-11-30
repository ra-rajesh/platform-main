env_name    = "test-1"
region      = "eu-north-1"
nlb_name = "test-1-nlb"

network_state_key = "test-1/platform-main/network/terraform.tfstate"
compute_state_key = "test-1/platform-main/compute/terraform.tfstate"

# NLB config
ports = []

internal   = true
ssm_prefix = "/platform-main/nlb/test-1"

common_tags = {
  Environment = "test-1"
  Project     = "platform-main"
}
