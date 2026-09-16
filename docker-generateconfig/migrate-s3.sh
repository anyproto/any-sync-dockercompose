#!/bin/sh
# One-off migration of any-sync-filenode blobs from MinIO to Garage.
# Runs inside the rclone image, started by:
#   docker compose --profile migrate run --rm s3-migrate
set -e

SRC_BUCKET="${S3_LEGACY_BUCKET:-minio-bucket}"
DST_BUCKET="${S3_BUCKET}"
MARKER="/code/storage/garage/.migrated-from-minio"

# rclone remotes are configured entirely through the environment
export RCLONE_CONFIG_SRC_TYPE=s3
export RCLONE_CONFIG_SRC_PROVIDER=Minio
export RCLONE_CONFIG_SRC_ENDPOINT="http://minio-legacy:9000"
export RCLONE_CONFIG_SRC_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID}"
export RCLONE_CONFIG_SRC_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY}"
export RCLONE_CONFIG_SRC_REGION="${S3_REGION:-us-east-1}"
export RCLONE_CONFIG_SRC_FORCE_PATH_STYLE=true

export RCLONE_CONFIG_DST_TYPE=s3
export RCLONE_CONFIG_DST_PROVIDER=Other
export RCLONE_CONFIG_DST_ENDPOINT="http://garage:3900"
export RCLONE_CONFIG_DST_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID}"
export RCLONE_CONFIG_DST_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY}"
export RCLONE_CONFIG_DST_REGION="${S3_REGION:-us-east-1}"
export RCLONE_CONFIG_DST_FORCE_PATH_STYLE=true

if [ -f "${MARKER}" ]; then
    echo "INFO: migration already completed, nothing to do:"
    sed 's/^/INFO:   /' "${MARKER}"
    exit 0
fi

if [ ! -d /code/storage/minio ]; then
    echo "INFO: no legacy MinIO data found, nothing to migrate"
    exit 0
fi

echo "INFO: copying objects  src:${SRC_BUCKET} -> dst:${DST_BUCKET}"
rclone copy "src:${SRC_BUCKET}" "dst:${DST_BUCKET}" \
    --checksum --transfers 8 --checkers 8 --stats 5s --stats-one-line

echo "INFO: verifying (checksum comparison, one-way)"
rclone check "src:${SRC_BUCKET}" "dst:${DST_BUCKET}" --one-way --checksum

SRC_COUNT=$(rclone size "src:${SRC_BUCKET}" --json | sed 's/.*"count":\([0-9]*\).*/\1/')
DST_COUNT=$(rclone size "dst:${DST_BUCKET}" --json | sed 's/.*"count":\([0-9]*\).*/\1/')
SRC_BYTES=$(rclone size "src:${SRC_BUCKET}" --json | sed 's/.*"bytes":\([0-9]*\).*/\1/')

if [ "${SRC_COUNT}" -gt "${DST_COUNT}" ]; then
    echo "ERROR: object count mismatch: src=${SRC_COUNT} dst=${DST_COUNT}, marker not written" >&2
    exit 1
fi

mkdir -p /code/storage/garage
cat > "${MARKER}" <<MARKER_EOF
migrated from MinIO to Garage at $(date -u +%Y-%m-%dT%H:%M:%SZ)
source bucket: ${SRC_BUCKET}, objects: ${SRC_COUNT}, bytes: ${SRC_BYTES}
target bucket: ${DST_BUCKET}, objects: ${DST_COUNT}
MARKER_EOF

cat <<MSG

=================================================================================
 Migration finished: ${SRC_COUNT} objects copied and verified.
=================================================================================

 Next step:

   docker compose up -d        (or: make start)

 The old MinIO data is kept untouched as a backup. Once you have confirmed that
 your files are accessible from the Anytype client, you can remove it:

   rm -rf ./storage/minio      (or: make cleanLegacyMinio)

=================================================================================

MSG
