
env_name = "stage"
region   = "ap-south-1"

# Remote state (S3) location that holds *all* stack states
tf_state_bucket = "stage-btl-idlms-backend-api-tfstate-881490099206"

# Compute needs to read the NETWORK state for VPC/subnets
network_state_key = "stage/network/terraform.tfstate"

# EC2 settings
ec2_name      = "Backend API IDLMS-stage" # matches the tag your workflows search for
instance_type = "t3.small"
ami_id        = "ami-02d26659fd82cf299"
# ami_ssm_parameter_name = "/idlms/shared/stage/ami-id"
key_name = null # keep null if you don't want SSH key; SSM is used

# Security group app ports (align with NLB listener/TG 4000)
app_ports = [4000, 4001, 4002, 4010]

# CloudWatch Agent config stored in SSM (adjust if your CW stack used a different name)
# Tip: aws ssm describe-parameters --query 'Parameters[].Name' --region ap-south-1
cloudwatch_ssm_config_path = "/idlms/cloudwatch/stage/agent-config"

# S3 bucket used to store docker-compose.yml (already created)
docker_artifact_bucket = "stage-btl-idlms-backend-api-artifact-881490099206"

ingress_cidrs        = ["0.0.0.0/0"]
ec2_ssm_role_name    = null
ec2_ssm_profile_name = null
