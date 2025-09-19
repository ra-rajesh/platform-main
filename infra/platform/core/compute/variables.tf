variable "env_name" { type = string }
variable "region" { type = string }

# network inputs
variable "vpc_id" { type = string }
variable "private_subnet_ids" { type = list(string) }

# instance settings
variable "ec2_name" { type = string }
variable "instance_type" { type = string }
variable "key_name" { type = string }
variable "app_ports" { type = list(number) }
variable "ingress_cidrs" {
  type        = list(string)
  description = "IPv4 CIDRs allowed inbound for the listed ports"
}

# AMI: either set ami_id OR leave it null to use the SSM param below
variable "ami_id" {
  type    = string
  default = null
}
variable "ami_ssm_parameter_name" {
  type    = string
  default = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-6.1-x86_64"
}

# agents/config/artifacts
variable "cloudwatch_ssm_config_path" { type = string }
variable "docker_artifact_bucket" {
  type    = string
  default = null
}

# reuse existing IAM names (or module will create)
variable "existing_iam_role_name" {
  type    = string
  default = null
}
variable "existing_instance_profile_name" {
  type    = string
  default = null
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "user_data" {
  type    = string
  default = ""
}
variable "ec2_ssm_role_name" {
  type    = string
  default = null
}
variable "ec2_ssm_profile_name" {
  type    = string
  default = null
}
