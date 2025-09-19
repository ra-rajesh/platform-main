variable "region" {
  type        = string
  description = "AWS region"
}

# EC2 instance role (for SSM PutParameter/GetParameter, etc.)
variable "ec2_role_name" {
  type        = string
  description = "Existing EC2 SSM role name"
}

# GitHub OIDC deploy role (for ECR push)
variable "deploy_role_name" {
  type        = string
  description = "GitHub OIDC role name used by GitHub Actions"
}

# One or more ECR repos to grant push rights to (e.g., stage-idlms-reuse)
variable "repo_names" {
  type        = list(string)
  description = "ECR repository names"
}
