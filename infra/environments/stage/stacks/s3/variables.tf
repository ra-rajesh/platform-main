variable "env_name" { type = string }
variable "region" { type = string }

variable "state_bucket_name" { type = string }
variable "artifacts_bucket_name" { type = string }
variable "tags" {
  type    = map(string)
  default = {}
}
