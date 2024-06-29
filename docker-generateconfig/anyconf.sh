#!/bin/bash

echo "INFO: $0 start"
echo "INFO: loading .env file"
source .env
ANY_SYNC_NODE_INDEXES=($(compgen -v | grep -o '^ANY_SYNC_NODE_\d\+_ADDRESSES' | grep -o '\d\+' | sort -n))

SYNC_NODE_TEMPLATE="$(pwd)/docker-generateconfig/etc/node-1.yml"
echo "INFO: create persistent config dir='./storage/docker-generateconfig'"
install -d ./storage/docker-generateconfig
cd ./storage/docker-generateconfig

# generate networkId
if [[ -s .networkId ]]; then
    echo "INFO: saved networkId found, skipping"
else
    echo "INFO: saved networkId not found, creating"
    anyconf create-network
    cat nodes.yml | grep '^networkId:' | awk '{print $NF}' > .networkId
    cat account.yml | yq '.account.signingKey' > .networkSigningKey

    if [ $? -ne 0 ]; then
        echo "ERROR: Failed network creations!"
        exit 1
    fi
fi
NETWORK_ID=$( cat .networkId)
NETWORK_SIGNING_KEY=$( cat .networkSigningKey )

if [[ -s account-coordinator.yml ]]; then
    echo "INFO: saved nodes and accounts configuration found, skipping"
else
    echo "INFO: save nodes and accounts not found, createing"
    node_type_args=("--t" "coordinator" "--t" "consensus" "--t" "file")
    node_addr_args=("--addresses" "${ANY_SYNC_COORDINATOR_ADDRESSES}" "--addresses" "${ANY_SYNC_CONSENSUSNODE_ADDRESSES}" "--addresses" "${ANY_SYNC_FILENODE_ADDRESSES}")
    for i in ${!ANY_SYNC_NODE_INDEXES[@]}; do
        index="${ANY_SYNC_NODE_INDEXES[$i]}"
        key="ANY_SYNC_NODE_${index}_ADDRESSES"
        node_type_args+=("--t" "tree")
        node_addr_args+=("--addresses" "${!key}")
    done
    anyconf generate-nodes "${node_type_args[@]}" "${node_addr_args[@]}"

    if [ $? -ne 0 ]; then
        echo "ERROR: Failed to generate nodes and accounts!"
        exit 1
    fi

    mv account0.yml account-coordinator.yml
    mv account1.yml account-consensus.yml
    mv account2.yml account-file.yml
    for i in ${!ANY_SYNC_NODE_INDEXES[@]}; do
        index="${ANY_SYNC_NODE_INDEXES[$i]}"
        mv "account$((i+3)).yml" "account-node-${index}.yml"
        cp "$SYNC_NODE_TEMPLATE" "node-${index}.yml"
        sed -i "s/ANY_SYNC_NODE_1_/ANY_SYNC_NODE_${index}_/g" "node-${index}.yml"
    done
fi

echo "INFO: yq processing yml files"
yq --indent 2 --inplace 'del(.creationTime)' nodes.yml
yq --indent 2 --inplace ".networkId |= \"${NETWORK_ID}\"" nodes.yml
yq --indent 2 --inplace ".account.signingKey |= \"${NETWORK_SIGNING_KEY}\"" account-coordinator.yml
yq --indent 2 --inplace ".account.signingKey |= \"${NETWORK_SIGNING_KEY}\"" account-consensus.yml

echo "INFO: $0 done"
