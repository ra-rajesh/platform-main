output "app_log_group_name" {
  value       = aws_cloudwatch_log_group.app.name
  description = "CloudWatch log group name for app/docker logs"
}

output "access_logs_bucket_name" {
  value       = try(aws_s3_bucket.nlb_logs[0].bucket, null)
  description = "NLB access logs bucket (if created)"
}

output "access_logs_bucket_arn" {
  value       = try(aws_s3_bucket.nlb_logs[0].arn, null)
  description = "NLB access logs bucket ARN (if created)"
}

output "ssm_param_name" {
  value       = aws_ssm_parameter.cw_agent_config.name
  description = "SSM parameter storing CloudWatch Agent config JSON"
}
