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

# Helper: does bucket exist?
bucket_exists() {
  local B="$1"
  aws s3api head-bucket --bucket "$B" >/dev/null 2>&1
}

# Helper: delete all versions & delete-markers for a key prefix (no jq)
purge_key() {
  local BUCKET="$1" KEY="$2"
  [[ -z "$KEY" ]] && return

  if ! bucket_exists "$BUCKET"; then
    echo "Bucket $BUCKET not found; skip purge for $KEY"
    return
  fi

  echo "Purging s3://$BUCKET/$KEY (versions + delete markers)"
  # Versions
  aws s3api list-object-versions \
    --bucket "$BUCKET" \
    --prefix "$KEY" \
    --page-size 1000 --max-items 100000 \
    --query 'Versions[].{K:Key,V:VersionId}' \
    --output text 2>/dev/null \
  | while read -r K V; do
      [[ -z "${K:-}" || -z "${V:-}" ]] && continue
      aws s3api delete-object --bucket "$BUCKET" --key "$K" --version-id "$V" || true
    done

  # Delete markers
  aws s3api list-object-versions \
    --bucket "$BUCKET" \
    --prefix "$KEY" \
    --page-size 1000 --max-items 100000 \
    --query 'DeleteMarkers[].{K:Key,V:VersionId}' \
    --output text 2>/dev/null \
  | while read -r K V; do
      [[ -z "${K:-}" || -z "${V:-}" ]] && continue
      aws s3api delete-object --bucket "$BUCKET" --key "$K" --version-id "$V" || true
    done

  # Non-versioned fallback
  aws s3 rm "s3://$BUCKET/$KEY" || true
}

# Helper: empty & delete a whole bucket (no jq)
empty_and_delete_bucket() {
  local BUCKET="$1"
  if ! bucket_exists "$BUCKET"; then
    echo "Bucket $BUCKET not found; skip delete"
    return
  fi
  echo "Emptying all versions in bucket: $BUCKET"

  # Versions
  aws s3api list-object-versions \
    --bucket "$BUCKET" \
    --page-size 1000 --max-items 100000 \
    --query 'Versions[].{K:Key,V:VersionId}' \
    --output text 2>/dev/null \
  | while read -r K V; do
      [[ -z "${K:-}" || -z "${V:-}" ]] && continue
      aws s3api delete-object --bucket "$BUCKET" --key "$K" --version-id "$V" || true
    done

  # Delete markers
  aws s3api list-object-versions \
    --bucket "$BUCKET" \
    --page-size 1000 --max-items 100000 \
    --query 'DeleteMarkers[].{K:Key,V:VersionId}' \
    --output text 2>/dev/null \
  | while read -r K V; do
      [[ -z "${K:-}" || -z "${V:-}" ]] && continue
      aws s3api delete-object --bucket "$BUCKET" --key "$K" --version-id "$V" || true
    done

  # Non-versioned leftovers
  aws s3 rm "s3://$BUCKET" --recursive || true

  echo "Deleting bucket: $BUCKET"
  aws s3api delete-bucket --bucket "$BUCKET" || true
}

# Detect if backend exists; if not, skip TF destroys (no state to read)
BACKEND_EXISTS=false
if bucket_exists "$TFSTATE_BUCKET"; then
  BACKEND_EXISTS=true
else
  echo "NOTE: tfstate bucket $TFSTATE_BUCKET does NOT exist; skipping Terraform destroy steps."
fi

# 1) Destroy stacks in safe order (only if backend exists)
if $BACKEND_EXISTS; then
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
fi

# 2) Purge remote state objects in tfstate bucket (only if backend exists)
if $BACKEND_EXISTS; then
  find "infra/environments/${ENV}/stacks" -maxdepth 2 -name "backend-${ENV}.hcl" | while read -r BCFG; do
    BKT="$(grep -E '^\s*bucket\s*=' "$BCFG" | sed -E 's/.*=\s*"([^"]+)".*/\1/')"
    KEY="$(grep -E '^\s*key\s*='    "$BCFG" | sed -E 's/.*=\s*"([^"]+)".*/\1/')"
    [[ "$BKT" != "$TFSTATE_BUCKET" ]] && { echo "skip $(dirname "$BCFG") (bucket mismatch: $BKT)"; continue; }
    purge_key "$BKT" "$KEY"
  done
fi

# 3) Optional: nuke SSM parameters
if [[ -n "${SSM_PREFIXES:-}" ]]; then
  IFS=',' read -ra PFX <<< "$SSM_PREFIXES"
  for PREFIX in "${PFX[@]}"; do
    PREFIX="$(echo "$PREFIX" | xargs)"; [[ -z "$PREFIX" ]] && continue
    echo "Deleting SSM params under $PREFIX"

    NEXT=""
    while : ; do
      if [[ -n "$NEXT" ]]; then
        RESP="$(aws ssm get-parameters-by-path --path "$PREFIX" --recursive --with-decryption --max-items 50 --next-token "$NEXT" || true)"
      else
        RESP="$(aws ssm get-parameters-by-path --path "$PREFIX" --recursive --with-decryption --max-items 50 || true)"
      fi

      # Print as text list and batch-delete
      echo "$RESP" | sed -n 's/.*"Name": "\([^"]*\)".*/\1/p' | xargs -r -n10 aws ssm delete-parameters --names || true
      NEXT="$(echo "$RESP" | sed -n 's/.*"NextToken": "\([^"]*\)".*/\1/p')"
      [[ -z "$NEXT" ]] && break
    done
  done
fi

# 4) Optional: delete artifact buckets (no jq)
if [[ -n "${ARTIFACT_BUCKETS:-}" ]]; then
  IFS=',' read -ra B <<< "$ARTIFACT_BUCKETS"
  for BUCKET in "${B[@]}"; do
    BUCKET="$(echo "$BUCKET" | xargs)"; [[ -z "$BUCKET" ]] && continue
    echo "Empty & delete artifact bucket: $BUCKET"
    empty_and_delete_bucket "$BUCKET"
  done
fi

# 5) Optional: lifecycle on backend bucket
if [[ -n "${LIFECYCLE_DAYS:-}" && "${LIFECYCLE_DAYS}" != "0" && $BACKEND_EXISTS == true ]]; then
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

# 6) Optional: purge & delete backend infra (no jq)
if $PURGE_BACKEND; then
  echo "Purging & deleting tfstate bucket: ${TFSTATE_BUCKET}"
  empty_and_delete_bucket "$TFSTATE_BUCKET"

  echo "Deleting DynamoDB lock table: ${LOCK_TABLE}"
  aws dynamodb delete-table --table-name "$LOCK_TABLE" >/dev/null 2>&1 || true
  aws dynamodb wait table-not-exists --table-name "$LOCK_TABLE" >/dev/null 2>&1 || true
fi

# 7) Local cleanup
find infra/environments -type d -name ".terraform" -exec rm -rf {} + || true
find infra/environments -type f -name "tfplan" -delete || true
find infra/environments -type f -name ".terraform.lock.hcl" -delete || true

echo "Done."
