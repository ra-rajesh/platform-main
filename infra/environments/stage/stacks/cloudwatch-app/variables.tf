variable "env_name" { type = string }
variable "region" { type = string }
variable "tags" {
  type    = map(string)
  default = {}
}
variable "ssm_param_name" { type = string }
variable "docker_log_group_name" { type = string }
variable "log_stream_name" {
  type    = string
  default = "{instance_id}"
}
variable "docker_log_file_path" {
  type    = string
  default = "/var/lib/docker/containers/*/*.log"
}
