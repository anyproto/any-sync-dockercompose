# test stand in docker-compose

## prepare
* Creating a personal access token - https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token
* login in ghcr.io: ```echo <you token>| docker login ghcr.io -u <github username> --password-stdin```

## usage
* start stand: ```make start```
* stop stand: ```make stop```
* clean unused docker objects: ```make clean```
* clean tmp files for any-sync-node and s3: ```cleanTmpFiles```
* show logs:
```
docker-compose logs -f any-sync-node
docker-compose logs -f any-sync-filenode
docker-compose logs -f
```

## set specific versions
use file .env
