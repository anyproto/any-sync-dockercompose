start: generate_etc
	docker compose up --force-recreate --build --detach

generate_etc:
	install -d \
		tmp/etc/any-sync-node-{1..3}/ \
		tmp/etc/any-sync-filenode/ \
		tmp/etc/any-sync-coordinator/
	cat etc/{network,common,node-1}.yml > tmp/etc/any-sync-node-1/config.yml
	cat etc/{network,common,node-2}.yml > tmp/etc/any-sync-node-2/config.yml
	cat etc/{network,common,node-3}.yml > tmp/etc/any-sync-node-3/config.yml
	cat etc/{network,common,filenode}.yml > tmp/etc/any-sync-filenode/config.yml
	cat etc/{network,common,coordinator}.yml > tmp/etc/any-sync-coordinator/config.yml
	cat etc/network.yml | grep -v '^network:' > tmp/etc/any-sync-coordinator/network.yml

stop:
	docker-compose stop

clean:
	docker system prune --all

restart: stop start
update: stop clean start

cleanTmp:
	rm -rf tmp/
