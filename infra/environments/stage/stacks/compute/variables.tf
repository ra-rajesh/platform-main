variable "env_name" { type = string }
variable "region" { type = string }

# remote network state
variable "tf_state_bucket" { type = string }
variable "network_state_key" { type = string }
variable "remote_state_region" {
  type    = string
  default = null
}
variable "ingress_cidrs" {
  type        = list(string)
  description = "IPv4 CIDRs allowed inbound for the listed ports"
}
# compute settings
variable "ec2_name" { type = string }
variable "instance_type" { type = string }
variable "app_ports" { type = list(number) }
variable "key_name" { type = string }

variable "ami_id" {
  type    = string
  default = null
}
variable "ami_ssm_parameter_name" {
  type    = string
  default = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-6.1-x86_64"
}

variable "cloudwatch_ssm_config_path" { type = string }
variable "docker_artifact_bucket" { type = string }

# reuse IAM (OPTIONAL now)
variable "ec2_ssm_role_name" {
  type    = string
  default = null
}
variable "ec2_ssm_profile_name" {
  type    = string
  default = null
}

variable "tags" {
  type    = map(string)
  default = {}
}

# Ports to expose on the NLB. If empty, app_ports will be used.
variable "nlb_ports" {
  type    = list(number)
  default = []
}
