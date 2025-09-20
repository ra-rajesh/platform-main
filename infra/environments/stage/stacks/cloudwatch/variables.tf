variable "env_name" {
  type = string
}

variable "region" {
  type = string
}

variable "nlb_ssm_prefix" {
  type = string # e.g. /idlms/nlb/stage
}

variable "alert_email" {
  description = "Email address to subscribe to SNS; leave blank to skip."
  type        = string
  default     = ""
}

variable "instance_name_tag" {
  description = "Value of the Name tag to find your app instance (e.g., stage-idlms-ec2)"
  type        = string
}

variable "api_name" {
  type    = string
  default = "idlms-api"
}

variable "api_stage" {
  type    = string
  default = "stage"
}

variable "common_tags" {
  type    = map(string)
  default = {}
}

# Controls whether we read NLB/TG info from SSM or use overrides.
variable "use_ssm" {
  type    = bool
  default = true
}

# If use_ssm = false, set these overrides:
variable "lb_arn_override" {
  type    = string
  default = ""
}

variable "tg_arns_json_override" {
  type    = string
  default = ""
}
