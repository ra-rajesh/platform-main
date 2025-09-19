# NOTE: No provider block here (the stack calls this module and provides the provider).

# ---------------- Read inputs ----------------
data "aws_ssm_parameter" "lb_arn" {
  name = "${var.nlb_ssm_prefix}/lb_arn"
}

data "aws_ssm_parameter" "tg_map" {
  name = "${var.nlb_ssm_prefix}/target_group_arns"
}

locals {
  tg_by_port = jsondecode(data.aws_ssm_parameter.tg_map.value)
  tg_arn     = try(local.tg_by_port[tostring(var.port)], null)
  lb_arn     = data.aws_ssm_parameter.lb_arn.value

  # Get suffixes after "loadbalancer/" and "targetgroup/" WITHOUT regex/region/account
  # Works on older Terraform too.
  lb_suffix = element(split("loadbalancer/", local.lb_arn), length(split("loadbalancer/", local.lb_arn)) - 1)

  tg_suffix = local.tg_arn == null ? null : element(split("targetgroup/", local.tg_arn), length(split("targetgroup/", local.tg_arn)) - 1)
}

# ---------------- REST API state (REST v1). Metrics use ApiName + Stage ----------------
data "terraform_remote_state" "api" {
  backend = "s3"
  config = {
    bucket = var.rest_state_bucket
    key    = var.rest_state_key
    region = var.rest_state_region
  }
}

locals {
  rest_api_name = try(data.terraform_remote_state.api.outputs.rest_api_name, "idlms-api-${var.env_name}")
  stage_name    = try(data.terraform_remote_state.api.outputs.stage_name, var.env_name)
}

# ---------------- API Gateway (REST v1) Alarms ----------------
resource "aws_cloudwatch_metric_alarm" "api_5xx" {
  alarm_name          = "idlms-${var.env_name}-api-5xx"
  namespace           = "AWS/ApiGateway"
  metric_name         = "5XXError"
  dimensions          = { ApiName = local.rest_api_name, Stage = local.stage_name }
  period              = 60
  evaluation_periods  = 1
  statistic           = "Sum"
  threshold           = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"
  treat_missing_data  = "notBreaching"
  alarm_actions       = var.alarm_actions
  tags                = merge(var.tags, { Environment = var.env_name, Project = "IDLMS" })
}

resource "aws_cloudwatch_metric_alarm" "api_latency_p95" {
  alarm_name          = "idlms-${var.env_name}-api-latency-p95"
  namespace           = "AWS/ApiGateway"
  metric_name         = "Latency"
  dimensions          = { ApiName = local.rest_api_name, Stage = local.stage_name }
  period              = 60
  evaluation_periods  = 3
  extended_statistic  = "p95"
  threshold           = 1000
  comparison_operator = "GreaterThanOrEqualToThreshold"
  treat_missing_data  = "notBreaching"
  alarm_actions       = var.alarm_actions
  tags                = merge(var.tags, { Environment = var.env_name, Project = "IDLMS" })
}

# ---------------- NLB Alarms (only if TG for this port exists) ----------------
resource "aws_cloudwatch_metric_alarm" "nlb_unhealthy" {
  count               = local.tg_arn == null ? 0 : 1
  alarm_name          = "idlms-${var.env_name}-nlb-unhealthy-${var.port}"
  namespace           = "AWS/NetworkELB"
  metric_name         = "UnHealthyHostCount"
  dimensions          = { TargetGroup = local.tg_suffix, LoadBalancer = local.lb_suffix }
  period              = 60
  evaluation_periods  = 1
  statistic           = "Maximum"
  threshold           = 0
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"
  alarm_actions       = var.alarm_actions
  tags                = merge(var.tags, { Environment = var.env_name, Project = "IDLMS" })
}

resource "aws_cloudwatch_metric_alarm" "nlb_healthy_min" {
  count               = local.tg_arn == null ? 0 : 1
  alarm_name          = "idlms-${var.env_name}-nlb-healthy-min-${var.port}"
  namespace           = "AWS/NetworkELB"
  metric_name         = "HealthyHostCount"
  dimensions          = { TargetGroup = local.tg_suffix, LoadBalancer = local.lb_suffix }
  period              = 60
  evaluation_periods  = 1
  statistic           = "Minimum"
  threshold           = 1
  comparison_operator = "LessThanThreshold"
  treat_missing_data  = "breaching"
  alarm_actions       = var.alarm_actions
  tags                = merge(var.tags, { Environment = var.env_name, Project = "IDLMS" })
}

# ---------------- Dashboard (no tags supported on this resource) ----------------
resource "aws_cloudwatch_dashboard" "idlms" {
  dashboard_name = "IDLMS-${var.env_name}"
  dashboard_body = jsonencode({
    widgets = concat(
      [
        {
          "type" : "metric", "width" : 12, "height" : 6,
          "properties" : {
            "title" : "API Gateway 5XX Errors", "view" : "timeSeries", "stacked" : false,
            "metrics" : [["AWS/ApiGateway", "5XXError", "ApiName", local.rest_api_name, "Stage", local.stage_name]],
            "region" : var.region
          }
        },
        {
          "type" : "metric", "width" : 12, "height" : 6,
          "properties" : {
            "title" : "API Latency p95", "view" : "timeSeries", "stacked" : false,
            "metrics" : [["AWS/ApiGateway", "Latency", "ApiName", local.rest_api_name, "Stage", local.stage_name, { "stat" : "p95" }]],
            "region" : var.region
          }
        }
      ],
      local.tg_arn == null ? [] : [
        {
          "type" : "metric", "width" : 12, "height" : 6,
          "properties" : {
            "title" : "NLB UnHealthyHostCount", "view" : "timeSeries", "stacked" : false,
            "metrics" : [["AWS/NetworkELB", "UnHealthyHostCount", "TargetGroup", local.tg_suffix, "LoadBalancer", local.lb_suffix]],
            "region" : var.region
          }
        },
        {
          "type" : "metric", "width" : 12, "height" : 6,
          "properties" : {
            "title" : "NLB HealthyHostCount", "view" : "timeSeries", "stacked" : false,
            "metrics" : [["AWS/NetworkELB", "HealthyHostCount", "TargetGroup", local.tg_suffix, "LoadBalancer", local.lb_suffix]],
            "region" : var.region
          }
        }
      ]
    )
  })
}
