locals {
  ports_map = { for p in var.ports : tostring(p) => p }
  attachments = flatten([
    for pk, _ in local.ports_map : [
      for id in var.target_instance_ids : {
        key    = "${pk}-${id}"
        port_k = pk
        id     = id
      }
    ]
  ])
}

resource "aws_lb" "this" {
  name                             = var.name
  internal                         = var.internal
  load_balancer_type               = "network"
  subnets                          = var.subnet_ids
  enable_cross_zone_load_balancing = var.cross_zone
  enable_deletion_protection       = false

  tags = merge(
    var.tags,
    { Name = var.name, Env = var.env_name }
  )
}

resource "aws_lb_target_group" "multi" {
  for_each    = local.ports_map
  name        = "${var.name}-${each.key}"
  port        = each.value
  protocol    = var.protocol
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    enabled             = true
    protocol            = var.hc_protocol == "" ? var.protocol : var.hc_protocol
    port                = "traffic-port"
    interval            = var.hc_interval
    timeout             = var.hc_timeout
    healthy_threshold   = var.hc_healthy_threshold
    unhealthy_threshold = var.hc_unhealthy_threshold
  }

  tags = var.tags
}

resource "aws_lb_listener" "this" {
  for_each          = aws_lb_target_group.multi
  load_balancer_arn = aws_lb.this.arn
  port              = tonumber(each.key)    # <-- FIX: use the port key
  protocol          = var.protocol

  default_action {
    type             = "forward"
    target_group_arn = each.value.arn
  }
}

resource "aws_lb_target_group_attachment" "instance_multi" {
  for_each         = { for o in local.attachments : o.key => o }
  target_group_arn = aws_lb_target_group.multi[each.value.port_k].arn
  target_id        = each.value.id
  port             = tonumber(each.value.port_k)
}

resource "aws_ssm_parameter" "lb_arn" {
  count = var.ssm_prefix == "" ? 0 : 1
  name  = "${var.ssm_prefix}/lb_arn"
  type  = "String"
  value = aws_lb.this.arn
}

resource "aws_ssm_parameter" "lb_dns" {
  count = var.ssm_prefix == "" ? 0 : 1
  name  = "${var.ssm_prefix}/lb_dns_name"
  type  = "String"
  value = aws_lb.this.dns_name
}

resource "aws_ssm_parameter" "lb_zone" {
  count = var.ssm_prefix == "" ? 0 : 1
  name  = "${var.ssm_prefix}/lb_zone_id"
  type  = "String"
  value = aws_lb.this.zone_id
}
