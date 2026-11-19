#!/bin/bash
set -euxo pipefail

# Update packages
apt-get update -y
apt-get upgrade -y

# Install prerequisite utilities
apt-get install -y ca-certificates curl gnupg lsb-release awscli libdigest-sha-perl

# Setup Docker official repository
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker engine
apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Start and enable Docker
systemctl start docker
systemctl enable docker
usermod -aG docker ubuntu

# Allocate 2GB Swap file to ensure smooth Deep Learning inference memory headroom
fallocate -l 2G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo '/swapfile none swap sw 0 0' >> /etc/fstab

# =============================================================================
# Automated GitHub Actions Self-Hosted Runner Bootstrapping
# (Eliminates any manual AWS CLI / Dashboard / SSH execution)
# =============================================================================
GITHUB_REPO_URL="${github_repo_url}"
GITHUB_RUNNER_TOKEN="${github_runner_token}"

if [ -n "$GITHUB_REPO_URL" ] && [ -n "$GITHUB_RUNNER_TOKEN" ]; then
    echo "=== Auto-registering GitHub Actions Self-Hosted Runner ==="
    RUNNER_DIR="/home/ubuntu/actions-runner"
    mkdir -p "$RUNNER_DIR" && cd "$RUNNER_DIR"

    # Download GitHub Actions runner package (latest v2.338.2)
    curl -o actions-runner-linux-x64-2.338.2.tar.gz -L https://github.com/actions/runner/releases/download/v2.338.2/actions-runner-linux-x64-2.338.2.tar.gz
    tar xzf ./actions-runner-linux-x64-2.338.2.tar.gz
    chown -R ubuntu:ubuntu "$RUNNER_DIR"

    # Configure runner as user ubuntu non-interactively
    sudo -u ubuntu ./config.sh \
      --unattended \
      --url "$GITHUB_REPO_URL" \
      --token "$GITHUB_RUNNER_TOKEN" \
      --name "asg-node-$(hostname)" \
      --work "_work" \
      --labels "self-hosted,linux,x64" \
      --replace

    # Install and launch as an automatic systemd background service
    ./svc.sh install ubuntu
    ./svc.sh start
    echo "=== GitHub Self-Hosted Runner Registered and Running Successfully ==="
fi

echo "=== Auto Scaling Instance Provisioned Successfully ==="
