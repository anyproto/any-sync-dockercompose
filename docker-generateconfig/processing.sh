#!/bin/bash

echo "INFO: $0 start"
echo "INFO: loading .env file"
source .env

# Set file paths
DEST_PATH="./etc"
NETWORK_FILE="./storage/docker-generateconfig/network.yml"

echo "INFO: Create directories for all node types"
for NODE_TYPE in node-1 node-2 node-3 filenode coordinator consensusnode; do
    mkdir -p "${DEST_PATH}/any-sync-${NODE_TYPE}"
done

echo "INFO: Create directory for aws credentials"
mkdir -p "${DEST_PATH}/.aws"

echo "INFO: Configure external listen host"
python ./docker-generateconfig/setListenIp.py "./storage/docker-generateconfig/nodes.yml" "./storage/docker-generateconfig/nodesProcessed.yml"

echo "INFO: Create config for clients"
cp "./storage/docker-generateconfig/nodesProcessed.yml" "${DEST_PATH}/client.yml"

echo "INFO: Generate network file"
yq eval '. as $item | {"network": $item}' --indent 2 ./storage/docker-generateconfig/nodesProcessed.yml > "${NETWORK_FILE}"

echo "INFO: Generate config files for 3 nodes"
for i in {0..2}; do
    cat \
        "${NETWORK_FILE}" \
        docker-generateconfig/etc/common.yml \
        storage/docker-generateconfig/account${i}.yml \
        docker-generateconfig/etc/node-$((i+1)).yml \
        > "${DEST_PATH}/any-sync-node-$((i+1))/config.yml"
done

echo "INFO: Generate config files for coordinator"
cat "${NETWORK_FILE}" docker-generateconfig/etc/common.yml storage/docker-generateconfig/account3.yml docker-generateconfig/etc/coordinator.yml \
    > ${DEST_PATH}/any-sync-coordinator/config.yml
echo "INFO: Generate config files for filenode"
cat "${NETWORK_FILE}" docker-generateconfig/etc/common.yml storage/docker-generateconfig/account4.yml docker-generateconfig/etc/filenode.yml \
    > ${DEST_PATH}/any-sync-filenode/config.yml
echo "INFO: Generate config files for consensusnode"
cat "${NETWORK_FILE}" docker-generateconfig/etc/common.yml storage/docker-generateconfig/account5.yml docker-generateconfig/etc/consensusnode.yml \
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
