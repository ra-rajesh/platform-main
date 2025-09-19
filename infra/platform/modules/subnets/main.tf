terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

# If your VPC is created in THIS module, replace var.vpc_id with aws_vpc.this.id.

resource "aws_subnet" "idlms_public_subnets" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = var.vpc_id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    var.common_tags,
    { Name = "IDLMS Public Subnet ${count.index + 1}" }
  )
}

resource "aws_subnet" "idlms_private_subnets" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = var.vpc_id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.azs[count.index]

  tags = merge(
    var.common_tags,
    { Name = "IDLMS Private Subnet ${count.index + 1}" }
  )
}
