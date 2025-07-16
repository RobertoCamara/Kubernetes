#!/bin/bash

set -e

NAMESPACE="portainer"
RELEASE_NAME="portainer"

echo "🚨 Cleaning up old Portainer (Helm release and namespace)..."

if helm ls -n "$NAMESPACE" | grep -q "^$RELEASE_NAME"; then
  echo "🔻 Uninstalling Helm release '$RELEASE_NAME' in namespace '$NAMESPACE'..."
  helm uninstall "$RELEASE_NAME" -n "$NAMESPACE"
else
  echo "⚠️ Helm release '$RELEASE_NAME' not found in namespace '$NAMESPACE'."
fi

if kubectl get ns "$NAMESPACE" &>/dev/null; then
  echo "🔻 Deleting namespace '$NAMESPACE'..."
  kubectl delete ns "$NAMESPACE" --wait --timeout=60s
else
  echo "⚠️ Namespace '$NAMESPACE' does not exist."
fi

echo "🔧 Creating namespace '$NAMESPACE'..."
kubectl create ns "$NAMESPACE"
sleep 5

echo "📥 Updating Helm repository for Portainer..."
helm repo add portainer https://portainer.github.io/k8s/ --force-update 2>/dev/null || true
helm repo update

echo "🚀 Installing Portainer with default ports (NodePort 9000/9443)..."
helm install "$RELEASE_NAME" portainer/portainer \
  --namespace "$NAMESPACE" \
  --set service.type=NodePort \
  --set service.nodePort=9000 \
  --set service.ports.https.nodePort=9443

echo "⏳ Waiting for Portainer rollout..."
kubectl rollout status deployment/portainer -n "$NAMESPACE" --timeout=120s

echo -e "\n✅ Portainer successfully installed!"
echo "Access it via: http://localhost:9000"