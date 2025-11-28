env_name    = "test"
region      = "eu-north-1"
vpc_name                 = "test-vpc"
vpc_cidr                 = "10.11.0.0/16"
azs                      = ["eu-north-1a", "eu-north-1b", "eu-north-1c"]
public_subnet_cidrs      = ["10.11.1.0/24", "10.11.2.0/24", "10.11.3.0/24"]
private_subnet_cidrs     = ["10.11.10.0/24", "10.11.20.0/24", "10.11.30.0/24"]
public_subnet_names      = ["test-public-1", "test-public-2", "test-public-3"]
private_subnet_names     = ["test-private-1", "test-private-2", "test-private-3"]
route_table_public_name  = "test-public-rt"
route_table_private_name = "test-private-rt"
internet_gateway_name    = "test-igw"
nat_gateway_name         = "test-natgw"
enable_dns_support       = true
enable_dns_hostnames     = true
instance_tenancy         = "default"

tags = {
  Environment = "test"
  Project     = "platform_main"
}
