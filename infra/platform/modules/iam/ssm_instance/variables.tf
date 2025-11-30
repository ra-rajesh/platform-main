variable "name" {
  type    = string
  default = null
}

variable "role_name" {
  type        = string
  description = "Exact IAM role name to create (e.g., test-ec2-ssm-role)"
}

variable "instance_profile_name" {
  type        = string
  description = "Exact IAM instance profile name to create (e.g., test-ec2-ssm-instance-profile)"
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "s3_backup_arn" {
  description = "S3 ARN for docker backup read (e.g., arn:aws:s3:::bucket/prefix/*). Leave empty to disable."
  type        = string
  default     = ""
}

variable "enable_ecr_pull" {
  description = "If true, attach ECR pull permissions to the role"
  type        = bool
  default     = false
}

variable "enable_describe_helpers" {
  description = "If true, attach EC2 and ELB Describe* helper permissions"
  type        = bool
  default     = true
}

variable "ssm_parameter_arns" {
  description = "List of SSM Parameter ARNs the instance may read (e.g., ['arn:aws:ssm:ap-south-1:<acct>:parameter/idlms/*']). Use ['*'] for broad access."
  type        = list(string)
  default     = ["*"]
  validation {
    condition     = length(var.ssm_parameter_arns) > 0 && alltrue([for a in var.ssm_parameter_arns : a == "*" || startswith(a, "arn:aws:ssm:")])
    error_message = "ssm_parameter_arns must be ['*'] or a list of ARNs starting with 'arn:aws:ssm:'."
  }
}

variable "use_managed_policies" {
  type        = bool
  default     = true
  description = "Attach AWS-managed policies instead of creating customer-managed ones"
}
