variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "attach_to" {
  description = "Attach policy to 'user' or 'role'"
  type        = string
  default     = "user"
  validation {
    condition     = contains(["user", "role"], var.attach_to)
    error_message = "attach_to must be 'user' or 'role'."
  }
}

variable "target_user_name" {
  description = "User to attach the policy to (when attach_to = user)"
  type        = string
  default     = "testing-user"
}

variable "target_role_name" {
  description = "Role to attach the policy to (when attach_to = role)"
  type        = string
  default     = null
}

# Optional: remote state access, if you want this module to also grant S3/DDB
variable "tf_state_bucket_arn" {
  description = "ARN of the Terraform state bucket (optional)"
  type        = string
  default     = null
}
variable "tf_state_bucket_name" {
  description = "Name of the Terraform state bucket (optional, for ListBucket)"
  type        = string
  default     = null
}
variable "tf_lock_table_arn" {
  description = "ARN of the DynamoDB lock table (optional)"
  type        = string
  default     = null
}
