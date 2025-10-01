output "docker_log_group_name" {
  value = aws_cloudwatch_log_group.docker.name
}

# Name of the actually-created SSM parameter ("" when disabled)
output "ssm_param" {
  value = try(aws_ssm_parameter.agent_config[0].name, "")
}

# Pass-through of the requested SSM param name ("" when disabled)
output "ssm_param_name" {
  value = var.ssm_param_name
}

# Back-compat alias, in case any stacks refer to module.cloudwatch_app.log_group
output "log_group" {
  value = aws_cloudwatch_log_group.docker.name
}
