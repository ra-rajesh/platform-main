output "public_subnet_ids" {
  value = [for s in aws_subnet.platform_main_public_subnets : s.id]
}

output "private_subnet_ids" {
  value = [for s in aws_subnet.platform_main_private_subnets : s.id]
}

output "public_subnet_cidrs" {
  value = var.public_subnet_cidrs
}

output "private_subnet_cidrs" {
  value = var.private_subnet_cidrs
}

output "azs" {
  value = var.azs
}
