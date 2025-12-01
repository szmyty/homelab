#!/usr/bin/env bash
#
# Deploy services locally using Docker Compose
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
COMPOSE_DIR="${REPO_ROOT}/infra/compose"

# Default values
BUNDLE="core"
ACTION="up"
DETACH="true"

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

Deploy homelab services locally using Docker Compose.

Options:
    --bundle <name>     Compose bundle to use (core, media, vault, docs, all)
                        Default: core
    --action <action>   Docker Compose action (up, down, restart, logs, ps)
                        Default: up
    --attached          Run in attached mode (not detached)
    --help              Show this help message

Examples:
    $(basename "$0") --bundle core --action up
    $(basename "$0") --bundle media --action logs
    $(basename "$0") --bundle all --action down

Available bundles:
    core    - Caddy, monitoring, Uptime Kuma
    media   - Jellyfin, qBittorrent stack
    vault   - Vaultwarden + backups
    docs    - Paperless-ngx
    all     - All bundles
EOF
}

parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --bundle)
                BUNDLE="$2"
                shift 2
                ;;
            --action)
                ACTION="$2"
                shift 2
                ;;
            --attached)
                DETACH="false"
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

get_compose_files() {
    local bundle="$1"
    local files=""

    case "${bundle}" in
        core)
            files="${COMPOSE_DIR}/core.yml"
            ;;
        media)
            files="${COMPOSE_DIR}/media.yml"
            ;;
        vault)
            files="${COMPOSE_DIR}/vault.yml"
            ;;
        docs)
            files="${COMPOSE_DIR}/docs.yml"
            ;;
        all)
            files="${COMPOSE_DIR}/core.yml"
            files="${files} --file ${COMPOSE_DIR}/media.yml"
            files="${files} --file ${COMPOSE_DIR}/vault.yml"
            files="${files} --file ${COMPOSE_DIR}/docs.yml"
            ;;
        *)
            log_error "Unknown bundle: ${bundle}"
            exit 1
            ;;
    esac

    echo "${files}"
}

run_compose() {
    local compose_files="$1"
    local action="$2"
    local detach="$3"

    local cmd="docker compose --file ${compose_files}"

    case "${action}" in
        up)
            if [[ "${detach}" == "true" ]]; then
                cmd="${cmd} up --detach --remove-orphans"
            else
                cmd="${cmd} up --remove-orphans"
            fi
            ;;
        down)
            cmd="${cmd} down --remove-orphans"
            ;;
        restart)
            cmd="${cmd} restart"
            ;;
        logs)
            cmd="${cmd} logs --follow --tail 100"
            ;;
        ps)
            cmd="${cmd} ps --all"
            ;;
        *)
            log_error "Unknown action: ${action}"
            exit 1
            ;;
    esac

    log_info "Running: ${cmd}"
    eval "${cmd}"
}

main() {
    parse_args "$@"

    log_info "=== Local Deployment ==="
    log_info "Bundle: ${BUNDLE}"
    log_info "Action: ${ACTION}"

    # Check Docker
    if ! command -v docker &> /dev/null; then
        log_error "Docker not found. Please run bootstrap.sh first."
        exit 1
    fi

    if ! docker compose version &> /dev/null; then
        log_error "Docker Compose not found or not working."
        exit 1
    fi

    # Get compose files
    compose_files=$(get_compose_files "${BUNDLE}")

    # Run compose command
    run_compose "${compose_files}" "${ACTION}" "${DETACH}"

    log_info "=== Deployment Complete ==="
}

main "$@"
