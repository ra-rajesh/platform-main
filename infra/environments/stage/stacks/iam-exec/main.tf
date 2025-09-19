locals {
  requested_region = var.region
}

# Optionally look up the user/role we’ll attach to
data "aws_iam_user" "target" {
  count     = var.attach_to == "user" ? 1 : 0
  user_name = var.target_user_name
}

data "aws_iam_role" "target" {
  count = var.attach_to == "role" ? 1 : 0
  name  = var.target_role_name
}

# --- Single consolidated policy: TerraformExecution (least-but-complete) ---

resource "aws_iam_policy" "terraform_execution" {
  name        = "TerraformExecution"
  description = "Permissions needed by Terraform for APIGW, ELBv2 (incl. *Attributes), Logs meta, SSM params, EC2 Describe"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      # API Gateway (manage REST APIs, stages, deployments, account settings)
      {
        Sid    = "APIGatewayReadWrite",
        Effect = "Allow",
        Action = [
          "apigateway:GET", "apigateway:POST", "apigateway:PUT",
          "apigateway:PATCH", "apigateway:DELETE"
        ],
        Resource = [
          "arn:aws:apigateway:*::/account",
          "arn:aws:apigateway:*::/restapis",
          "arn:aws:apigateway:*::/restapis/*",
          "arn:aws:apigateway:*::/restapis/*/*"
        ]
      },

      # ELBv2 / NLB (includes specific *Attributes calls that Terraform v5 uses)
      {
        Sid    = "ELBv2AllNeeded",
        Effect = "Allow",
        Action = [
          "elasticloadbalancing:CreateLoadBalancer",
          "elasticloadbalancing:DeleteLoadBalancer",
          "elasticloadbalancing:DescribeLoadBalancers",
          "elasticloadbalancing:DescribeLoadBalancerAttributes",
          "elasticloadbalancing:ModifyLoadBalancerAttributes",

          "elasticloadbalancing:AddTags",
          "elasticloadbalancing:RemoveTags",
          "elasticloadbalancing:DescribeTags",
          "elasticloadbalancing:DescribeAccountLimits",

          "elasticloadbalancing:CreateTargetGroup",
          "elasticloadbalancing:DeleteTargetGroup",
          "elasticloadbalancing:DescribeTargetGroups",
          "elasticloadbalancing:DescribeTargetGroupAttributes",
          "elasticloadbalancing:ModifyTargetGroup",
          "elasticloadbalancing:ModifyTargetGroupAttributes",
          "elasticloadbalancing:RegisterTargets",
          "elasticloadbalancing:DeregisterTargets",
          "elasticloadbalancing:DescribeTargetHealth",

          "elasticloadbalancing:CreateListener",
          "elasticloadbalancing:DeleteListener",
          "elasticloadbalancing:DescribeListeners",
          "elasticloadbalancing:DescribeListenerAttributes",
          "elasticloadbalancing:ModifyListener",
          "elasticloadbalancing:ModifyListenerAttributes",

          "elasticloadbalancing:DescribeRules",
          "elasticloadbalancing:CreateRule",
          "elasticloadbalancing:DeleteRule",
          "elasticloadbalancing:ModifyRule",

          "elasticloadbalancing:DescribeSSLPolicies"
        ],
        Resource = "*",
        Condition = {
          "StringEquals" = { "aws:RequestedRegion" = local.requested_region }
        }
      },

      # Create ELB service-linked role (first use in an account)
      {
        Sid      = "ELBServiceLinkedRole",
        Effect   = "Allow",
        Action   = ["iam:CreateServiceLinkedRole"],
        Resource = "arn:aws:iam::*:role/aws-service-role/elasticloadbalancing.amazonaws.com/AWSServiceRoleForElasticLoadBalancing"
      },

      # CloudWatch Logs meta for APIGW access logs & tagging checks
      {
        Sid    = "CloudWatchLogsMeta",
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:PutRetentionPolicy",
          "logs:TagResource",
          "logs:ListTagsForResource",
          "logs:DescribeLogGroups"
        ],
        Resource = "*"
      },

      # SSM Parameter Store (if you read/write NLB params like lb_arn, lb_dns_name)
      {
        Sid    = "SSMParameterReadWrite",
        Effect = "Allow",
        Action = [
          "ssm:GetParameter", "ssm:GetParameters", "ssm:PutParameter"
        ],
        Resource = "*"
      },

      # EC2 Describe (NLB needs these for subnets/sg/vpc lookups)
      {
        Sid    = "EC2Describe",
        Effect = "Allow",
        Action = [
          "ec2:DescribeVpcs",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeAccountAttributes"
        ],
        Resource = "*"
      }
    ]
  })
}

# Treat empty strings as "not provided"
locals {
  have_state_bucket = var.tf_state_bucket_arn != null && trimspace(var.tf_state_bucket_arn) != ""
  have_lock_table   = var.tf_lock_table_arn != null && trimspace(var.tf_lock_table_arn) != ""
}

resource "aws_iam_policy" "terraform_state" {
  count       = (local.have_state_bucket || local.have_lock_table) ? 1 : 0
  name        = "TerraformStateAccess"
  description = "Access to S3 bucket and DynamoDB table used for Terraform state/locks"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = concat(
      local.have_state_bucket ? [
        {
          Sid      = "S3State"
          Effect   = "Allow"
          Action   = ["s3:ListBucket"]
          Resource = (var.tf_state_bucket_name != null && trimspace(var.tf_state_bucket_name) != "") ? "arn:aws:s3:::${var.tf_state_bucket_name}" : var.tf_state_bucket_arn
        },
        {
          Sid      = "S3StateObjects"
          Effect   = "Allow"
          Action   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
          Resource = "${var.tf_state_bucket_arn}/*"
        }
      ] : [],
      local.have_lock_table ? [
        {
          Sid    = "DynamoDBLocks"
          Effect = "Allow"
          Action = [
            "dynamodb:DescribeTable",
            "dynamodb:GetItem", "dynamodb:PutItem",
            "dynamodb:UpdateItem", "dynamodb:DeleteItem"
          ]
          Resource = var.tf_lock_table_arn
        }
      ] : []
    )
  })
}


# Attach to user or role
resource "aws_iam_user_policy_attachment" "exec_user" {
  count      = var.attach_to == "user" ? 1 : 0
  user       = data.aws_iam_user.target[0].user_name
  policy_arn = aws_iam_policy.terraform_execution.arn
}

resource "aws_iam_role_policy_attachment" "exec_role" {
  count      = var.attach_to == "role" ? 1 : 0
  role       = data.aws_iam_role.target[0].name
  policy_arn = aws_iam_policy.terraform_execution.arn
}

resource "aws_iam_user_policy_attachment" "state_user" {
  count      = var.attach_to == "user" && length(aws_iam_policy.terraform_state) > 0 ? 1 : 0
  user       = data.aws_iam_user.target[0].user_name
  policy_arn = aws_iam_policy.terraform_state[0].arn
}

resource "aws_iam_role_policy_attachment" "state_role" {
  count      = var.attach_to == "role" && length(aws_iam_policy.terraform_state) > 0 ? 1 : 0
  role       = data.aws_iam_role.target[0].name
  policy_arn = aws_iam_policy.terraform_state[0].arn
}
