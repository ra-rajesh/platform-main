terraform {
  backend "s3" {
    bucket         = "stage-btl-idlms-backend-api-artifact-881490099206"
    key            = "stage/network/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "platform-main-terraform-locks"
    encrypt        = true
  }
}
