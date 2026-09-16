#!/bin/bash
# Refuses to start the stack when data from a previous MinIO-based install
# has not been migrated to Garage yet. See the Upgrade Guide wiki page.
set -e

source .env

LEGACY_DIR="./storage/minio"
LEGACY_BUCKET_DIR="${LEGACY_DIR}/${S3_LEGACY_BUCKET:-minio-bucket}"
MARKER="./storage/garage/.migrated-from-minio"

if [[ ! -d "${LEGACY_DIR}" ]]; then
    echo "INFO: no legacy MinIO data found, nothing to migrate"
    exit 0
fi

if [[ -f "${MARKER}" ]]; then
    echo "INFO: MinIO -> Garage migration already done:"
    sed 's/^/INFO:   /' "${MARKER}"
    exit 0
fi

OBJECT_COUNT=$(find "${LEGACY_BUCKET_DIR}" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l)

if [[ "${OBJECT_COUNT}" -eq 0 ]]; then
    echo "INFO: legacy MinIO directory '${LEGACY_DIR}' is empty, nothing to migrate"
    install -d ./storage/garage
    echo "nothing to migrate: legacy MinIO bucket was empty ($(date -u +%Y-%m-%dT%H:%M:%SZ))" > "${MARKER}"
    exit 0
fi

cat >&2 <<MSG

=================================================================================
 STOP: migration required — the stack was NOT started, your data is untouched.
=================================================================================

 MinIO is no longer maintained upstream and has been replaced by Garage:
 https://github.com/anyproto/any-sync-dockercompose/issues/178

 Found ${OBJECT_COUNT} objects of the old MinIO storage in:
   ${STORAGE_DIR:-./storage}/minio/${S3_LEGACY_BUCKET:-minio-bucket}

 Migrate them to Garage (nothing is deleted, MinIO data is kept as a backup):

   docker compose --profile migrate run --rm s3-migrate
   docker compose up -d

 or, if you use make:

   make migrate
   make start

 Full instructions and rollback steps:
   https://github.com/anyproto/any-sync-dockercompose/wiki/Upgrade-Guide

=================================================================================

MSG
exit 1
