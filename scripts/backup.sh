#!/usr/bin/env sh
set -eu

# Environment variables expected:
# POSTGRES_HOST, POSTGRES_DB, POSTGRES_USER, POSTGRES_PASSWORD
# Optional: S3_BUCKET, S3_REGION, AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, RETENTION_DAYS

timestamp=$(date -u +"%Y%m%dT%H%M%SZ")
backup_dir="/backups"
mkdir -p "$backup_dir"

export PGPASSWORD="${POSTGRES_PASSWORD:-}"

filename="${POSTGRES_DB:-lab_results}_$timestamp.sql.gz"
filepath="$backup_dir/$filename"

echo "[backup] Starting backup to $filepath"
pg_dump -h "${POSTGRES_HOST:-postgres}" -U "${POSTGRES_USER:-labuser}" -d "${POSTGRES_DB:-lab_results}" -F p \
  | gzip -9 > "$filepath"

echo "[backup] Backup completed: $filepath"

# Optional: upload to S3-compatible storage if configured
if [ -n "${S3_BUCKET:-}" ]; then
  echo "[backup] Uploading to s3://${S3_BUCKET}/..."
  aws s3 cp "$filepath" "s3://${S3_BUCKET}/db-backups/$filename" --region "${S3_REGION:-us-east-1}"
fi

# Retention cleanup
retention_days=${RETENTION_DAYS:-7}
find "$backup_dir" -type f -name "*.sql.gz" -mtime +"$retention_days" -print -delete || true

echo "[backup] Done"

