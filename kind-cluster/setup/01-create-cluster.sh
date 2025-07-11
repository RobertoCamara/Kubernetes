#!/bin/bash
set -e

# 🔧 Configuration
CLUSTER_NAME="kindkubelocal"
KIND_CONFIG_FILE="./kind/kind-config.yaml"

if ! command -v kind &>/dev/null; then
  echo "❌ 'kind' not found. Please install it first: https://kind.sigs.k8s.io/"
  exit 1
fi

if [ ! -f "$KIND_CONFIG_FILE" ]; then
  echo "❌ Configuration file '$KIND_CONFIG_FILE' not found."
  exit 1
fi

read -p "❓ Do you want to create/recreate the kind cluster '$CLUSTER_NAME'? (y/N): " CONFIRM

if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
  echo "🧹 Deleting existing cluster (if any)..."
  kind delete cluster --name $CLUSTER_NAME || true

  echo "🚀 Creating kind cluster with exposed ports..."
  kind create cluster --name $CLUSTER_NAME --config $KIND_CONFIG_FILE

  echo "✅ Cluster '$CLUSTER_NAME' created successfully!"
else
  echo "🚫 Cluster creation canceled by user."
fi