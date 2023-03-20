start:
	install -d \
		{etc,storage}/any-sync-node-{1..3}/ \
		etc/any-sync-filenode/ \
		etc/any-sync-coordinator/
	cat etc/{nodes,common,node-1}.yml > etc/any-sync-node-1/config.yml
	cat etc/{nodes,common,node-2}.yml > etc/any-sync-node-2/config.yml
	cat etc/{nodes,common,node-3}.yml > etc/any-sync-node-3/config.yml
	cat etc/{nodes,common,filenode}.yml > etc/any-sync-filenode/config.yml
	cat etc/{nodes,common,coordinator}.yml > etc/any-sync-coordinator/config.yml
	docker compose up -d

stop:
	docker-compose stop

clean:
	docker system prune -a

cleanTmpFiles:
	rm -rf storage/ s3_root/
