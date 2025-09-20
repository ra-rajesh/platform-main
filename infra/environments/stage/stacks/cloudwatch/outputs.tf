output "dashboard_name" {
  description = "CloudWatch dashboard name"
  value       = aws_cloudwatch_dashboard.nlb.dashboard_name
}

output "sns_topic_arn" {
  description = "SNS topic for alarms"
  value       = aws_sns_topic.ops.arn
}

output "api_5xx_alarm_name" {
  description = "API Gateway 5XX alarm"
  value       = aws_cloudwatch_metric_alarm.api_5xx.alarm_name
}

# One NLB TG alarm per port
output "tg_unhealthy_alarm_names" {
  description = "TargetGroup UnHealthyHostCount alarms (by port)"
  value       = [for a in aws_cloudwatch_metric_alarm.tg_unhealthy : a.alarm_name]
}

# EC2 alarms: return only names that exist (no conditionals needed)
output "ec2_alarm_names" {
  description = "EC2 alarms (StatusCheckFailed, CPU>80) if instance found"
  value = [
    for n in [
      try(aws_cloudwatch_metric_alarm.ec2_status_failed[0].alarm_name, null),
      try(aws_cloudwatch_metric_alarm.ec2_cpu_high[0].alarm_name, null)
    ] : n if n != null
  ]
}
