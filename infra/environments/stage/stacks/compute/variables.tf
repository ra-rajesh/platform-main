variable "env_name" {
  type        = string
  description = "Environment name (e.g., dev/stage/prod)"
}

variable "region" {
  type        = string
  description = "AWS region (e.g., ap-south-1)"
}

# Remote network state (to read VPC/subnets)
variable "tf_state_bucket" {
  type        = string
  description = "S3 bucket name where the network state is stored"
}

variable "network_state_key" {
  type        = string
  description = "S3 key (path) to the network state file"
}

variable "remote_state_region" {
  type        = string
  default     = null
  description = "Region of the remote state bucket (defaults to var.region when null)"
}

# Networking
variable "ingress_cidrs" {
  type        = list(string)
  description = "IPv4 CIDRs allowed inbound for the listed ports"
}

# Compute settings
variable "ec2_name" {
  type        = string
  description = "Name tag for the EC2 instance"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type (e.g., t3.medium)"
}

variable "app_ports" {
  type        = list(number)
  description = "Application ports to open on the instance SG"
}

variable "key_name" {
  type        = string
  description = "EC2 key pair name"
}

# AMI selection (use one: ami_id OR ami_ssm_parameter_name)
variable "ami_id" {
  type        = string
  default     = null
  description = "Explicit AMI ID to use (set this OR ami_ssm_parameter_name)"
}

variable "ami_ssm_parameter_name" {
  type        = string
  default     = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-6.1-x86_64"
  description = "SSM parameter path that holds the AMI ID (set this OR ami_id)"
}
variable "cloudwatch_ssm_config_path" {
  type        = string
  description = "SSM path to CloudWatch agent config (e.g., /idlms/shared/stage/cloudwatch-config)"
}

variable "docker_artifact_bucket" {
  type        = string
  description = "S3 bucket that holds docker-compose.yml and any artifacts"
}
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
