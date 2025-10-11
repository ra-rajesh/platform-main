variable "vpc_id" {
  type = string
}
variable "internet_gateway_id" {
  type = string
}
variable "common_tags" {
  type    = map(string)
  default = {}
}
variable "nat_gateway_id" {
  type = string
}
variable "route_table_public_name" {
  type = string
}
variable "route_table_private_name" {
  type = string
}
