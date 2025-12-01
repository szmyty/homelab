#!/bin/bash
set -euo pipefail

echo "=== Post-create setup ==="

# Source asdf if available
if [[ -f "$HOME/.asdf/asdf.sh" ]]; then
    # shellcheck source=/dev/null
    source "$HOME/.asdf/asdf.sh"
fi

# Install pre-commit hooks if .pre-commit-config.yaml exists
if [[ -f ".pre-commit-config.yaml" ]]; then
    echo "Installing pre-commit hooks..."
    pre-commit install --install-hooks
fi

# Make scripts executable
if [[ -d "scripts" ]]; then
    echo "Making scripts executable..."
    chmod +x scripts/*.sh 2>/dev/null || true
    chmod +x scripts/*.py 2>/dev/null || true
fi

echo "=== Post-create setup complete ==="
