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

# e.g. "/stage/platform_main/apps"
variable "log_group_prefix" {
  type        = string
  description = "Base prefix for app log groups"
}

# e.g. "/stage/platform_main/cloudwatch/agent-config"
variable "cwagent_ssm_param_path" {
  type        = string
  description = "SSM path where the CW Agent config JSON is stored"
}

# instance Name tag value (used only to name the EC2 system log group)
# we’ll default to "${env_name}-compute" if null
variable "instance_tag_value" {
  type    = string
  default = null
}

variable "retention_in_days" {
  type    = number
  default = 14
}

# System files your agent should ship (stdout/errs go via awslogs driver)
variable "system_log_files" {
  type    = list(string)
  default = ["/var/log/syslog", "/var/log/auth.log"]
}

variable "tags" {
  type    = map(string)
  default = {}
}
