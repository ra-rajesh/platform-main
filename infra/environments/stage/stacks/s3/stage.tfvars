env_name              = "stage"
region                = "ap-south-1"
state_bucket_name     = "stage-btl-idlms-repo-backend-api-tfstate-592776312448"
artifacts_bucket_name = "stage-idlms-artifacts-592776312448"

tags = {
  "user:Project" = "IDLMS"
  "user:Env"     = "stage"
  "user:Stack"   = "s3"
}
