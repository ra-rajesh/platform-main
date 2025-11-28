env_name    = "db-test"
region      = "us-east-1"
vpc_name                 = "db-test-vpc"
vpc_cidr                 = "10.90.0.0/16"
azs                      = ["us-east-1a", "us-east-1b", "us-east-1c"]
public_subnet_cidrs      = ["10.90.1.0/24", "10.90.2.0/24", "10.90.3.0/24"]
private_subnet_cidrs     = ["10.90.10.0/24", "10.90.20.0/24", "10.90.30.0/24"]
public_subnet_names      = ["db-test-public-1", "db-test-public-2", "db-test-public-3"]
private_subnet_names     = ["db-test-private-1", "db-test-private-2", "db-test-private-3"]
route_table_public_name  = "db-test-public-rt"
route_table_private_name = "db-test-private-rt"
internet_gateway_name    = "db-test-igw"
nat_gateway_name         = "db-test-natgw"
enable_dns_support       = true
enable_dns_hostnames     = true
instance_tenancy         = "default"

tags = {
  Environment = "db-test"
  Project     = "platform_main"
}
