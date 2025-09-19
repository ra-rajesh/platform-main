terraform {
  backend "s3" {
    bucket = "stage-btl-idlms-repo-backend-api-tfstate-592776312448"
    key = "stage/cloudwatch/terraform.tfstate"
    region       = "ap-south-1"
    use_lockfile = true
    encrypt      = true
  }
}
