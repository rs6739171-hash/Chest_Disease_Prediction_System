#!/bin/bash
set -ex

exec > >(tee /var/log/user_data.log|logger -t user-data -s 2>/dev/console) 2>&1
echo "=== Starting Chest Disease Prediction ASG Instance Provisioning ==="

# 1. Force IPv4 in APT to prevent IPv6 unreachable timeouts in AWS VPC
echo 'Acquire::ForceIPv4 "true";' > /etc/apt/apt.conf.d/99force-ipv4

# 2. Point to Canonical main archive to avoid regional mirror 503 issues
sed -i 's/ap-south-1.ec2.archive.ubuntu.com/archive.ubuntu.com/g' /etc/apt/sources.list
sed -i 's/ap-south-1.ec2.ports.ubuntu.com/ports.ubuntu.com/g' /etc/apt/sources.list

# 3. Update package index
apt-get update -y || (sleep 5 && apt-get update -y)

# 4. Install Docker and dependencies
DEBIAN_FRONTEND=noninteractive apt-get install -y docker.io curl tar ca-certificates jq unzip git || true

# 5. Failsafe: Install static Docker if apt failed
if ! command -v docker &> /dev/null; then
    echo "Installing static Docker binaries..."
    curl -fsSL https://download.docker.com/linux/static/stable/x86_64/docker-27.3.1.tgz | tar xz -C /usr/bin --strip-components=1
fi

# 6. Start and enable Docker
systemctl start docker || dockerd &
systemctl enable docker || true
usermod -aG docker ubuntu || true
chmod 666 /var/run/docker.sock || true

echo "Docker version: $(docker --version)"

# =============================================================================
# 7. Automated GitHub Actions Self-Hosted Runner Bootstrapping
# =============================================================================
GITHUB_REPO_URL="${github_repo_url}"
GITHUB_RUNNER_TOKEN="${github_runner_token}"

if [ -n "$GITHUB_REPO_URL" ] && [ -n "$GITHUB_RUNNER_TOKEN" ]; then
    RUNNER_DIR="/home/ubuntu/actions-runner"
    mkdir -p "$RUNNER_DIR"
    cd "$RUNNER_DIR"

    echo "Downloading GitHub Actions runner v2.338.2..."
    curl -o runner.tar.gz -L https://github.com/actions/runner/releases/download/v2.338.2/actions-runner-linux-x64-2.338.2.tar.gz
    tar xzf ./runner.tar.gz
    chown -R ubuntu:ubuntu "$RUNNER_DIR"

    export HOME=/home/ubuntu
    sudo -H -u ubuntu ./config.sh \
      --unattended \
      --url "$GITHUB_REPO_URL" \
      --token "$GITHUB_RUNNER_TOKEN" \
      --name "asg-node-$(hostname)" \
      --work "_work" \
      --labels "self-hosted,linux,x64" \
      --replace

    ./svc.sh install ubuntu
    ./svc.sh start
    echo "=== GitHub Self-Hosted Runner Registered and Running Successfully ==="
fi

echo "=== Auto Scaling Instance Provisioned Successfully ==="
