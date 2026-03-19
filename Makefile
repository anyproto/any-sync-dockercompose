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
start:
	@[ -f .env ] || { echo "Error: .env not found — run: cp .env.example .env"; exit 1; }
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

STORAGE_DIR := $(shell grep -m1 '^STORAGE_DIR=' .env 2>/dev/null | cut -d= -f2- | tr -d '"')
STORAGE_DIR := $(if $(STORAGE_DIR),$(STORAGE_DIR),./storage)

cleanEtcStorage:
	rm -rf etc/ $(STORAGE_DIR)
