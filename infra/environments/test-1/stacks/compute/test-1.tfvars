
env_name                   = "test-1"
region                     = "eu-north-1"
tf_state_region            = "eu-north-1"
network_state_key          = "test-1/platform-main/network/terraform.tfstate"
ec2_name                   = "test-1-compute"
sg_name                    = "test-1-compute-security-group"
instance_type              = "t3.small"
ami_id                     = "ami-0a716d3f3b16d290c"
key_name                   = null
app_ports                  = []
ingress_cidrs              = []
docker_artifact_bucket     = ""
cloudwatch_ssm_config_path = "/test-1/platform_main/cloudwatch/agent-config"
ec2_ssm_role_name          = "test-1-ec2-ssm-role"
ec2_ssm_profile_name       = "test-1-ec2-ssm-instance-profile"

tags = {
  Environment = "test-1"
  Project     = "platform_main"
}
