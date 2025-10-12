env_name           = "stage"
region             = "ap-south-1"
base_prefix        = "/platform-main"
overwrite          = true
network_state_key  = "prod/platform-main/network/terraform.tfstate"
compute_state_key  = "prod/platform-main/compute/terraform.tfstate"
nlb_state_key      = "prod/platform-main/nlb/terraform.tfstate"
rest_api_state_key = "prod/platform-main/rest-api/terraform.tfstate"
