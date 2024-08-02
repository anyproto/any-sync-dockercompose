#!/bin/bash

echo "INFO: $0 start"
echo "INFO: loading .env file"
source .env

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

if [[ -s account0.yml ]]; then
    echo "INFO: saved nodes and accounts configuration found, skipping"
else
    echo "INFO: save nodes and accounts not found, createing"
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
        --addresses ${ANY_SYNC_CONSENSUSNODE_ADDRESSES} \

    if [ $? -ne 0 ]; then
        echo "ERROR: Failed to generate nodes and accounts!"
        exit 1
    fi
fi

echo "INFO: yq processing yml files"
yq --indent 2 --inplace 'del(.creationTime)' nodes.yml
yq --indent 2 --inplace ".networkId |= \"${NETWORK_ID}\"" nodes.yml
yq --indent 2 --inplace ".account.signingKey |= \"${NETWORK_SIGNING_KEY}\"" account3.yml
yq --indent 2 --inplace ".account.signingKey |= \"${NETWORK_SIGNING_KEY}\"" account5.yml

echo "INFO: $0 done"
