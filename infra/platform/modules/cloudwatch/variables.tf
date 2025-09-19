variable "docker_log_group_name" {
  type        = string
  description = "CloudWatch log group name for your app/docker logs"
}

variable "retention_in_days" {
  type        = number
  default     = 30
  description = "Retention for the app log group"
}

# Optional S3 bucket for NLB access logs (created only if name != "")
variable "access_logs_bucket" {
  type        = string
  default     = ""
  description = "S3 bucket name for NLB access logs (leave empty to skip)"
}

variable "access_logs_prefix" {
  type        = string
  default     = "nlb"
  description = "Prefix inside the access-logs bucket"
}

variable "environment" {
  type        = string
  description = "Env tag (e.g., stage, prod)"
}

variable "region" {
  type        = string
  description = "AWS region (used in bucket policy SourceArn)"
}

variable "common_tags" {
  type        = map(string)
  default     = {}
  description = "Common tags applied to created resources"
}

# ---- CloudWatch Agent SSM parameter (for EC2 instances to fetch) ----
variable "ssm_param_name" {
  type        = string
  description = "SSM Parameter name to store the CW Agent config JSON"
}

variable "docker_log_file_path" {
  type        = string
  description = "Path of the application/docker log file on EC2 (CW Agent will tail this)"
}

variable "log_stream_name" {
  type        = string
  default     = "{instance_id}"
  description = "CW Agent log stream name (supports {instance_id})"
}

variable "timezone" {
  type        = string
  default     = "UTC"
  description = "Timezone for CW Agent"
}

variable "metrics_collection_interval" {
  type        = number
  default     = 60
  description = "CW Agent metrics collection interval"
}

variable "cloudwatch_agent_logfile" {
  type        = string
  default     = "/opt/aws/amazon-cloudwatch-agent/logs/amazon-cloudwatch-agent.log"
  description = "CW Agent local log file"
}

# Optional tag names for individual resources (if you want)
variable "log_group_tag_name" {
  type    = string
  default = "docker-api-logs"
}

variable "nlb_logs_bucket_tag_name" {
  type    = string
  default = "nlb-access-logs"
}

variable "ssm_tag_name" {
  type    = string
  default = "cw-agent-config"
}
