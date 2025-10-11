output "count" { value = length(aws_ssm_parameter.kv) }
output "names" { value = [for p in aws_ssm_parameter.kv : p.name] }
