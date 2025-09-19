variable "path_prefix" {
  type        = string
  description = "SSM base path, e.g. /idlms/nlb/stage"
}

variable "values" {
  type        = map(string)
  description = "Key/value pairs to publish under the prefix. Keys become final path segments."
}

variable "overwrite" {
  type        = bool
  default     = true
  description = "Allow updating existing SSM parameters"
}

variable "common_tags" {
  type        = map(string)
  default     = {}
  description = "Tags propagated to SSM parameters"
}
