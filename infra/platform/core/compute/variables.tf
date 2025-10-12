variable "region" {
  type = string
}

variable "env_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
  validation {
    condition     = length(var.private_subnet_ids) > 0
    error_message = "private_subnet_ids must contain at least one subnet ID."
  }
}

variable "ec2_name" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "key_name" {
  type    = string
  default = null
}

variable "ami_id" {
  type    = string
  default = null
}

variable "ami_ssm_parameter_name" {
  type = string
}

variable "sg_name" {
  type = string
}

variable "app_ports" {
  type    = list(number)
  default = []
  # Allow empty. If provided, validate the range.
  validation {
    condition     = alltrue([for p in var.app_ports : p >= 1 && p <= 65535])
    error_message = "app_ports must contain valid TCP ports (1-65535) when provided."
  }
}
variable "ingress_cidrs" {
  type    = list(string)
  default = []
}

variable "tags" {
  type    = map(string)
  default = {}
}

# IAM reuse knobs (leave null to auto-create env-prefixed names)
variable "ec2_ssm_role_name" {
  type    = string
  default = null
}

variable "ec2_ssm_profile_name" {
  type    = string
  default = null
}

variable "s3_backup_arn" {
  type    = string
  default = ""
}

variable "cloudwatch_ssm_config_path" {
  type = string
}

variable "user_data" {
  type    = string
  default = ""
}
