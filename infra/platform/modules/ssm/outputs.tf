output "published_names" {
  value       = [for p in aws_ssm_parameter.this : p.name]
  description = "List of SSM parameter names that were created/updated"
}
