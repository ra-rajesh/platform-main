terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}


resource "aws_ecr_repository" "idlms_repo" {
  name                 = var.name
  image_tag_mutability = var.image_tag_mutability
  force_delete         = var.force_delete
  tags                 = var.tags

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }
}

#   encryption_configuration {
#     encryption_type = var.encryption_type
#     kms_key         = var.encryption_type == "KMS" ? var.kms_key_arn : null
#   }
# 

# # Optional lifecycle policy
# resource "aws_ecr_lifecycle_policy" "this" {
#   count      = var.lifecycle_policy_json != null && trimspace(var.lifecycle_policy_json) != "" ? 1 : 0
#   repository = aws_ecr_repository.idlms_repo.name
#   policy     = var.lifecycle_policy_json
# }

# # Optional repository policy (e.g., cross-account pulls)
# resource "aws_ecr_repository_policy" "this" {
#   count      = var.repository_policy_json != null && trimspace(var.repository_policy_json) != "" ? 1 : 0
#   repository = aws_ecr_repository.idlms_repo.name
#   policy     = var.repository_policy_json
# }
