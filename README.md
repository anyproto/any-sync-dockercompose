# Docker-compose for any-sync
Self-host for any-sync, designed for review and testing purposes.
> [!IMPORTANT]
> please don't use it for production!

## Prepare
* install docker and docker-compose https://docs.docker.com/compose/install/linux/

## Usage
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
  docker compose exec any-sync-node-1 bash
  docker compose exec any-sync-coordinator bash
  ```

* get current network config
  ```
  docker compose exec mongo-1 mongosh coordinator
  db.nodeConf.find().sort( { _id: -1 } ).limit(1)
  ```

## Set specific versions
Use file .env
### Compatible versions
You can find compatible versions on this pages:  
* stable versions, used in production - https://puppetdoc.anytype.io/api/v1/prod-any-sync-compatible-versions/
* unstable versions, used in test stand - https://puppetdoc.anytype.io/api/v1/stage1-any-sync-compatible-versions/

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

## Contribution
Thank you for your desire to develop Anytype together!

❤️ This project and everyone involved in it is governed by the [Code of Conduct](https://github.com/anyproto/.github/blob/main/docs/CODE_OF_CONDUCT.md).

🧑‍💻 Check out our [contributing guide](https://github.com/anyproto/.github/blob/main/docs/CONTRIBUTING.md) to learn about asking questions, creating issues, or submitting pull requests.

🫢 For security findings, please email [security@anytype.io](mailto:security@anytype.io) and refer to our [security guide](https://github.com/anyproto/.github/blob/main/docs/SECURITY.md) for more information.

🤝 Follow us on [Github](https://github.com/anyproto) and join the [Contributors Community](https://github.com/orgs/anyproto/discussions).

---
Made by Any — a Swiss association 🇨🇭

Licensed under [MIT](./LICENSE.md).
