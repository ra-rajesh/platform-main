variable "name" {
  type        = string
  description = "Name tag for the instance"
}

variable "ami_id" {
  type        = string
  description = "AMI ID to use (Ubuntu AMI in your example)"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type (e.g., t3.micro)"
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID to launch into (typically a private subnet)"
}

variable "security_group_ids" {
  type        = list(string)
  description = "List of security group IDs"
}

variable "instance_profile_name" {
  type        = string
  description = "IAM instance profile NAME (e.g., ec2_ssm_profile)"
}

variable "key_name" {
  type        = string
  default     = null
  description = "Optional EC2 key pair name"
}

variable "associate_public_ip_address" {
  type        = bool
  default     = false
  description = "Whether to associate a public IP"
}

variable "cloudwatch_ssm_config_path" {
  type        = string
  description = "SSM Parameter path for CloudWatch Agent config (e.g., /idlms/cloudwatch/agent/config)"
}

variable "user_data" {
  type        = string
  default     = null
  description = "Optional custom user-data; if null, module uses a sane Ubuntu script"
}

variable "ec2_tags" {
  type        = map(string)
  default     = {}
  description = "Extra tags to apply to the instance"
}
