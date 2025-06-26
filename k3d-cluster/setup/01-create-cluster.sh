#!/bin/bash
set -e

read -p "❓ Deseja criar/recriar o cluster k3d? (s/N): " CONFIRM

if [[ "$CONFIRM" =~ ^[Ss]$ ]]; then
  echo "🚀 Iniciando criação do cluster..."

  CLUSTER_NAME="kubelocal-cluster"

  echo "🧹 Deletando cluster antigo (se existir)..."
  k3d cluster delete $CLUSTER_NAME || true

  echo "🚀 Criando cluster k3d com portas expostas..."
  k3d cluster create $CLUSTER_NAME \
    --api-port 6550 \
    -p "8080:30080@loadbalancer" \
    -p "8081:30081@loadbalancer" \
    -p "8082:30082@loadbalancer" \
    -p "8083:30083@loadbalancer" \
    -p "8084:30084@loadbalancer" \
    -p "8085:30085@loadbalancer" \
    -p "8086:30086@loadbalancer" \
    -p "9000:30777@loadbalancer" \
    -p "9092:30092@loadbalancer" \
    -p "9021:30021@loadbalancer" \
    -p "80:80@loadbalancer" \
    -p "443:443@loadbalancer" \
    --agents 1

  echo "✅ Cluster criado com sucesso!"
else
  echo "🚫 Criação do cluster cancelada pelo usuário."
fi
