TF_LOCK_TABLE: resources-terraform-locks

create this table once


aws dynamodb describe-table --table-name resources-terraform-locks --region ap-south-1 >/dev/null 2>&1 || \
aws dynamodb create-table \
  --table-name resources-terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --sse-specification Enabled=true,SSEType=KMS \
  --region ap-south-1 && \
aws dynamodb wait table-exists --table-name resources-terraform-locks --region ap-south-1
