# Architecture Documentation

## Overview

This homelab repository follows a modular, service-oriented architecture designed for:

- **Local development**: Docker Compose for running services locally
- **Cloud deployment**: Pulumi for infrastructure provisioning
- **Portability**: Works across macOS, WSL, and Linux environments

## Directory Structure

```text
/
├── .devcontainer/     # Development container configuration
├── .github/workflows/ # CI/CD pipelines
├── docs/              # Documentation
├── infra/             # Infrastructure as code
│   ├── ansible/       # Ansible playbooks
│   ├── compose/       # Docker Compose bundles
│   ├── docker/        # Shared Dockerfiles
│   ├── k8s/           # Kubernetes manifests (future)
│   └── pulumi/        # Pulumi stacks
├── manifests/         # Generated manifests
│   └── runtipi/       # Runtipi app manifests
├── scripts/           # Utility scripts
└── services/          # Service configurations
    ├── caddy/         # Reverse proxy
    ├── jellyfin/      # Media server
    ├── paperless/     # Document management
    ├── qbittorrent/   # Torrent client with VPN
    ├── syncthing/     # File synchronization
    ├── uptime-kuma/   # Monitoring
    └── vaultwarden/   # Password manager
```

## Design Principles

### 1. Single Source of Truth

Each service has its own directory containing:

- `docker-compose.yml`: Service definition
- `env.example`: Environment variable template
- `caddy/Caddyfile`: Reverse proxy configuration
- `metadata.yml`: Service metadata for manifest generation

### 2. Composability

Services are designed to be:

- Run independently
- Bundled together using compose profiles
- Deployed via infrastructure bundles in `infra/compose/`

### 3. Security First

- No hardcoded secrets
- Environment variables for sensitive data
- Pre-commit hooks for secret scanning
- Encrypted media storage support

### 4. Infrastructure as Code

All infrastructure is defined declaratively:

- Docker Compose for container orchestration
- Pulumi for cloud resource provisioning
- Ansible for configuration management

## Network Architecture

```text
┌─────────────────────────────────────────────────────────────┐
│                        Internet                              │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
                    ┌─────────────────┐
                    │      Caddy      │
                    │  (Reverse Proxy)│
                    │    :80/:443     │
                    └─────────────────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        ▼                     ▼                     ▼
┌───────────────┐   ┌───────────────┐   ┌───────────────┐
│   Jellyfin    │   │  Vaultwarden  │   │   Paperless   │
│    :8096      │   │     :8080     │   │     :8000     │
└───────────────┘   └───────────────┘   └───────────────┘
```

## Data Flow

1. **User Request**: HTTPS request to domain
2. **Reverse Proxy**: Caddy terminates TLS, routes to service
3. **Service**: Processes request, accesses data volumes
4. **Storage**: Data persisted in Docker volumes or bind mounts

## Scalability Considerations

- Horizontal scaling via Docker Swarm or Kubernetes (future)
- Load balancing through Caddy
- Stateless services where possible
- External database support for services requiring it
