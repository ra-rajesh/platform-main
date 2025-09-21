env_name = "stage"
region   = "ap-south-1"

artifact_bucket_name_override = "stage-btl-idlms-backend-api-artifact-881490099206"
ssm_prefix                    = "/idlms/artifacts"

common_tags = {
  Environment = "stage"
  Project     = "IDLMS"
}
