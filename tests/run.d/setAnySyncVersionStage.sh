# Sets staging version for Any Sync components in .env.override
cat <<EOF > $PROJECT_DIR/.env.override
ANY_SYNC_NODE_VERSION=${ANY_SYNC_NODE_VERSION[2]}
ANY_SYNC_FILENODE_VERSION=${ANY_SYNC_FILENODE_VERSION[2]}
ANY_SYNC_COORDINATOR_VERSION=${ANY_SYNC_COORDINATOR_VERSION[2]}
ANY_SYNC_CONSENSUSNODE_VERSION=${ANY_SYNC_CONSENSUSNODE_VERSION[2]}
EOF
