variable "env_name" {
  type = string
}

variable "region" {
  type = string
}

# Map of logical key => repository name (final name in ECR)
# Example: { "idlms-reuse" = "idlms-reuse", "vitalreg-app" = "vitalreg-app" }
variable "repositories" {
  type        = map(string)
  description = "Repos to create (key => repo name)"
}

variable "image_tag_mutability" {
  type    = string
  default = "MUTABLE"
}

variable "scan_on_push" {
  type    = bool
  default = true
}

variable "encryption_type" {
  type    = string
  default = "AES256"
}

# Optional single policy JSON applied to all repos (null = no policy)
variable "lifecycle_policy_json" {
  type    = string
  default = null
}

# If set, write SSM pointers here:
# /<ssm_prefix>/ecr/<env>/<repo>/repository_url (and arn/name)
variable "ssm_prefix" {
  type        = string
  default     = ""
  description = "If set, publish repo pointers to SSM under this prefix"
}

variable "tags" {
  type    = map(string)
  default = {}
}
