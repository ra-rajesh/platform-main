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

Destroy
MINGW64 /e/Practice/NDZ/platform-main/infra/environments/stage/stacks (main) 
$ (cd rest-api && terraform destroy -var-file=stage.tfvars -auto-approve)
1) rest-api → 2) compute → 3) ssm → 4) nlb → 5) ecr → 6) s3 → 7) network.