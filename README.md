# 1) Configure a fresh profile (static keys)
aws configure --profile platform-main-stage
#  (enter Access key ID, Secret access key, Default region: ap-south-1)

# 2) Verify the profile works
aws sts get-caller-identity --profile platform-main-stage --region ap-south-1

# 3) Tell Terraform to use that profile
export AWS_PROFILE=platform-main-stage
export AWS_REGION=ap-south-1

aws dynamodb create-table \
  --table-name platform-main-terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --sse-specification Enabled=true,SSEType=KMS \
  --region ap-south-1

aws dynamodb wait table-exists \
  --table-name platform-main-terraform-locks \
  --region ap-south-1



# 4) Re-run init
terraform init -upgrade -reconfigure

Destroy
# 1) CloudWatch
cd infra/environments/stage/stacks/cloudwatch
terraform init -reconfigure -backend-config=backend-stage.hcl
terraform destroy -var-file=stage.tfvars -auto-approve

# 2) REST API
cd ../rest-api
terraform init -reconfigure -backend-config=backend-stage.hcl
terraform destroy -var-file=stage.tfvars -auto-approve

# 3) SSM
cd ../ssm
terraform init -reconfigure -backend-config=backend-stage.hcl
terraform destroy -var-file=stage.tfvars -auto-approve

# 4) NLB
cd ../nlb
terraform init -reconfigure -backend-config=backend-stage.hcl
terraform destroy -var-file=stage.tfvars -auto-approve

# 5) Compute
cd ../compute
terraform init -reconfigure -backend-config=backend-stage.hcl
terraform destroy -var-file=stage.tfvars -auto-approve

# 6) ECR
cd ../ecr
terraform init -reconfigure -backend-config=backend-stage.hcl
terraform destroy -var-file=stage.tfvars -auto-approve

# 7) S3 (artifact bucket must be empty or force_destroy=true)
cd ../s3
terraform init -reconfigure -backend-config=backend-stage.hcl
terraform destroy -var-file=stage.tfvars -auto-approve

# 8) Network (VPC last)
cd ../network
terraform init -reconfigure -backend-config=backend-stage.hcl
terraform destroy -var-file=stage.tfvars -auto-approve
