variable "name" {
  type        = string
  description = "ECR repository name"
}

variable "image_tag_mutability" {
  type        = string
  description = "MUTABLE or IMMUTABLE"
  default     = "MUTABLE"
}

variable "scan_on_push" {
  type        = bool
  description = "Enable image scan on push"
  default     = true
}

variable "encryption_type" {
  type        = string
  description = "AES256 or KMS"
  default     = "AES256"
}

# Optional JSON lifecycle policy (null = disabled)
variable "lifecycle_policy_json" {
  type        = string
  description = "Lifecycle policy JSON (optional)"
  default     = null
}

variable "force_delete" {
  type        = bool
  description = "Allow destroy even if images exist"
  default     = true
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply"
  default     = {}
}
