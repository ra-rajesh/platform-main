locals {
  env_name = "stage"
  tags = {
    "user:Project" = "IDLMS"
    "user:Env"     = local.env_name
    "user:Stack"   = "nlb"
  }
}

data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket       = var.tf_state_bucket
    key          = var.network_state_key
    region       = var.tf_state_region
    encrypt      = true
    use_lockfile = true
  }
}

data "terraform_remote_state" "compute" {
  backend = "s3"
  config = {
    bucket       = var.tf_state_bucket
    key          = var.compute_state_key
    region       = var.tf_state_region
    encrypt      = true
    use_lockfile = true
  }
}

module "nlb" {
  source = "../../../../platform/container/nlb"

  env_name = local.env_name
  name     = "${local.env_name}-idlms-nlb"

  vpc_id     = data.terraform_remote_state.network.outputs.vpc_id
  subnet_ids = data.terraform_remote_state.network.outputs.private_subnet_ids

  internal   = true
  cross_zone = true
  protocol   = "TCP"
  ports      = var.ports

  # If not provided in tfvars, fall back to compute's single instance_id
  target_instance_ids = length(var.target_instance_ids) > 0 ? var.target_instance_ids : [
    data.terraform_remote_state.compute.outputs.instance_id
  ]

  ssm_prefix = var.ssm_prefix
  tags       = local.tags
}
