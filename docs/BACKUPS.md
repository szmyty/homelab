# Backup Documentation

## Overview

Regular backups are essential for disaster recovery. This homelab includes automated backup capabilities.

## Backup Strategy

### 3-2-1 Rule

- **3** copies of data
- **2** different storage media
- **1** offsite copy

### What to Backup

| Category | Location | Priority |
|----------|----------|----------|
| Service configs | Docker volumes | High |
| Databases | Docker volumes | High |
| Media metadata | Service volumes | Medium |
| Environment files | `.env` files | High |
| Certificates | `certs/` | High |
| Media files | Encrypted storage | Medium |

### What NOT to Backup

- Cache files
- Temporary data
- Log files (unless required)
- Decrypted mount points

## Backup Script

### Usage

```bash
# Backup all services
./scripts/backup.sh --all

# Backup specific service
./scripts/backup.sh --service jellyfin

# Backup to specific location
./scripts/backup.sh --all --destination /mnt/backup

# Dry run (show what would be backed up)
./scripts/backup.sh --all --dry-run

# Verbose output
./scripts/backup.sh --all --verbose
```

### Options

| Option | Description |
|--------|-------------|
| `--all` | Backup all services |
| `--service <name>` | Backup specific service |
| `--destination <path>` | Backup destination |
| `--dry-run` | Show what would be backed up |
| `--verbose` | Verbose output |
| `--compress` | Compress backup (default: true) |

## Manual Backup

### Docker Volumes

```bash
# List volumes
docker volume ls

# Backup volume to tar
docker run --rm \
    --volume jellyfin_config:/source:ro \
    --volume $(pwd)/backups:/backup \
    alpine tar --create --gzip --verbose \
        --file /backup/jellyfin_config_$(date +%Y%m%d).tar.gz \
        --directory /source .
```

### Database Backup

For services with databases:

```bash
# Paperless-ngx (PostgreSQL)
docker compose exec paperless-db pg_dump \
    --username paperless \
    --format custom \
    --file /tmp/paperless.dump paperless

# Copy out of container
docker compose cp paperless-db:/tmp/paperless.dump ./backups/
```

## Restore

### Docker Volumes

```bash
# Restore volume from tar
docker run --rm \
    --volume jellyfin_config:/target \
    --volume $(pwd)/backups:/backup:ro \
    alpine tar --extract --gzip --verbose \
        --file /backup/jellyfin_config_20240101.tar.gz \
        --directory /target
```

### Database Restore

```bash
# Restore PostgreSQL
docker compose exec paperless-db pg_restore \
    --username paperless \
    --dbname paperless \
    /tmp/paperless.dump
```

## Automation

### GitHub Actions

The `backup-cron.yml` workflow runs nightly backups.

### Cron Job

For local automation:

```bash
# Edit crontab
crontab -e

# Add nightly backup at 2 AM
0 2 * * * /path/to/homelab/scripts/backup.sh --all --destination /mnt/backup
```

## Offsite Backup

### Rclone

```bash
# Install rclone
curl https://rclone.org/install.sh | sudo bash

# Configure remote (e.g., Google Drive)
rclone config

# Sync backups
rclone sync /path/to/backups remote:homelab-backups
```

### Restic

```bash
# Initialize repository
restic init --repo s3:s3.amazonaws.com/bucket-name

# Backup
restic backup --repo s3:s3.amazonaws.com/bucket-name /path/to/backups

# Restore
restic restore latest --target /path/to/restore
```

## Backup Verification

### Test Restore

Regularly test restores:

```bash
# Create test environment
mkdir /tmp/restore-test

# Restore backup
./scripts/backup.sh --restore --source /mnt/backup/latest --destination /tmp/restore-test

# Verify data
ls /tmp/restore-test
```

### Integrity Check

```bash
# Check tar archive
tar --test --verbose --file backup.tar.gz

# Check with checksums
sha256sum --check backup.sha256
```

## Retention Policy

| Backup Type | Retention |
|-------------|-----------|
| Daily | 7 days |
| Weekly | 4 weeks |
| Monthly | 12 months |
| Yearly | Indefinite |

### Cleanup Script

```bash
# Remove backups older than 7 days
find /mnt/backup -name "*.tar.gz" -mtime +7 -delete
```

## Disaster Recovery

### Scenario: Complete Data Loss

1. Provision new infrastructure (Pulumi)
2. Clone repository
3. Restore latest backup
4. Update DNS if needed
5. Verify services

### Scenario: Single Service Failure

1. Stop affected service
2. Restore service volume
3. Restart service
4. Verify functionality

## Monitoring

### Backup Status

```bash
# Check last backup
ls --long --human-readable /mnt/backup | tail --lines 5

# Check backup size
du --summarize --human-readable /mnt/backup
```

### Alerts

Configure Uptime Kuma to monitor:

- Backup script exit code
- Backup file age
- Backup storage space
