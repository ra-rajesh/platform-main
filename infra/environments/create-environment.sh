#!/usr/bin/env bash
set -euo pipefail

# Usage: crate_env.sh <env.name> <aws.region>
if [[ $# -ne 3 ]]; then
  echo "Usage: $0 <env.name> <aws.region> <cidr.prefix>"
  echo "Example: $0 test eu-north-1 10.10"
  exit 1
fi

ENV_NAME="$1"
AWS_REGION="$2"
CIDR_PREFIX="$3"

TEMPLATE_DIR="template"  # Folder next to this script
DEST_DIR="$ENV_NAME"     # New folder based on env.name

# Checks
if [[ ! -d "$TEMPLATE_DIR" ]]; then
  echo "ERROR: Template folder '$TEMPLATE_DIR' not found." >&2
  exit 1
fi
if [[ -e "$DEST_DIR" ]]; then
  echo "ERROR: '$DEST_DIR' already exists. Refusing to overwrite." >&2
  exit 1
fi

echo "Creating environment folder: $DEST_DIR"
mkdir -p "$DEST_DIR"
cp -a "$TEMPLATE_DIR"/. "$DEST_DIR"/

cd "$DEST_DIR/stacks"
echo "Now working in: $(pwd)"

# Pick correct sed syntax for OS
if sed --version >/dev/null 2>&1; then
  SED_INPLACE=(sed -i)      # GNU sed
else
  SED_INPLACE=(sed -i '')   # BSD/macOS sed
fi

# Escape & for sed safety
ENV_REPL="${ENV_NAME//&/\\&}"
REGION_REPL="${AWS_REGION//&/\\&}"
CIDR_REPL="${CIDR_PREFIX//&/\\&}"

echo "Replacing placeholders only in env.tfvars:"
echo "  {{env.name}}   -> $ENV_NAME"
echo "  {{aws.region}} -> $AWS_REGION"
echo "  {{cidr.prefix}} -> $CIDR_PREFIX"

# Only modify test.tfvars files
find . -type f -name "env.tfvars" -print0 \
| xargs -0 "${SED_INPLACE[@]}" \
    -e "s|{{env\.name}}|$ENV_REPL|g" \
    -e "s|{{aws\.region}}|$REGION_REPL|g" \
    -e "s|{{cidr\.prefix}}|$CIDR_REPL|g"

echo "Renaming env.tfvars files to ${ENV_NAME}.tfvars..."
find . -type f -name "env.tfvars" -print0 \
| while IFS= read -r -d '' file; do
    dir=$(dirname "$file")
    mv "$file" "$dir/${ENV_NAME}.tfvars"
done

# Count renamed files
COUNT=$(find . -type f -name "${ENV_NAME}.tfvars" | wc -l | tr -d ' ')

echo "Done! Updated and renamed $COUNT ${ENV_NAME}.tfvars file(s)."
