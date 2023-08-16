.DEFAULT_GOAL := start
SHELL := /bin/bash
include .env

generate_etc:
	install -d \
		tmp/etc/any-sync-node-{1..3}/ \
		tmp/etc/any-sync-filenode/ \
		tmp/etc/any-sync-coordinator/ \
		tmp/etc/any-sync-consensusnode/
	docker compose --file docker-compose-generateconfig.yml up --build --remove-orphans --detach
	sleep 2
	sed 's|^|    |; 1s|^|network:\n|' tmp/generateconfig/nodes.yml > tmp/etc/network.yml
	cat tmp/etc/network.yml etc/common.yml tmp/generateconfig/account0.yml etc/node-1.yml > tmp/etc/any-sync-node-1/config.yml
	cat tmp/etc/network.yml etc/common.yml tmp/generateconfig/account1.yml etc/node-2.yml > tmp/etc/any-sync-node-2/config.yml
	cat tmp/etc/network.yml etc/common.yml tmp/generateconfig/account2.yml etc/node-3.yml > tmp/etc/any-sync-node-3/config.yml
	cat tmp/etc/network.yml etc/common.yml tmp/generateconfig/account3.yml etc/coordinator.yml > tmp/etc/any-sync-coordinator/config.yml
	cat tmp/etc/network.yml etc/common.yml tmp/generateconfig/account4.yml etc/filenode.yml > tmp/etc/any-sync-filenode/config.yml
	cat tmp/etc/network.yml etc/common.yml tmp/generateconfig/account5.yml etc/consensusnode.yml > tmp/etc/any-sync-consensusnode/config.yml
	cp tmp/generateconfig/nodes.yml tmp/etc/any-sync-coordinator/network.yml
	perl -i -pe's|%ANY_SYNC_NODE_1_ADDRESSES%|${ANY_SYNC_NODE_1_ADDRESSES}|g' tmp/etc/network.yml tmp/etc/*/*.yml
	perl -i -pe's|%ANY_SYNC_NODE_2_ADDRESSES%|${ANY_SYNC_NODE_2_ADDRESSES}|g' tmp/etc/network.yml tmp/etc/*/*.yml
	perl -i -pe's|%ANY_SYNC_NODE_3_ADDRESSES%|${ANY_SYNC_NODE_3_ADDRESSES}|g' tmp/etc/network.yml tmp/etc/*/*.yml
	perl -i -pe's|%ANY_SYNC_COORDINATOR_ADDRESSES%|${ANY_SYNC_COORDINATOR_ADDRESSES}|g' tmp/etc/network.yml tmp/etc/*/*.yml
	perl -i -pe's|%ANY_SYNC_FILENODE_ADDRESSES%|${ANY_SYNC_FILENODE_ADDRESSES}|g' tmp/etc/network.yml tmp/etc/*/*.yml
	perl -i -pe's|%ANY_SYNC_CONSENSUSNODE_ADDRESSES%|${ANY_SYNC_CONSENSUSNODE_ADDRESSES}|g' tmp/etc/network.yml tmp/etc/*/*.yml
	perl -i -pe's|%MONGO_CONNECT%|${MONGO_CONNECT}|g' tmp/etc/network.yml tmp/etc/*/*.yml
	perl -i -pe's|%REDIS_URL%|${REDIS_URL}|g' tmp/etc/network.yml tmp/etc/*/*.yml
	perl -i -pe's|%AWS_PORT%|${AWS_PORT}|g' tmp/etc/network.yml tmp/etc/*/*.yml
	docker compose --file docker-compose-generateconfig.yml stop

start: generate_etc
	docker compose up --force-recreate --build --remove-orphans --detach --pull always

stop:
	docker compose stop
	docker compose --file docker-compose-generateconfig.yml stop

clean:
	docker system prune --all

pull:
	docker compose pull

down:
	docker compose down
	docker compose --file docker-compose-generateconfig.yml down

# build with "plain" log for debug
build:
	docker compose build --no-cache --progress plain

restart: stop start
update: stop pull start
upgrade: stop clean start

cleanTmp:
	rm -rf tmp/
