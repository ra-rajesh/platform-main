variable "env_name" {
  type        = string
  description = "Environment name (e.g., dev, stage, prod)"
}

variable "region" {
  type        = string
  description = "AWS region for all resources (e.g., ap-south-1)"
}

# --- Remote state wiring for NETWORK stack ---
variable "tf_state_bucket" {
  type        = string
  description = "S3 bucket that stores Terraform states (network & compute)."
}

variable "network_state_key" {
  type        = string
  description = "Object key for the NETWORK stack state in the bucket (e.g., stage/network/terraform.tfstate)"
}

variable "tf_state_region" {
  type        = string
  default     = null
  description = "Region for the state bucket/DynamoDB. If null, falls back to remote_state_region or region (see main.tf)."
}

variable "remote_state_region" {
  type        = string
  default     = null
  description = "Deprecated: use tf_state_region. Kept for compatibility."
}

variable "ingress_cidrs" {
  type        = list(string)
  description = "IPv4 CIDRs allowed inbound for the listed ports"
}

# --- Compute settings ---
variable "ec2_name" {
  type        = string
  description = "Name tag for the EC2 instance"
}

variable "sg_name" {
  type        = string
  description = "Security group name"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type (e.g., t3.small)"
}

variable "app_ports" {
  type        = list(number)
  description = "Application ports the instance listens on (e.g., [22, 3000])"
}

variable "key_name" {
  type        = string
  description = "Existing EC2 key pair name"
}

# --- AMI / SSM / CloudWatch ---
variable "ami_id" {
  type        = string
  default     = null
  description = "Optional explicit AMI ID; if null, the SSM parameter below is used"
}

variable "ami_ssm_parameter_name" {
  type        = string
  default     = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-6.1-x86_64"
  description = "SSM parameter name that provides the AMI ID when ami_id is null"
}

variable "cloudwatch_ssm_config_path" {
  type        = string
  description = "SSM Parameter Store path containing the CloudWatch Agent JSON config"
}

variable "docker_artifact_bucket" {
  type        = string
  description = "S3 bucket name where Docker artifacts (images/backups) are stored"
}

# --- IAM reuse (recommended; avoid CreatePolicy) ---
variable "ec2_ssm_role_name" {
  type        = string
  default     = null
  description = "Optional existing IAM role name for EC2; if null, module may create one"
}

variable "ec2_ssm_profile_name" {
  type        = string
  default     = null
  description = "Optional existing IAM instance profile name; if null, module may create one"
}

# --- Tags ---
variable "tags" {
  type        = map(string)
  default     = {}
  description = "Common tags applied to all resources"
}

# --- Optional NLB support (if your compute module uses it) ---
variable "nlb_ports" {
  type        = list(number)
  default     = []
  description = "NLB listener ports. Leave empty to mirror app_ports."
}

# --- Optional pass-throughs ---
variable "s3_backup_arn" {
  type        = string
  default     = ""
  description = "Pass-through to enable S3 docker backup read (optional)"
}

variable "ssm_parameter_arns" {
  type        = list(string)
  default     = ["*"]
  description = "Restrict SSM Parameter access (e.g., only /idlms/*). If using AWS-managed SSMReadOnly, this may be ignored."
}
