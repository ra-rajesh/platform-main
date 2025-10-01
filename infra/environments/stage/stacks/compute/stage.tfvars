env_name = "stage"

region = "ap-south-1"

tf_state_bucket = "stage-btl-idlms-repo-backend-api-tfstate-592776312448"

network_state_key = "stage/network/terraform.tfstate"

ec2_name = "IDLMS-stage" # matches the tag your workflows search for

instance_type = "t3.small"

ami_id = "ami-02d26659fd82cf299"

key_name = null

app_ports = [4000, 4010]

cloudwatch_ssm_config_path = "/idlms/cloudwatch/stage/agent-config"

docker_artifact_bucket = "idlms-stage-built-artifact-592776312448"

ingress_cidrs = ["10.10.0.0/16"]
