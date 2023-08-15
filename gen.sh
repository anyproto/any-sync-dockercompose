#!/bin/bash

source /.env

# generate networkId
if ! [[ -s .networkId ]]; then
    anyconf create-network
    yq -r .networkId nodes.yml > .networkId
    yq -r .account.signingKey account.yml > .networkSigningKey
fi
NETWORK_ID=$( cat .networkId)
NETWORK_SIGNING_KEY=$( cat .networkSigningKey )

if ! [[ -s account0.yml ]]; then
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

fi

yq -yi ".networkId |= \"${NETWORK_ID}\"" nodes.yml
yq -yi ".account.signingKey |= \"${NETWORK_SIGNING_KEY}\"" account3.yml
yq -yi ".account.signingKey |= \"${NETWORK_SIGNING_KEY}\"" account5.yml
