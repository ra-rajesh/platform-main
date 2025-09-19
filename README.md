# 1) Configure a fresh profile (static keys)
aws configure --profile platform-main-stage
#  (enter Access key ID, Secret access key, Default region: ap-south-1)

# 2) Verify the profile works
aws sts get-caller-identity --profile platform-main-stage --region ap-south-1

# 3) Tell Terraform to use that profile
export AWS_PROFILE=platform-main-stage
export AWS_REGION=ap-south-1

# 4) Re-run init
terraform init -upgrade -reconfigure
