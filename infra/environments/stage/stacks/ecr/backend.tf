terraform {
  backend "s3" {
    bucket = "stage-btl-idlms-repo-backend-api-tfstate-592776312448"
    key = "stage/ecr/terraform.tfstate"
    region       = "ap-south-1"
    encrypt      = true
    use_lockfile = true
  }
}
