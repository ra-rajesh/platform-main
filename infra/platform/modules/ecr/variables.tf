variable "name" {
  type        = string
  description = "ECR repository name (e.g., idlms-api)"
}

variable "image_tag_mutability" {
  type        = string
  default     = "MUTABLE"
  description = "MUTABLE or IMMUTABLE"
  validation {
    condition     = contains(["MUTABLE", "IMMUTABLE"], var.image_tag_mutability)
    error_message = "image_tag_mutability must be MUTABLE or IMMUTABLE."
  }
}

variable "scan_on_push" {
  type        = bool
  default     = true
  description = "Enable image scanning on push"
}

# variable "encryption_type" {
#   type        = string
#   default     = "AES256"
#   description = "AES256 or KMS"
#   validation {
#     condition     = contains(["AES256", "KMS"], var.encryption_type)
#     error_message = "encryption_type must be AES256 or KMS."
#   }
# }

variable "kms_key_arn" {
  type        = string
  default     = null
  description = "KMS key ARN (required if encryption_type=KMS)"
}

variable "force_delete" {
  type        = bool
  default     = true
  description = "Force delete repo (and images) on destroy"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags for the repository"
}

# # Optional: lifecycle policy JSON
# variable "lifecycle_policy_json" {
#   type        = string
#   default     = null
#   description = "ECR lifecycle policy JSON (optional)"
# }

# # Optional: repository policy JSON (e.g., cross-account pull permissions)
# variable "repository_policy_json" {
#   type        = string
#   default     = null
#   description = "ECR repository policy JSON (optional)"
# }
