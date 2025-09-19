variable "env_name" {
  type = string
}

variable "region" {
  type = string
}

variable "repositories" {
  type = list(string)
}

variable "prefix_with_env" {
  type    = bool
  default = true
}

variable "image_tag_mutability" {
  type    = string
  default = "MUTABLE"
}

variable "scan_on_push" {
  type    = bool
  default = true
}

variable "force_delete" {
  type    = bool
  default = true
}

variable "tags" {
  type    = map(string)
  default = {}
}
