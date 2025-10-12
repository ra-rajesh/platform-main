variable "env_name" {
  type = string
}

variable "region" {
  type = string
}

# Keep in sync with your compute stack's tfvars (already set there)
variable "cwagent_ssm_param_path" {
  type = string
}

# Add/remove apps here to create more per-app groups
variable "apps" {
  type        = list(string)
  description = "Application names to create log groups for"
}

variable "retention_in_days" {
  type    = number
  default = 14
}
