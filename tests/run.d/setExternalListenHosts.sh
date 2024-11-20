# Sets multiple external listen hosts in .env.override
cat <<EOF > $PROJECT_DIR/.env.override
EXTERNAL_LISTEN_HOSTS=\"$EXTERNAL_LISTEN_HOSTS\"
EOF
