locals {
  env_name = var.env_name
  tags = {
    "user:Project" = "Platform-Main"
    "user:Env"     = local.env_name
    "user:Stack"   = "nlb"
  }
}

# --- Remote state: network ---
data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket  = var.tf_state_bucket
    key     = var.network_state_key
    region  = var.tf_state_region
    encrypt = true
  }
}

# --- Remote state: compute ---
data "terraform_remote_state" "compute" {
  backend = "s3"
  config = {
    bucket  = var.tf_state_bucket
    key     = var.compute_state_key
    region  = var.tf_state_region
    encrypt = true
  }
}

module "nlb" {
  source = "../../../../platform/modules/nlb"

  env_name   = var.env_name
  nlb_name   = var.nlb_name
  vpc_id     = data.terraform_remote_state.network.outputs.vpc_id
  subnet_ids = data.terraform_remote_state.network.outputs.private_subnet_ids

  # Make it like IDLMSReplatforming: IP targets on selected ports
  target_type  = "ip"
  ip_addresses = [data.terraform_remote_state.compute.outputs.instance_private_ip]
  ports        = var.ports
  internal     = var.internal
  cross_zone   = true

  # Health check knobs are defaults in the module, override if needed:
  # health_check_protocol = "TCP"

  tags = local.tags
}
resource "aws_ssm_parameter" "lb_dns" {
  count = var.ssm_prefix == "" ? 0 : 1
  name  = "${var.ssm_prefix}/lb_dns_name"
  type  = "String"
  value = module.nlb.lb_dns_name
}

resource "aws_ssm_parameter" "lb_zone" {
  count = var.ssm_prefix == "" ? 0 : 1
  name  = "${var.ssm_prefix}/lb_zone_id"
  type  = "String"
  value = module.nlb.lb_zone_id
}
