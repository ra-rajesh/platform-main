variable "vpc_id" {
  description = "VPC ID to place the subnets in"
  type        = string
}

variable "azs" {
  description = "Availability Zones to use, in order (must match number of subnets)"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets, in AZ order"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets, in AZ order"
  type        = list(string)
}

variable "common_tags" {
  description = "Common tags applied to all subnets"
  type        = map(string)
  default     = {}
}

# # --- Validations to ensure lengths match ---
# locals {
#   _pub_len_ok  = length(var.public_subnet_cidrs) == length(var.azs)
#   _priv_len_ok = length(var.private_subnet_cidrs) == length(var.azs)
# }

# # Using 'precondition' blocks on a null_resource makes the error nice & early.
# resource "null_resource" "validate_lengths" {
#   triggers = {
#     azs_len     = length(var.azs)
#     pub_len     = length(var.public_subnet_cidrs)
#     private_len = length(var.private_subnet_cidrs)
#   }

#   lifecycle {
#     precondition {
#       condition     = local._pub_len_ok
#       error_message = "public_subnet_cidrs length must equal azs length."
#     }
#     precondition {
#       condition     = local._priv_len_ok
#       error_message = "private_subnet_cidrs length must equal azs length."
#     }
#   }
# }
