# Partition is needed to build a correct ARN (aws, aws-cn, aws-us-gov)
data "aws_partition" "current" {}

output "artifact_bucket_name" {
  description = "Artifact bucket name (created or external override)"
  value       = local.bucket_name
}

output "artifact_bucket_arn" {
  description = "Artifact bucket ARN (works whether created by TF or provided via override)"
  value       = "arn:${data.aws_partition.current.partition}:s3:::${local.bucket_name}"
}
