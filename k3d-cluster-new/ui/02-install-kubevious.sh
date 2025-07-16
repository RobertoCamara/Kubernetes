#!/bin/bash
set -e

NAMESPACE="kubevious"
RELEASE_NAME="kubevious"
SERVICE_NAME="kubevious-ui-clusterip"
NODE_PORT=30082
LOCAL_PORT=8082

echo "📂 Checking if namespace '$NAMESPACE' exists..."
if ! kubectl get namespace "$NAMESPACE" &> /dev/null; then
  echo "📦 Creating namespace '$NAMESPACE'..."
  kubectl create namespace "$NAMESPACE"
else
  echo "✅ Namespace '$NAMESPACE' already exists."
fi

echo "📦 Adding Kubevious Helm repository (if needed)..."
helm repo add kubevious https://helm.kubevious.io || true
helm repo update

echo "🔍 Checking if release '$RELEASE_NAME' is already installed..."
if ! helm status "$RELEASE_NAME" -n "$NAMESPACE" &> /dev/null; then
  echo "🚀 Installing Kubevious..."
  helm install "$RELEASE_NAME" kubevious/kubevious -n "$NAMESPACE" --wait
else
  echo "✅ Kubevious is already installed in namespace '$NAMESPACE'."
fi

echo "🔍 Checking if service '$SERVICE_NAME' exists..."
if ! kubectl get svc "$SERVICE_NAME" -n "$NAMESPACE" &> /dev/null; then
  echo "❌ Service '$SERVICE_NAME' not found. Please check the Kubevious installation."
  exit 1
fi

echo "🔧 Updating service type to NodePort and overriding ports..."
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
echo "✅ Kubevious successfully configured!"
echo "🔗 Access the UI at: http://localhost:$LOCAL_PORT"