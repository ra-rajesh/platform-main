terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

resource "aws_internet_gateway" "idlms_igw" {
  vpc_id = var.vpc_id
  tags   = merge(var.common_tags, { Name = var.internet_gateway_name })
}
