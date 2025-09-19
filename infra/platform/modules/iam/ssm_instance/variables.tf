variable "name" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

# Reuse existing IAM (accept both alias styles)
variable "existing_role_name" {
  type    = string
  default = null
}
variable "existing_iam_role_name" {
  type    = string
  default = null
}
variable "existing_instance_profile_name" {
  type    = string
  default = null
}
variable "existing_iam_instance_profile_name" {
  type    = string
  default = null
}
