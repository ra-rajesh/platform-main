locals {
  tags = merge(
    {
      "user:Project" = "Platform-Main"
      "user:Env"     = var.env_name
      "user:Stack"   = "ssm"
      "Project"      = "platform-main"
      "Environment"  = var.env_name
    },
    var.tags
  )

  values = {
    # --- Network ---
    "network/${var.env_name}/vpc_id"             = var.vpc_id
    "network/${var.env_name}/private_subnet_ids" = jsonencode(var.private_subnet_ids)

    # --- Compute ---
    "compute/${var.env_name}/instance_id"           = var.instance_id
    "compute/${var.env_name}/instance_private_ip"   = var.instance_private_ip
    "compute/${var.env_name}/iam_role_name"         = var.iam_role_name
    "compute/${var.env_name}/instance_profile_name" = var.instance_profile_name

    # --- NLB (maps JSON-encoded) ---
    "nlb/${var.env_name}/lb_dns_name"       = var.lb_dns_name
    "nlb/${var.env_name}/lb_zone_id"        = var.lb_zone_id
    "nlb/${var.env_name}/listener_arns"     = jsonencode(var.listener_arns)
    "nlb/${var.env_name}/target_group_arns" = jsonencode(var.target_group_arns)

    # --- REST API (may be empty; filtered by publisher) ---
    "rest-api/${var.env_name}/id"          = var.rest_api_id
    "rest-api/${var.env_name}/vpc_link_id" = var.vpc_link_id
    "rest-api/${var.env_name}/invoke_url"  = var.invoke_url
  }
}

module "publisher" {
  source      = "../../modules/ssm"
  path_prefix = var.base_prefix
  values      = local.values
  overwrite   = var.overwrite
  tags        = local.tags
}
