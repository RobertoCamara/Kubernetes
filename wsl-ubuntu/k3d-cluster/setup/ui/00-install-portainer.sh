#!/bin/bash

set -e

NAMESPACE="portainer"
RELEASE_NAME="portainer"

echo "🚨 Limpando Portainer antigo (release Helm e namespace)..."

if helm ls -n "$NAMESPACE" | grep -q "^$RELEASE_NAME"; then
  echo "🔻 Desinstalando release Helm $RELEASE_NAME no namespace $NAMESPACE..."
  helm uninstall "$RELEASE_NAME" -n "$NAMESPACE"
else
  echo "⚠️ Release Helm $RELEASE_NAME não encontrado no namespace $NAMESPACE."
fi

if kubectl get ns "$NAMESPACE" &>/dev/null; then
  echo "🔻 Deletando namespace $NAMESPACE..."
  kubectl delete ns "$NAMESPACE" --wait --timeout=60s
else
  echo "⚠️ Namespace $NAMESPACE não existe."
fi

echo "🔧 Criando namespace $NAMESPACE..."
kubectl create ns "$NAMESPACE"
sleep 5

echo "📥 Atualizando repositório Helm do Portainer..."
helm repo add portainer https://portainer.github.io/k8s/ --force-update 2>/dev/null || true
helm repo update

echo "🚀 Instalando Portainer com portas padrão (NodePort 9000/9443)..."
helm install "$RELEASE_NAME" portainer/portainer \
  --namespace "$NAMESPACE" \
  --set service.type=NodePort

echo -e "\n✅ Portainer instalado com sucesso!"
echo "Acesse via: http://localhost:9000"