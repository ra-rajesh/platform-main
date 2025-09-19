output "public_subnet_ids" {
  description = "IDs of created public subnets"
  value       = [for s in aws_subnet.idlms_public_subnets : s.id]
}

output "private_subnet_ids" {
  description = "IDs of created private subnets"
  value       = [for s in aws_subnet.idlms_private_subnets : s.id]
}

output "public_subnet_cidrs" {
  description = "CIDRs of public subnets (in AZ order)"
  value       = var.public_subnet_cidrs
}

output "private_subnet_cidrs" {
  description = "CIDRs of private subnets (in AZ order)"
  value       = var.private_subnet_cidrs
}

output "azs" {
  description = "Availability Zones used"
  value       = var.azs
}
