#!/bin/bash

# Color codes for output
BLUE='\033[1;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

DATE=$(date +%Y%m%d-%H%M%S)
TESTS_DIR="$(dirname $0)"
PROJECT_DIR="$TESTS_DIR/.."
BACKUP_DIR="$PROJECT_DIR/backup/$DATE"
DEBUG=false

# set make cmd
if $DEBUG; then
    MAKE="make -C $PROJECT_DIR"
else
    MAKE="make --quiet -C $PROJECT_DIR"
fi

# show variables
if $DEBUG; then
    echo -e "${YELLOW}Variables:${NC}"
    cat <<EOF
TESTS_DIR=$TESTS_DIR
PROJECT_DIR=$PROJECT_DIR
BACKUP_DIR=$BACKUP_DIR
EOF
fi

# load variables
source $TESTS_DIR/variables

# record the start time in seconds since the epoch
TEST_START_TIME=$(date +%s)

# Checks network status of Any Sync services and displays result
runNetcheck() {
    sleep 3
    # wait for netcheck to finish checking
    while true; do
        STATUS=$( docker inspect --format='{{json .State.Health.Status}}' $(docker-compose ps --quiet netcheck) )
        if [[ "$STATUS" != "starting" ]]; then
            $DEBUG && echo "Container 'netcheck' health status: '$STATUS', continue"
            break
        else
            $DEBUG && echo "Container 'netcheck' health status: '$STATUS', waiting..."
            sleep 5
        fi
    done
    if [[ "$STATUS" != "healthy" ]]; then
        echo -e "${GREEN} Netcheck - OK [✔] ${NC}"
    else
        echo -e "${RED} Netcheck - FAILED [✖] ${NC}"
        echo -e "${RED} Please investigate the issue. And after that, you can restore the previous storage state by executing the following commands:"
        cat <<EOF
$MAKE down && $MAKE cleanEtcStorage
mv $BACKUP_DIR/etc $PROJECT_DIR/
mv $BACKUP_DIR/storage $PROJECT_DIR/
mv $BACKUP_DIR/.env.override $PROJECT_DIR/
rmdir $BACKUP_DIR
EOF
        #restoreBackup
        exit 1
    fi
}

# Verifies if Minio bucket was created successfully
checkBucketCreation() {
    if docker compose logs create-bucket | grep -q "Bucket created successfully"; then
        echo -e "${GREEN} Minio bucket creation - OK [✔] ${NC}"
    else
        echo -e "${RED} Minio bucket creation - FAILED [✖] ${NC}"
        restoreBackup
        exit 1
    fi
}

restoreBackup() {
    echo -e "${YELLOW}Finish! Backup restore...${NC}"
    $MAKE down && $MAKE cleanEtcStorage
    mv $BACKUP_DIR/etc $PROJECT_DIR/
    mv $BACKUP_DIR/storage $PROJECT_DIR/
    mv $BACKUP_DIR/.env.override $PROJECT_DIR/
    rmdir $BACKUP_DIR
}

runTest(){
    local PARAM_1=$1
    if [[ $PARAM_1 == 'cleanData' ]]; then
        local CLEAN_DATA=true
    else
        local CLEAN_DATA=false
    fi

    if $CLEAN_DATA; then
        echo -e "${YELLOW}Testing without user data storage...${NC}"
    else
        echo -e "${YELLOW}Testing with user data storage...${NC}"
    fi
    local RUN_TEST_START_TIME=$(date +%s) # record the start time in seconds since the epoch
    for TEST in $TESTS_DIR/run.d/*.sh; do
        echo -e "${YELLOW}Executing test: $TEST ${NC}"
        local TEST_FILE_NAME=$(basename $TEST)
        if [[ $TEST_FILE_NAME == 'setAnySyncPort.sh' ]]; then
            if ! $CLEAN_DATA; then
                echo "skipping for exist storage"
                continue
            fi
        fi

        # record the start time in seconds since the epoch
        local START_TIME=$(date +%s)

        # source the test file
        source $TEST

        # restart stand
        if $CLEAN_DATA; then
            $MAKE down && $MAKE cleanEtcStorage && $MAKE start
            local STATUS_CODE=$?
        else
            $MAKE down && $MAKE start
            local STATUS_CODE=$?
        fi

        local END_TIME=$(date +%s) # record the end time in seconds since the epoch
        local ELAPSED_TIME=$((END_TIME - START_TIME)) # calculate the elapsed time
        echo -e "${BLUE}Test $TEST took $ELAPSED_TIME seconds to complete${NC}" # log the time taken for the test

        # check 'make start' status
        if [[ $STATUS_CODE -eq 0 ]]; then
            # if successful, run checks
            runNetcheck
            if $CLEAN_DATA; then
                checkBucketCreation
            fi
            echo -e "${GREEN} $TEST - OK [✔] ${NC}"
        else
            # if failed, log the error, stop services, restore backup, and exit
            echo -e "${RED} $TEST - FAILED [✖] ${NC}"
            $MAKE down
            restoreBackup
            exit 1
        fi
    done
    local RUN_TEST_END_TIME=$(date +%s) # record the end time in seconds since the epoch
    local RUN_TEST_ELAPSED_TIME=$((RUN_TEST_END_TIME - RUN_TEST_START_TIME)) # calculate the elapsed time
    echo -e "${BLUE}runTest took $RUN_TEST_ELAPSED_TIME seconds to complete${NC}" # log the time taken for the test
    echo
}

# create data backup
echo -e "${YELLOW}Pre-start user data backup...${NC}"
$MAKE down
install -d $BACKUP_DIR
cp -r $PROJECT_DIR/etc $BACKUP_DIR/
cp -r $PROJECT_DIR/storage $BACKUP_DIR/
cp $PROJECT_DIR/.env.override $BACKUP_DIR/

# run tests
runTest notCleanData
runTest cleanData

# restore backup and exit
restoreBackup

# logging run time
TEST_END_TIME=$(date +%s) # record the end time in seconds since the epoch
TEST_ELAPSED_TIME=$((TEST_END_TIME - TEST_START_TIME)) # calculate the elapsed time
echo -e "${BLUE}$0 took $TEST_ELAPSED_TIME seconds to complete${NC}" # log the time taken for the test
exit 0
