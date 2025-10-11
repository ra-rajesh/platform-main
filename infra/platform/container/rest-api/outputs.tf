# Always available
output "rest_api_id" {
  value = aws_api_gateway_rest_api.this.id
}

output "rest_api_name" {
  value = aws_api_gateway_rest_api.this.name
}

output "root_resource_id" {
  value = aws_api_gateway_rest_api.this.root_resource_id
}

# Conditionally available (only when stage/deployment created)
output "stage_name" {
  value = var.create_stage_and_deployment && length(aws_api_gateway_stage.this) > 0 ? aws_api_gateway_stage.this[0].stage_name : null
}

output "vpc_link_id" {
  value = aws_api_gateway_vpc_link.this.id
}

# Safe invoke_url (only when stage exists)
output "invoke_url" {
  value = var.create_stage_and_deployment && length(aws_api_gateway_stage.this) > 0 ? "https://${aws_api_gateway_rest_api.this.id}.execute-api.${var.region}.amazonaws.com/${aws_api_gateway_stage.this[0].stage_name}" : null
}

# Used by SSM module for logging configuration
output "access_log_group" {
  value = aws_cloudwatch_log_group.access_logs.name
}

# Helpful for debugging / visibility
output "routes" {
  value = var.routes
}

# Optional but useful
output "execution_arn" {
  value = aws_api_gateway_rest_api.this.execution_arn
}
