output "rest_api_id" {
  value = aws_api_gateway_rest_api.this.id
}

output "rest_api_name" {
  value = aws_api_gateway_rest_api.this.name
}

output "root_resource_id" {
  value = aws_api_gateway_rest_api.this.root_resource_id
}

output "stage_name" {
  value = aws_api_gateway_stage.this.stage_name
}

output "vpc_link_id" {
  value = aws_api_gateway_vpc_link.this.id
}

output "invoke_url" {
  value = "https://${aws_api_gateway_rest_api.this.id}.execute-api.${var.region}.amazonaws.com/${aws_api_gateway_stage.this.stage_name}"
}

# Your ssm.tf uses this
output "access_log_group" {
  value = aws_cloudwatch_log_group.access_logs.name
}

# Helpful for debugging / visibility
output "routes" {
  value = var.routes
}

# (Optional but useful)
output "execution_arn" {
  value = aws_api_gateway_rest_api.this.execution_arn
}
