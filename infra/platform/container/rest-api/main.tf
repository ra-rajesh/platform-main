# --- Read NLB details from SSM ---
data "aws_ssm_parameter" "lb_arn" {
  name = "${var.nlb_ssm_prefix}/lb_arn"
}

data "aws_ssm_parameter" "lb_dns_name" {
  name = "${var.nlb_ssm_prefix}/lb_dns_name"
}

locals {
  nlb_arn      = data.aws_ssm_parameter.lb_arn.value
  nlb_dns_name = data.aws_ssm_parameter.lb_dns_name.value

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
  first_route_url = local.first_route_key == null ? null : "http://${local.nlb_dns_name}:${local.first_route.port}"
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
  target_arns = [local.nlb_arn]
  tags        = var.tags
}

# --- REST API ---
resource "aws_api_gateway_rest_api" "this" {
  name        = "${var.api_name}-${var.env_name}"
  description = var.description

  endpoint_configuration {
    types = [var.endpoint_type]
  }

  tags = var.tags
}

# --- ROOT (GET /) → first route's /health ---
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

# --- For each route: resources ---
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

# --- NEW: Base path ANY on /{app} -> http://NLB:<port>/ ---
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
  uri                     = "http://${local.nlb_dns_name}:${each.value.port}/"
}

# --- Proxy ANY on /{app}/{proxy+} -> http://NLB:<port>/{proxy} ---
resource "aws_api_gateway_method" "route_any" {
  for_each      = local.routes
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.route_proxy[each.key].id
  http_method   = "ANY"
  authorization = "NONE"

  request_parameters = {
    "method.request.path.proxy" = true
  }
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
  uri                     = "http://${local.nlb_dns_name}:${each.value.port}/{proxy}"

  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }
}

# --- Deployment (re-deploy when integrations change) ---
resource "aws_api_gateway_deployment" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id

  triggers = {
    redeploy_hash = sha1(jsonencode([
      aws_api_gateway_integration.root_get.*.id,
      values(aws_api_gateway_integration.route_base_any)[*].id,
      values(aws_api_gateway_integration.route_any)[*].id
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

# --- Stage with Access logs ---
resource "aws_cloudwatch_log_group" "access_logs" {
  name              = "/aws/api-gateway/${var.stage_name}/${var.api_name}/access"
  retention_in_days = var.access_log_retention_days
  tags              = var.tags
}

# resource "aws_cloudwatch_log_group" "execution_logs" {
#   name              = "/aws/api-gateway/${var.stage_name}/${var.api_name}/execution"
#   retention_in_days = var.access_log_retention_days
#   tags              = var.tags
# }

resource "aws_api_gateway_stage" "this" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  stage_name    = var.stage_name
  deployment_id = aws_api_gateway_deployment.this.id

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.access_logs.arn
    format          = <<EOF
{"timestamp":"$context.requestTime","apiId":"$context.apiId","domainName":"$context.domainName","httpMethod":"$context.httpMethod","path":"$context.resourcePath","protocol":"$context.protocol","requestId":"$context.requestId","responseLatency":$context.responseLatency,"responseLength":$context.responseLength,"sourceIp":"$context.identity.sourceIp","stage":"$context.stage","status":$context.status,"userAgent":"$context.identity.userAgent","integrationStatus":$context.integrationStatus,"error":"$context.error.message","integrationError":"$context.integrationErrorMessage"}
EOF
  }

  tags = var.tags
}

# --- Allow API Gateway to write execution logs ---
resource "aws_api_gateway_account" "this" {
  cloudwatch_role_arn = aws_iam_role.apigw_logs.arn
}

# --- Method settings (INFO logs/metrics) ---
resource "aws_api_gateway_method_settings" "all" {
  count       = var.enable_execution_logs ? 1 : 0
  rest_api_id = aws_api_gateway_rest_api.this.id
  stage_name  = aws_api_gateway_stage.this.stage_name
  method_path = "*/*"

  settings {
    metrics_enabled    = var.execution_metrics_enabled
    logging_level      = "INFO" # or "ERROR"
    data_trace_enabled = var.execution_data_trace
  }

  depends_on = [aws_api_gateway_stage.this, aws_api_gateway_account.this]
}
