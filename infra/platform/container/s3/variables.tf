# Wrapper over infra/platform/modules/s3 (already in your repo)

variable "environment" {
  type = string # e.g., "stage"
}

variable "name" {
  type = string # e.g., "built-artifact"
}

# If null => module uses "${environment}-${name}". If set => exact bucket name.
variable "bucket_name_override" {
  type    = string
  default = null
}

# Encryption
variable "sse_algorithm" {
  type    = string
  default = "AES256" # "AES256" or "aws:kms"
}

variable "kms_key_id" {
  type    = string
  default = null # required if aws:kms
}

# Behavior
variable "versioning" {
  type    = bool
  default = true
}

variable "force_destroy" {
  type    = bool
  default = false
}

# Lifecycle (module supports these toggles)
variable "enable_ia_transition" {
  type    = bool
  default = false
}

variable "ia_after_days" {
  type    = number
  default = 30
}

variable "noncurrent_expire_days" {
  type    = number
  default = 90
}

variable "expire_after_days" {
  type    = number
  default = 0
}

# SSM
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
