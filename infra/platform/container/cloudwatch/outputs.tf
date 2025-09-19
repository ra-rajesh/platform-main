output "dashboard_name" {
  value = aws_cloudwatch_dashboard.idlms.dashboard_name
}

output "api_5xx_alarm_name" {
  value = aws_cloudwatch_metric_alarm.api_5xx.alarm_name
}

output "api_latency_p95_alarm" {
  value = aws_cloudwatch_metric_alarm.api_latency_p95.alarm_name
}

# NLB alarms are conditional (count = 0 or 1), so index safely
output "nlb_unhealthy_alarm" {
  value = try(aws_cloudwatch_metric_alarm.nlb_unhealthy[0].alarm_name, null)
}

output "nlb_healthy_min_alarm" {
  value = try(aws_cloudwatch_metric_alarm.nlb_healthy_min[0].alarm_name, null)
}
