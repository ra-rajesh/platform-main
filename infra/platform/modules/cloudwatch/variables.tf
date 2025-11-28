variable "env_name" {
  type = string
}

variable "region" {
  type = string
}

# Apps you want per-app log groups for, e.g. ["idlms-app","vitalreg-app"]
variable "apps" {
  type        = list(string)
  default     = []
  description = "Application names to create log groups for"
}

variable "log_group_prefix" {
  type        = string
  description = "Base prefix for app log groups"
}

variable "cwagent_ssm_param_path" {
  type        = string
  description = "SSM path where the CW Agent config JSON is stored"
}

variable "instance_tag_value" {
  type    = string
  default = null
}

variable "retention_in_days" {
  type    = number
  default = 14
}

variable "system_log_files" {
  type    = list(string)
  default = ["/var/log/syslog", "/var/log/auth.log"]
}

variable "tags" {
  type    = map(string)
  default = {}
}
