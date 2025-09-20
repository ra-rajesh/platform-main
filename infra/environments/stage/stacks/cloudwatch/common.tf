data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
}

# Only read SSM if use_ssm = true
data "aws_ssm_parameter" "lb_arn" {
  count = var.use_ssm ? 1 : 0
  name  = "${var.nlb_ssm_prefix}/lb_arn"
}

data "aws_ssm_parameter" "tg_arns" {
  count = var.use_ssm ? 1 : 0
  name  = "${var.nlb_ssm_prefix}/target_group_arns"
  # If your SSM writer uses "/tg_arns" instead, change the name above.
}

locals {
  # Prefer SSM values (made non-sensitive), else use overrides (single-line conditionals)
  lb_arn_value = var.use_ssm && length(data.aws_ssm_parameter.lb_arn) > 0 ? nonsensitive(data.aws_ssm_parameter.lb_arn[0].value) : var.lb_arn_override
  tg_json      = var.use_ssm && length(data.aws_ssm_parameter.tg_arns) > 0 ? nonsensitive(data.aws_ssm_parameter.tg_arns[0].value) : var.tg_arns_json_override

  tg_map = try(jsondecode(local.tg_json), {})

  lb_suffix = replace(local.lb_arn_value, "arn:aws:elasticloadbalancing:${var.region}:${local.account_id}:loadbalancer/", "")

  # Ensure keys are STRINGS and values are not sensitive
  tg_suffixes = {
    for port, arn in local.tg_map :
    tostring(port) => replace(arn, "arn:aws:elasticloadbalancing:${var.region}:${local.account_id}:targetgroup/", "")
  }
}
