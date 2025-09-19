data "terraform_remote_state" "nlb" {
  backend = "s3"
  config = {
    bucket = var.nlb_state_bucket
    key    = var.nlb_state_key
    region = var.nlb_state_region
  }
}

locals {
  prefix = trimsuffix(var.ssm_path_prefix, "/")
  tg_map = data.terraform_remote_state.nlb.outputs.target_group_arns
  ls_map = data.terraform_remote_state.nlb.outputs.listener_arns

  values_base = {
    lb_arn      = data.terraform_remote_state.nlb.outputs.lb_arn
    lb_dns_name = data.terraform_remote_state.nlb.outputs.lb_dns_name
    lb_zone_id  = data.terraform_remote_state.nlb.outputs.lb_zone_id
    # Store the maps as JSON strings for consumers
    target_group_arns = jsonencode(local.tg_map)
    listener_arns     = jsonencode(local.ls_map)
  }

  per_port_pairs = var.include_per_port ? merge(
    { for k, v in local.tg_map : "tg_${k}" => v },
    { for k, v in local.ls_map : "listener_${k}" => v }
  ) : {}

  values_final = merge(local.values_base, local.per_port_pairs)
}

module "ssm" {
  source = "../../../../platform/container/ssm"

  path_prefix = local.prefix
  values      = local.values_final

  overwrite   = var.overwrite
  common_tags = var.common_tags
}

output "published_names" {
  value = module.ssm.published_names
}
