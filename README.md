# test stand (self-host) in docker-compose
self-host for any-sync  
intended for review and testing  
> [!IMPORTANT]
> please don't use it for production!

## prepare
* Creating a personal access token, instruction:
  * go to https://github.com/settings/tokens/
  * push "generate new token (classic)"
    minimal permissions "read:packages"

* login in ghcr.io:
  ```
  echo <you token>| docker login ghcr.io -u <github username> --password-stdin
  ```
* installing docker and docker compose https://docs.docker.com/compose/install/linux/

## usage
* start stand:
  ```
  make start
  ```
* stop stand:
  ```
  make stop
  ```
* restart stand:
  ```
  make restart
  ```
* update image versions and start:
  ```
  make update
  ```
* clean unused docker objects:
  ```
  make clean
  ```
* clean tmp files - deleting data for redis, mongo, s3, any-sync-*:
  ```
  make cleanTmp
  ```
* show logs:
  ```
  docker-compose logs -f any-sync-node
  docker-compose logs -f any-sync-filenode
  docker-compose logs -f
  ```
* attach to vm:
  ```
  docker compose exec mongo-1 bash
  docker compose exec any-type-node-1 bash
  docker compose exec any-sync-coordinator bash
  ```

* get current network config
  ```
  docker compose exec mongo-1 mongosh coordinator
  db.nodeConf.find().sort( { _id: -1 } ).limit(1)
  ```

## set specific versions
use file .env
### compatible versions
you cat find compatible versions on this pages:  
* stable versions, used on production - https://puppetdoc.anytype.io/api/v1/prod-any-sync-compatible-versions/
* unstable versions, used on test stand - https://puppetdoc.anytype.io/api/v1/stage1-any-sync-compatible-versions/

## usage "local build" images
if you need to make local build binaries for any-sync-*  
you can doing it by using "overrides" functional in docker-compose

* clone repos
  ```
  install -d repos && for REPO in any-sync-{node,filenode,coordinator,consensusnode}; do if [[ ! -d repos/$REPO ]]; then git clone git@github.com:anyproto/${REPO}.git repos/$REPO; fi; done
  ```
* create a symlink to the "override file" you need (or you can create docker-compose.override.yml by your self)
  ```
  ln -F -s docker-compose.any-sync-node-1.yml docker-compose.override.yml
  ```
* restart docker compose
  ```
  make restart
  ```
