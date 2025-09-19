output "public_route_table_id" {
  value = aws_route_table.idlms_public_rt.id
}

output "private_route_table_id" {
  value = aws_route_table.idlms_private_rt.id
}
