# Homelab Repository Notes

## Overview

This repository contains a complete homelab setup that is:

- **Local-first**: Docker Compose based
- **Cloud-capable**: Pulumi for infrastructure provisioning
- **Portable**: Works across macOS, WSL, and Linux
- **Runtipi-ready**: Optional manifest generator for future integration
- **Opinionated**: Organized and fully reproducible

---

## Repository Structure

```
/
├── NOTES.md
├── README.md
├── docs/
├── infra/
│   ├── docker/
│   ├── compose/
│   ├── k8s/
│   ├── ansible/
│   └── pulumi/
├── services/
│   ├── jellyfin/
│   ├── vaultwarden/
│   ├── paperless/
│   ├── uptime-kuma/
│   ├── qbittorrent/
│   ├── syncthing/
│   └── caddy/
├── manifests/
│   └── runtipi/
├── scripts/
└── .devcontainer/
```

---

## Core Services

| Service | Description | Port |
|---------|-------------|------|
| Jellyfin | Media server | 8096 |
| Vaultwarden | Password manager | 8080 |
| Paperless-ngx | Document management | 8000 |
| Uptime Kuma | Monitoring | 3001 |
| qBittorrent | Torrent client with VPN | 8085 |
| Syncthing | File synchronization | 8384 |
| Caddy | Reverse proxy | 80/443 |

---

## Infrastructure

### Docker Compose Bundles

- `core.yml`: Caddy, monitoring, Uptime Kuma
- `media.yml`: Jellyfin, qBittorrent stack
- `vault.yml`: Vaultwarden + backups
- `docs.yml`: Paperless-ngx

### Pulumi Stacks

- **Local**: Docker-based local deployment
- **Cloud**: GCP VM provisioning with firewall, DNS, and cloud-init

---

## Scripts

| Script | Purpose |
|--------|---------|
| `bootstrap.sh` | Set up local environment |
| `deploy_local.sh` | Run Docker Compose with long args |
| `deploy_cloud.sh` | Pulumi up wrapper |
| `backup.sh` | Volume backups |
| `check_health.sh` | Service health checks |
| `encrypt_volume.sh` | Wrapper for gocryptfs or encfs |
| `generate_runtipi_manifests.py` | Generate Runtipi JSON from metadata.yml |

---

## Encrypted Media Architecture

- Encrypted folder on host: `/mnt/d/.media/videos`
- Decrypted mount inside WSL: `/home/alan/.media/videos`
- Docker containers bind-mount decrypted folder
- Storage is NOT duplicated due to FUSE passthrough

---

## Security Baseline

Configured security tools:
- gitleaks (secret scanning)
- hadolint (Dockerfile linting)
- shellcheck (shell script linting)
- pre-commit hooks

---

## Runtipi Integration (Optional)

- Services have `metadata.yml` for app info
- `/manifests/runtipi/` contains template JSON
- `generate_runtipi_manifests.py` reads metadata and outputs Runtipi-ready JSON

---

## Quick Start

```bash
# Bootstrap local environment
./scripts/bootstrap.sh

# Deploy locally
./scripts/deploy_local.sh

# Deploy to cloud
./scripts/deploy_cloud.sh
```

---

## Documentation

See `/docs` for detailed documentation:
- ARCHITECTURE.md
- SERVICES.md
- SECURITY.md
- STORAGE.md
- BOOTSTRAP.md
- CLOUD.md
- BACKUPS.md
