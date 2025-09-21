#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   ENV=stage TFSTATE_BUCKET=stage-...-tfstate-... LOCK_TABLE=platform-main-terraform-locks ./scripts/tf_deep_clean.sh [--purge-backend]
#
# Optional envs:
#   ARTIFACT_BUCKETS="bucket1,bucket2"
#   SSM_PREFIXES="/idlms/ecr/stage,/idlms/nlb/stage"
#   LIFECYCLE_DAYS=0

ENV="${ENV:-stage}"
REGION="${AWS_REGION:-ap-south-1}"
TFSTATE_BUCKET="${TFSTATE_BUCKET:?set TFSTATE_BUCKET}"
LOCK_TABLE="${LOCK_TABLE:?set LOCK_TABLE}"
PURGE_BACKEND=false
[[ "${1:-}" == "--purge-backend" ]] && PURGE_BACKEND=true

echo "Env: $ENV"
echo "Region: $REGION"
echo "TFSTATE_BUCKET: $TFSTATE_BUCKET"
echo "LOCK_TABLE: $LOCK_TABLE"
echo "PURGE_BACKEND: $PURGE_BACKEND"

# 1) Destroy stacks in safe order
ORDER=( cloudwatch rest-api ssm nlb compute ecr s3 network )
for S in "${ORDER[@]}"; do
  WD="infra/environments/${ENV}/stacks/${S}"
  [[ -d "$WD" ]] || { echo "skip $WD"; continue; }
  [[ -f "${WD}/backend-${ENV}.hcl" ]] || { echo "missing backend-${ENV}.hcl in $WD"; exit 1; }

  echo "=== INIT (destroy): $WD"
  terraform -chdir="$WD" init -input=false -reconfigure -backend-config="backend-${ENV}.hcl" || true

  TFVARS_FLAG=""
  [[ -f "${WD}/${ENV}.tfvars" ]] && TFVARS_FLAG="-var-file=${ENV}.tfvars"

  echo "=== PLAN (destroy): $WD"
  terraform -chdir="$WD" plan -destroy -input=false $TFVARS_FLAG -var="env_name=${ENV}" -out=tfplan || true

  echo "=== DESTROY: $WD"
  terraform -chdir="$WD" apply -input=false -auto-approve tfplan || echo "destroy failed for $WD; continuing"
done

# 2) Purge remote state objects in tfstate bucket
purge_key() {
  local BUCKET="$1" KEY="$2"
  [[ -z "$KEY" ]] && return
  echo "Purging s3://$BUCKET/$KEY"
  aws s3api list-object-versions --bucket "$BUCKET" --prefix "$KEY" --output json \
    | jq -r '.Versions[]?, .DeleteMarkers[]? | [.Key, .VersionId] | @tsv' \
    | while IFS=$'\t' read -r K VID; do
        aws s3api delete-object --bucket "$BUCKET" --key "$K" --version-id "$VID" || true
      done
  aws s3 rm "s3://$BUCKET/$KEY" || true
}

find "infra/environments/${ENV}/stacks" -maxdepth 2 -name "backend-${ENV}.hcl" | while read -r BCFG; do
  BKT="$(grep -E '^\s*bucket\s*=' "$BCFG" | sed -E 's/.*=\s*"([^"]+)".*/\1/')"
  KEY="$(grep -E '^\s*key\s*='    "$BCFG" | sed -E 's/.*=\s*"([^"]+)".*/\1/')"
  [[ "$BKT" != "$TFSTATE_BUCKET" ]] && { echo "skip $(dirname "$BCFG") (bucket mismatch: $BKT)"; continue; }
  purge_key "$BKT" "$KEY"
done

# 3) Optional: nuke SSM parameters
if [[ -n "${SSM_PREFIXES:-}" ]]; then
  IFS=',' read -ra PFX <<< "$SSM_PREFIXES"
  for PREFIX in "${PFX[@]}"; do
    PREFIX="$(echo "$PREFIX" | xargs)"; [[ -z "$PREFIX" ]] && continue
    echo "Deleting SSM params under $PREFIX"
    NEXT=""
    while : ; do
      if [[ -n "$NEXT" ]]; then
        RESP="$(aws ssm get-parameters-by-path --path "$PREFIX" --recursive --with-decryption --max-items 50 --next-token "$NEXT")"
      else
        RESP="$(aws ssm get-parameters-by-path --path "$PREFIX" --recursive --with-decryption --max-items 50)"
      fi
      echo "$RESP" | jq -r '.Parameters[].Name' | xargs -r -n10 aws ssm delete-parameters --names || true
      NEXT="$(echo "$RESP" | jq -r '.NextToken // empty')"
      [[ -z "$NEXT" ]] && break
    done
  done
fi

# 4) Optional: delete artifact buckets
if [[ -n "${ARTIFACT_BUCKETS:-}" ]]; then
  IFS=',' read -ra B <<< "$ARTIFACT_BUCKETS"
  for BUCKET in "${B[@]}"; do
    BUCKET="$(echo "$BUCKET" | xargs)"; [[ -z "$BUCKET" ]] && continue
    echo "Empty & delete artifact bucket: $BUCKET"
    aws s3api list-object-versions --bucket "$BUCKET" --output json \
      | jq -r '.Versions[]?, .DeleteMarkers[]? | [.Key, .VersionId] | @tsv' \
      | while IFS=$'\t' read -r K VID; do
          aws s3api delete-object --bucket "$BUCKET" --key "$K" --version-id "$VID" || true
        done
    aws s3 rm "s3://$BUCKET" --recursive || true
    aws s3api delete-bucket --bucket "$BUCKET" || true
  done
fi

# 5) Optional: lifecycle on backend bucket
if [[ -n "${LIFECYCLE_DAYS:-}" && "${LIFECYCLE_DAYS}" != "0" ]]; then
  echo "Setting lifecycle (expire >${LIFECYCLE_DAYS}d) on ${TFSTATE_BUCKET}"
  aws s3api put-bucket-lifecycle-configuration \
    --bucket "$TFSTATE_BUCKET" \
    --lifecycle-configuration "{
      \"Rules\": [{
        \"ID\": \"expire-old-objects\",
        \"Status\": \"Enabled\",
        \"Filter\": {\"Prefix\": \"\"},
        \"Expiration\": {\"Days\": ${LIFECYCLE_DAYS}}
      }]
    }" || true
fi

# 6) Optional: purge & delete backend infra
if $PURGE_BACKEND; then
  echo "Purging & deleting tfstate bucket: ${TFSTATE_BUCKET}"
  aws s3api list-object-versions --bucket "$TFSTATE_BUCKET" --output json \
    | jq -r '.Versions[]?, .DeleteMarkers[]? | [.Key, .VersionId] | @tsv' \
    | while IFS=$'\t' read -r K VID; do
        aws s3api delete-object --bucket "$TFSTATE_BUCKET" --key "$K" --version-id "$VID" || true
      done
  aws s3 rm "s3://$TFSTATE_BUCKET" --recursive || true
  aws s3api delete-bucket --bucket "$TFSTATE_BUCKET" || true

  echo "Deleting DynamoDB lock table: ${LOCK_TABLE}"
  aws dynamodb delete-table --table-name "$LOCK_TABLE" || true
  aws dynamodb wait table-not-exists --table-name "$LOCK_TABLE" || true
fi

# 7) Local cleanup
find infra/environments -type d -name ".terraform" -exec rm -rf {} + || true
find infra/environments -type f -name "tfplan" -delete || true
find infra/environments -type f -name ".terraform.lock.hcl" -delete || true

echo "Done."
