env_name    = "dev"
region      = "ap-south-1"
vpc_name                 = "dev-vpc"
vpc_cidr                 = "10.10.0.0/16"
azs                      = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
public_subnet_cidrs      = ["10.10.1.0/24", "10.10.2.0/24", "10.10.3.0/24"]
private_subnet_cidrs     = ["10.10.10.0/24", "10.10.20.0/24", "10.10.30.0/24"]
public_subnet_names      = ["dev-public-1", "dev-public-2", "dev-public-3"]
private_subnet_names     = ["dev-private-1", "dev-private-2", "dev-private-3"]
route_table_public_name  = "dev-public-rt"
route_table_private_name = "dev-private-rt"
internet_gateway_name    = "dev-igw"
nat_gateway_name         = "dev-natgw"
enable_dns_support       = true
enable_dns_hostnames     = true
instance_tenancy         = "default"

tags = {
  Environment = "dev"
  Project     = "platform_main"
}
