output "published_names" {
  value       = module.ssm.published_names
  description = "List of SSM parameter names created/updated"
}
