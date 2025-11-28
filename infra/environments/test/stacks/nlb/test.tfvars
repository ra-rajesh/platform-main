env_name    = "test"
region      = "eu-north-1"
nlb_name = "test-nlb"

network_state_key = "test/platform-main/network/terraform.tfstate"
compute_state_key = "test/platform-main/compute/terraform.tfstate"

# NLB config
ports = []

internal   = true
ssm_prefix = "/platform-main/nlb/test"

common_tags = {
  Environment = "test"
  Project     = "platform-main"
}
