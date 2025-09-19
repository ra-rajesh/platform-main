variable "path_prefix" {
  type        = string
  description = "Base SSM path, e.g. /idlms/stage/network"
}

variable "values" {
  type        = map(string)
  description = "Key/value pairs to publish under the prefix. Key becomes the final path segment."
}

variable "overwrite" {
  type        = bool
  default     = true
  description = "Allow updating existing SSM parameters"
}

variable "common_tags" {
  type    = map(string)
  default = {}
}
