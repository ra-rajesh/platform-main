
env_name                   = "db-test"
region                     = "us-east-1"
tf_state_region            = "us-east-1"
network_state_key          = "db-test/platform-main/network/terraform.tfstate"
ec2_name                   = "db-test-compute"
sg_name                    = "db-test-compute-security-group"
instance_type              = "t3.small"
ami_id                     = "ami-0ecb62995f68bb549"
key_name                   = null
app_ports                  = []
ingress_cidrs              = []
docker_artifact_bucket     = ""
cloudwatch_ssm_config_path = "/db-test/platform_main/cloudwatch/agent-config"
ec2_ssm_role_name          = "db-test-ec2-ssm-role"
ec2_ssm_profile_name       = "db-test-ec2-ssm-instance-profile"

tags = {
  Environment = "db-test"
  Project     = "platform_main"
}
