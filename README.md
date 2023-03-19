# test stand in docker-compose

## prepare
* Creating a personal access token - https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token
* login in ghcr.io: ```echo <you token>| docker login ghcr.io -u <github username> --password-stdin```

## usage
* start stand: ```make start```
* stop stand: ```make stop```
* clean unused objects: ```make clean```
