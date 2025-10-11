variable "env_name" {
  type = string
}

variable "region" {
  type = string
}

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

variable "lifecycle_policy_json" {
  type    = string
  default = null
}

variable "ssm_prefix" {
  type        = string
  default     = "/platform-main"
  description = "SSM base prefix to publish repo pointers"
}

variable "tags" {
  type = map(string)
  default = {
    Project     = "platform-main"
    Environment = "stage"
  }
}
