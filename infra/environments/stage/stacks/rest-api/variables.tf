variable "env_name" {
  type = string
}

variable "region" {
  type = string
}

variable "nlb_ssm_prefix" {
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
  default = "IDLMS shared REST API"
}

variable "endpoint_type" {
  type = string
}

# NEW: path -> port map

variable "routes" {
  type = map(object({
    port        = number
    health_path = optional(string, "/health")
  }))
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
variable "tf_state_bucket" { type = string }
variable "tf_state_region" { type = string }
variable "nlb_state_key" { type = string } # e.g., "stage/nlb/terraform.tfstate"
