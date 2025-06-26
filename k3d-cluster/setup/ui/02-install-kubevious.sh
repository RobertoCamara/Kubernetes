#!/bin/bash
set -e

NAMESPACE="kubevious"
RELEASE_NAME="kubevious"
SERVICE_NAME="kubevious-ui-clusterip"
NODE_PORT=30082
LOCAL_PORT=8082

echo "📂 Verificando se o namespace '$NAMESPACE' existe..."
if ! kubectl get namespace "$NAMESPACE" &> /dev/null; then
  echo "📦 Criando namespace '$NAMESPACE'..."
  kubectl create namespace "$NAMESPACE"
else
  echo "✅ Namespace '$NAMESPACE' já existe."
fi

echo "📦 Adicionando repositório do Kubevious (se necessário)..."
helm repo add kubevious https://helm.kubevious.io || true
helm repo update

echo "🔍 Verificando se o release '$RELEASE_NAME' já está instalado..."
if ! helm status "$RELEASE_NAME" -n "$NAMESPACE" &> /dev/null; then
  echo "🚀 Instalando Kubevious..."
  helm install "$RELEASE_NAME" kubevious/kubevious -n "$NAMESPACE" --wait
else
  echo "✅ Kubevious já está instalado no namespace '$NAMESPACE'."
fi

echo "🔍 Verificando se o Service '$SERVICE_NAME' existe..."
if ! kubectl get svc "$SERVICE_NAME" -n "$NAMESPACE" &> /dev/null; then
  echo "❌ Service '$SERVICE_NAME' não encontrado. Verifique a instalação do Kubevious."
  exit 1
fi

echo "🔧 Alterando tipo do Service para NodePort e sobrescrevendo portas..."
kubectl patch svc "$SERVICE_NAME" -n "$NAMESPACE" --type='merge' -p "{
  \"spec\": {
    \"type\": \"NodePort\",
    \"ports\": [
      {
        \"name\": \"http\",
        \"port\": 4000,
        \"targetPort\": 4000,
        \"nodePort\": $NODE_PORT,
        \"protocol\": \"TCP\"
      }
    ]
  }
}"

echo ""
echo "✅ Kubevious configurado com sucesso!"
echo "🔗 Acesse a UI em: http://localhost:$LOCAL_PORT"
