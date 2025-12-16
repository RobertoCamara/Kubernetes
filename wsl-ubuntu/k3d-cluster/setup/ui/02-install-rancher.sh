#!/bin/bash
set -e

CLUSTER_NAME="rancher"
NAMESPACE="cattle-system"
HOSTNAME="rancher.localhost"
BOOTSTRAP_PASSWORD="admin"

echo "🔎 Verificando conexão com o cluster k3d..."
kubectl cluster-info >/dev/null

echo "📦 Adicionando Helm repo do Rancher..."
helm repo add rancher-latest https://releases.rancher.com/server-charts/latest >/dev/null
helm repo update >/dev/null

echo "🧹 Limpando instalação anterior (se existir)..."
helm uninstall rancher -n $NAMESPACE 2>/dev/null || true
kubectl delete namespace $NAMESPACE --ignore-not-found

echo "⏳ Aguardando namespace ser removido..."
kubectl wait --for=delete namespace/$NAMESPACE --timeout=120s 2>/dev/null || true

echo "🚀 Instalando Rancher..."
helm install rancher rancher-latest/rancher \
  --namespace $NAMESPACE \
  --create-namespace \
  --set hostname=$HOSTNAME \
  --set replicas=1 \
  --set ingress.enabled=true \
  --set ingress.ingressClassName=traefik \
  --set bootstrapPassword=$BOOTSTRAP_PASSWORD

echo "⏳ Aguardando Rancher ficar pronto..."
kubectl -n $NAMESPACE rollout status deployment/rancher --timeout=180s

echo "🔎 Verificando Ingress..."
kubectl -n $NAMESPACE get ingress

echo "✅ Rancher instalado com sucesso!"
echo ""
echo "👉 Acesse no browser do Windows:"
echo "   https://$HOSTNAME"
echo ""
echo "⚠️ Certificado será self-signed — aceite o aviso no browser"
