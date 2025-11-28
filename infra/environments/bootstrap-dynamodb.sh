#!/usr/bin/env bash
set -euo pipefail

# Usage: crate_env.sh <env.name> <aws.region>
if [[ $# -ne 3 ]]; then
  echo "Usage: $0 <env.name> <aws.region> <aws.profile>"
  echo "Example: $0 test eu-north-1 default"
  exit 1
fi

ENV_NAME="$1"
AWS_REGION="$2"
AWS_PROFILE="$3"

# echo the command and input params
echo "$0 $1 $2 $3"

# change if needed
TABLE=$1-platform-main-state-lock

#create the dynamodb table
aws dynamodb create-table --region "$AWS_REGION" --profile "$AWS_PROFILE" --table-name "$TABLE" --attribute-definitions AttributeName=LockID,AttributeType=S --key-schema AttributeName=LockID,KeyType=HASH --billing-mode PAY_PER_REQUEST --sse-specification Enabled=true,SSEType=KMS

# confirm the table exists
aws dynamodb wait table-exists --region "$AWS_REGION" --profile "$AWS_PROFILE" –table-name "$TABLE"

# describe table
aws dynamodb describe-table --region "$AWS_REGION" --profile "$AWS_PROFILE" –table-name "$TABLE"
