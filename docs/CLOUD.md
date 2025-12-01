# Cloud Deployment Documentation

## Overview

This homelab supports cloud deployment using Pulumi for infrastructure provisioning.

## Supported Providers

- Google Cloud Platform (GCP)
- AWS (future)
- Azure (future)

## Prerequisites

- Pulumi CLI installed
- Cloud provider CLI installed and configured
- Valid cloud credentials

## GCP Setup

### 1. Install Google Cloud CLI

```bash
# Install gcloud CLI
curl https://sdk.cloud.google.com | bash
exec --login $SHELL

# Initialize
gcloud init
```

### 2. Configure Authentication

```bash
# Login to GCP
gcloud auth login
gcloud auth application-default login

# Set project
gcloud config set project <project-id>
```

### 3. Enable Required APIs

```bash
gcloud services enable compute.googleapis.com
gcloud services enable dns.googleapis.com
gcloud services enable cloudresourcemanager.googleapis.com
```

## Pulumi Configuration

### Initialize Stack

```bash
cd infra/pulumi

# Login to Pulumi
pulumi login

# Select or create stack
pulumi stack select dev
# or
pulumi stack init dev
```

### Configure Stack

```bash
# Set GCP project
pulumi config set gcp:project <project-id>
pulumi config set gcp:region us-central1
pulumi config set gcp:zone us-central1-a

# Set VM configuration
pulumi config set vm-size e2-medium
pulumi config set domain homelab.example.com

# Set secrets
pulumi config set --secret ssh-public-key "$(cat ~/.ssh/id_rsa.pub)"
```

## Deployment

### Preview Changes

```bash
# Using script
./scripts/deploy_cloud.sh --preview

# Or directly
cd infra/pulumi && pulumi preview
```

### Deploy

```bash
# Using script
./scripts/deploy_cloud.sh --up

# Or directly
cd infra/pulumi && pulumi up
```

### Destroy

```bash
# Using script
./scripts/deploy_cloud.sh --destroy

# Or directly
cd infra/pulumi && pulumi destroy
```

## What Gets Deployed

### Compute

- GCE VM instance with specified machine type
- Boot disk with Ubuntu LTS
- SSH access via your public key

### Networking

- VPC network (or default)
- Firewall rules for HTTP/HTTPS
- Static external IP

### DNS

- A record for domain
- AAAA record for IPv6 (if available)
- CNAME records for services

### Cloud-Init

The VM is configured via cloud-init to:

1. Install Docker and Docker Compose
2. Install Caddy
3. Clone this repository to `/opt/homelab`
4. Start services

## Post-Deployment

### Access VM

```bash
# SSH to VM
gcloud compute ssh homelab-vm --zone us-central1-a

# Or using IP
ssh user@<external-ip>
```

### Verify Services

```bash
# On the VM
cd /opt/homelab
docker compose --file infra/compose/core.yml ps
```

### Update Deployment

```bash
# Pull latest changes on VM
ssh user@<ip> "cd /opt/homelab && git pull && ./scripts/deploy_local.sh"
```

## Cost Optimization

### VM Sizing

| Size | vCPU | RAM | Use Case |
|------|------|-----|----------|
| e2-micro | 0.25 | 1GB | Testing only |
| e2-small | 0.5 | 2GB | Light usage |
| e2-medium | 1 | 4GB | Recommended |
| e2-standard-2 | 2 | 8GB | Heavy usage |

### Preemptible VMs

For non-critical workloads, use preemptible VMs:

```bash
pulumi config set preemptible true
```

### Scheduled Scaling

Consider stopping VM during off-hours.

## Troubleshooting

### Pulumi Login Issues

```bash
# Re-login
pulumi logout
pulumi login
```

### GCP Permission Errors

```bash
# Check current identity
gcloud auth list

# Refresh credentials
gcloud auth application-default login
```

### VM Not Accessible

```bash
# Check firewall rules
gcloud compute firewall-rules list

# Check VM status
gcloud compute instances describe homelab-vm --zone us-central1-a
```

## Stacks

### Local Stack

For testing Pulumi locally with Docker:

```bash
pulumi stack select local
```

### Dev Stack

For development GCP environment:

```bash
pulumi stack select dev
```

### Prod Stack

For production GCP environment:

```bash
pulumi stack select prod
```
