
#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 3 ]; then
  echo "Usage: $0 <aws.env> <aws.region> <aws.account-id>"
  echo "Example: $0 stage eu-north-1 123456789012"
  exit 1
fi

AWS_ENV="$1"
AWS_REGION="$2"
AWS_ACCOUNT="$3"
POLICY_FILE_NAME="policy-${AWS_ENV}.json"

echo "Updating placeholders..."
echo "  env:     $AWS_ENV"
echo "  region:  $AWS_REGION"
echo "  account: $AWS_ACCOUNT"
echo "  policy-file-name: $POLICY_FILE_NAME"

cp policy-template.json ${POLICY_FILE_NAME}

# Use proper sed variant based on OS
if sed --version >/dev/null 2>&1; then
  # Linux (GNU sed)
  SED_CMD="sed -i"
else
  # macOS (BSD sed)
  SED_CMD="sed -i ''"
fi

find . -type f -name "${POLICY_FILE_NAME}" -print0 |
while IFS= read -r -d '' file; do
  echo "Processing $file ..."
  eval "$SED_CMD 's/{{aws\.env}}/$AWS_ENV/g' \"$file\""
  eval "$SED_CMD 's/{{aws\.region}}/$AWS_REGION/g' \"$file\""
  eval "$SED_CMD 's/{{aws\.account-id}}/$AWS_ACCOUNT/g' \"$file\""
done

echo "Done! Your scrolls are reforged."
