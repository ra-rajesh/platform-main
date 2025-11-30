locals {
  tags = merge(
    {
      "user:Project" = "Platform-Main"
      "user:Env"     = var.env_name
      "user:Stack"   = "rest-api"
      "Environment"  = var.env_name
    },
    var.tags
  )
}

# --- CloudWatch IAM Role for API Gateway Execution Logs ---
resource "aws_iam_role" "apigw_cw" {
  name = "${var.env_name}-apigw-cloudwatch-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "apigateway.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "apigw_cw_attach" {
  role       = aws_iam_role.apigw_cw.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}

resource "aws_api_gateway_account" "this" {
  cloudwatch_role_arn = aws_iam_role.apigw_cw.arn
  depends_on          = [aws_iam_role_policy_attachment.apigw_cw_attach]
}

# --- Compute correct backend state bucket for NLB ---
data "aws_caller_identity" "current" {}

locals {
  resolved_tf_bucket = length(var.tf_bucket) > 0 ? var.tf_bucket : "${var.env_name}-btl-platform-main-repo-backend-tfstate-${data.aws_caller_identity.current.account_id}"
}

# --- Remote-state: read NLB outputs from platform-main ---
data "terraform_remote_state" "nlb" {
  backend = "s3"
  config = {
    bucket  = local.resolved_tf_bucket
    key     = "${var.env_name}/platform-main/nlb/terraform.tfstate"
    region  = var.region
    encrypt = true
  }
}

# --- Resolve effective NLB details (allow overrides via variables) ---
locals {
  effective_nlb_arn      = length(var.nlb_arn) > 0 ? var.nlb_arn : data.terraform_remote_state.nlb.outputs.lb_arn
  effective_nlb_dns_name = length(var.nlb_dns_name) > 0 ? var.nlb_dns_name : data.terraform_remote_state.nlb.outputs.lb_dns_name
}

# --- REST API module (container layer) ---
module "rest_api" {
  source = "../../../../platform/container/rest-api"

  # Identity / basics
  env_name    = var.env_name
  region      = var.region
  api_name    = var.api_name
  stage_name  = var.stage_name
  description = var.description

  # NLB connectivity (direct values; SSM fallback is disabled here)
  nlb_arn        = local.effective_nlb_arn
  nlb_dns_name   = local.effective_nlb_dns_name
  nlb_ssm_prefix = null

  # Routes (empty => create seed /health)
  routes        = var.routes
  endpoint_type = var.endpoint_type

  # CloudWatch logging configs (container module enables exec + access logs)
  access_log_retention_days = var.access_log_retention_days
  enable_execution_logs     = true
  execution_metrics_enabled = true
  execution_data_trace      = false

  # IMPORTANT: must be true to create Stage/Deployment and seed when routes = {}
  create_stage_and_deployment = true

  tags = local.tags

  depends_on = [aws_api_gateway_account.this]
}
