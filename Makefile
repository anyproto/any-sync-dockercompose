.DEFAULT_GOAL := start

generate_env:
	docker buildx build --load --tag generateconfig-env --file Dockerfile-generateconfig-env .
	docker run --rm \
		--volume ${CURDIR}/:/code/ \
		generateconfig-env

start: generate_env
	docker compose up --detach --remove-orphans
	@echo "Done! Upload your self-hosted network configuration file ${CURDIR}/etc/client.yml into the client app"
	@echo "See: https://doc.anytype.io/anytype-docs/data-and-security/self-hosting#switching-between-networks"

stop:
	docker compose stop

clean:
	docker system prune --all --volumes

pull:
	docker compose pull

down:
	docker compose down --remove-orphans
logs:
	docker compose logs --follow

# build with "plain" log for debug
build:
	docker compose build --no-cache --progress plain

restart: down start
update: pull down start
upgrade: down clean start

cleanEtcStorage:
	rm -rf etc/ storage/
