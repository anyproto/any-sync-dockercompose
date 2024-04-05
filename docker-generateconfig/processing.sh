#!/bin/bash

source generateconfig/.env

# Set file paths
DEST_PATH="etc"
NETWORK_FILE="${DEST_PATH}/network.yml"

# Create directories for all node types
for NODE_TYPE in node-1 node-2 node-3 filenode coordinator consensusnode admin; do
    mkdir -p "${DEST_PATH}/any-sync-${NODE_TYPE}"
done

# Create directory for aws credentials
mkdir -p "${DEST_PATH}/.aws"

# add external listen host
./setListenIp.py "${EXTERNAL_LISTEN_HOST}" "generateconfig/nodes.yml"

# create config for clients
cp "generateconfig/nodes.yml" "${DEST_PATH}/client.yml"

# Generate network file
sed 's|^|    |; 1s|^|network:\n|' "generateconfig/nodes.yml" > "${NETWORK_FILE}"

# Generate config files for 3 nodes
for i in {0..2}; do
    cat "${NETWORK_FILE}" tmp-etc/common.yml generateconfig/account${i}.yml tmp-etc/node-$((i+1)).yml > "${DEST_PATH}/any-sync-node-$((i+1))/config.yml"
done

# Generate config files for coordinator, filenode, consensusnode
cat "${NETWORK_FILE}" tmp-etc/common.yml generateconfig/account3.yml tmp-etc/coordinator.yml > ${DEST_PATH}/any-sync-coordinator/config.yml
cat "${NETWORK_FILE}" tmp-etc/common.yml generateconfig/account4.yml tmp-etc/filenode.yml > ${DEST_PATH}/any-sync-filenode/config.yml
cat "${NETWORK_FILE}" tmp-etc/common.yml generateconfig/account5.yml tmp-etc/consensusnode.yml > ${DEST_PATH}/any-sync-consensusnode/config.yml

# Copy network file to coordinator directory
cp "generateconfig/nodes.yml" "${DEST_PATH}/any-sync-coordinator/network.yml"

# Generate any-sync-admin config
cp "tmp-etc/admin.yml" ${DEST_PATH}/any-sync-admin/config.yml

# Generate aws credentials
cp "tmp-etc/aws-credentials" ${DEST_PATH}/.aws/credentials

# Replace variables from .env file
for PLACEHOLDER in $( perl -ne 'print "$1\n" if /^([A-z0-9_-]+)=/' generateconfig/.env ); do
    perl -i -pe "s|%${PLACEHOLDER}%|${!PLACEHOLDER}|g" \
        "${DEST_PATH}/"/.aws/credentials \
        "${NETWORK_FILE}" \
        "${DEST_PATH}/"/*/*.yml
done

# save generated configs
rsync -a --delete generateconfig/ /opt/processing/docker-generateconfig
