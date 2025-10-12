terraform {
  backend "s3" {
    bucket  = "stage-btl-platform-main-repo-backend-tfstate-592776312448"
    key     = "stage/compute/terraform.tfstate"
    region  = "ap-south-1"
    encrypt = true
  }
}
