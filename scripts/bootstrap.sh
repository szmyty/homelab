#!/usr/bin/env bash
#
# Bootstrap script for homelab local environment setup
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_command() {
    if ! command -v "$1" &> /dev/null; then
        return 1
    fi
    return 0
}

install_docker() {
    log_info "Installing Docker..."
    if [[ "$(uname)" == "Darwin" ]]; then
        log_warn "Please install Docker Desktop for macOS manually"
        log_warn "Download from: https://www.docker.com/products/docker-desktop"
        return 1
    else
        curl --fail --silent --show-error --location https://get.docker.com | sh
        sudo usermod --append --groups docker "${USER}"
        log_warn "You may need to log out and back in for Docker group to take effect"
    fi
}

install_tools() {
    log_info "Installing required tools..."

    # Install jq
    if ! check_command jq; then
        log_info "Installing jq..."
        if [[ "$(uname)" == "Darwin" ]]; then
            brew install jq
        else
            sudo apt-get update && sudo apt-get install --yes jq
        fi
    else
        log_info "jq already installed"
    fi

    # Install yq
    if ! check_command yq; then
        log_info "Installing yq..."
        if [[ "$(uname)" == "Darwin" ]]; then
            brew install yq
        else
            sudo wget --quiet --output-document=/usr/local/bin/yq \
                https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64
            sudo chmod +x /usr/local/bin/yq
        fi
    else
        log_info "yq already installed"
    fi

    # Install pre-commit
    if ! check_command pre-commit; then
        log_info "Installing pre-commit..."
        pip3 install --user pre-commit
    else
        log_info "pre-commit already installed"
    fi
}

setup_environment() {
    log_info "Setting up environment files..."

    for dir in "${REPO_ROOT}"/services/*/; do
        service_name="$(basename "${dir}")"
        if [[ -f "${dir}env.example" ]] && [[ ! -f "${dir}.env" ]]; then
            log_info "Creating .env for ${service_name}"
            cp "${dir}env.example" "${dir}.env"
        fi
    done
}

setup_precommit() {
    log_info "Setting up pre-commit hooks..."

    if [[ -f "${REPO_ROOT}/.pre-commit-config.yaml" ]]; then
        cd "${REPO_ROOT}"
        pre-commit install --install-hooks || log_warn "Failed to install pre-commit hooks"
    fi
}

make_scripts_executable() {
    log_info "Making scripts executable..."
    chmod +x "${REPO_ROOT}"/scripts/*.sh 2>/dev/null || true
    chmod +x "${REPO_ROOT}"/scripts/*.py 2>/dev/null || true
}

main() {
    log_info "=== Homelab Bootstrap Script ==="
    log_info "Repository root: ${REPO_ROOT}"

    # Check Docker
    if ! check_command docker; then
        log_warn "Docker not found"
        read -p "Would you like to install Docker? [y/N] " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            install_docker
        fi
    else
        log_info "Docker is installed: $(docker --version)"
    fi

    # Check Docker Compose
    if ! docker compose version &> /dev/null; then
        log_warn "Docker Compose not found or not working"
    else
        log_info "Docker Compose is available: $(docker compose version --short)"
    fi

    # Install tools
    install_tools

    # Setup environment
    setup_environment

    # Setup pre-commit
    setup_precommit

    # Make scripts executable
    make_scripts_executable

    log_info "=== Bootstrap Complete ==="
    log_info ""
    log_info "Next steps:"
    log_info "  1. Edit .env files in services/ directories"
    log_info "  2. Run: ./scripts/deploy_local.sh"
    log_info "  3. Access services via Caddy reverse proxy"
}

main "$@"
