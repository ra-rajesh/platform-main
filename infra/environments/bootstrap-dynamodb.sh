#!/usr/bin/env bash
set -euo pipefail

# Usage: bootstrap-dynamodb.sh <env.name> <aws.region> <aws.profile>
if [[ $# -ne 3 ]]; then
  echo "Usage: $0 <env.name> <aws.region> <aws.profile>"
  echo "Example: $0 db-test us-east-1 default"
  exit 1
fi

ENV_NAME="$1"
AWS_REGION="$2"
AWS_PROFILE="$3"

TABLE="${ENV_NAME}-platform-main-state-lock"

echo "Creating DynamoDB lock table: $TABLE in $AWS_REGION (profile: $AWS_PROFILE)"

aws dynamodb create-table \
  --region "$AWS_REGION" \
  --profile "$AWS_PROFILE" \
  --table-name "$TABLE" \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --sse-specification Enabled=true,SSEType=KMS

echo "Waiting for table to become ACTIVE..."
aws dynamodb wait table-exists \
  --region "$AWS_REGION" \
  --profile "$AWS_PROFILE" \
  --table-name "$TABLE"

echo "Describing table:"
aws dynamodb describe-table \
  --region "$AWS_REGION" \
  --profile "$AWS_PROFILE" \
  --table-name "$TABLE"
