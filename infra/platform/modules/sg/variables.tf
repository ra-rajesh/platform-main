variable "vpc_id" {
  type        = string
  description = "VPC ID where the security group will be created"
}

variable "sg_name" {
  type        = string
  description = "Name tag for the security group (e.g., idlms-stage-ec2-sg)"
}

variable "description" {
  type        = string
  description = "Security group description"
  default     = "Managed by Terraform"
}

variable "ingress_ports" {
  type        = list(number)
  description = "List of TCP ports to allow inbound"
}

# Apply these CIDRs to ALL ports above. Change to your office IP(s) for tighter security.
variable "ingress_cidrs" {
  type        = list(string)
  description = "IPv4 CIDRs allowed inbound for the listed ports"
}

# # Optional IPv6 CIDRs
# variable "ingress_ipv6_cidrs" {
#   type        = list(string)
#   description = "IPv6 CIDRs allowed inbound for the listed ports"
#   default     = []
# }

# # Optional: allow another SG (e.g., ALB/EC2 SG) to reach these ports
# variable "source_security_group_ids" {
#   type        = list(string)
#   description = "Security group IDs allowed inbound for the listed ports"
#   default     = []
# }

# Typical pattern: allow all egress
variable "allow_all_egress" {
  type        = bool
  description = "Allow all outbound traffic"
  default     = true
}

variable "common_tags" {
  type        = map(string)
  description = "Common tags applied to the security group"
  default     = {}
}
