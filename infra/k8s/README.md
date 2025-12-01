# Kubernetes Manifests

This directory contains Kubernetes manifests for homelab services.

## Status

Kubernetes deployment is planned for future development.

## Structure

```text
k8s/
├── base/           # Base manifests
├── overlays/       # Environment-specific overlays
│   ├── dev/
│   └── prod/
└── README.md
```

## Usage

Deploy with kubectl:

```bash
kubectl apply --kustomize k8s/overlays/dev
```
