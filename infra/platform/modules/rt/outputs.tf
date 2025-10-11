output "public_route_table_id" {
  value = aws_route_table.platform_main_public_rt.id
}

output "private_route_table_id" {
  value = aws_route_table.platform_main_private_rt.id
}
