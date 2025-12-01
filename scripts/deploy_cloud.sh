#!/usr/bin/env bash
#
# Deploy infrastructure to cloud using Pulumi
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
PULUMI_DIR="${REPO_ROOT}/infra/pulumi"

# Default values
STACK="dev"
ACTION="preview"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

usage() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Deploy homelab infrastructure to cloud using Pulumi.

Options:
    --stack <name>      Pulumi stack to use (local, dev, prod)
                        Default: dev
    --preview           Preview changes without deploying (default)
    --up                Deploy infrastructure
    --destroy           Destroy infrastructure
    --refresh           Refresh stack state
    --output            Show stack outputs
    --help              Show this help message

Examples:
    $(basename "$0") --stack dev --preview
    $(basename "$0") --stack prod --up
    $(basename "$0") --stack dev --destroy

Stacks:
    local   - Local Docker-based deployment
    dev     - Development GCP environment
    prod    - Production GCP environment
EOF
}

parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --stack)
                STACK="$2"
                shift 2
                ;;
            --preview)
                ACTION="preview"
                shift
                ;;
            --up)
                ACTION="up"
                shift
                ;;
            --destroy)
                ACTION="destroy"
                shift
                ;;
            --refresh)
                ACTION="refresh"
                shift
                ;;
            --output)
                ACTION="output"
                shift
                ;;
            --help)
                usage
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                usage
                exit 1
                ;;
        esac
    done
}

check_pulumi() {
    if ! command -v pulumi &> /dev/null; then
        log_error "Pulumi not found. Please install Pulumi first."
        log_info "Install with: curl --fail --silent --show-error --location https://get.pulumi.com | bash"
        exit 1
    fi
}

run_pulumi() {
    local stack="$1"
    local action="$2"

    cd "${PULUMI_DIR}"

    # Select stack
    log_info "Selecting stack: ${stack}"
    pulumi stack select "${stack}" 2>/dev/null || {
        log_warn "Stack ${stack} not found. Creating..."
        pulumi stack init "${stack}"
    }

    case "${action}" in
        preview)
            log_info "Previewing changes..."
            pulumi preview
            ;;
        up)
            log_info "Deploying infrastructure..."
            pulumi up --yes
            ;;
        destroy)
            log_warn "Destroying infrastructure..."
            read -p "Are you sure you want to destroy all resources? [y/N] " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                pulumi destroy --yes
            else
                log_info "Destroy cancelled"
            fi
            ;;
        refresh)
            log_info "Refreshing stack state..."
            pulumi refresh --yes
            ;;
        output)
            log_info "Stack outputs:"
            pulumi stack output
            ;;
        *)
            log_error "Unknown action: ${action}"
            exit 1
            ;;
    esac
}

main() {
    parse_args "$@"

    log_info "=== Cloud Deployment ==="
    log_info "Stack: ${STACK}"
    log_info "Action: ${ACTION}"

    check_pulumi

    run_pulumi "${STACK}" "${ACTION}"

    log_info "=== Cloud Deployment Complete ==="
}

main "$@"
