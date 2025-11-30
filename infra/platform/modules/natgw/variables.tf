variable "public_subnet_ids" {
  type = list(string)
}

variable "nat_gateway_name" {
  type = string
}
variable "common_tags" {
  type    = map(string)
  default = {}
}
