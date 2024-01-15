.DEFAULT_GOAL := start
include .env

generate_config:
	docker build -t generateconfig -f Dockerfile-generateconfig .
	docker run --rm -v ${CURDIR}/etc:/opt/processing/etc --name any-sync-generator generateconfig

start: generate_config
	docker compose up -d

stop:
	docker compose stop

clean:
	docker system prune --all

pull:
	docker compose pull

down:
	docker compose down
logs:
	docker compose logs -f

# build with "plain" log for debug
build:
	docker compose build --no-cache --progress plain

restart: down start
update: down pull start
upgrade: down clean start

cleanEtcStorage:
	rm -rf etc/
	rm -rf storage/
