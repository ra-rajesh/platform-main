variable "vpc_id" {
  type        = string
  description = "VPC ID to attach the Internet Gateway to"
}

variable "internet_gateway_name" {
  type        = string
  description = "Name tag for the Internet Gateway (e.g., stage-igw)"
}

variable "common_tags" {
  type        = map(string)
  description = "Common tags applied to the IGW"
  default     = {}
}
