env_name                 = "prod"
region                   = "ap-south-1"
vpc_name                 = "prod-vpc"
vpc_cidr                 = "10.10.0.0/16"
azs                      = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
public_subnet_cidrs      = ["10.10.1.0/24", "10.10.2.0/24", "10.10.3.0/24"]
private_subnet_cidrs     = ["10.10.10.0/24", "10.10.20.0/24", "10.10.30.0/24"]
public_subnet_names      = ["prod-public-1", "prod-public-2", "prod-public-3"]
private_subnet_names     = ["prod-private-1", "prod-private-2", "prod-private-3"]
route_table_public_name  = "prod-public-rt"
route_table_private_name = "prod-private-rt"
internet_gateway_name    = "prod-igw"
nat_gateway_name         = "prod-natgw"
enable_dns_support       = true
enable_dns_hostnames     = true
instance_tenancy         = "default"

tags = {
  Environment = "prod"
  Project     = "platform_main"
}
