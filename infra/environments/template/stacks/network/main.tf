module "network" {
  source                   = "../../../../platform/core/network"
  env_name                 = var.env_name
  region                   = var.region
  vpc_name                 = var.vpc_name
  vpc_cidr                 = var.vpc_cidr
  azs                      = var.azs
  public_subnet_cidrs      = var.public_subnet_cidrs
  private_subnet_cidrs     = var.private_subnet_cidrs
  public_subnet_names      = var.public_subnet_names
  private_subnet_names     = var.private_subnet_names
  route_table_public_name  = var.route_table_public_name
  route_table_private_name = var.route_table_private_name
  internet_gateway_name    = var.internet_gateway_name
  nat_gateway_name         = var.nat_gateway_name
  enable_dns_support       = var.enable_dns_support
  enable_dns_hostnames     = var.enable_dns_hostnames
  instance_tenancy         = var.instance_tenancy
  #   nat_gateway_mode     = var.nat_gateway_mode
  tags = var.tags
}



