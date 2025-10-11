variable "env_name" {
  type = string
}

variable "region" {
  type = string
}

variable "apps" {
  type = list(string)
}

variable "log_group_prefix" {
  type = string
}

variable "cwagent_ssm_param_path" {
  type = string
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
