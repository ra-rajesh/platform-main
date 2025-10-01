output "docker_log_group_name" {
  value = aws_cloudwatch_log_group.docker.name
}

# Returns the created SSM parameter name, or "" when ssm_param_name = ""
output "ssm_param" {
  value = try(aws_ssm_parameter.agent_config[0].name, "")
}
