#!/bin/bash
set -e

# 🔧 Configurações
CLUSTER_NAME="kubelocal"
K3S_IMAGE="rancher/k3s:v1.33.2-k3s1"

# 🔎 Verificação de dependência
if ! command -v k3d &>/dev/null; then
  echo "❌ k3d não encontrado. Instale-o primeiro: https://k3d.io/"
  exit 1
fi

read -p "❓ Deseja criar/recriar o cluster k3d '$CLUSTER_NAME'? (s/N): " CONFIRM

if [[ "$CONFIRM" =~ ^[Ss]$ ]]; then
  echo "🚀 Iniciando criação do cluster..."

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
    --image $K3S_IMAGE \
    --agents 1

  echo "✅ Cluster '$CLUSTER_NAME' criado com sucesso!"
else
  echo "🚫 Criação do cluster cancelada pelo usuário."
fi