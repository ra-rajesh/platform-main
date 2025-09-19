terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}


resource "aws_route_table" "idlms_public_rt" {
  vpc_id = var.vpc_id
  tags   = merge(var.common_tags, { Name = var.route_table_name })
}

resource "aws_route" "idlms_public_route" {
  route_table_id         = aws_route_table.idlms_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = var.internet_gateway_id
}


resource "aws_route_table" "idlms_private_rt" {
  vpc_id = var.vpc_id
  tags   = merge(var.common_tags, { Name = var.route_table_name })
}

resource "aws_route" "idlms_private_route" {
  route_table_id         = aws_route_table.idlms_private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = var.nat_gateway_id
}
