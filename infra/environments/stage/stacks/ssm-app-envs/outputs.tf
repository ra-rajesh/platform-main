output "parameter_names" {
  value = [for p in aws_ssm_parameter.app_env : p.name]
}
