env_name = "stage"
region   = "ap-south-1"

# exactly like IDLMSReplatforming
ssm_param_name        = ""
docker_log_group_name = "/idlms/stage/docker"

log_stream_name      = "{instance_id}"
docker_log_file_path = "/var/lib/docker/containers/*/*.log"

tags = { Project = "IDLMS", Environment = "stage" }
