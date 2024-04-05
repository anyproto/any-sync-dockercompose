# Upgrade Guide

This document provides detailed instructions for upgrading between different versions of the project.

## General Recommendations

- Always back up data dir (./storage) and configuration (./etc) before starting the upgrade process.
- Follow the instructions for the specific version you are upgrading to.

## Generic Update Routine

### Before the Upgrade

1. Ensure you have a complete backup of your data and configuration.

### Upgrade Process

usually enough to run this update command ```make update```
in some cases it may be necessary to run ```make upgrade```


### After the Upgrade

1. Check logs for any errors. ```docker-compose logs -f```
2. Verify that all critical functionalities are working as expected.

## Upgrading from v1.x.x to v2.x.x

Starting with version 2.0.1, we have switched from s3-emulator to MinIO for storing data uploaded via the any-sync-filenode daemon.  
To preserve your data, you will need to manually migrate it from s3-emulator to MinIO.  
For this You can use https://min.io/docs/minio/linux/reference/minio-mc/mc-mirror.html.  

## Upgrading from v2.x.x to v3.x.x
Starting with version 3.0.0, we have reduced mongo instances from 3 to 1.  
For correctly working You need reconfigure mongo cluster.  
After Upgrade please run:
```
docker compose exec mongo-1 mongosh 127.0.0.1:27001/coordinator
use admin
var cfg = rs.conf()
cfg.members = [{ _id: 0, host: "mongo-1:27001" }]
rs.reconfig(cfg, {force: true})
```
