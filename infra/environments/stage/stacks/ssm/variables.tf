variable "env_name" {
  type = string
}

variable "region" {
  type    = string
  default = "ap-south-1"
}

variable "tf_bucket" {
  type    = string
  default = ""
}

variable "base_prefix" {
  type    = string
  default = "/platform-main"
}

variable "overwrite" {
  type    = bool
  default = true
}
