# Look up the GitHub OIDC deploy role by name
data "aws_iam_role" "deploy" {
  name = var.deploy_role_name
}

# Look up each target ECR repository by name
data "aws_ecr_repository" "targets" {
  for_each = toset(var.repo_names)
  name     = each.value
}

# Attach one inline policy per repo to the deploy role
resource "aws_iam_role_policy" "ecr_push" {
  for_each = data.aws_ecr_repository.targets

  name = "ecr-push-${each.key}"
  role = data.aws_iam_role.deploy.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      # Required on * for ECR login
      {
        Sid      = "AuthToken",
        Effect   = "Allow",
        Action   = ["ecr:GetAuthorizationToken"],
        Resource = "*"
      },
      # Push/pull/describe on this specific repository
      {
        Sid    = "RepoPushPull",
        Effect = "Allow",
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:PutImage",
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer",
          "ecr:DescribeRepositories",
          "ecr:DescribeImages"
        ],
        Resource = each.value.arn
      }
    ]
  })
}
