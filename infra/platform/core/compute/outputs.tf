output "security_group_id"     { value = module.sg_app.security_group_id }
output "instance_profile_name" { value = module.iam_ssm.instance_profile_name }
output "iam_role_name"         { value = module.iam_ssm.role_name }
output "instance_id"           { value = module.ec2.instance_id }
output "instance_private_ip"   { value = module.ec2.private_ip }
