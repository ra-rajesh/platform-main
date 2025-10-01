output "docker_log_group_name" {
  value = module.cloudwatch_app.docker_log_group_name
}

output "ssm_param" {
  value = module.cloudwatch_app.ssm_param
}

output "ssm_param_name" {
  value = module.cloudwatch_app.ssm_param_name
}
