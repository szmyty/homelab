# Storage Documentation

## Overview

This homelab uses a combination of Docker volumes and bind mounts for persistent storage.

## Storage Architecture

```text
┌─────────────────────────────────────────────────────────────┐
│                      Host System                             │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────────┐    ┌──────────────────────────────┐   │
│  │  Docker Volumes  │    │       Bind Mounts            │   │
│  │                  │    │                              │   │
│  │  - config data   │    │  /mnt/d/.media (encrypted)   │   │
│  │  - app data      │    │         │                    │   │
│  │  - databases     │    │         ▼ (FUSE decrypt)     │   │
│  │                  │    │  ~/.media (decrypted)        │   │
│  └──────────────────┘    │         │                    │   │
│           │              │         ▼                    │   │
│           │              │  Container bind mount        │   │
│           ▼              └──────────────────────────────┘   │
│  ┌──────────────────────────────────────────────────────┐   │
│  │              Docker Container                         │   │
│  └──────────────────────────────────────────────────────┘   │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

## Volume Types

### Docker Named Volumes

Used for:

- Service configuration
- Application databases
- Cache data

Example:

```yaml
volumes:
  jellyfin_config:
  jellyfin_cache:
```

### Bind Mounts

Used for:

- Media files
- Documents for Paperless
- Synced files

Example:

```yaml
volumes:
  - ${MEDIA_PATH}:/media:ro
  - ${DOCUMENTS_PATH}:/consume
```

## Encrypted Media Storage

### WSL Configuration

**Encrypted Location** (on Windows drive):

```text
/mnt/d/.media/videos
```

**Decrypted Mount** (inside WSL):

```text
/home/<user>/.media/videos
```

### How It Works

1. Encrypted data stored on Windows NTFS drive
2. gocryptfs/encfs mounts decrypted view in WSL
3. Docker containers bind-mount decrypted path
4. **No storage duplication** - FUSE passthrough

### Setup Commands

```bash
# Create encrypted directory
mkdir --parents /mnt/d/.media/videos

# Initialize encryption (first time only)
gocryptfs --init /mnt/d/.media/videos

# Mount decrypted view
mkdir --parents ~/.media/videos
gocryptfs /mnt/d/.media/videos ~/.media/videos
```

### Using encrypt_volume.sh

```bash
# Mount encrypted volume
./scripts/encrypt_volume.sh --mount

# Unmount
./scripts/encrypt_volume.sh --unmount

# Check status
./scripts/encrypt_volume.sh --status
```

## Backup Considerations

### What to Backup

- Docker volumes (config, databases)
- Encrypted media source (not the decrypted mount)
- Environment files
- Certificates

### What NOT to Backup

- Decrypted mounts (redundant)
- Cache volumes
- Temporary files

### Backup Commands

```bash
# Backup all volumes
./scripts/backup.sh --all

# Backup specific service
./scripts/backup.sh --service jellyfin
```

## Storage Best Practices

1. **Separate concerns**: Config vs data vs media
2. **Use encryption**: For sensitive data
3. **Regular backups**: Automated and tested
4. **Monitor capacity**: Set alerts for low space
5. **Document paths**: Keep this file updated

## Path Configuration

Update `.env` files with your paths:

```bash
# Example .env configuration
MEDIA_PATH=/home/user/.media/videos
DOCUMENTS_PATH=/home/user/documents/consume
DATA_PATH=/var/lib/homelab
```

## Troubleshooting

### Permission Issues

```bash
# Check ownership
ls --long --all /path/to/volume

# Fix permissions
sudo chown --recursive 1000:1000 /path/to/volume
```

### Mount Issues

```bash
# Check if encrypted volume is mounted
mount | grep gocryptfs

# Force unmount
fusermount --unmount ~/.media/videos
```
