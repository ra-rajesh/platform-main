provider "aws" {
  region = var.region
}

# 1) VPC only
module "vpc" {
  source               = "../../modules/vpc"
  env_name             = var.env_name
  vpc_name             = var.vpc_name
  region               = var.region
  vpc_cidr             = var.vpc_cidr
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames
  instance_tenancy     = var.instance_tenancy
  tags                 = var.tags
}

# 2) Subnets (needs azs & CIDR lists)
module "subnets" {
  source               = "../../modules/subnets"
  vpc_id               = module.vpc.vpc_id
  azs                  = var.azs
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

# 3) Internet Gateway
module "igw" {
  source                = "../../modules/igw"
  vpc_id                = module.vpc.vpc_id
  internet_gateway_name = "${var.env_name}-igw"
  common_tags           = var.tags
}

# 4) NAT (your module creates 1 NAT in the first public subnet)
module "nat" {
  source            = "../../modules/natgw"
  public_subnet_ids = module.subnets.public_subnet_ids
  nat_gateway_name  = "${var.env_name}-natgw"
  common_tags       = var.tags
}

# 5) Route tables (public + private)
module "rt" {
  source              = "../../modules/rt"
  vpc_id              = module.vpc.vpc_id
  internet_gateway_id = module.igw.internet_gateway_id
  nat_gateway_id      = module.nat.nat_gateway_id
  route_table_name    = "${var.env_name}-rt"
  common_tags         = var.tags
}

# 6) Associations (run twice: once for public, once for private)
module "rta_public" {
  source             = "../../modules/rta"
  route_table_id     = module.rt.public_route_table_id
  public_subnet_ids  = module.subnets.public_subnet_ids
  private_subnet_ids = []
}

module "rta_private" {
  source             = "../../modules/rta"
  route_table_id     = module.rt.private_route_table_id
  public_subnet_ids  = []
  private_subnet_ids = module.subnets.private_subnet_ids
}
