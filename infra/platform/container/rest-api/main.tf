# --- NLB values: prefer direct, fallback to SSM (only if prefix is provided) ---
data "aws_ssm_parameter" "lb_arn" {
  count = var.nlb_arn == null && var.nlb_ssm_prefix != null ? 1 : 0
  name  = "${var.nlb_ssm_prefix}/stage/lb_arn"
}

data "aws_ssm_parameter" "lb_dns_name" {
  count = var.nlb_dns_name == null && var.nlb_ssm_prefix != null ? 1 : 0
  name  = "${var.nlb_ssm_prefix}/stage/lb_dns_name"
}

locals {
  # Prefer direct values, else fallback to SSM if enabled and present
  lb_arn = var.nlb_arn != null ? var.nlb_arn : (var.nlb_ssm_prefix != null && length(data.aws_ssm_parameter.lb_arn) > 0 ? data.aws_ssm_parameter.lb_arn[0].value : null)

  lb_dns_name = var.nlb_dns_name != null ? var.nlb_dns_name : (var.nlb_ssm_prefix != null && length(data.aws_ssm_parameter.lb_dns_name) > 0
  ? data.aws_ssm_parameter.lb_dns_name[0].value : null)

  # Normalize health_path default
  routes = {
    for k, v in var.routes :
    k => {
      port        = v.port
      health_path = coalesce(try(v.health_path, null), "/health")
    }
  }

  first_route_key = try(keys(local.routes)[0], null)
  first_route     = try(local.routes[local.first_route_key], null)
  first_route_url = (local.first_route_key != null && local.lb_dns_name != null) ? "http://${local.lb_dns_name}:${local.first_route.port}" : null
}

# Hard validation: ensure we ended up with values from either direct vars or SSM.
resource "null_resource" "validate_nlb_inputs" {
  triggers = {
    lb_arn      = tostring(local.lb_arn)
    lb_dns_name = tostring(local.lb_dns_name)
  }

  lifecycle {
    precondition {
      condition     = local.lb_arn != null && local.lb_dns_name != null
      error_message = "NLB details missing. Provide nlb_arn and nlb_dns_name via tfvars, or set nlb_ssm_prefix to a valid SSM path that contains /stage/lb_arn and /stage/lb_dns_name."
    }
  }
}

