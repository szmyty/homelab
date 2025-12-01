#!/usr/bin/env bash
#
# Backup Docker volumes and configuration
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Default values
BACKUP_ALL="false"
SERVICE=""
DESTINATION="${REPO_ROOT}/backups"
DRY_RUN="false"
VERBOSE="false"
COMPRESS="true"
DATE_SUFFIX="$(date +%Y%m%d_%H%M%S)"

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

log_verbose() {
    if [[ "${VERBOSE}" == "true" ]]; then
        echo -e "[VERBOSE] $1"
    fi
}

usage() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Backup Docker volumes and service configuration.

Options:
    --all                   Backup all services
    --service <name>        Backup specific service
    --destination <path>    Backup destination directory
                            Default: ./backups
    --dry-run               Show what would be backed up
    --verbose               Verbose output
    --no-compress           Don't compress backups
    --help                  Show this help message

Examples:
    $(basename "$0") --all
    $(basename "$0") --service jellyfin
    $(basename "$0") --all --destination /mnt/backup --verbose
EOF
}

parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --all)
                BACKUP_ALL="true"
                shift
                ;;
            --service)
                SERVICE="$2"
                shift 2
                ;;
            --destination)
                DESTINATION="$2"
                shift 2
                ;;
            --dry-run)
                DRY_RUN="true"
                shift
                ;;
            --verbose)
                VERBOSE="true"
                shift
                ;;
            --no-compress)
                COMPRESS="false"
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

    if [[ "${BACKUP_ALL}" == "false" ]] && [[ -z "${SERVICE}" ]]; then
        log_error "Please specify --all or --service <name>"
        usage
        exit 1
    fi
}

get_service_volumes() {
    local service="$1"
    local compose_file="${REPO_ROOT}/services/${service}/docker-compose.yml"

    if [[ ! -f "${compose_file}" ]]; then
        log_warn "No docker-compose.yml found for ${service}"
        return
    fi

    # Extract named volumes from compose file
    yq eval '.volumes | keys | .[]' "${compose_file}" 2>/dev/null || true
}

backup_volume() {
    local volume_name="$1"
    local destination="$2"

    local backup_file="${destination}/${volume_name}_${DATE_SUFFIX}"

    if [[ "${COMPRESS}" == "true" ]]; then
        backup_file="${backup_file}.tar.gz"
    else
        backup_file="${backup_file}.tar"
    fi

    log_verbose "Backing up volume: ${volume_name} to ${backup_file}"

    if [[ "${DRY_RUN}" == "true" ]]; then
        log_info "[DRY RUN] Would backup ${volume_name} to ${backup_file}"
        return
    fi

    # Check if volume exists
    if ! docker volume inspect "${volume_name}" &>/dev/null; then
        log_warn "Volume ${volume_name} does not exist, skipping"
        return
    fi

    local tar_opts="--create --verbose"
    if [[ "${COMPRESS}" == "true" ]]; then
        tar_opts="${tar_opts} --gzip"
    fi

    docker run --rm \
        --volume "${volume_name}:/source:ro" \
        --volume "${destination}:/backup" \
        alpine tar ${tar_opts} \
            --file "/backup/$(basename "${backup_file}")" \
            --directory /source .

    log_info "Backed up ${volume_name} to ${backup_file}"
}

backup_service() {
    local service="$1"
    local destination="$2"

    log_info "Backing up service: ${service}"

    local service_dir="${destination}/${service}"
    mkdir --parents "${service_dir}"

    # Backup environment file if exists
    local env_file="${REPO_ROOT}/services/${service}/.env"
    if [[ -f "${env_file}" ]]; then
        if [[ "${DRY_RUN}" == "true" ]]; then
            log_info "[DRY RUN] Would backup ${env_file}"
        else
            cp "${env_file}" "${service_dir}/.env_${DATE_SUFFIX}"
            log_verbose "Backed up .env file"
        fi
    fi

    # Backup volumes
    local volumes
    volumes=$(get_service_volumes "${service}")

    for volume in ${volumes}; do
        backup_volume "${volume}" "${service_dir}"
    done
}

main() {
    parse_args "$@"

    log_info "=== Backup Script ==="
    log_info "Destination: ${DESTINATION}"

    # Create destination directory
    mkdir --parents "${DESTINATION}"

    if [[ "${BACKUP_ALL}" == "true" ]]; then
        log_info "Backing up all services..."
        for service_dir in "${REPO_ROOT}"/services/*/; do
            service_name=$(basename "${service_dir}")
            backup_service "${service_name}" "${DESTINATION}"
        done
    else
        backup_service "${SERVICE}" "${DESTINATION}"
    fi

    log_info "=== Backup Complete ==="

    if [[ "${DRY_RUN}" == "false" ]]; then
        log_info "Backup location: ${DESTINATION}"
        ls --long --human-readable "${DESTINATION}"
    fi
}

main "$@"
