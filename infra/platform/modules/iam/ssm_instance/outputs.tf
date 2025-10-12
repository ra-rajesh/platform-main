# ---------- Outputs ----------
output "iam_role_name" {
  value = local.role_name_effective
}

output "instance_profile_name" {
  value = local.profile_name_effective
}
