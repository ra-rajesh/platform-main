output "repository_names" {
  description = "Final created repo names (ordered)"
  value       = local.repo_names
}

output "repository_urls" {
  description = "ECR repository URLs (ordered like repository_names)"
  value       = local.repository_urls
}

output "repository_arns" {
  description = "ECR repository ARNs (ordered like repository_names)"
  value       = local.repository_arns
}
