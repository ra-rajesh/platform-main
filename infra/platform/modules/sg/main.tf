terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

resource "aws_security_group" "idlms_sg" {
  name        = var.sg_name
  description = var.description
  vpc_id      = var.vpc_id
  tags        = merge(var.common_tags, { Name = var.sg_name })
}

locals {
  # Build cartesian pairs of (port x cidr) so each becomes its own rule.
  ipv4_pairs = flatten([
    for p in var.ingress_ports : [
      for c in var.ingress_cidrs : {
        port = p
        cidr = c
      }
    ]
  ])

  # ipv6_pairs = flatten([
  #   for p in var.ingress_ports : [
  #     for c in var.ingress_ipv6_cidrs : {
  #       port = p
  #       cidr = c
  #     }
  #   ]
  # ])

  # sg_pairs = flatten([
  #   for p in var.ingress_ports : [
  #     for sg in var.source_security_group_ids : {
  #       port = p
  #       sg   = sg
  #     }
  #   ]
  # ])
}

# Ingress from IPv4 CIDRs (one rule per {port,cidr})
resource "aws_vpc_security_group_ingress_rule" "ipv4" {
  for_each = {
    for pair in local.ipv4_pairs :
    "${pair.port}_${replace(replace(pair.cidr, "/", "-"), ".", "_")}" => pair
  }

  security_group_id = aws_security_group.idlms_sg.id
  cidr_ipv4         = each.value.cidr
  from_port         = each.value.port
  to_port           = each.value.port
  ip_protocol       = "tcp"
  description       = "Allow TCP ${each.value.port} from ${each.value.cidr}"
}

# # Ingress from IPv6 CIDRs
# resource "aws_vpc_security_group_ingress_rule" "ipv6" {
#   for_each = {
#     for pair in local.ipv6_pairs :
#     "v6_${pair.port}_${replace(replace(pair.cidr, "/", "-"), ":", "_")}" => pair
#   }

#   security_group_id = aws_security_group.this.id
#   cidr_ipv6         = each.value.cidr
#   from_port         = each.value.port
#   to_port           = each.value.port
#   ip_protocol       = "tcp"
#   description       = "Allow TCP ${each.value.port} from ${each.value.cidr}"
# }

# # Ingress from other Security Groups
# resource "aws_vpc_security_group_ingress_rule" "from_sg" {
#   for_each = {
#     for pair in local.sg_pairs : "${pair.port}_${pair.sg}" => pair
#   }

#   security_group_id              = aws_security_group.this.id
#   referenced_security_group_id   = each.value.sg
#   from_port                      = each.value.port
#   to_port                        = each.value.port
#   ip_protocol                    = "tcp"
#   description                    = "Allow TCP ${each.value.port} from SG ${each.value.sg}"
# }

# Egress: allow all (typical). Disable by setting allow_all_egress = false and add your own egress rules.
resource "aws_vpc_security_group_egress_rule" "all" {
  count             = var.allow_all_egress ? 1 : 0
  security_group_id = aws_security_group.idlms_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  description       = "Allow all outbound traffic"
}
