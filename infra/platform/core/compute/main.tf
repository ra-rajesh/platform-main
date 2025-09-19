terraform {
  required_version = ">= 1.5.0"
  required_providers { aws = { source = "hashicorp/aws", version = ">= 5.0" } }
}

provider "aws" { region = var.region }

# Resolve AMI: explicit ami_id wins; else use SSM latest AL2023
data "aws_ssm_parameter" "ami_latest" {
  name = var.ami_ssm_parameter_name
}
locals {
  ami_effective = var.ami_id != null && var.ami_id != "" ? var.ami_id : data.aws_ssm_parameter.ami_latest.value
}

# SG MODULE — expects: vpc_id, sg_name, ingress_ports
module "sg_app" {
  source        = "../../modules/sg"
  vpc_id        = var.vpc_id
  sg_name       = "${var.env_name}-app-sg"
  ingress_ports = var.app_ports
  ingress_cidrs = var.ingress_cidrs
}

# IAM (reuse existing names if provided)
module "iam_ssm" {
  source                         = "../../modules/iam/ssm_instance"
  name                           = "${var.env_name}-ec2-ssm"
  tags                           = var.tags
  existing_role_name             = var.existing_iam_role_name
  existing_instance_profile_name = var.existing_instance_profile_name
}

# EC2 MODULE — expects: security_group_ids, instance_profile_name
module "ec2" {
  source                     = "../../modules/ec2"
  name                       = var.ec2_name
  ami_id                     = local.ami_effective
  instance_type              = var.instance_type
  subnet_id                  = var.private_subnet_ids[0]
  security_group_ids         = [module.sg_app.security_group_id]
  instance_profile_name      = module.iam_ssm.instance_profile_name
  key_name                   = var.key_name
  cloudwatch_ssm_config_path = var.cloudwatch_ssm_config_path
}
