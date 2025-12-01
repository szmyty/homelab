# Bootstrap Documentation

## Overview

This guide covers setting up your local development environment for the homelab.

## Prerequisites

- Docker and Docker Compose
- Git
- Bash shell (macOS, Linux, or WSL)

## Quick Start

```bash
# Clone the repository
git clone <repository-url>
cd homelab

# Run bootstrap script
./scripts/bootstrap.sh
```

## Manual Setup

### 1. Install Docker

**Linux (Ubuntu/Debian)**:

```bash
# Install Docker
curl --fail --silent --show-error --location https://get.docker.com | sh

# Add user to docker group
sudo usermod --append --groups docker $USER

# Start Docker service
sudo systemctl enable --now docker
```

**macOS**:

```bash
# Install Docker Desktop
brew install --cask docker
```

**Windows (WSL)**:

Install Docker Desktop for Windows and enable WSL integration.

### 2. Install Additional Tools

```bash
# Install yq (YAML processor)
wget --quiet --output-document=/usr/local/bin/yq \
    https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64
chmod +x /usr/local/bin/yq

# Install jq (JSON processor)
sudo apt-get install --yes jq
```

### 3. Configure Environment

```bash
# Copy example environment files
for dir in services/*/; do
    if [[ -f "${dir}env.example" ]]; then
        cp "${dir}env.example" "${dir}.env"
    fi
done

# Edit environment files with your settings
# vim services/jellyfin/.env
```

### 4. Set Up Pre-commit Hooks

```bash
# Install pre-commit
pip install pre-commit

# Install hooks
pre-commit install --install-hooks
```

### 5. Initialize Encrypted Storage (Optional)

```bash
# Install gocryptfs
sudo apt-get install --yes gocryptfs

# Initialize encrypted directory
./scripts/encrypt_volume.sh --init

# Mount encrypted volume
./scripts/encrypt_volume.sh --mount
```

## Development Container

For a consistent development environment, use the devcontainer:

### VS Code

1. Install "Dev Containers" extension
2. Open repository in VS Code
3. Click "Reopen in Container" when prompted

### CLI

```bash
# Build and run devcontainer
docker build --tag homelab-dev .devcontainer/
docker run --interactive --tty --rm \
    --volume "$(pwd):/workspace" \
    --volume /var/run/docker.sock:/var/run/docker.sock \
    homelab-dev
```

## Verify Setup

```bash
# Check Docker
docker --version
docker compose version

# Check tools
jq --version
yq --version

# Validate compose files
docker compose --file infra/compose/core.yml config --quiet

# Run health check
./scripts/check_health.sh
```

## Environment Variables

### Required Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `DOMAIN` | Your domain name | `homelab.local` |
| `EMAIL` | Email for Let's Encrypt | `admin@example.com` |
| `TZ` | Timezone | `America/New_York` |
| `PUID` | User ID for containers | `1000` |
| `PGID` | Group ID for containers | `1000` |

### Service-Specific Variables

See individual service `env.example` files for required variables.

## Troubleshooting

### Docker Permission Denied

```bash
# Add user to docker group
sudo usermod --append --groups docker $USER
# Log out and back in
```

### Port Already in Use

```bash
# Find process using port
sudo lsof -i :80
# or
sudo netstat --listening --numeric --programs | grep :80
```

### Environment File Not Found

```bash
# Copy from example
cp services/<service>/env.example services/<service>/.env
```

## Next Steps

1. [Deploy locally](./CLOUD.md#local-deployment)
2. [Configure services](./SERVICES.md)
3. [Set up backups](./BACKUPS.md)
