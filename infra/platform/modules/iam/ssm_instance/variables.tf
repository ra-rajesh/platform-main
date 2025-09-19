variable "name" { type = string }

# Reuse existing IAM (optional)
variable "existing_role_name" {
  type    = string
  default = null
}
variable "existing_instance_profile_name" {
  type    = string
  default = null
}

variable "tags" {
  type    = map(string)
  default = {}
}
