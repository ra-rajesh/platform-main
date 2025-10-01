variable "env_name" {
  type = string
}

variable "region" {
  type = string
}

variable "api_name" {
  type    = string
  default = "idlms-api"
}

variable "stage_name" {
  type    = string
  default = "stage"
}

variable "description" {
  type    = string
  default = "IDLMS shared REST API (Option B: path -> backend route)"
}

# Path -> { port, optional health_path }
variable "routes" {
  type = map(object({
    port        = number
    health_path = optional(string, "/health")
  }))
}

variable "endpoint_type" {
  type    = string
  default = "REGIONAL"
  validation {
    condition     = contains(["REGIONAL", "EDGE", "PRIVATE"], var.endpoint_type)
    error_message = "endpoint_type must be one of REGIONAL, EDGE, PRIVATE."
  }
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
  type    = map(string)
  default = {}
}

variable "nlb_arn" {
  type = string
}

variable "nlb_dns_name" {
  type = string
}
