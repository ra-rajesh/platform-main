locals {
  ssm_prefix = "/idlms/rest-api/${var.stage_name}"
}

resource "aws_ssm_parameter" "rest_api_id" {
  name  = "${local.ssm_prefix}/id"
  type  = "String"
  value = module.rest_api.rest_api_id
}

resource "aws_ssm_parameter" "invoke_url" {
  name  = "${local.ssm_prefix}/invoke_url"
  type  = "String"
  value = module.rest_api.invoke_url
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
