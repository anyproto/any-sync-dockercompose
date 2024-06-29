#!/bin/bash

echo "INFO: $0 start"
echo "INFO: loading .env file"
source .env
ANY_SYNC_NODE_INDEXES=($(compgen -v | grep -o '^ANY_SYNC_NODE_\d\+_ADDRESSES' | grep -o '\d\+' | sort -n))

# Set file paths
DEST_PATH="./etc"
NETWORK_FILE="./storage/docker-generateconfig/network.yml"

echo "INFO: Create directories for all node types"
node_types=(filenode coordinator consensusnode)
for i in ${!ANY_SYNC_NODE_INDEXES[@]}; do
    index="${ANY_SYNC_NODE_INDEXES[$i]}"
    node_types+=("node-${index}")
done
for i in ${!node_types[@]}; do
    node_type="${node_types[$i]}"
    mkdir -p "${DEST_PATH}/any-sync-${node_type}"
done

echo "INFO: Create directory for aws credentials"
mkdir -p "${DEST_PATH}/.aws"

echo "INFO: Configure external listen host"
./docker-generateconfig/setListenIp.py "./storage/docker-generateconfig/nodes.yml" "./storage/docker-generateconfig/nodesProcessed.yml"

echo "INFO: Create config for clients"
cp "./storage/docker-generateconfig/nodesProcessed.yml" "${DEST_PATH}/client.yml"

echo "INFO: Generate network file"
yq eval '. as $item | {"network": $item}' --indent 2 ./storage/docker-generateconfig/nodesProcessed.yml > "${NETWORK_FILE}"

echo "INFO: Generate config files for ${#ANY_SYNC_NODE_INDEXES[@]} nodes"
for i in ${!ANY_SYNC_NODE_INDEXES[@]}; do
    index="${ANY_SYNC_NODE_INDEXES[$i]}"
    cat \
        "${NETWORK_FILE}" \
        docker-generateconfig/etc/common.yml \
        storage/docker-generateconfig/account-node-${index}.yml \
        storage/docker-generateconfig/node-${index}.yml \
        > "${DEST_PATH}/any-sync-node-${index}/config.yml"
done

echo "INFO: Generate config files for coordinator"
cat "${NETWORK_FILE}" docker-generateconfig/etc/common.yml storage/docker-generateconfig/account-coordinator.yml docker-generateconfig/etc/coordinator.yml \
    > ${DEST_PATH}/any-sync-coordinator/config.yml
echo "INFO: Generate config files for filenode"
cat "${NETWORK_FILE}" docker-generateconfig/etc/common.yml storage/docker-generateconfig/account-file.yml docker-generateconfig/etc/filenode.yml \
    > ${DEST_PATH}/any-sync-filenode/config.yml
echo "INFO: Generate config files for consensusnode"
cat "${NETWORK_FILE}" docker-generateconfig/etc/common.yml storage/docker-generateconfig/account-consensus.yml docker-generateconfig/etc/consensusnode.yml \
    > ${DEST_PATH}/any-sync-consensusnode/config.yml

echo "INFO: Copy network file to coordinator directory"
cp "storage/docker-generateconfig/nodesProcessed.yml" "${DEST_PATH}/any-sync-coordinator/network.yml"

echo "INFO: Copy aws credentials config"
cp "docker-generateconfig/etc/aws-credentials" "${DEST_PATH}/.aws/credentials"

echo "INFO: Replace variables from .env file"
for PLACEHOLDER in $( perl -ne 'print "$1\n" if /^([A-z0-9_-]+)=/' .env ); do
    perl -i -pe "s|%${PLACEHOLDER}%|${!PLACEHOLDER}|g" \
        "${DEST_PATH}/"/.aws/credentials \
        "${NETWORK_FILE}" \
        "${DEST_PATH}/"/*/*.yml
done

echo "INFO: fix indent in yml files"
for FILE in $( find ${DEST_PATH}/ -name "*.yml" ); do
    yq --inplace --indent=2 $FILE
done

echo "INFO: $0 done"
