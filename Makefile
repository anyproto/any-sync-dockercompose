.DEFAULT_GOAL := start

# Check if the 's' flag (silent/quiet mode) is present in MAKEFLAGS
ifeq ($(findstring s,$(MAKEFLAGS)),s)
	QUIET_MODE := true
	DOCKER_COMPOSE := docker compose --progress=quiet
else
	QUIET_MODE := false
	DOCKER_COMPOSE := docker compose
endif

# targets
generate_env:
ifeq ($(QUIET_MODE),true)
	docker buildx build --quiet --load --tag generate-env --file Dockerfile-generate-env . >/dev/null
else
	docker buildx build --load --tag generate-env --file Dockerfile-generate-env .
endif
	docker run --detach --rm --volume ${CURDIR}/:/code/ generate-env

start: generate_env
	$(DOCKER_COMPOSE) up --detach --remove-orphans --quiet-pull
ifeq ($(QUIET_MODE),false)
	@echo "Done! Upload your self-hosted network configuration file ${CURDIR}/etc/client.yml into the client app"
	@echo "See: https://doc.anytype.io/anytype-docs/data-and-security/self-hosting#switching-between-networks"
endif

stop:
	$(DOCKER_COMPOSE) stop

clean:
	docker system prune --all --volumes

pull:
	$(DOCKER_COMPOSE) pull

down:
	$(DOCKER_COMPOSE) down --remove-orphans
logs:
	$(DOCKER_COMPOSE) logs --follow

# build with "plain" log for debug
build:
	$(DOCKER_COMPOSE) build --no-cache --progress plain

restart: down start
update: pull down start
upgrade: down clean start

cleanEtcStorage:
	rm -rf etc/ storage/
