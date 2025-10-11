terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

resource "aws_eip" "platform_main_nat_eip" {
  domain = "vpc"
  tags   = merge(var.common_tags, { Name = "platform-main-nat-eip" })
}

resource "aws_nat_gateway" "platform_main_nat" {
  allocation_id = aws_eip.platform_main_nat_eip.id
  subnet_id     = var.public_subnet_ids[0]
  tags          = merge(var.common_tags, { Name = var.nat_gateway_name })
}
