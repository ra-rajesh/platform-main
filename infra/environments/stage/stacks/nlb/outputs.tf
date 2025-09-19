output "lb_arn"              { value = module.nlb.lb_arn }
output "lb_dns_name"         { value = module.nlb.lb_dns_name }
output "lb_zone_id"          { value = module.nlb.lb_zone_id }
output "listener_arns"       { value = module.nlb.listener_arns }
output "target_group_arns"   { value = module.nlb.target_group_arns }
