# Runtipi Manifests

This directory contains Runtipi-compatible manifests generated from service metadata.

## Generation

Manifests are generated using the `generate_runtipi_manifests.py` script:

```bash
./scripts/generate_runtipi_manifests.py
```

## Structure

Each service has a corresponding JSON manifest file:

```text
runtipi/
├── caddy.json
├── jellyfin.json
├── paperless.json
├── qbittorrent.json
├── syncthing.json
├── uptime-kuma.json
└── vaultwarden.json
```

## Usage

Import manifests into Runtipi according to Runtipi documentation.

## Note

Generated files are gitignored. Run the generator script to create them.
