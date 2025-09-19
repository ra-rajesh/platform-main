terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

resource "aws_eip" "idlms_nat_eip" {
  domain = "vpc"
  tags   = merge(var.common_tags, { Name = "idlms-nat-eip" })
}

resource "aws_nat_gateway" "idlms_nat" {
  allocation_id = aws_eip.idlms_nat_eip.id
  subnet_id     = var.public_subnet_ids[0]
  tags          = merge(var.common_tags, { Name = var.nat_gateway_name })
}
