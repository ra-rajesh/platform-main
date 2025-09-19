data "aws_caller_identity" "current" {}

# Look up EC2 SSM role by name
data "aws_iam_role" "ec2" {
  name = var.ec2_role_name
}

# Allow EC2 to write/read last-successful-bundle for idlms-test (adjust path if you also want reuse)
resource "aws_iam_role_policy" "idlms_test_ssm_putparam" {
  name = "idlms-test-ssm-putparam"
  role = data.aws_iam_role.ec2.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["ssm:PutParameter", "ssm:GetParameter"],
        Resource = "arn:aws:ssm:${var.region}:${data.aws_caller_identity.current.account_id}:parameter/idlms/test/stage/*"
      }
    ]
  })
}
