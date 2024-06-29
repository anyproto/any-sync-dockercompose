.DEFAULT_GOAL := start

generate_env_and_compose:
	docker buildx build --tag generateconfig-env-and-compose --file Dockerfile-generateconfig-env-and-compose .
	docker run --rm \
		--volume ${CURDIR}/:/code/ \
		generateconfig-env-and-compose

start: generate_env_and_compose
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
