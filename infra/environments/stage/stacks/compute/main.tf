terraform {
  required_version = ">= 1.5.0"
  required_providers { aws = { source = "hashicorp/aws", version = ">= 5.0" } }
}

data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = var.tf_state_bucket
    key    = var.network_state_key
    region = coalesce(var.remote_state_region, var.region)
  }
}

module "compute" {
  source = "../../../../platform/core/compute"

  env_name = var.env_name
  region   = var.region

  vpc_id             = data.terraform_remote_state.network.outputs.vpc_id
  private_subnet_ids = data.terraform_remote_state.network.outputs.private_subnet_ids

  ec2_name      = var.ec2_name
  instance_type = var.instance_type
  key_name      = var.key_name
  app_ports     = var.app_ports
  ingress_cidrs = var.ingress_cidrs

  ami_id                     = var.ami_id
  ami_ssm_parameter_name     = var.ami_ssm_parameter_name
  cloudwatch_ssm_config_path = var.cloudwatch_ssm_config_path
  docker_artifact_bucket     = var.docker_artifact_bucket

  existing_iam_role_name         = var.ec2_ssm_role_name
  existing_instance_profile_name = var.ec2_ssm_profile_name

  tags = var.tags
}

