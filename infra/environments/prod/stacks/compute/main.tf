terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

# Fallback so you can set either tf_state_region OR remote_state_region OR just use var.region
locals {
  remote_state_region = coalesce(var.tf_state_region, var.remote_state_region, var.region)
}

# Read NETWORK stack state from S3
data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = var.tf_state_bucket
    key    = var.network_state_key
    region = local.remote_state_region
  }
}

module "compute" {
  source = "../../../../platform/core/compute"

  # basic
  env_name = var.env_name
  region   = var.region

  # network inputs from remote state
  vpc_id             = data.terraform_remote_state.network.outputs.vpc_id
  private_subnet_ids = data.terraform_remote_state.network.outputs.private_subnet_ids

  # security group + app ingress
  sg_name       = var.sg_name # FIX: was sg-name
  app_ports     = var.app_ports
  ingress_cidrs = var.ingress_cidrs

  # ec2
  ec2_name      = var.ec2_name
  instance_type = var.instance_type
  key_name      = var.key_name

  # AMI + agents
  ami_id                     = var.ami_id
  ami_ssm_parameter_name     = var.ami_ssm_parameter_name
  cloudwatch_ssm_config_path = var.cloudwatch_ssm_config_path

  # user-data (optional)
  user_data = var.user_data

  # IAM reuse knobs (leave null to auto-create env-prefixed names)
  ec2_ssm_role_name    = var.ec2_ssm_role_name    # FIX: key names
  ec2_ssm_profile_name = var.ec2_ssm_profile_name # FIX: key names

  # Optional S3 backup permission for EC2 agent
  s3_backup_arn = var.s3_backup_arn

  tags = var.tags
}
