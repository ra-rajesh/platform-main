
locals {
  tags = {
    "user:Project" = "Platform-Main"
    "user:Env"     = var.env_name
    "user:Stack"   = "ssm"
    "Project"      = "platform-main"
    "Environment"  = var.env_name
  }
}

data "aws_caller_identity" "current" {}

locals {
  resolved_tf_bucket = length(trimspace(var.tf_bucket)) > 0 ? var.tf_bucket : "${var.env_name}-btl-platform-main-repo-backend-tfstate-${data.aws_caller_identity.current.account_id}"
}

data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket  = local.resolved_tf_bucket
    key     = "${var.env_name}/platform-main/network/terraform.tfstate"
    region  = var.region
    encrypt = true
  }
}

data "terraform_remote_state" "compute" {
  backend = "s3"
  config = {
    bucket  = local.resolved_tf_bucket
    key     = "${var.env_name}/platform-main/compute/terraform.tfstate"
    region  = var.region
    encrypt = true
  }
}

data "terraform_remote_state" "nlb" {
  backend = "s3"
  config = {
    bucket  = local.resolved_tf_bucket
    key     = "${var.env_name}/platform-main/nlb/terraform.tfstate"
    region  = var.region
    encrypt = true
  }
}

data "terraform_remote_state" "rest_api" {
  backend = "s3"
  config = {
    bucket  = local.resolved_tf_bucket
    key     = "${var.env_name}/platform-main/rest-api/terraform.tfstate"
    region  = var.region
    encrypt = true
  }
}

module "ssm" {
  source = "../../../../platform/container/ssm"

  env_name    = var.env_name
  base_prefix = var.base_prefix
  overwrite   = var.overwrite
  tags        = local.tags

  # Network
  vpc_id             = data.terraform_remote_state.network.outputs.vpc_id
  private_subnet_ids = data.terraform_remote_state.network.outputs.private_subnet_ids

  # Compute
  instance_id           = data.terraform_remote_state.compute.outputs.instance_id
  instance_private_ip   = data.terraform_remote_state.compute.outputs.instance_private_ip
  iam_role_name         = data.terraform_remote_state.compute.outputs.iam_role_name
  instance_profile_name = data.terraform_remote_state.compute.outputs.instance_profile_name

  # NLB  (your NLB module outputs are MAPs; container wraps JSON)
  lb_dns_name       = data.terraform_remote_state.nlb.outputs.lb_dns_name
  lb_zone_id        = data.terraform_remote_state.nlb.outputs.lb_zone_id
  listener_arns     = data.terraform_remote_state.nlb.outputs.listener_arns
  target_group_arns = data.terraform_remote_state.nlb.outputs.target_group_arns

  # REST API (OK if blank; publisher skips empty strings)
  rest_api_id = try(data.terraform_remote_state.rest_api.outputs.rest_api_id, "")
  vpc_link_id = try(data.terraform_remote_state.rest_api.outputs.vpc_link_id, "")
  invoke_url  = try(data.terraform_remote_state.rest_api.outputs.invoke_url, "")
}
