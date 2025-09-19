variable "vpc_id" {
  type = string
}
variable "internet_gateway_id" {
  type = string
}
variable "route_table_name" {
  type    = string
  default = "IDLMS Public Route Table"
}
variable "common_tags" {
  type    = map(string)
  default = {}
}
variable "nat_gateway_id" {
  type = string
}
