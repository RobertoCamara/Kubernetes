#!/bin/bash
set -e

# Caminho absoluto da pasta onde este script está
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "📂 Criando namespace kafka..."
kubectl create namespace kafka || true

echo "📦 Adicionando repositório Bitnami..."
helm repo add bitnami https://charts.bitnami.com/bitnami || true
helm repo update

echo "🧠 Instalando Kafka em modo KRaft com NodePort..."
helm install kafka bitnami/kafka \
  -n kafka \
  -f "$SCRIPT_DIR/values-kafka-kraft.yaml" \
  --wait

"$SCRIPT_DIR/../../docker/build-kafka-connect-custom.sh"

echo "📥 Aplicando manifests Kafka..."
kubectl apply -f "$SCRIPT_DIR/../../manifests/kafka" -n kafka

echo "✅ Kafka instalado com sucesso!"
echo ""
echo "🔗 Endpoints disponíveis:"
echo "Kafka Broker        => PLAINTEXT://localhost:9092"
echo "Kafka (UI)          => http://localhost:8080"
echo "Kafka Connect       => http://localhost:8083"