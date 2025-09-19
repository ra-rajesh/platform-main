output "bucket_id" { value = module.s3.bucket_id }
output "bucket_arn" { value = module.s3.bucket_arn }
output "bucket_domain_name" { value = module.s3.bucket_domain_name }
output "bucket_regional_domain" { value = module.s3.bucket_regional_domain }
output "ssm_bucket_name_param" { value = module.s3.ssm_bucket_name_param }
output "ssm_bucket_arn_param" { value = module.s3.ssm_bucket_arn_param }
