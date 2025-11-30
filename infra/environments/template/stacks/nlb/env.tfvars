env_name    = "{{env.name}}"
region      = "{{aws.region}}"
nlb_name = "{{env.name}}-nlb"

network_state_key = "{{env.name}}/platform-main/network/terraform.tfstate"
compute_state_key = "{{env.name}}/platform-main/compute/terraform.tfstate"

# NLB config
ports = []

internal   = true
ssm_prefix = "/platform-main/nlb/{{env.name}}"

common_tags = {
  Environment = "{{env.name}}"
  Project     = "platform-main"
}
