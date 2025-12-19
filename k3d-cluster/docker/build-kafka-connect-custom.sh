#!/bin/bash
set -e

CLUSTER_NAME="kubelocal-cluster"
IMAGE_NAME="kafka-connect-custom:local"

# Caminho absoluto da pasta onde este script está
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

read -p "Deseja construir e importar a imagem customizada do Kafka Connect? (s/n): " CONFIRM
CONFIRM=${CONFIRM,,}  # converte para minúsculas

if [[ "$CONFIRM" != "s" && "$CONFIRM" != "y" ]]; then
  echo "❌ Operação cancelada pelo usuário. Seguindo o fluxo das demais instalações."
  exit 0
fi

echo "🛠️  Construindo imagem customizada do Kafka Connect com plugins..."
docker build -f "$SCRIPT_DIR/Dockerfile.connect" -t $IMAGE_NAME .

echo "📦 Importando imagem para o cluster K3d '$CLUSTER_NAME'..."
k3d image import $IMAGE_NAME -c $CLUSTER_NAME

echo "✅ Imagem criada e importada para o cluster k3d com sucesso."