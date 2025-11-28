variable "env_name" {
  type = string
}

variable "region" {
  type = string
}

variable "nlb_ssm_prefix" {
  type    = string
  default = null
}

variable "api_name" {
  type    = string
  default = "platform-main-api"
}

variable "stage_name" {
  type    = string
  default = "stage"
}

variable "description" {
  type    = string
  default = "Platform-Main shared REST API"
}

variable "tf_bucket" {
  type        = string
  default     = ""
  description = "Override the platform-main state bucket. If empty, it's computed automatically."
}

variable "endpoint_type" {
  type    = string
  default = "REGIONAL"
}

variable "routes" {
  type = any
}

variable "access_log_retention_days" {
  type    = number
  default = 14
}

variable "enable_execution_logs" {
  type    = bool
  default = true
}

variable "execution_metrics_enabled" {
  type    = bool
  default = true
}

variable "execution_data_trace" {
  type    = bool
  default = false
}

variable "tags" {
  type = map(string)
  default = {
    Project     = "Platform-main"
    Environment = "stage"
  }
}
variable "nlb_arn" {
  type        = string
  default     = ""
  description = "NLB ARN (set to bypass SSM)"
}

variable "nlb_dns_name" {
  type        = string
  default     = ""
  description = "NLB DNS name (set to bypass SSM)"
}

variable "ssm_prefix" {
  type    = string
  default = ""
}

variable "seed_path" {
  type        = string
  default     = "_seed"
  description = "Mock seed route (no leading slash)."
}
