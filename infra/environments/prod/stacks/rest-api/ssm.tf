locals {
  ssm_prefix          = "/platform-main/rest-api/${var.stage_name}"
  computed_invoke_url = "https://${module.rest_api.rest_api_id}.execute-api.${var.region}.amazonaws.com/${var.stage_name}"

}

resource "aws_ssm_parameter" "rest_api_id" {
  name  = "${local.ssm_prefix}/id"
  type  = "String"
  value = module.rest_api.rest_api_id
}

resource "aws_ssm_parameter" "invoke_url" {
  name           = "${local.ssm_prefix}/invoke_url"
  type           = "String"
  insecure_value = local.computed_invoke_url
  overwrite      = true
}

resource "aws_ssm_parameter" "vpc_link_id" {
  name  = "${local.ssm_prefix}/vpc_link_id"
  type  = "String"
  value = module.rest_api.vpc_link_id
}

resource "aws_ssm_parameter" "access_log_group" {
  name  = "${local.ssm_prefix}/access_log_group"
  type  = "String"
  value = module.rest_api.access_log_group
}
