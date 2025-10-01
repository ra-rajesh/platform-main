output "log_group" {
  value = module.cloudwatch_app.log_group
}

output "ssm_param" {
  value = module.cloudwatch_app.ssm_param
}
