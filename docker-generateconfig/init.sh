#!/bin/bash
set -e

echo "INFO: loading .env file"
source .env

# =============================================================================
echo "INFO: === Phase 1: anyconf ==="
# =============================================================================

echo "INFO: create persistent config dir='./storage/docker-generateconfig'"
install -d ./storage/docker-generateconfig

(
    cd ./storage/docker-generateconfig

    if [[ -s .networkId ]]; then
        echo "INFO: saved networkId found, skipping"
    else
        echo "INFO: saved networkId not found, creating"
        anyconf create-network
        grep '^networkId:' nodes.yml | awk '{print $NF}' > .networkId
        yq '.account.signingKey' account.yml > .networkSigningKey
    fi
    NETWORK_ID=$(cat .networkId)
    NETWORK_SIGNING_KEY=$(cat .networkSigningKey)

    if [[ -s account0.yml ]]; then
        echo "INFO: saved nodes and accounts configuration found, skipping"
    else
        echo "INFO: saved nodes and accounts not found, creating"
        anyconf generate-nodes \
            --t tree \
            --t tree \
            --t tree \
            --t coordinator \
            --t file \
            --t consensus \
            --addresses ${ANY_SYNC_NODE_1_ADDRESSES} \
            --addresses ${ANY_SYNC_NODE_2_ADDRESSES} \
            --addresses ${ANY_SYNC_NODE_3_ADDRESSES} \
            --addresses ${ANY_SYNC_COORDINATOR_ADDRESSES} \
            --addresses ${ANY_SYNC_FILENODE_ADDRESSES} \
            --addresses ${ANY_SYNC_CONSENSUSNODE_ADDRESSES}
    fi

    echo "INFO: yq processing yml files"
    yq --indent 2 --inplace 'del(.creationTime)' nodes.yml
    yq --indent 2 --inplace ".networkId |= \"${NETWORK_ID}\"" nodes.yml
    yq --indent 2 --inplace ".account.signingKey |= \"${NETWORK_SIGNING_KEY}\"" account3.yml
    yq --indent 2 --inplace ".account.signingKey |= \"${NETWORK_SIGNING_KEY}\"" account5.yml
)

# =============================================================================
echo "INFO: === Phase 2: processing ==="
# =============================================================================

DEST_PATH="./etc"
NETWORK_FILE="./storage/docker-generateconfig/network.yml"

echo "INFO: Create directories for all node types"
for NODE_TYPE in node-1 node-2 node-3 filenode coordinator consensusnode; do
    mkdir -p "${DEST_PATH}/any-sync-${NODE_TYPE}"
done

echo "INFO: Create directory for S3 credentials"
mkdir -p "${DEST_PATH}/.aws"

echo "INFO: Configure external listen host"
python ./docker-generateconfig/setListenIp.py \
    "./storage/docker-generateconfig/nodes.yml" \
    "./storage/docker-generateconfig/nodesProcessed.yml"

echo "INFO: Generate client.yml"
cp "./storage/docker-generateconfig/nodesProcessed.yml" "${DEST_PATH}/client.yml"

echo "INFO: Generate network file"
yq eval '. as $item | {"network": $item}' --indent 2 \
    ./storage/docker-generateconfig/nodesProcessed.yml > "${NETWORK_FILE}"

echo "INFO: Generate config files for any-sync-nodes - x3"
for i in {0..2}; do
    cat \
        "${NETWORK_FILE}" \
        docker-generateconfig/etc/common.yml \
        storage/docker-generateconfig/account${i}.yml \
        docker-generateconfig/etc/node-$((i+1)).yml \
        > "${DEST_PATH}/any-sync-node-$((i+1))/config.yml"
done

echo "INFO: Generate config files for coordinator, filenode, consensusnode"
declare -A SERVICE_ACCOUNTS=([coordinator]=3 [filenode]=4 [consensusnode]=5)
for SERVICE in coordinator filenode consensusnode; do
    cat \
        "${NETWORK_FILE}" \
        docker-generateconfig/etc/common.yml \
        storage/docker-generateconfig/account${SERVICE_ACCOUNTS[$SERVICE]}.yml \
        docker-generateconfig/etc/${SERVICE}.yml \
        > "${DEST_PATH}/any-sync-${SERVICE}/config.yml"
done

echo "INFO: Copy network file to coordinator directory"
cp "storage/docker-generateconfig/nodesProcessed.yml" "${DEST_PATH}/any-sync-coordinator/network.yml"

echo "INFO: Copy S3 credentials config"
cp "docker-generateconfig/etc/aws-credentials" "${DEST_PATH}/.aws/credentials"

echo "INFO: Replace variables from .env file"
for PLACEHOLDER in $(perl -ne 'print "$1\n" if /^([A-z0-9_-]+)=/' .env); do
    perl -i -pe "s|%${PLACEHOLDER}%|${!PLACEHOLDER}|g" \
        "${DEST_PATH}/.aws/credentials" \
        "${NETWORK_FILE}" \
        "${DEST_PATH}"/*/*.yml
done

echo "INFO: fix indent in yml files"
for FILE in $(find ${DEST_PATH}/ -name "*.yml"); do
    yq --inplace --indent=2 "${FILE}"
done

echo "INFO: === any-sync-init done ==="
