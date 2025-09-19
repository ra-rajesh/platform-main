output "lb_arn" {
  value = aws_lb.this.arn
}

output "lb_dns_name" {
  value = aws_lb.this.dns_name
}

output "lb_zone_id" {
  value = aws_lb.this.zone_id
}

output "listener_arns" {
  value = { for k, l in aws_lb_listener.this : k => l.arn }
}

output "target_group_arns" {
  value = { for k, g in aws_lb_target_group.multi : k => g.arn }
}
