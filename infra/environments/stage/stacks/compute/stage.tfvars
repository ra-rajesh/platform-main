
env_name    = "stage"
region      = "ap-south-1"
tf_state_region = "ap-south-1"
network_state_key = "stage/platform-main/network/terraform.tfstate"
ec2_name = "stage-compute"
sg_name = "stage-compute-security-group"
instance_type = "t3.small"
ami_id = "ami-02d26659fd82cf299"
key_name = null
app_ports = []
ingress_cidrs = []
docker_artifact_bucket = ""
cloudwatch_ssm_config_path = "/stage/platform_main/cloudwatch/agent-config"
ec2_ssm_role_name = "stage-ec2-ssm-role"
ec2_ssm_profile_name = "stage-ec2-ssm-instance-profile"

tags = {
  Environment = "stage"
  Project     = "platform_main"
}
