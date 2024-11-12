#!/bin/bash

# Color codes for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

source variables.txt

# Writes Any Sync ports to .env.override file
setAnySyncPort() {
  {
    echo "ANY_SYNC_NODE_1_PORT=$ANY_SYNC_NODE_1_PORT"
    echo "ANY_SYNC_NODE_2_PORT=$ANY_SYNC_NODE_2_PORT"
    echo "ANY_SYNC_NODE_3_PORT=$ANY_SYNC_NODE_3_PORT"
    echo "ANY_SYNC_COORDINATOR_PORT=$ANY_SYNC_COORDINATOR_PORT"
    echo "ANY_SYNC_FILENODE_PORT=$ANY_SYNC_FILENODE_PORT"
    echo "ANY_SYNC_CONSENSUSNODE_PORT=$ANY_SYNC_CONSENSUSNODE_PORT"
  } > ../.env.override
}

# Sets the external listen host in .env.override
setExternalListenHost() {
 echo "EXTERNAL_LISTEN_HOST=\"$EXTERNAL_LISTEN_HOST\"" > ../.env.override
}

# Sets multiple external listen hosts in .env.override
setExternalListenHosts() {
  echo "EXTERNAL_LISTEN_HOSTS=\"$EXTERNAL_LISTEN_HOSTS\"" > ../.env.override
}

# Sets the default version for Any Sync components in .env.override
setAnySyncVersionNumber() {
  {
    echo "ANY_SYNC_NODE_VERSION=${ANY_SYNC_NODE_VERSION[0]}"
    echo "ANY_SYNC_FILENODE_VERSION=${ANY_SYNC_FILENODE_VERSION[0]}"
    echo "ANY_SYNC_COORDINATOR_VERSION=${ANY_SYNC_COORDINATOR_VERSION[0]}"
    echo "ANY_SYNC_CONSENSUSNODE_VERSION=${ANY_SYNC_CONSENSUSNODE_VERSION[0]}"
  } > ../.env.override
}

# Sets production version for Any Sync components in .env.override
setAnySyncVersionProd() {
  {
    echo "ANY_SYNC_NODE_VERSION=${ANY_SYNC_NODE_VERSION[1]}"
    echo "ANY_SYNC_FILENODE_VERSION=${ANY_SYNC_FILENODE_VERSION[1]}"
    echo "ANY_SYNC_COORDINATOR_VERSION=${ANY_SYNC_COORDINATOR_VERSION[1]}"
    echo "ANY_SYNC_CONSENSUSNODE_VERSION=${ANY_SYNC_CONSENSUSNODE_VERSION[1]}"
  } > ../.env.override
}

# Sets staging version for Any Sync components in .env.override
setAnySyncVersionStage() {
  {
    echo "ANY_SYNC_NODE_VERSION=${ANY_SYNC_NODE_VERSION[2]}"
    echo "ANY_SYNC_FILENODE_VERSION=${ANY_SYNC_FILENODE_VERSION[2]}"
    echo "ANY_SYNC_COORDINATOR_VERSION=${ANY_SYNC_COORDINATOR_VERSION[2]}"
    echo "ANY_SYNC_CONSENSUSNODE_VERSION=${ANY_SYNC_CONSENSUSNODE_VERSION[2]}"
  } > ../.env.override
}

# Writes Minio port configurations to .env.override
setMinioPort() {
  {
    echo "MINIO_PORT=$MINIO_PORT"
    echo "EXTERNAL_MINIO_PORT=$EXTERNAL_MINIO_PORT"
    echo "MINIO_WEB_PORT=$MINIO_WEB_PORT"
    echo "EXTERNAL_MINIO_WEB_PORT=$EXTERNAL_MINIO_WEB_PORT"
  } > ../.env.override
}

# Checks network status of Any Sync services and displays result
runNetcheck() {
  sleep 7 # wait for netcheck to finish checking
  if docker compose ps | grep -q "any-sync-dockercompose-netcheck-1.*healthy"; then
    echo -e "\n${GREEN} Netcheck - OK [✔] ${NC}"
  else
    echo -e "\n${RED} Netcheck - FAILED [✖] ${NC}\n"
    (cd .. && make down)
    exit 1
  fi
}

# Verifies if Minio bucket was created successfully
checkBucketCreation() {
  if docker compose logs create-bucket | grep -q "Bucket created successfully"; then
    echo -e "\n${GREEN} Minio bucket creation - OK [✔] ${NC}"
  else
    echo -e "\n${RED} Minio bucket creation - FAILED [✖] ${NC}\n"
    (cd .. && make down)
    restoreBackup
    exit 1
  fi
}

createBackup() {
  echo -e "\n\n${YELLOW}Pre-start user data backup...${NC}\n\n"
  make -C ../ down
  cp -r ../etc/ ../etc-back/
  cp -r ../storage/ ../storage-back/
  cp ../.env.override ../.env.override-back
}

restoreBackup() {
  echo -e "\n\n${YELLOW}Finish! Backup restore...${NC}\n\n"
  make -C ../ down && make -C ../ cleanEtcStorage
  mv ../etc-back/ ../etc/
  mv ../storage-back/ ../storage/
  mv ../.env.override-back ../.env.override
}

if [[ -e ../etc/ && -e ../storage/ && -e ../.env.override ]]; then
  createBackup
else
  echo "User data doesn't exist, skipping backup..."
fi

echo "Testing with user data storage..."
for func in $(grep -oP '^set\w+' "$0" | grep -v '^setAnySyncPort'); do
  echo -e "\n${YELLOW}Executing func: $func ${NC}\n"
  $func
  make -C ../ down && make -C ../ start
  if [ $? -eq 0 ]; then
    runNetcheck
    echo -e "\n${GREEN} $func - OK [✔] ${NC}\n"
  else
    echo -e "\n${RED} $func - FAILED [✖] ${NC}\n"
    make -C ../ down
    restoreBackup
    exit 1
  fi
done

echo "Testing without user data storage..."
for func in $(grep -oP '^set\w+' "$0"); do
  echo -e "\n${YELLOW}Executing func: $func ${NC}\n"
  $func
  make -C ../ down && make -C ../ cleanEtcStorage && make -C ../ start
  if [ $? -eq 0 ]; then
    runNetcheck
    checkBucketCreation
    echo -e "\n${GREEN} $func - OK [✔] ${NC}\n"
  else
    echo -e "\n${RED} $func - FAILED [✖] ${NC}\n"
    make -C ../ down
    restoreBackup
    exit 1
  fi
done

restoreBackup
exit 0