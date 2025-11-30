variable "environment" {
  type = string
}

variable "stage_name" {
  type        = string
  description = "e.g., 'prod' or 'stage'"
}

variable "api_name" {
  type = string
}


variable "api_description" {
  type    = string
  default = " REST API"
}

variable "binary_media_types" {
  type    = list(string)
  default = []
}

variable "log_retention_days" {
  type    = number
  default = 14
}

variable "logging_level" {
  type    = string
  default = "INFO"
}

variable "data_trace_enabled" {
  type    = bool
  default = false
}

variable "metrics_enabled" {
  type    = bool
  default = true
}

variable "throttling_burst_limit" {
  type    = number
  default = 0
}

variable "throttling_rate_limit" {
  type    = number
  default = 0
}

variable "vpc_link_target_arns" {
  type        = list(string)
  description = "NLB ARN(s)"
}

variable "nlb_dns_name" {
  type        = string
  description = "NLB DNS"
}

variable "api_port" {
  type        = number
  description = "Backend port on NLB"
}

variable "region" {
  type        = string
  description = "For invoke URL"
}

variable "common_tags" {
  type    = map(string)
  default = {}
}
