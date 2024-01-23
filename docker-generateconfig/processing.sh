#!/bin/bash

source generateconfig/.env

# Set file paths
dest_path="etc"
network_file="${dest_path}/network.yml"

# Create directories for all node
for i in {1..3}; do
    mkdir -p "${dest_path}/any-sync-node-${i}"
done

# Create directories for other node types
for node_type in filenode coordinator consensusnode; do
    mkdir -p "${dest_path}/any-sync-${node_type}"
done

# add external listen host
./setListenIp.py "${EXTERNAL_LISTEN_HOST}" "generateconfig/nodes.yml"

# create config for clients
cp "generateconfig/nodes.yml" "${dest_path}/client.yml"

# Generate network file
sed 's|^|    |; 1s|^|network:\n|' "generateconfig/nodes.yml" > "${network_file}"

# Generate config files for 3 nodes
for i in {0..2}; do
    node_file="${dest_path}/any-sync-node-$((i+1))/config.yml"
    cat "${network_file}" tmp-etc/common.yml generateconfig/account${i}.yml tmp-etc/node-$((i+1)).yml > "${node_file}"
done

# Generate config files for coordinator, filenode, consensusnode
cat "${network_file}" tmp-etc/common.yml generateconfig/account3.yml tmp-etc/coordinator.yml > ${dest_path}/any-sync-coordinator/config.yml
cat "${network_file}" tmp-etc/common.yml generateconfig/account4.yml tmp-etc/filenode.yml > ${dest_path}/any-sync-filenode/config.yml
cat "${network_file}" tmp-etc/common.yml generateconfig/account5.yml tmp-etc/consensusnode.yml > ${dest_path}/any-sync-consensusnode/config.yml

# Copy network file to coordinator directory
cp "generateconfig/nodes.yml" "${dest_path}/any-sync-coordinator/network.yml"

# Replace placeholders in config files
for node_type in node_1 node_2 node_3 coordinator filenode consensusnode; do
    addresses="ANY_SYNC_${node_type^^}_ADDRESSES"
    quic_addresses="ANY_SYNC_${node_type^^}_QUIC_ADDRESSES"
    perl -i -pe "s|%${addresses}%|${!addresses}|g" "${network_file}" "${dest_path}/"/*/*.yml
    perl -i -pe "s|%${quic_addresses}%|${!quic_addresses}|g" "${network_file}" "${dest_path}/"/*/*.yml
done

# Replace other placeholders
placeholders=( "MONGO_CONNECT" "REDIS_URL" "MINIO_PORT" "MINIO_BUCKET" "ANY_SYNC_COORDINATOR_FILE_LIMIT_DEFAULT" "ANY_SYNC_COORDINATOR_FILE_LIMIT_ALPHA_USERS" "ANY_SYNC_COORDINATOR_FILE_LIMIT_NIGHTLY_USERS")
for placeholder in "${placeholders[@]}"; do
    perl -i -pe "s|%${placeholder}%|${!placeholder}|g" "${network_file}" "${dest_path}/"/*/*.yml
done
