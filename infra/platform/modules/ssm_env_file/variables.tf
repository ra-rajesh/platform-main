variable "param_root" {
  description = "Root prefix for parameters"
  type        = string
  default     = "/idlms"
}

variable "app_name" {
  description = "App/repo name (e.g., idlms-app, vitalreg-app)"
  type        = string
}

variable "env_name" {
  description = "Environment (dev/stage/prod)"
  type        = string
}

variable "env_file_path" {
  description = "Local path to .env file (use either this OR env_value)"
  type        = string
  default     = null
}

variable "env_value" {
  description = "Raw .env content (multiline). Use either this OR env_file_path."
  type        = string
  default     = null
  sensitive   = true
}

variable "tags" {
  description = "Tags to apply to the SSM parameter"
  type        = map(string)
  default     = {}
}
