
env_name                   = "test"
region                     = "eu-north-1"
tf_state_region            = "eu-north-1"
network_state_key          = "test/platform-main/network/terraform.tfstate"
ec2_name                   = "test-compute"
sg_name                    = "test-compute-security-group"
instance_type              = "t3.small"
ami_id                     = "ami-0a716d3f3b16d290c"
key_name                   = null
app_ports                  = []
ingress_cidrs              = []
docker_artifact_bucket     = ""
cloudwatch_ssm_config_path = "/test/platform_main/cloudwatch/agent-config"
ec2_ssm_role_name          = "test-ec2-ssm-role"
ec2_ssm_profile_name       = "test-ec2-ssm-instance-profile"

tags = {
  Environment = "test"
  Project     = "platform_main"
}
