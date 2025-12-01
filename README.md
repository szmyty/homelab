# Homelab

A complete, self-hosted homelab infrastructure that is:

- **Local-first**: Docker Compose for running services locally
- **Cloud-capable**: Pulumi for infrastructure provisioning
- **Portable**: Works across macOS, WSL, and Linux
- **Runtipi-ready**: Optional manifest generator for future integration
- **Opinionated**: Organized and fully reproducible

## Quick Start

```bash
# Clone the repository
git clone https://github.com/szmyty/homelab.git
cd homelab

# Run bootstrap script
./scripts/bootstrap.sh

# Deploy core services locally
./scripts/deploy_local.sh --bundle core

# Check service health
./scripts/check_health.sh
```

## Services

| Service | Description | Port |
|---------|-------------|------|
| Caddy | Reverse proxy with automatic HTTPS | 80/443 |
| Jellyfin | Open-source media server | 8096 |
| Vaultwarden | Bitwarden-compatible password manager | 8080 |
| Paperless-ngx | Document management with OCR | 8000 |
| Uptime Kuma | Self-hosted monitoring | 3001 |
| qBittorrent | Torrent client with VPN | 8085 |
| Syncthing | File synchronization | 8384 |

## Repository Structure

```text
/
├── .devcontainer/      # Development container configuration
├── .github/workflows/  # CI/CD pipelines
├── docs/               # Documentation
├── infra/              # Infrastructure as code
│   ├── ansible/        # Ansible playbooks
│   ├── compose/        # Docker Compose bundles
│   ├── docker/         # Shared Dockerfiles
│   ├── k8s/            # Kubernetes manifests
│   └── pulumi/         # Pulumi stacks
├── manifests/          # Generated manifests
│   └── runtipi/        # Runtipi app manifests
├── scripts/            # Utility scripts
└── services/           # Service configurations
```

## Documentation

- [Architecture](docs/ARCHITECTURE.md)
- [Services](docs/SERVICES.md)
- [Security](docs/SECURITY.md)
- [Storage](docs/STORAGE.md)
- [Bootstrap](docs/BOOTSTRAP.md)
- [Cloud Deployment](docs/CLOUD.md)
- [Backups](docs/BACKUPS.md)

## Scripts

| Script | Purpose |
|--------|---------|
| `bootstrap.sh` | Set up local environment |
| `deploy_local.sh` | Deploy services with Docker Compose |
| `deploy_cloud.sh` | Deploy infrastructure with Pulumi |
| `backup.sh` | Backup Docker volumes |
| `check_health.sh` | Check service health |
| `encrypt_volume.sh` | Manage encrypted storage |
| `generate_runtipi_manifests.py` | Generate Runtipi manifests |

## Development

Use the included devcontainer for a consistent development environment:

1. Install [VS Code](https://code.visualstudio.com/) with [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)
2. Open repository in VS Code
3. Click "Reopen in Container" when prompted

## License

See [LICENSE](LICENSE) for details.
