variable "environment" {
  type = string
} # e.g. "stage"
variable "name" {
  type = string
} # short logical name, e.g. "idlms-artifacts"

# If you need an exact bucket name (must be globally-unique), set this.
# Otherwise, bucket name = "${environment}-${name}"
variable "bucket_name_override" {
  type    = string
  default = null
}

# Default encryption
variable "sse_algorithm" {
  type    = string
  default = "AES256" # or "aws:kms"
  validation {
    condition     = contains(["AES256", "aws:kms"], var.sse_algorithm)
    error_message = "sse_algorithm must be AES256 or aws:kms"
  }
}

variable "kms_key_id" {
  type    = string
  default = null
} # required if aws:kms
variable "versioning" {
  type    = bool
  default = true
}
variable "force_destroy" {
  type    = bool
  default = false
} # true only in non-prod

# Lifecycle (optional; all are optional toggles)
variable "enable_ia_transition" {
  type    = bool
  default = false
}
variable "ia_after_days" {
  type    = number
  default = 30
} # to STANDARD_IA
variable "noncurrent_expire_days" {
  type    = number
  default = 90
} # delete old versions
variable "expire_after_days" {
  type    = number
  default = 0
} # 0=disabled

# SSM parameters for reuse by other stacks
variable "create_ssm_params" {
  type    = bool
  default = true
}
variable "ssm_path_prefix" {
  type    = string
  default = "/idlms"
}

variable "tags" {
  type    = map(string)
  default = {}
}
