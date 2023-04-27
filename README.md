# test stand in docker-compose

## prepare
* Creating a personal access token - https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token
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
  docker compose exec mongo bash
  docker compose exec any-type-node-1 bash
  docker compose exec any-sync-coordinator bash
  ```

## set specific versions
use file .env
### minimal versions
* any-sync-coordinator v0.0.10
* any-sync-filenode v0.1.5
* any-sync-node v0.0.31
