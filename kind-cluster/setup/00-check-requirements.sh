#!/bin/bash
set -e

echo "🧪 Checking and installing prerequisites..."

# Install kubectl if not present
if ! command -v kubectl &> /dev/null; then
  echo "📥 Installing kubectl..."
  curl -LO "https://dl.k8s.io/release/$(curl -sL https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  chmod +x kubectl
  sudo mv kubectl /usr/local/bin/
else
  echo "✅ kubectl is already installed."
fi

# Install kind if not present
if ! command -v kind &> /dev/null; then
  echo "📥 Installing kind..."
  curl -Lo /tmp/kind https://kind.sigs.k8s.io/dl/v0.33.0/kind-linux-amd64
  chmod +x /tmp/kind
  sudo mv /tmp/kind /usr/local/bin/kind
else
  echo "✅ kind is already installed."
fi

# Install helm if not present
if ! command -v helm &> /dev/null; then
  echo "📥 Installing Helm..."
  curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-4 | bash
else
  echo "✅ Helm is already installed."
fi

echo "✅ All prerequisites checked and installed!"