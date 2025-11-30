
env_name    = "dev"
region      = "ap-south-1"
tf_state_region = "ap-south-1"
network_state_key = "dev/platform-main/network/terraform.tfstate"
ec2_name = "dev-compute"
sg_name = "dev-compute-security-group"
instance_type = "t3.small"
ami_id = "ami-02d26659fd82cf299"
key_name = null
app_ports = []
ingress_cidrs = []
docker_artifact_bucket = ""
cloudwatch_ssm_config_path = "/dev/platform_main/cloudwatch/agent-config"
ec2_ssm_role_name = "dev-ec2-ssm-role"
ec2_ssm_profile_name = "dev-ec2-ssm-instance-profile"

tags = {
  Environment = "dev"
  Project     = "platform_main"
}
