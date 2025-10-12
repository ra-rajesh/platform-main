# REST API core info
output "rest_api_id" {
  value = try(module.rest_api.rest_api_id, null)
}

output "invoke_url" {
  value = try(module.rest_api.invoke_url, null)
}

output "vpc_link_id" {
  value = try(module.rest_api.vpc_link_id, null)
}

output "execution_arn" {
  value = try(module.rest_api.execution_arn, null)
}

# Stage name (safe optional output)
output "stage_name" {
  value = try(module.rest_api.stage_name, null)
}

# --- CloudWatch log groups ---
output "access_log_group" {
  description = "CloudWatch group for API Gateway access logs"
  value       = try(module.rest_api.access_log_group, null)
}

output "execution_log_group" {
  description = "CloudWatch group for API Gateway execution logs"
  value       = try(module.rest_api.execution_log_group, null)
}

# For debugging or visibility if you want to confirm route setup
output "routes" {
  value = try(module.rest_api.routes, null)
}
