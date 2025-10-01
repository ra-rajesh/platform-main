variable "region" { type = string }
variable "env_name" { type = string } # "stage"
variable "param_root" {
  type    = string
  default = "/idlms"
}
variable "kms_key_id" {
  type    = string
  default = null
}
variable "build_tag" {
  type    = string
  default = null
} # optional seed

variable "shared_defaults" {
  description = "Common KEY=VAL for all apps (lowest precedence in deploy merge)"
  type        = map(string)
  default     = {}
}

variable "apps" {
  description = <<EOT
List of apps to create SSM .env for.
Each item:
{
  name = "idlms-app" | "vitalreg-app" | "whatever-next"
  port = 4000
  env  = { EXTRA_KEY = "VALUE", ... }   # optional
}
EOT
  type = list(object({
    name = string
    port = number
    env  = optional(map(string), {})
  }))
}

variable "common_tags" {
  type    = map(string)
  default = {}
}
