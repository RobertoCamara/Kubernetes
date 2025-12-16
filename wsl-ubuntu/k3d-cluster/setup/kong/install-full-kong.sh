#!/bin/bash
set -e

# 🔧 Configurações
NAMESPACE="kong"
RELEASE_NAME="kong"
KONG_VERSION="2.50.0"
TMP_DIR="./${SCRIPT_DIR}/kong/.tmp-kong"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VALUES_FILE="${SCRIPT_DIR}/values-kong.yaml"
KONGA_FILE="${SCRIPT_DIR}/konga.yaml"

# ❓ Confirmação de reinstalação
read -p "❓ Deseja reinstalar completamente o Kong e o Konga? (s/N): " CONFIRM

if [[ "$CONFIRM" =~ ^[Ss]$ ]]; then
  echo "🧹 Deletando namespace '${NAMESPACE}' (se existir)..."
  kubectl delete namespace ${NAMESPACE} --ignore-not-found

  echo "⌛ Aguardando remoção do namespace..."
  while kubectl get ns ${NAMESPACE} &>/dev/null; do
    sleep 1
  done
else
  echo "⚠️ Reinstalação cancelada. Saindo do script."
  exit 0
fi

echo "🔧 Criando namespace '${NAMESPACE}'..."
kubectl create namespace ${NAMESPACE}

echo "📁 Criando diretório temporário '${TMP_DIR}'..."
mkdir -p ${TMP_DIR}

echo "📦 Baixando chart do Kong (versão ${KONG_VERSION})..."
helm repo add kong https://charts.konghq.com || true
helm repo update
helm pull kong/kong --version ${KONG_VERSION} --untar --untardir ${TMP_DIR}

CRD_PATH="${TMP_DIR}/kong/crds"
if [ ! -d "${CRD_PATH}" ]; then
  echo "❌ Diretório de CRDs não encontrado em ${CRD_PATH}. Abortando."
  exit 1
fi

echo "📥 Aplicando CRDs no cluster Kubernetes..."
kubectl apply -f ${CRD_PATH}

echo "🚀 Instalando Kong com Helm..."
helm install ${RELEASE_NAME} kong/kong \
  --version ${KONG_VERSION} \
  -n ${NAMESPACE} \
  -f ${VALUES_FILE}

echo "✅ Kong instalado com sucesso."

echo "🎨 Aplicando Konga UI..."
kubectl apply -f ${KONGA_FILE} -n ${NAMESPACE}

echo "🧹 Limpando diretório temporário..."
rm -rf ${TMP_DIR}

echo "✅ Instalação finalizada com sucesso!"
echo "🌐 Acesse o Konga via: http://localhost:8081 (ou a porta mapeada via k3d)"
echo "🌐 To connect Kong in your UI (Konga), create a new connection to the following address: http://kong-kong-admin:30085"
echo "🌐 Access Kong Admin at: http://localhost:8085"
