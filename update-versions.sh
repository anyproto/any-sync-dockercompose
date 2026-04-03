#!/usr/bin/env bash
# Fetches the latest compatible any-sync versions from puppetdoc.anytype.io
# and updates the version variables in .env in-place.
#
# Usage:
#   ./update-versions.sh                    # updates .env with prod versions
#   ./update-versions.sh --stage1           # updates .env with stage1 versions
#   ./update-versions.sh my.env             # updates a custom env file
#   ./update-versions.sh my.env --stage1    # updates a custom env file with stage1 versions

set -euo pipefail

ENV_FILE=".env"
CHANNEL="prod"

for arg in "$@"; do
    case "$arg" in
        --stage1) CHANNEL="stage1" ;;
        *)        ENV_FILE="$arg" ;;
    esac
done

API_URL="https://puppetdoc.anytype.io/api/v1/${CHANNEL}-any-sync-compatible-versions/"

for cmd in curl jq; do
    command -v "$cmd" >/dev/null 2>&1 || { echo "Error: '$cmd' is required but not installed."; exit 1; }
done

if [[ ! -f "$ENV_FILE" ]]; then
    echo "Error: $ENV_FILE not found. Run: cp .env.example .env"
    exit 1
fi

echo "Fetching latest compatible versions (channel: ${CHANNEL})..."
response=$(curl -fsSL --max-time 10 "$API_URL") || {
    echo "Error: failed to fetch versions from $API_URL"
    exit 1
}

versions=$(echo "$response" | jq -r 'to_entries | sort_by(.key | tonumber) | last | .value')

node_version=$(echo "$versions" | jq -r '."pkg::any-sync-node"')
filenode_version=$(echo "$versions" | jq -r '."pkg::any-sync-filenode"')
coordinator_version=$(echo "$versions" | jq -r '."pkg::any-sync-coordinator"')
consensusnode_version=$(echo "$versions" | jq -r '."pkg::any-sync-consensusnode"')

for v in "$node_version" "$filenode_version" "$coordinator_version" "$consensusnode_version"; do
    if [[ "$v" == "null" || -z "$v" ]]; then
        echo "Error: unexpected API response — could not parse versions."
        exit 1
    fi
done

# sed -i is not portable between Linux and macOS
if [[ "$(uname)" == "Darwin" ]]; then
    SED_I=(-i '')
else
    SED_I=(-i)
fi

sed "${SED_I[@]}" "s/^ANY_SYNC_NODE_VERSION=.*/ANY_SYNC_NODE_VERSION=v${node_version}/" "$ENV_FILE"
sed "${SED_I[@]}" "s/^ANY_SYNC_FILENODE_VERSION=.*/ANY_SYNC_FILENODE_VERSION=v${filenode_version}/" "$ENV_FILE"
sed "${SED_I[@]}" "s/^ANY_SYNC_COORDINATOR_VERSION=.*/ANY_SYNC_COORDINATOR_VERSION=v${coordinator_version}/" "$ENV_FILE"
sed "${SED_I[@]}" "s/^ANY_SYNC_CONSENSUSNODE_VERSION=.*/ANY_SYNC_CONSENSUSNODE_VERSION=v${consensusnode_version}/" "$ENV_FILE"

echo "Updated $ENV_FILE:"
echo "  ANY_SYNC_NODE_VERSION=v${node_version}"
echo "  ANY_SYNC_FILENODE_VERSION=v${filenode_version}"
echo "  ANY_SYNC_COORDINATOR_VERSION=v${coordinator_version}"
echo "  ANY_SYNC_CONSENSUSNODE_VERSION=v${consensusnode_version}"
