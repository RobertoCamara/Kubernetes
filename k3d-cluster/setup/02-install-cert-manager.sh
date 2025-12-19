#!/bin/bash
set -e

CERT_MANAGER_VERSION="v1.14.5"

echo "📦 Instalando cert-manager CRDs..."
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/${CERT_MANAGER_VERSION}/cert-manager.crds.yaml

echo "📦 Criando namespace cert-manager..."
kubectl create namespace cert-manager --dry-run=client -o yaml | kubectl apply -f -

echo "📦 Adicionando Helm repo cert-manager..."
helm repo add jetstack https://charts.jetstack.io >/dev/null
helm repo update >/dev/null

echo "🚀 Instalando cert-manager..."
helm upgrade --install cert-manager jetstack/cert-manager \
  -n cert-manager \
  --version ${CERT_MANAGER_VERSION}

echo "⏳ Aguardando cert-manager ficar pronto..."
kubectl -n cert-manager rollout status deploy/cert-manager --timeout=120s
kubectl -n cert-manager rollout status deploy/cert-manager-webhook --timeout=120s
kubectl -n cert-manager rollout status deploy/cert-manager-cainjector --timeout=120s

echo "✅ cert-manager instalado com sucesso"
