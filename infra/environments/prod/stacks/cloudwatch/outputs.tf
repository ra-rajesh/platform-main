output "app_log_groups" { value = module.cloudwatch.app_log_groups }
output "system_log_group" { value = module.cloudwatch.system_log_group }
output "cwagent_ssm_param_path" { value = module.cloudwatch.cwagent_ssm_param_path }
