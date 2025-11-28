env_name    = "test-1"
region      = "eu-north-1"
vpc_name                 = "test-1-vpc"
vpc_cidr                 = "10.20.0.0/16"
azs                      = ["eu-north-1a", "eu-north-1b", "eu-north-1c"]
public_subnet_cidrs      = ["10.20.1.0/24", "10.20.2.0/24", "10.20.3.0/24"]
private_subnet_cidrs     = ["10.20.10.0/24", "10.20.20.0/24", "10.20.30.0/24"]
public_subnet_names      = ["test-1-public-1", "test-1-public-2", "test-1-public-3"]
private_subnet_names     = ["test-1-private-1", "test-1-private-2", "test-1-private-3"]
route_table_public_name  = "test-1-public-rt"
route_table_private_name = "test-1-private-rt"
internet_gateway_name    = "test-1-igw"
nat_gateway_name         = "test-1-natgw"
enable_dns_support       = true
enable_dns_hostnames     = true
instance_tenancy         = "default"

tags = {
  Environment = "test-1"
  Project     = "platform_main"
}
