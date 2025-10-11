variable "env_name" {
  type = string
}

# e.g. "/platform-main"
variable "base_prefix" {
  type = string
}

variable "overwrite" {
  type    = bool
  default = true
}

variable "tags" {
  type = map(string)
  default = {
    Project     = "platform-main"
    Environment = "stage"
  }
}

# Network
variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

# Compute
variable "instance_id" {
  type = string
}

variable "instance_private_ip" {
  type = string
}

variable "iam_role_name" {
  type = string
}

variable "instance_profile_name" {
  type = string
}

variable "lb_dns_name" {
  type = string
}

variable "lb_zone_id" {
  type = string
}

variable "listener_arns" {
  type = map(string)
}

variable "target_group_arns" {
  type = map(string)
}

# REST API (may be empty; module filters empty values)
variable "rest_api_id" {
  type    = string
  default = ""
}

variable "vpc_link_id" {
  type    = string
  default = ""
}

variable "invoke_url" {
  type    = string
  default = ""
}
