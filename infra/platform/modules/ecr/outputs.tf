output "repository_name" {
  description = "ECR repository name"
  value       = aws_ecr_repository.idlms_repo.name
}

output "repository_arn" {
  description = "ECR repository ARN"
  value       = aws_ecr_repository.idlms_repo.arn
}

output "repository_url" {
  description = "ECR repository URL (registry/repo)"
  value       = aws_ecr_repository.idlms_repo.repository_url
}

output "registry_id" {
  description = "ECR registry ID"
  value       = aws_ecr_repository.idlms_repo.registry_id
}
