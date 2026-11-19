#!/bin/bash

# Fix AWS regional mirror 503 error by switching to Canonical's main archive
sed -i 's/ap-south-1.ec2.archive.ubuntu.com/archive.ubuntu.com/g' /etc/apt/sources.list
sed -i 's/ap-south-1.ec2.ports.ubuntu.com/ports.ubuntu.com/g' /etc/apt/sources.list

# Update package index with retry
apt-get update -y || (sleep 5 && apt-get update -y)

# Install Docker, curl, and extraction tools directly from official Ubuntu repositories
DEBIAN_FRONTEND=noninteractive apt-get install -y docker.io curl tar ca-certificates

# Start and enable Docker daemon
systemctl start docker
systemctl enable docker
usermod -aG docker ubuntu
chmod 666 /var/run/docker.sock || true

# =============================================================================
# Automated GitHub Actions Self-Hosted Runner Bootstrapping
# =============================================================================
GITHUB_REPO_URL="${github_repo_url}"
GITHUB_RUNNER_TOKEN="${github_runner_token}"

if [ -n "$GITHUB_REPO_URL" ] && [ -n "$GITHUB_RUNNER_TOKEN" ]; then
    RUNNER_DIR="/home/ubuntu/actions-runner"
    mkdir -p "$RUNNER_DIR"
    cd "$RUNNER_DIR"

    # Download GitHub Actions runner package (v2.338.2)
    curl -o runner.tar.gz -L https://github.com/actions/runner/releases/download/v2.338.2/actions-runner-linux-x64-2.338.2.tar.gz
    tar xzf ./runner.tar.gz
    chown -R ubuntu:ubuntu "$RUNNER_DIR"

    # Configure runner as user ubuntu with correct HOME directory
    export HOME=/home/ubuntu
    sudo -H -u ubuntu ./config.sh \
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
