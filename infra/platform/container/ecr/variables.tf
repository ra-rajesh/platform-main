variable "env_name" {
  type = string
}

variable "repositories" {
  type = list(string) # e.g., ["idlms-api"]
}

variable "prefix_with_env" {
  type    = bool
  default = true # stage-<name> if true
}

variable "image_tag_mutability" {
  type    = string
  default = "IMMUTABLE" # or "MUTABLE"
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

variable "ssm_prefix" {
  type        = string
  default     = ""
  description = "If non-empty, publish ECR details to SSM under this prefix (e.g., /idlms/ecr/stage)"
}
