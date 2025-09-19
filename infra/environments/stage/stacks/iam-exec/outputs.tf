output "attached_to" {
  value = var.attach_to == "user" ? var.target_user_name : var.target_role_name
}

output "execution_policy_arn" {
  value = aws_iam_policy.terraform_execution.arn
}

output "state_policy_arn" {
  value       = try(aws_iam_policy.terraform_state[0].arn, null)
  description = "Only present if you set tf_state_bucket_arn/tf_lock_table_arn"
}
