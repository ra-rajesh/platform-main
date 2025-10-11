output "repositories" {
  value = local.repo_info
}

# Convenience flat maps (optional, but handy)
output "repository_urls" {
  value = { for k, v in local.repo_info : k => v.url }
}

output "repository_arns" {
  value = { for k, v in local.repo_info : k => v.arn }
}

output "repository_names" {
  value = { for k, v in local.repo_info : k => v.name }
}
