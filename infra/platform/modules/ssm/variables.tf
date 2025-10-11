variable "path_prefix" {
  type        = string
  description = "Base SSM path prefix, e.g. /platform-main"
}

variable "values" {
  type        = map(string)
  description = "Key/value to publish; key becomes final path segment(s) relative to path_prefix"
}

variable "overwrite" {
  type        = bool
  default     = true
  description = "Allow updating existing parameters"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags for SSM parameters"
}
