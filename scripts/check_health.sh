#!/usr/bin/env bash
#
# Check health of homelab services
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Default values
VERBOSE="false"
SERVICE=""
CHECK_ALL="true"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Service endpoints (update with your domain)
declare -A SERVICE_ENDPOINTS=(
    ["caddy"]="http://localhost:80"
    ["jellyfin"]="http://localhost:8096"
    ["vaultwarden"]="http://localhost:8080"
    ["paperless"]="http://localhost:8000"
    ["uptime-kuma"]="http://localhost:3001"
    ["qbittorrent"]="http://localhost:8085"
    ["syncthing"]="http://localhost:8384"
)

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_verbose() {
    if [[ "${VERBOSE}" == "true" ]]; then
        echo -e "[VERBOSE] $1"
    fi
}

usage() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Check health of homelab services.

Options:
    --service <name>    Check specific service
    --verbose           Verbose output
    --help              Show this help message

Examples:
    $(basename "$0")
    $(basename "$0") --service jellyfin
    $(basename "$0") --verbose
EOF
}

parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --service)
                SERVICE="$2"
                CHECK_ALL="false"
                shift 2
                ;;
            --verbose)
                VERBOSE="true"
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

check_docker_running() {
    if ! docker info &>/dev/null; then
        log_error "Docker is not running"
        return 1
    fi
    log_verbose "Docker is running"
    return 0
}

check_container_status() {
    local service="$1"
    local container_name="${service}"

    # Try to find container with common naming patterns
    local container_id
    container_id=$(docker ps --quiet --filter "name=${container_name}" 2>/dev/null | head --lines 1)

    if [[ -z "${container_id}" ]]; then
        log_warn "${service}: Container not found or not running"
        return 1
    fi

    local status
    status=$(docker inspect --format '{{.State.Status}}' "${container_id}" 2>/dev/null)

    if [[ "${status}" == "running" ]]; then
        log_info "${service}: Container running ✓"
        return 0
    else
        log_error "${service}: Container status: ${status}"
        return 1
    fi
}

check_endpoint() {
    local service="$1"
    local endpoint="${SERVICE_ENDPOINTS[${service}]:-}"

    if [[ -z "${endpoint}" ]]; then
        log_verbose "${service}: No endpoint configured"
        return 0
    fi

    log_verbose "Checking endpoint: ${endpoint}"

    local http_code
    http_code=$(curl --silent --output /dev/null --write-out '%{http_code}' \
        --max-time 5 \
        "${endpoint}" 2>/dev/null || echo "000")

    if [[ "${http_code}" =~ ^[23] ]]; then
        log_info "${service}: HTTP ${http_code} ✓"
        return 0
    else
        log_warn "${service}: HTTP ${http_code}"
        return 1
    fi
}

check_service() {
    local service="$1"
    local failed=0

    log_info "Checking ${service}..."

    check_container_status "${service}" || ((failed++))
    check_endpoint "${service}" || ((failed++))

    return "${failed}"
}

main() {
    parse_args "$@"

    log_info "=== Health Check ==="

    if ! check_docker_running; then
        exit 1
    fi

    local total_failed=0

    if [[ "${CHECK_ALL}" == "true" ]]; then
        for service in "${!SERVICE_ENDPOINTS[@]}"; do
            check_service "${service}" || ((total_failed++))
            echo ""
        done
    else
        check_service "${SERVICE}" || ((total_failed++))
    fi

    echo ""
    log_info "=== Health Check Complete ==="

    if [[ "${total_failed}" -gt 0 ]]; then
        log_warn "Services with issues: ${total_failed}"
        exit 1
    else
        log_info "All services healthy ✓"
        exit 0
    fi
}

main "$@"
