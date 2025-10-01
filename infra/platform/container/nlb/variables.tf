variable "env_name" {
  type = string
}

variable "name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "internal" {
  type    = bool
  default = true
}

variable "cross_zone" {
  type    = bool
  default = true
}

variable "protocol" {
  type    = string
  default = "TCP"
}

variable "ports" {
  type = list(number)
}

variable "target_instance_ids" {
  type = list(string)
}

variable "hc_protocol" {
  type    = string
  default = ""
}

variable "hc_interval" {
  type    = number
  default = 10
}

variable "hc_timeout" {
  type    = number
  default = 6
}

variable "hc_healthy_threshold" {
  type    = number
  default = 3
}

variable "hc_unhealthy_threshold" {
  type    = number
  default = 3
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "ssm_prefix" {
  type        = string
  default     = ""
  description = "If set, write lb_arn/lb_dns_name/lb_zone_id to this SSM path"
}
