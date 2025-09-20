# SNS for notifications
resource "aws_sns_topic" "ops" {
  name = "${var.env_name}-idlms-alarms"
  tags = var.common_tags
}

# Optional email subscription
resource "aws_sns_topic_subscription" "ops_email" {
  count     = length(var.alert_email) > 0 ? 1 : 0
  topic_arn = aws_sns_topic.ops.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

# NLB TG alarms — use a map with string keys (not sensitive)
locals {
  tg_suffixes_for_each = { for k, v in local.tg_suffixes : tostring(k) => v }
}

resource "aws_cloudwatch_metric_alarm" "tg_unhealthy" {
  for_each            = local.tg_suffixes_for_each
  alarm_name          = "${var.env_name}-tg-${each.key}-unhealthy"
  alarm_description   = "Unhealthy hosts in TG ${each.key} for 5 minutes"
  namespace           = "AWS/NetworkELB"
  metric_name         = "UnHealthyHostCount"
  statistic           = "Average"
  period              = 60
  evaluation_periods  = 5
  threshold           = 0
  comparison_operator = "GreaterThanThreshold"

  dimensions = {
    TargetGroup  = each.value
    LoadBalancer = local.lb_suffix
  }

  alarm_actions = [aws_sns_topic.ops.arn]
  ok_actions    = [aws_sns_topic.ops.arn]
  tags          = var.common_tags
}

# EC2 instance lookup
data "aws_instances" "app" {
  instance_tags = { Name = var.instance_name_tag }

  filter {
    name   = "instance-state-name"
    values = ["pending", "running", "stopping", "stopped"]
  }
}

locals {
  instance_id = length(data.aws_instances.app.ids) > 0 ? data.aws_instances.app.ids[0] : null
}

resource "aws_cloudwatch_metric_alarm" "ec2_status_failed" {
  count               = local.instance_id == null ? 0 : 1
  alarm_name          = "${var.env_name}-ec2-statuscheckfailed"
  alarm_description   = "EC2 status check failed"
  namespace           = "AWS/EC2"
  metric_name         = "StatusCheckFailed"
  statistic           = "Maximum"
  period              = 60
  evaluation_periods  = 2
  threshold           = 0
  comparison_operator = "GreaterThanThreshold"
  dimensions          = { InstanceId = local.instance_id }
  alarm_actions       = [aws_sns_topic.ops.arn]
  ok_actions          = [aws_sns_topic.ops.arn]
  tags                = var.common_tags
}

resource "aws_cloudwatch_metric_alarm" "ec2_cpu_high" {
  count               = local.instance_id == null ? 0 : 1
  alarm_name          = "${var.env_name}-ec2-cpu-high"
  alarm_description   = "EC2 CPU > 80% for 10 minutes"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  statistic           = "Average"
  period              = 60
  evaluation_periods  = 10
  threshold           = 80
  comparison_operator = "GreaterThanThreshold"
  dimensions          = { InstanceId = local.instance_id }
  alarm_actions       = [aws_sns_topic.ops.arn]
  ok_actions          = [aws_sns_topic.ops.arn]
  tags                = var.common_tags
}

# API Gateway 5XX burst
resource "aws_cloudwatch_metric_alarm" "api_5xx" {
  alarm_name          = "${var.env_name}-${var.api_name}-${var.api_stage}-5xx"
  alarm_description   = "API Gateway 5XX errors >= 5 in 5 minutes"
  namespace           = "AWS/ApiGateway"
  metric_name         = "5XXError"
  statistic           = "Sum"
  period              = 60
  evaluation_periods  = 5
  threshold           = 5
  comparison_operator = "GreaterThanOrEqualToThreshold"

  dimensions = {
    ApiName = var.api_name
    Stage   = var.api_stage
  }

  alarm_actions = [aws_sns_topic.ops.arn]
  ok_actions    = [aws_sns_topic.ops.arn]
  tags          = var.common_tags
}
