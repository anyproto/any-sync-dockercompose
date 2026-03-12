# Docker Compose for any-sync

Self-hosted any-sync network, designed for personal use or review and testing purposes.

> [!IMPORTANT]
> This setup is suitable for personal self-hosted any-sync networks.
> For heavily used production deployments, consider [Puppet](https://github.com/anyproto/puppet-anysync) or [Ansible](https://github.com/anyproto/ansible-anysync) modules.

> [!WARNING]
> Before upgrading, read the [Upgrade Guide](../../wiki/Upgrade-Guide).

## Requirements

- [Docker](https://docs.docker.com/compose/install/) with Compose plugin v2+
- ~1 GB RAM available

## Architecture

The stack runs the following services:

| Service | Role | Depends on |
|---|---|---|
| `any-sync-coordinator` | Network coordinator, manages spaces and members | MongoDB |
| `any-sync-node` ×3 | Document sync nodes | coordinator |
| `any-sync-filenode` | File storage node | coordinator, MinIO, Redis |
| `any-sync-consensusnode` | Consensus for conflict resolution | coordinator |
| `netcheck` | Periodic connectivity health monitor | all nodes |
| MongoDB | Coordinator state | — |
| Redis | Filenode index | — |
| MinIO | S3-compatible object storage for files | — |

Optional service: `anytype-cli` (commented out in `docker-compose.yml`) — HTTP/gRPC API server for automation.

## Getting Started

1. **Clone the repository:**
   ```bash
   git clone https://github.com/anyproto/any-sync-dockercompose.git
   cd any-sync-dockercompose
   ```

2. **Configure** (optional — skip for local-only use):
   ```bash
   # Expose to an external IP:
   echo 'EXTERNAL_LISTEN_HOSTS="<yourExternalIp>"' >> .env.override
   ```
   See [Configuration](../../wiki/Configuration) for all options.

3. **Start:**
   ```bash
   make start
   ```
   On first run this generates configs in `./etc/` and starts all services.

4. **Connect Anytype client:**
   Upload `./etc/client.yml` to the Anytype app as your self-hosted network config.
   See [Anytype docs](https://doc.anytype.io/anytype-docs/data-and-security/self-hosting#switching-between-networks).

## Configuration

| File | Purpose |
|---|---|
| `.env.default` | Default values — **do not edit** |
| `.env` | Generated file — **do not edit** |
| `.env.override` | Your customizations — edit this |

Common overrides:

```bash
# External IP(s) for clients outside localhost
EXTERNAL_LISTEN_HOSTS="1.2.3.4"

# Custom storage path (default: ./storage)
STORAGE_DIR="/mnt/data/any-sync"

# Per-daemon memory limit (default: 500M)
ANY_SYNC_DAEMONS_MEMORY_LIMIT=1G
```

Full reference: [Configuration Wiki](../../wiki/Configuration).

## Quick Reference

```bash
make start      # Generate config and start all services
make stop       # Stop services (data preserved)
make restart    # Stop and start again
make logs       # Follow logs from all services
make pull       # Pull latest Docker images
make update     # pull + restart (rolling update)
make upgrade    # ⚠️  Full reset: removes containers and volumes, then starts fresh
make down       # Stop and remove containers (data preserved)
make clean      # ⚠️  docker system prune --all --volumes (removes all Docker data)
make cleanEtcStorage  # Remove generated ./etc/ configs and ./storage/
```

## Documentation

Full guides are in the [Wiki](../../wiki):
- [Usage Guide](../../wiki/Usage)
- [Configuration](../../wiki/Configuration)
- [Upgrade Guide](../../wiki/Upgrade-Guide)
- [Anytype CLI](../../wiki/Anytype-cli)

## Contribution

Thank you for your desire to develop Anytype together!

❤️ This project and everyone involved in it is governed by the [Code of Conduct](https://github.com/anyproto/.github/blob/main/docs/CODE_OF_CONDUCT.md).

🧑‍💻 Check out our [contributing guide](https://github.com/anyproto/.github/blob/main/docs/CONTRIBUTING.md) to learn about asking questions, creating issues, or submitting pull requests.

🫢 For security findings, please email [security@anytype.io](mailto:security@anytype.io) and refer to our [security guide](https://github.com/anyproto/.github/blob/main/docs/SECURITY.md) for more information.

🤝 Follow us on [Github](https://github.com/anyproto) and join the [Contributors Community](https://github.com/orgs/anyproto/discussions).

---
Made by Any — a Swiss association 🇨🇭

Licensed under [MIT](./LICENSE.md).