# --- IAM role for API Gateway execution logs ---
data "aws_iam_policy_document" "apigw_logs_assume" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "apigw_logs" {
  name               = "${var.env_name}-apigw-logs-role"
  assume_role_policy = data.aws_iam_policy_document.apigw_logs_assume.json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "apigw_logs_attach" {
  role       = aws_iam_role.apigw_logs.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}

# --- VPC Link to NLB ---
resource "aws_api_gateway_vpc_link" "this" {
  name        = "${var.api_name}-vpc-link-${var.env_name}"
  target_arns = [local.lb_arn]
  tags        = var.tags
}

# --- REST API ---
resource "aws_api_gateway_rest_api" "this" {
  name        = "${var.env_name}-${var.api_name}"
  description = var.description
  endpoint_configuration { types = [var.endpoint_type] }
  tags = var.tags
}

# (Optional) Precreate the execution log group so you can see it immediately in CW Logs  # <<<
resource "aws_cloudwatch_log_group" "execution_logs" {
  name              = "API-Gateway-Execution-Logs_${aws_api_gateway_rest_api.this.id}/${var.stage_name}"
  retention_in_days = var.access_log_retention_days
  tags              = var.tags
}

# --- ROOT (GET /) -> first route's /health ---
resource "aws_api_gateway_method" "root_get" {
  count         = local.first_route_key == null ? 0 : 1
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_rest_api.this.root_resource_id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "root_get" {
  count                   = local.first_route_key == null ? 0 : 1
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_rest_api.this.root_resource_id
  http_method             = aws_api_gateway_method.root_get[0].http_method
  type                    = "HTTP_PROXY"
  connection_type         = "VPC_LINK"
  connection_id           = aws_api_gateway_vpc_link.this.id
  integration_http_method = "GET"
  uri                     = "${local.first_route_url}${local.first_route.health_path}"
}

# --- For each route: resources & methods ---
resource "aws_api_gateway_resource" "route_base" {
  for_each    = local.routes
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = each.key
}

resource "aws_api_gateway_resource" "route_proxy" {
  for_each    = local.routes
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_resource.route_base[each.key].id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "route_base_any" {
  for_each      = local.routes
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.route_base[each.key].id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "route_base_any" {
  for_each                = local.routes
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_resource.route_base[each.key].id
  http_method             = aws_api_gateway_method.route_base_any[each.key].http_method
  type                    = "HTTP_PROXY"
  connection_type         = "VPC_LINK"
  connection_id           = aws_api_gateway_vpc_link.this.id
  integration_http_method = "ANY"
  uri                     = "http://${local.lb_dns_name}:${each.value.port}/"
}

resource "aws_api_gateway_method" "route_any" {
  for_each           = local.routes
  rest_api_id        = aws_api_gateway_rest_api.this.id
  resource_id        = aws_api_gateway_resource.route_proxy[each.key].id
  http_method        = "ANY"
  authorization      = "NONE"
  request_parameters = { "method.request.path.proxy" = true }
}

resource "aws_api_gateway_integration" "route_any" {
  for_each                = local.routes
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_resource.route_proxy[each.key].id
  http_method             = aws_api_gateway_method.route_any[each.key].http_method
  type                    = "HTTP_PROXY"
  connection_type         = "VPC_LINK"
  connection_id           = aws_api_gateway_vpc_link.this.id
  integration_http_method = "ANY"
  uri                     = "http://${local.lb_dns_name}:${each.value.port}/{proxy}"
  request_parameters      = { "integration.request.path.proxy" = "method.request.path.proxy" }
}

# Only create deployment if routes exist
resource "aws_api_gateway_deployment" "this" {
  count       = var.create_stage_and_deployment ? 1 : 0
  rest_api_id = aws_api_gateway_rest_api.this.id

  # keep your existing triggers; example:
  triggers = {
    redeploy_hash = sha1(jsonencode({
      # include whatever you use to trigger redeploys
      lb_arn = try(local.lb_arn, null)
      routes = try(local.routes, {})
    }))
  }

  lifecycle { create_before_destroy = true }
}

# --- Access logs (stable path per env/api) ---
resource "aws_cloudwatch_log_group" "access_logs" {
  name              = "/aws/api-gateway/${var.stage_name}/${var.api_name}/access"
  retention_in_days = var.access_log_retention_days
  tags              = var.tags
}

# Stage
resource "aws_api_gateway_stage" "this" {
  count = var.create_stage_and_deployment ? 1 : 0

  rest_api_id   = aws_api_gateway_rest_api.this.id
  deployment_id = aws_api_gateway_deployment.this[0].id
  stage_name    = var.stage_name

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.access_logs.arn

    format = <<EOF
{"timestamp":"$context.requestTime","apiId":"$context.apiId","domainName":"$context.domainName","httpMethod":"$context.httpMethod","path":"$context.resourcePath","protocol":"$context.protocol","requestId":"$context.requestId","responseLatency":$context.responseLatency,"responseLength":$context.responseLength,"sourceIp":"$context.identity.sourceIp","stage":"$context.stage","status":$context.status,"userAgent":"$context.identity.userAgent","integrationStatus":"$context.integration.status","integrationLatency":$context.integration.latency,"integrationError":"$context.integration.error"}
EOF
  }

  tags = var.tags

  # Ensure CloudWatch role is in place before stage is evaluated                 # <<<
  depends_on = [
    aws_cloudwatch_log_group.access_logs,
    aws_cloudwatch_log_group.execution_logs, # precreated exec group (optional)
    aws_iam_role_policy_attachment.apigw_logs_attach
  ]
}

# --- Account-level logs role (singleton) ---
resource "aws_api_gateway_account" "this" {
  cloudwatch_role_arn = aws_iam_role.apigw_logs.arn
  depends_on          = [aws_iam_role_policy_attachment.apigw_logs_attach]
}

# Global method settings (*/*) → enables EXECUTION LOGGING
resource "aws_api_gateway_method_settings" "all" {
  count = var.create_stage_and_deployment ? 1 : 0

  rest_api_id = aws_api_gateway_rest_api.this.id
  stage_name  = var.stage_name
  method_path = "*/*"

  settings {
    logging_level      = "INFO"
    metrics_enabled    = true
    data_trace_enabled = false
  }

  # Make execution logging wait until account-level CW role is wired             # <<<
  depends_on = [
    aws_api_gateway_stage.this,
    aws_api_gateway_account.this
  ]
}
