env_name    = "{{env.name}}"
region      = "{{aws.region}}"
vpc_name                 = "{{env.name}}-vpc"
vpc_cidr                 = "{{cidr.prefix}}.0.0/16"
azs                      = ["{{aws.region}}a", "{{aws.region}}b", "{{aws.region}}c"]
public_subnet_cidrs      = ["{{cidr.prefix}}.1.0/24", "{{cidr.prefix}}.2.0/24", "{{cidr.prefix}}.3.0/24"]
private_subnet_cidrs     = ["{{cidr.prefix}}.10.0/24", "{{cidr.prefix}}.20.0/24", "{{cidr.prefix}}.30.0/24"]
public_subnet_names      = ["{{env.name}}-public-1", "{{env.name}}-public-2", "{{env.name}}-public-3"]
private_subnet_names     = ["{{env.name}}-private-1", "{{env.name}}-private-2", "{{env.name}}-private-3"]
route_table_public_name  = "{{env.name}}-public-rt"
route_table_private_name = "{{env.name}}-private-rt"
internet_gateway_name    = "{{env.name}}-igw"
nat_gateway_name         = "{{env.name}}-natgw"
enable_dns_support       = true
enable_dns_hostnames     = true
instance_tenancy         = "default"

tags = {
  Environment = "{{env.name}}"
  Project     = "platform_main"
}
