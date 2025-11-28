variable "env_name" {
  type        = string
  description = "Environment name (e.g., dev, stage, prod)"
}

variable "region" {
  type        = string
  description = "AWS region (e.g., ap-south-1)"
}

# Network inputs
variable "vpc_id" {
  type        = string
  description = "VPC ID where resources will be created"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Private subnet IDs for the instance"
}

# Instance settings
variable "ec2_name" {
  type        = string
  description = "Name tag for the EC2 instance"
}

variable "sg_name" {
  type        = string
  description = "Security group name"
}

variable "user_data" {
  type        = string
  default     = null
  description = "Optional plain-text user_data for EC2; null/empty to omit or use module default."
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type (e.g., t3.small)"
}

variable "key_name" {
  type        = string
  description = "Existing EC2 key pair name"
}

variable "app_ports" {
  type        = list(number)
  description = "Application ports the instance listens on (e.g., [3000, 4000])"
}

variable "ingress_cidrs" {
  type        = list(string)
  description = "IPv4 CIDRs allowed inbound for the listed ports"
}

# AMI: either set ami_id OR leave it null to use the SSM param below
variable "ami_id" {
  type        = string
  default     = null
  description = "Optional explicit AMI ID (e.g., ami-xxxxxxxx); if null, the SSM parameter is used."
}

variable "ami_ssm_parameter_name" {
  type        = string
  default     = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-6.1-x86_64"
  description = "SSM parameter name that resolves to the AMI ID if ami_id is null."
}

variable "cloudwatch_ssm_config_path" {
  type        = string
  description = "SSM Parameter Store path containing CloudWatch Agent JSON (e.g., /idlms/cloudwatch/stage/agent-config)"
}

variable "docker_artifact_bucket" {
  type        = string
  default     = null
  description = "Optional S3 bucket for Docker artifacts/backups; null to skip."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Common tags applied to all resources"
}

variable "ssm_parameter_arns" {
  type        = list(string)
  default     = null
  description = "Optional list of SSM Parameter ARNs the instance may read"
}

variable "s3_backup_arn" {
  description = "Optional ARN like arn:aws:s3:::<bucket>/docker/* to allow S3 read"
  type        = string
  default     = ""
}

variable "tf_state_region" {
  type        = string
  description = "Region of the S3 bucket/DynamoDB used for remote state and lock"
}

variable "network_state_key" {
  type        = string
  description = "Object key (path) to the NETWORK stack's state file in the bucket"
}

variable "allow_no_ingress" {
  type        = bool
  description = "If true, allows app_ports to be empty (no inbound rules)."
  default     = false
}

variable "ec2_ssm_role_name" {
  type = string
}

variable "ec2_ssm_profile_name" {
  type = string
}

