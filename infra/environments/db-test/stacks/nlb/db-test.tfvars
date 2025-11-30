env_name    = "db-test"
region      = "us-east-1"
nlb_name = "db-test-nlb"

network_state_key = "db-test/platform-main/network/terraform.tfstate"
compute_state_key = "db-test/platform-main/compute/terraform.tfstate"

# NLB config
ports = []

internal   = true
ssm_prefix = "/platform-main/nlb/db-test"

common_tags = {
  Environment = "db-test"
  Project     = "platform-main"
}
