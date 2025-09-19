variable "env_name" {
  type = string
}

variable "name" {
  type    = string
  default = "nlb"
}

variable "vpc_id" {
  type = string
}

# Either provide subnet_ids (simple) OR subnet_mapping (advanced w/ EIP / static IPs). Not both.
variable "subnet_ids" {
  description = "Subnet IDs for the NLB"
  type        = list(string)
  default     = []
}

variable "subnet_mapping" {
  description = "Advanced subnet mapping (optional)"
  type = list(object({
    subnet_id            = string
    allocation_id        = optional(string)
    private_ipv4_address = optional(string)
    ipv6_address         = optional(string)
  }))
  default = []
}

variable "internal" {
  type    = bool
  default = true
}

# Ports: one listener + one TG per port
variable "ports" {
  type    = list(number)
  default = [4000]
}

# Targets: "instance" or "ip"
variable "target_type" {
  type    = string
  default = "instance"

  validation {
    condition     = contains(["instance", "ip"], var.target_type)
    error_message = "target_type must be 'instance' or 'ip'"
  }
}

variable "instance_ids" {
  type    = list(string)
  default = [] # used when target_type = instance
}

variable "ip_addresses" {
  type    = list(string)
  default = [] # used when target_type = ip
}

# Tuning
variable "cross_zone" {
  type    = bool
  default = true
}

variable "deregistration_delay" {
  type    = number
  default = 60
}

variable "health_check_protocol" {
  type    = string
  default = "TCP" # TCP is typical for NLB
}

variable "tags" {
  type    = map(string)
  default = {}
}
