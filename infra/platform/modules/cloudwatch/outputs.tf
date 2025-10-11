output "app_log_groups" {
  description = "Map of app => log group name"
  value       = { for k, lg in aws_cloudwatch_log_group.app : k => lg.name }
}

output "system_log_group" {
  value = aws_cloudwatch_log_group.system.name
}

output "cwagent_ssm_param_path" {
  value = aws_ssm_parameter.cwagent_config.name
}
