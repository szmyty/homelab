#!/usr/bin/env bash
#
# Wrapper for encrypted volume management using gocryptfs
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Default paths (update these for your setup)
ENCRYPTED_PATH="${ENCRYPTED_PATH:-/mnt/d/.media/videos}"
DECRYPTED_PATH="${DECRYPTED_PATH:-${HOME}/.media/videos}"

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

Manage encrypted volumes using gocryptfs.

Options:
    --init              Initialize new encrypted volume
    --mount             Mount encrypted volume
    --unmount           Unmount encrypted volume
    --status            Check mount status
    --encrypted-path    Path to encrypted data
                        Default: ${ENCRYPTED_PATH}
    --decrypted-path    Path for decrypted mount
                        Default: ${DECRYPTED_PATH}
    --help              Show this help message

Environment Variables:
    ENCRYPTED_PATH      Path to encrypted data
    DECRYPTED_PATH      Path for decrypted mount

Examples:
    $(basename "$0") --init
    $(basename "$0") --mount
    $(basename "$0") --unmount
    $(basename "$0") --status

Note: gocryptfs must be installed. Install with:
    sudo apt-get install --yes gocryptfs
EOF
}

check_gocryptfs() {
    if ! command -v gocryptfs &>/dev/null; then
        log_error "gocryptfs not found"
        log_info "Install with: sudo apt-get install --yes gocryptfs"
        exit 1
    fi
}

check_fusermount() {
    if ! command -v fusermount &>/dev/null; then
        log_error "fusermount not found"
        log_info "Install with: sudo apt-get install --yes fuse"
        exit 1
    fi
}

init_volume() {
    log_info "Initializing encrypted volume..."
    log_info "Encrypted path: ${ENCRYPTED_PATH}"

    if [[ -f "${ENCRYPTED_PATH}/gocryptfs.conf" ]]; then
        log_error "Encrypted volume already initialized at ${ENCRYPTED_PATH}"
        exit 1
    fi

    mkdir --parents "${ENCRYPTED_PATH}"
    mkdir --parents "${DECRYPTED_PATH}"

    gocryptfs --init "${ENCRYPTED_PATH}"

    log_info "Encrypted volume initialized successfully"
    log_info "Remember your password! It cannot be recovered."
}

mount_volume() {
    log_info "Mounting encrypted volume..."

    if is_mounted; then
        log_warn "Volume already mounted at ${DECRYPTED_PATH}"
        return 0
    fi

    if [[ ! -f "${ENCRYPTED_PATH}/gocryptfs.conf" ]]; then
        log_error "Encrypted volume not initialized at ${ENCRYPTED_PATH}"
        log_info "Run: $(basename "$0") --init"
        exit 1
    fi

    mkdir --parents "${DECRYPTED_PATH}"

    gocryptfs "${ENCRYPTED_PATH}" "${DECRYPTED_PATH}"

    if is_mounted; then
        log_info "Volume mounted successfully at ${DECRYPTED_PATH}"
    else
        log_error "Failed to mount volume"
        exit 1
    fi
}

unmount_volume() {
    log_info "Unmounting encrypted volume..."

    if ! is_mounted; then
        log_warn "Volume not mounted at ${DECRYPTED_PATH}"
        return 0
    fi

    fusermount --unmount "${DECRYPTED_PATH}"

    if ! is_mounted; then
        log_info "Volume unmounted successfully"
    else
        log_error "Failed to unmount volume"
        exit 1
    fi
}

is_mounted() {
    mount | grep --quiet "on ${DECRYPTED_PATH} type fuse.gocryptfs"
}

show_status() {
    log_info "Volume Status"
    log_info "============="
    log_info "Encrypted path: ${ENCRYPTED_PATH}"
    log_info "Decrypted path: ${DECRYPTED_PATH}"

    if [[ -f "${ENCRYPTED_PATH}/gocryptfs.conf" ]]; then
        log_info "Initialized: Yes"
    else
        log_info "Initialized: No"
    fi

    if is_mounted; then
        log_info "Mounted: Yes"
        log_info ""
        log_info "Contents:"
        ls --long --human-readable "${DECRYPTED_PATH}" 2>/dev/null || log_warn "Unable to list contents"
    else
        log_info "Mounted: No"
    fi
}

main() {
    local action=""

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --init)
                action="init"
                shift
                ;;
            --mount)
                action="mount"
                shift
                ;;
            --unmount)
                action="unmount"
                shift
                ;;
            --status)
                action="status"
                shift
                ;;
            --encrypted-path)
                ENCRYPTED_PATH="$2"
                shift 2
                ;;
            --decrypted-path)
                DECRYPTED_PATH="$2"
                shift 2
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

    if [[ -z "${action}" ]]; then
        usage
        exit 1
    fi

    check_gocryptfs

    case "${action}" in
        init)
            init_volume
            ;;
        mount)
            mount_volume
            ;;
        unmount)
            check_fusermount
            unmount_volume
            ;;
        status)
            show_status
            ;;
    esac
}

main "$@"
