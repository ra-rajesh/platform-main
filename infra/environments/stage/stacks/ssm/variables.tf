variable "env_name" {
  type = string
}

variable "region" {
  type = string
}

# Where to write params, e.g., /idlms/nlb/stage (matches your existing convention)
variable "ssm_path_prefix" {
  type = string
}

# Remote state for the already-created NLB
variable "nlb_state_bucket" {
  type    = string
  default = "stage-btl-idlms-repo-backend-api-tfstate-592776312448"
}

variable "nlb_state_key" {
  type    = string
  default = "stage/nlb/terraform.tfstate" # change if you used a different key
}

variable "nlb_state_region" {
  type    = string
  default = "ap-south-1"
}

# Also create per-port convenience keys like tg_4000 and listener_4000
variable "include_per_port" {
  type    = bool
  default = true
}

# SSM options
variable "overwrite" {
  type    = bool
  default = true
}

variable "common_tags" {
  type    = map(string)
  default = {}
}
