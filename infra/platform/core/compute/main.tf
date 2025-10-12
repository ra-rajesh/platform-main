terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# AMI: prefer explicit var.ami_id, else SSM param value
data "aws_ssm_parameter" "ami_latest" {
  name = var.ami_ssm_parameter_name
}

locals {
  ami_effective = (
    var.ami_id != null && var.ami_id != ""
  ) ? var.ami_id : data.aws_ssm_parameter.ami_latest.value
}

# ---------------- SG (app) ----------------
module "sg_app" {
  source        = "../../modules/sg"
  vpc_id        = var.vpc_id
  sg_name       = var.sg_name # FIX: sg_name (no hyphen)
  ingress_ports = var.app_ports
  ingress_cidrs = var.ingress_cidrs
}

# ---------------- IAM + SSM (env-prefixed role/profile) ----------------
module "iam_ssm" {
  source = "../../modules/iam/ssm_instance"

  # Let the module derive names like "<env>-ec2-ssm-role" / "<env>-ec2-ssm-instance-profile"
  env_name = var.env_name
  tags     = var.tags

  # If you want to reuse existing names, set these; leave null to CREATE env-prefixed ones
  existing_role_name             = var.ec2_ssm_role_name
  existing_instance_profile_name = var.ec2_ssm_profile_name

  enable_ecr_pull         = true
  enable_describe_helpers = true
  s3_backup_arn           = var.s3_backup_arn

  # NOTE: do not pass ssm_parameter_arns; we use AWS-managed AmazonSSMReadOnlyAccess
}

# ---------------- EC2 ----------------
module "ec2" {
  source = "../../modules/ec2"

  name                  = var.ec2_name
  ami_id                = local.ami_effective
  instance_type         = var.instance_type
  subnet_id             = var.private_subnet_ids[0]
  security_group_ids    = [module.sg_app.security_group_id]
  instance_profile_name = module.iam_ssm.instance_profile_name
  key_name              = var.key_name

  cloudwatch_ssm_config_path = var.cloudwatch_ssm_config_path
  user_data                  = var.user_data
}
