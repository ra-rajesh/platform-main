env_name             = "stage"
region               = "ap-south-1"
vpc_name             = "stage-idlms-vpc"
vpc_cidr             = "10.10.0.0/16"
azs                  = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
public_subnet_cidrs  = ["10.10.1.0/24", "10.10.2.0/24", "10.10.3.0/24"]
private_subnet_cidrs = ["10.10.10.0/24", "10.10.20.0/24", "10.10.30.0/24"]
enable_dns_support   = true
enable_dns_hostnames = true
instance_tenancy     = "default"

tags = {
  Environment = "stage"
  Project     = "IDLMS"
}
