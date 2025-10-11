output "security_group_id" {
  description = "App security group ID"
  value       = module.sg_app.security_group_id
}

output "instance_profile_name" {
  description = "EC2 instance profile name attached to the instance"
  value       = module.iam_ssm.instance_profile_name
}

output "iam_role_name" {
  description = "IAM role name used by the instance"
  value       = module.iam_ssm.role_name
}

output "instance_id" {
  description = "EC2 instance ID"
  value       = module.ec2.instance_id
}

output "instance_private_ip" {
  description = "Private IP address of the EC2 instance"
  value       = module.ec2.private_ip
}
