terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

resource "aws_subnet" "platform_main_public_subnets" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = var.vpc_id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    var.common_tags,
    {
      Name = length(var.public_subnet_names) > 0 ? var.public_subnet_names[count.index] : "${var.env_name} Public Subnet ${count.index + 1}"
    }
  )
}

resource "aws_subnet" "platform_main_private_subnets" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = var.vpc_id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.azs[count.index]

  tags = merge(
    var.common_tags,
    {
      Name = length(var.private_subnet_names) > 0 ? var.private_subnet_names[count.index] : "${var.env_name} Private Subnet ${count.index + 1}"
    }
  )
}
