output "bucket_id" {
  value = aws_s3_bucket.this.id
}

output "bucket_arn" {
  value = aws_s3_bucket.this.arn
}

output "bucket_domain_name" {
  value = aws_s3_bucket.this.bucket_domain_name
}

output "bucket_regional_domain" {
  value = aws_s3_bucket.this.bucket_regional_domain_name
}

# These resources use `count = var.create_ssm_params ? 1 : 0`
# so index [0] when present, else return null.
output "ssm_bucket_name_param" {
  value = try(aws_ssm_parameter.bucket_name[0].name, null)
}

output "ssm_bucket_arn_param" {
  value = try(aws_ssm_parameter.bucket_arn[0].name, null)
}
