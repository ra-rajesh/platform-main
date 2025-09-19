output "public_association_ids" {
  description = "List of association IDs for public subnets (index-aligned with var.public_subnet_ids)"
  value       = aws_route_table_association.idlms_public_rta[*].id
}

output "private_association_ids" {
  description = "List of association IDs for private subnets (index-aligned with var.private_subnet_ids)"
  value       = aws_route_table_association.idlms_private_rta[*].id
}

output "public_association_by_subnet" {
  description = "Map: public subnet ID => association ID"
  value       = { for i, a in aws_route_table_association.idlms_public_rta : var.public_subnet_ids[i] => a.id }
}

output "private_association_by_subnet" {
  description = "Map: private subnet ID => association ID"
  value       = { for i, a in aws_route_table_association.idlms_private_rta : var.private_subnet_ids[i] => a.id }
}

# Optional: pass-through for convenience
output "route_table_id" {
  description = "The route table ID used for these associations"
  value       = var.route_table_id
}
