output "log_group" { value = aws_cloudwatch_log_group.docker.name }
output "ssm_param" { value = aws_ssm_parameter.agent_config.name }
