FROM mcr.microsoft.com/devcontainers/base:ubuntu

ARG DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install --yes --no-install-recommends \
    curl \
    wget \
    git \
    gnupg \
    lsb-release \
    ca-certificates \
    software-properties-common \
    apt-transport-https \
    jq \
    unzip \
    zip \
    python3 \
    python3-pip \
    python3-venv \
    shellcheck \
    && rm --recursive --force /var/lib/apt/lists/*

# Install yq
RUN wget --quiet --output-document=/usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 \
    && chmod +x /usr/local/bin/yq

# Install Pulumi
RUN curl --fail --silent --show-error --location https://get.pulumi.com | bash \
    && mv /root/.pulumi/bin/* /usr/local/bin/

# Install OpenTofu
RUN curl --proto '=https' --tlsv1.2 --fail --silent --show-error --location https://get.opentofu.org/install-opentofu.sh --output install-opentofu.sh \
    && chmod +x install-opentofu.sh \
    && ./install-opentofu.sh --install-method deb \
    && rm install-opentofu.sh

# Install Ansible
RUN pip3 install --no-cache-dir ansible ansible-lint

# Install asdf for version management
USER vscode
RUN git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.14.0 \
    && echo '. "$HOME/.asdf/asdf.sh"' >> ~/.bashrc \
    && echo '. "$HOME/.asdf/completions/asdf.bash"' >> ~/.bashrc

# Install pre-commit
RUN pip3 install --no-cache-dir --user pre-commit

USER root

# Create workspace directory
RUN mkdir --parents /workspace && chown vscode:vscode /workspace

WORKDIR /workspace
