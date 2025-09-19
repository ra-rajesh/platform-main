output "role_name" {
  value = coalesce(
    var.existing_role_name,
    try(aws_iam_role.this[0].name, null)
  )
}

output "instance_profile_name" {
  value = coalesce(
    var.existing_instance_profile_name,
    try(aws_iam_instance_profile.this[0].name, null)
  )
}
