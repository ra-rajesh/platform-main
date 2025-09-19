output "lb_arn"       { value = aws_lb.this.arn }
output "lb_dns_name"  { value = aws_lb.this.dns_name }
output "lb_zone_id"   { value = aws_lb.this.zone_id }
output "lb_name"      { value = aws_lb.this.name }

# Maps keyed by port (as string)
output "target_group_arns" {
  value = { for k, tg in aws_lb_target_group.multi : k => tg.arn }
}

output "listener_arns" {
  value = { for k, l in aws_lb_listener.this : k => l.arn }
}

output "attachment_ids" {
  value = concat(
    [for a in aws_lb_target_group_attachment.instance_multi : a.id],
    [for a in aws_lb_target_group_attachment.ip_multi : a.id]
  )
}
