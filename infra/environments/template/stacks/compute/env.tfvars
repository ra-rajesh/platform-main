
env_name    = "{{env.name}}"
region      = "{{aws.region}}"
tf_state_region = "{{aws.region}}"
network_state_key = "{{env.name}}/platform-main/network/terraform.tfstate"
ec2_name = "{{env.name}}-compute"
sg_name = "{{env.name}}-compute-security-group"
instance_type = "t3.small"
ami_id = "ami-02d26659fd82cf299"
key_name = null
app_ports = []
ingress_cidrs = []
docker_artifact_bucket = ""
cloudwatch_ssm_config_path = "/{{env.name}}/platform_main/cloudwatch/agent-config"
ec2_ssm_role_name = "{{env.name}}-ec2-ssm-role"
ec2_ssm_profile_name = "{{env.name}}-ec2-ssm-instance-profile"

tags = {
  Environment = "{{env.name}}"
  Project     = "platform_main"
}
