variable "env_name" {
  type        = string
  description = "Environment name (e.g., dev, stage, prod)"
}

variable "region" {
  type        = string
  description = "AWS region (e.g., ap-south-1)"
}

variable "vpc_name" {
  type        = string
  description = "Name tag for the VPC"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC (e.g., 10.0.0.0/16)"
}

variable "azs" {
  type        = list(string)
  description = "Availability Zones (e.g., ['ap-south-1a','ap-south-1b'])"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "Public subnet CIDRs (one per AZ)"
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "Private subnet CIDRs (one per AZ)"
}

variable "public_subnet_names" {
  type    = list(string)
  default = []
}

variable "private_subnet_names" {
  type    = list(string)
  default = []
}

variable "route_table_public_name" {
  type    = string
  default = ""
}

variable "route_table_private_name" {
  type    = string
  default = ""
}

variable "internet_gateway_name" {
  type    = string
  default = ""
}

variable "nat_gateway_name" {
  type    = string
  default = ""

}

variable "enable_dns_support" {
  type        = bool
  description = "Enable DNS support in the VPC"
}

variable "enable_dns_hostnames" {
  type        = bool
  description = "Enable DNS hostnames in the VPC"
}

variable "instance_tenancy" {
  type        = string
  description = "VPC instance tenancy: 'default' or 'dedicated'"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Common tags applied to all resources"
}
