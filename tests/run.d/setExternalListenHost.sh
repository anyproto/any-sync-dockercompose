# Sets the external listen host in .env.override
cat <<EOF > $PROJECT_DIR/.env.override
EXTERNAL_LISTEN_HOST="$EXTERNAL_LISTEN_HOST"
EOF
