env_name = "stage"
region   = "ap-south-1"

ssm_path_prefix = "/idlms/nlb/stage"

nlb_state_bucket = "stage-btl-idlms-backend-api-artifact-881490099206"
nlb_state_key    = "stage/nlb/terraform.tfstate"
nlb_state_region = "ap-south-1"

overwrite = true

common_tags = {
  Environment = "stage"
  Project     = "IDLMS"
}
