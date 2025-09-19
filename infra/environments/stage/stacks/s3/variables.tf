variable "env_name" { type = string }
variable "region" { type = string }

# Optional fixed name; leave empty to compute automatically
variable "artifact_bucket_name_override" {
  type        = string
  default     = ""
  description = "If set, use this exact bucket name."
}

# SSM path prefix where we publish the bucket details
variable "ssm_prefix" {
  type    = string
  default = "/idlms/artifacts"
}

# Extra tags to merge
variable "common_tags" {
  type    = map(string)
  default = {}
}
