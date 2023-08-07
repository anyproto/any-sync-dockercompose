.DEFAULT_GOAL := start
SHELL=/bin/bash

generate_etc:
	install -d \
		tmp/etc/any-sync-node-{1..3}/ \
		tmp/etc/any-sync-filenode/ \
		tmp/etc/any-sync-coordinator/ \
		tmp/etc/any-sync-consensusnode/
	cat etc/{network,common,node-1}.yml > tmp/etc/any-sync-node-1/config.yml
	cat etc/{network,common,node-2}.yml > tmp/etc/any-sync-node-2/config.yml
	cat etc/{network,common,node-3}.yml > tmp/etc/any-sync-node-3/config.yml
	cat etc/{network,common,filenode}.yml > tmp/etc/any-sync-filenode/config.yml
	cat etc/{network,common,coordinator}.yml > tmp/etc/any-sync-coordinator/config.yml
	cat etc/{network,common,consensusnode}.yml > tmp/etc/any-sync-consensusnode/config.yml
	cat etc/network.yml | grep -v '^network:' > tmp/etc/any-sync-coordinator/network.yml

start: generate_etc
	docker compose up --force-recreate --build --remove-orphans --detach --pull always

stop:
	docker compose stop

clean:
	docker system prune --all

pull:
	docker compose pull

down:
	docker compose down

# build with "plain" log for debug
build:
	docker compose build --no-cache --progress plain

restart: stop start
update: stop pull start
upgrade: stop clean start

cleanTmp:
	rm -rf tmp/
