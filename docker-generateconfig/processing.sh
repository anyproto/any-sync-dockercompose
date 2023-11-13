#!/bin/bash

source generateconfig/.env

# Set file paths
DEST_PATH="config"
NETWORK_FILE="${DEST_PATH}/network.yml"

# Create directories for all node
for i in {1..3}; do
    mkdir -p "${DEST_PATH}/any-sync-node-${i}"
done

# Create directories for other node types
for node_type in filenode coordinator consensusnode; do
    mkdir -p "${DEST_PATH}/any-sync-${node_type}"
done

# Generate network file
sed 's|^|    |; 1s|^|network:\n|' "generateconfig/nodes.yml" > "${NETWORK_FILE}"

# Generate config files for 3 nodes
for i in {0..2}; do
    NODE_FILE="${DEST_PATH}/any-sync-node-$((i+1))/config.yml"
    cat "${NETWORK_FILE}" etc/common.yml generateconfig/account${i}.yml etc/node-$((i+1)).yml > "${NODE_FILE}"
done

# Generate config files for coordinator, filenode, consensusnode
cat "${NETWORK_FILE}" etc/common.yml generateconfig/account3.yml etc/coordinator.yml > ${DEST_PATH}/any-sync-coordinator/config.yml
cat "${NETWORK_FILE}" etc/common.yml generateconfig/account4.yml etc/filenode.yml > ${DEST_PATH}/any-sync-filenode/config.yml
cat "${NETWORK_FILE}" etc/common.yml generateconfig/account5.yml etc/consensusnode.yml > ${DEST_PATH}/any-sync-consensusnode/config.yml

# Copy network file to coordinator directory
cp "generateconfig/nodes.yml" "${DEST_PATH}/any-sync-coordinator/network.yml"

# Replace placeholders in config files
for node_type in node_1 node_2 node_3 coordinator filenode consensusnode; do
    ADDRESSES_VAR="ANY_SYNC_${node_type^^}_ADDRESSES"
    QUIC_ADDRESSES_VAR="ANY_SYNC_${node_type^^}_QUIC_ADDRESSES"
    perl -i -pe "s|%${ADDRESSES_VAR}%|${!ADDRESSES_VAR}|g" "${NETWORK_FILE}" "${DEST_PATH}/"/*/*.yml
    perl -i -pe "s|%${QUIC_ADDRESSES_VAR}%|${!QUIC_ADDRESSES_VAR}|g" "${NETWORK_FILE}" "${DEST_PATH}/"/*/*.yml
done

# Replace other placeholders
PLACEHOLDERS=( "MONGO_CONNECT" "REDIS_URL" "AWS_PORT" )
for placeholder in "${PLACEHOLDERS[@]}"; do
    perl -i -pe "s|%${placeholder}%|${!placeholder}|g" "${NETWORK_FILE}" "${DEST_PATH}/"/*/*.yml
done
