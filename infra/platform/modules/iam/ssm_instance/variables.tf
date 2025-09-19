variable "name" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

# Reuse existing IAM instead of creating (optional)
variable "existing_role_name" {
  type    = string
  default = null
}

variable "existing_instance_profile_name" {
  type    = string
  default = null
}
