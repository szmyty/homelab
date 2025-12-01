# Services Documentation

## Overview

This homelab includes the following services:

| Service | Description | Default Port |
|---------|-------------|--------------|
| Caddy | Reverse proxy with automatic HTTPS | 80/443 |
| Jellyfin | Open-source media server | 8096 |
| Vaultwarden | Bitwarden-compatible password manager | 8080 |
| Paperless-ngx | Document management system | 8000 |
| Uptime Kuma | Self-hosted monitoring tool | 3001 |
| qBittorrent | Torrent client with VPN integration | 8085 |
| Syncthing | Continuous file synchronization | 8384 |

## Service Details

### Caddy

**Purpose**: Reverse proxy and automatic HTTPS certificate management

**Configuration**:

- Automatic TLS via Let's Encrypt or ZeroSSL
- HTTP/2 and HTTP/3 support
- Handles routing to all services

**Files**:

- `services/caddy/docker-compose.yml`
- `services/caddy/Caddyfile`

### Jellyfin

**Purpose**: Stream media to any device

**Features**:

- Video transcoding
- Live TV and DVR (with tuner)
- Multi-user support
- Mobile and TV apps

**Data**:

- Config: `/config`
- Cache: `/cache`
- Media: `/media` (bind mount from encrypted storage)

### Vaultwarden

**Purpose**: Self-hosted password manager

**Features**:

- Bitwarden-compatible clients
- Organizations and sharing
- 2FA support
- Secure attachment storage

**Security Notes**:

- Regular backups essential
- Admin panel disabled by default
- Rate limiting enabled

### Paperless-ngx

**Purpose**: Document management and OCR

**Features**:

- Automatic document classification
- Full-text search
- OCR for scanned documents
- Correspondent and tag management

**Data**:

- Consume: `/consume` (drop documents here)
- Data: `/data`
- Media: `/media`

### Uptime Kuma

**Purpose**: Service monitoring and alerting

**Features**:

- HTTP(s), TCP, Ping monitoring
- Multiple notification channels
- Status pages
- Maintenance windows

### qBittorrent

**Purpose**: Torrent client with VPN kill switch

**Features**:

- Web UI
- VPN integration (Gluetun)
- Kill switch for security
- Automatic torrent management

**Security Notes**:

- VPN mandatory for operation
- Kill switch prevents leaks
- Bound to VPN interface only

### Syncthing

**Purpose**: Continuous file synchronization

**Features**:

- Peer-to-peer sync
- End-to-end encryption
- Versioning
- Selective sync

**Data**:

- Config: `/config`
- Sync folders: User-defined

## Adding New Services

1. Create service directory: `services/<service-name>/`
2. Add required files:
   - `docker-compose.yml`
   - `env.example`
   - `caddy/Caddyfile`
   - `metadata.yml`
3. Update Caddy configuration
4. Add to appropriate compose bundle
5. Update documentation
