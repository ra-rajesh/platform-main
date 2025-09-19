# Reusable CloudWatch wrapper for IDLMS

variable "env_name" {
  type = string
}

variable "region" {
  type = string
}

# NLB info written by your NLB->SSM stack
# Example: "/idlms/nlb/stage"
variable "nlb_ssm_prefix" {
  type = string
}

# Remote state of the REST API stack (to fetch REST API name + stage)
variable "rest_state_bucket" {
  type = string
}

variable "rest_state_region" {
  type = string
}

variable "rest_state_key" {
  type = string
}

# Which port to watch on the NLB (must exist in target_group_arns SSM map)
variable "port" {
  type    = number
  default = 4000
}

# Optional: SNS topic ARNs that receive alarm notifications
variable "alarm_actions" {
  type    = list(string)
  default = []
}

# Optional tags applied to alarms (not the dashboard)
variable "tags" {
  type    = map(string)
  default = {}
}
