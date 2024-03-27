# Docker-compose for any-sync
Self-host for any-sync, designed for personal usage or for review and testing purposes.

> [!IMPORTANT]
> This image is suitable for running your personal self-hosted any-sync network for home usage.
> If you plan to self-host a heavily used any-sync network, please consider other options.

> [!WARNING]
> Starting from release version v2.0.1, we have transitioned from the **s3-emulator** to **minio** as the data storage for any-sync-filenode. Please note that this change will result in the loss of any-sync-filenode data (stored at the path `./storage/s3_root`).

## Prepare
* install docker and docker-compose https://docs.docker.com/compose/install/linux/

## Usage
* start stand - at the first run the directories `etc/` of configuration files and `storage/` for data storage will be generated:

  For Linux, MacOS and other nix* systems:
  ```
  make start
  ```
  For Windows (Run this in PowerShell, not cmd.exe):
  ```
  # Disable auto convert LF to CRLF
  # !!! run BEFORE clone repo !!!
  git config --global core.autocrlf false

  # Generate config
  docker build -t generateconfig -f Dockerfile-generateconfig .
  docker run --rm -v ${PWD}/etc:/opt/processing/etc --name any-sync-generator generateconfig
  # Run containers
  docker compose up -d
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
* clean config and storage files - deleting data for redis, mongo, s3, any-sync-*:
  ```
  make cleanEtcStorage
  ```
* show logs:
  ```
  docker-compose logs -f any-sync-node
  docker-compose logs -f any-sync-filenode
  docker-compose logs -f
  ```
* attach to container:
  ```
  docker compose exec mongo-1 bash
  docker compose exec any-sync-node-1 bash
  docker compose exec any-sync-coordinator bash
  ```

* restart certain container:
  ```
  docker compose restart any-sync-node-1
  ```

* get current network config
  ```
  docker compose exec mongo-1 mongosh 127.0.0.1:27001/coordinator
  db.getMongo().setReadPref('primaryPreferred'); db.nodeConf.find().sort( { _id: -1 } ).limit(1)
  ```

* run client (GUI)
  
  Use `<pathToRepo>/any-sync-dockercompose/etc/client.yml` as a network configuration for the clients.
  See [the documentation](https://doc.anytype.io/anytype-docs/data-and-security/self-hosting#switching-between-networks) for more details.

* run client (CLI) 
  ```
  # macos example
  ANYTYPE_LOG_LEVEL="*=DEBUG" ANYPROF=:6060 ANY_SYNC_NETWORK=<pathToRepo>/any-sync-dockercompose/etc/client.yml /Applications/Anytype.app/Contents/MacOS/Anytype
  ```

## configuration
Use file .env
* Set specific versions: find and edit variables with suffix "_VERSION"
* Set external listen host: default 127.0.0.1, for change you need edit variable "EXTERNAL_LISTEN_HOST"

## Compatible versions
You can find compatible versions on these pages:
* stable versions, used in [production](https://puppetdoc.anytype.io/api/v1/prod-any-sync-compatible-versions/)
* unstable versions, used in [test stand](https://puppetdoc.anytype.io/api/v1/stage1-any-sync-compatible-versions/)

## "local build" images usage
If you need to create local build binaries for any-sync-*, you can do so by using the "overrides" functionality in docker-compose.

* clone repos
  ```
  install -d repos && for REPO in any-sync-{node,filenode,coordinator,consensusnode}; do if [[ ! -d repos/$REPO ]]; then git clone git@github.com:anyproto/${REPO}.git repos/$REPO; fi; done
  ```
* to create a symlink for the "override file," you can either create it yourself as docker-compose.override.yml or use an existing one
  ```
  ln -F -s docker-compose.any-sync-node-1.yml docker-compose.override.yml
  ```
* restart docker compose
  ```
  make restart
  ```

## limits web admin
open link in browser: http://127.0.0.1:80

## Contribution
Thank you for your desire to develop Anytype together!

❤️ This project and everyone involved in it is governed by the [Code of Conduct](https://github.com/anyproto/.github/blob/main/docs/CODE_OF_CONDUCT.md).

🧑‍💻 Check out our [contributing guide](https://github.com/anyproto/.github/blob/main/docs/CONTRIBUTING.md) to learn about asking questions, creating issues, or submitting pull requests.

🫢 For security findings, please email [security@anytype.io](mailto:security@anytype.io) and refer to our [security guide](https://github.com/anyproto/.github/blob/main/docs/SECURITY.md) for more information.

🤝 Follow us on [Github](https://github.com/anyproto) and join the [Contributors Community](https://github.com/orgs/anyproto/discussions).

---
Made by Any — a Swiss association 🇨🇭

Licensed under [MIT](./LICENSE.md).
