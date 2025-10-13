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
  type = string
}

variable "description" {
  type    = string
  default = "shared REST API"
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

# ---- NLB inputs ----
# Provide these to BYPASS SSM entirely.
variable "nlb_arn" {
  type        = string
  default     = "arn:aws:elasticloadbalancing:ap-south-1:592776312448:loadbalancer/net/stage-nlb/6c8323c2092f314e"
  description = "NLB ARN (set to bypass SSM)"
}

variable "nlb_dns_name" {
  type        = string
  default     = "stage-nlb-6c8323c2092f314e.elb.ap-south-1.amazonaws.com"
  description = "NLB DNS name (set to bypass SSM)"
}
variable "nlb_ssm_prefix" {
  type        = string
  default     = null
  description = "SSM prefix used only when direct NLB values are not provided"
}

variable "create_stage_and_deployment" {
  description = "Create aws_api_gateway_deployment and aws_api_gateway_stage here"
  type        = bool
}

