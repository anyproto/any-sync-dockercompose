#!/bin/bash

source .env

# generate networkId
if ! [[ -s .networkId ]]; then
    anyconf create-network
    echo "Create network"
    cat nodes.yml | grep '^networkId:' | awk '{print $NF}' > .networkId
    cat account.yml | yq '.account.signingKey' > .networkSigningKey

    if [ $? -ne 0 ]; then
        echo "Failed network creations!"
        exit 1
    fi
fi
NETWORK_ID=$( cat .networkId)
NETWORK_SIGNING_KEY=$( cat .networkSigningKey )

if ! [[ -s account0.yml ]]; then
    echo "Generate nodes and accounts"
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
        echo "Failed to generate nodes and accounts!"
        exit 1
    fi
fi

yq --indent 4 --inplace ".networkId |= \"${NETWORK_ID}\"" nodes.yml
yq --indent 4 --inplace ".account.signingKey |= \"${NETWORK_SIGNING_KEY}\"" account3.yml
yq --indent 4 --inplace ".account.signingKey |= \"${NETWORK_SIGNING_KEY}\"" account5.yml
