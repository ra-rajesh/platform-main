variable "env_name" { type = string }
variable "region" { type = string }

variable "tf_state_bucket" { type = string }
variable "tf_state_region" { type = string }

variable "ports" {
  type = list(number)
}

variable "internal" {
  type    = bool
  default = true
}

variable "lb_create_sg" {
  type    = bool
  default = true
}

variable "additional_ports" {
  type    = list(number)
  default = []
}

variable "target_instance_ids" {
  type    = list(string)
  default = []
}

variable "common_tags" {
  type    = map(string)
  default = {}
}

variable "ssm_prefix" {
  type    = string
  default = ""
}

variable "network_state_key" { type = string }
variable "compute_state_key" { type = string }
