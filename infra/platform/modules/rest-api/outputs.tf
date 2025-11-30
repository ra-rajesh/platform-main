output "rest_api_id" {
  value = aws_api_gateway_rest_api.this.id
}

output "rest_api_name" {
  value = aws_api_gateway_rest_api.this.name
}

output "stage_name" {
  value = aws_api_gateway_stage.default.stage_name
}

output "execution_arn" {
  value = aws_api_gateway_rest_api.this.execution_arn
}

output "invoke_url" {
  description = "Invoke URL for the stage"
  value       = "https://${aws_api_gateway_rest_api.this.id}.execute-api.${var.region}.amazonaws.com/${aws_api_gateway_stage.default.stage_name}"
}

output "vpc_link_id" {
  value = aws_api_gateway_vpc_link.this.id
}

output "api_logs_group" {
  value = aws_cloudwatch_log_group.api_logs.name
}

output "api_execution_logs_group" {
  description = "CloudWatch log group that holds API Gateway execution logs"
  value       = aws_cloudwatch_log_group.api_execution_logs.name
}

output "api_logs_group_arn" {
  value = aws_cloudwatch_log_group.api_logs.arn
}

output "api_execution_logs_group_arn" {
  value = aws_cloudwatch_log_group.api_execution_logs.arn
}
