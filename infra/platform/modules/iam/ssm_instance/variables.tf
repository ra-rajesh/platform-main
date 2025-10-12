variable "env_name" {
  type = string
}

# Optional base name override (without "-role"/"-instance-profile" suffixes).
# If null, module uses "<env_name>-ec2-ssm" as the base.
variable "name" {
  type    = string
  default = null
}

# If you want to REUSE existing role/profile, set these to the exact names.
# If null, the module CREATES new ones with env-based names.
variable "existing_role_name" {
  type    = string
  default = null
}
variable "existing_instance_profile_name" {
  type    = string
  default = null
}

variable "enable_ecr_pull" {
  type    = bool
  default = true
}
variable "enable_describe_helpers" {
  type    = bool
  default = true
}

variable "s3_backup_arn" {
  type    = string
  default = ""
}

variable "tags" {
  type    = map(string)
  default = {}
}
