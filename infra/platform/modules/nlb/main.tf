locals {
  use_subnet_mapping = length(var.subnet_mapping) > 0

  port_map = { for p in var.ports : tostring(p) => p }

  # Build flattened attachments for instance + ip modes
  inst_attach = flatten([
    for pk, _p in local.port_map : [
      for id in var.instance_ids : {
        key    = "${pk}-${id}"
        port_k = pk
        id     = id
      }
    ]
  ])
  ip_attach = flatten([
    for pk, _p in local.port_map : [
      for ip in var.ip_addresses : {
        key    = "${pk}-${ip}"
        port_k = pk
        ip     = ip
      }
    ]
  ])
}

resource "aws_lb" "this" {
  name                             = substr("${var.env_name}-${var.name}", 0, 32)
  internal                         = var.internal
  load_balancer_type               = "network"
  enable_cross_zone_load_balancing = var.cross_zone

  # Either subnets or subnet_mapping
  dynamic "subnet_mapping" {
    for_each = local.use_subnet_mapping ? var.subnet_mapping : []
    content {
      subnet_id            = subnet_mapping.value.subnet_id
      allocation_id        = try(subnet_mapping.value.allocation_id, null)
      private_ipv4_address = try(subnet_mapping.value.private_ipv4_address, null)
      ipv6_address         = try(subnet_mapping.value.ipv6_address, null)
    }
  }

  subnets = local.use_subnet_mapping ? null : var.subnet_ids

  tags = merge(var.tags, {
    Environment = var.env_name
    Name        = substr("${var.env_name}-${var.name}", 0, 32)
  })
}

resource "aws_lb_target_group" "multi" {
  for_each             = local.port_map
  name                 = substr("${var.env_name}-${var.name}-${each.value}", 0, 32)
  port                 = each.value
  protocol             = "TCP"
  vpc_id               = var.vpc_id
  target_type          = var.target_type
  deregistration_delay = var.deregistration_delay

  health_check {
    protocol = var.health_check_protocol
    port     = "traffic-port"
  }

  tags = var.tags
}

resource "aws_lb_listener" "this" {
  for_each           = local.port_map
  load_balancer_arn  = aws_lb.this.arn
  port               = each.value
  protocol           = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.multi[each.key].arn
  }
}

# Attach instances (when target_type = "instance")
resource "aws_lb_target_group_attachment" "instance_multi" {
  for_each         = var.target_type == "instance" ? { for o in local.inst_attach : o.key => o } : {}
  target_group_arn = aws_lb_target_group.multi[each.value.port_k].arn
  target_id        = each.value.id
  port             = tonumber(each.value.port_k)
}

# Attach IPs (when target_type = "ip")
resource "aws_lb_target_group_attachment" "ip_multi" {
  for_each         = var.target_type == "ip" ? { for o in local.ip_attach : o.key => o } : {}
  target_group_arn = aws_lb_target_group.multi[each.value.port_k].arn
  target_id        = each.value.ip
  port             = tonumber(each.value.port_k)
}
