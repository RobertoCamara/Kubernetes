#!/bin/bash
set -euo pipefail

#######################################
# 📍 Diretório do script (PRIMEIRO)
#######################################
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

#######################################
# 🔧 Configurações globais
#######################################

NAMESPACE="kong"
RELEASE_NAME="kong"
KONG_VERSION="2.50.0"

TMP_DIR="${SCRIPT_DIR}/.tmp-kong"

VALUES_FILE="${SCRIPT_DIR}/values-kong.yaml"
KONGA_FILE="${SCRIPT_DIR}/konga.yaml"

KONG_DB_TEMPLATE="${SCRIPT_DIR}/kong-external-databases.yaml.tpl"
KONG_DB_RENDERED="${SCRIPT_DIR}/kong-external-databases.yaml"

POSTGRES_CONTAINER="mypostgresql-db"
DOCKER_NETWORK="databases_mydatabases-net"


#######################################
# 🧰 Funções utilitárias
#######################################

log() {
  echo -e "👉 $1"
}

error() {
  echo -e "❌ $1" >&2
  exit 1
}

confirm() {
  read -p "❓ $1 (s/N): " CONFIRM
  [[ "$CONFIRM" =~ ^[Ss]$ ]]
}

#######################################
# 🔍 Infra / Networking
#######################################

detect_wsl_gateway() {
  log "Detectando gateway da rede Docker: ${DOCKER_NETWORK}"

  WSL_GATEWAY_IP=$(docker inspect "$POSTGRES_CONTAINER" \
    | jq -r ".[0].NetworkSettings.Networks[\"$DOCKER_NETWORK\"].Gateway")

  if [[ -z "$WSL_GATEWAY_IP" || "$WSL_GATEWAY_IP" == "null" ]]; then
    error "Não foi possível detectar o gateway da rede Docker (${DOCKER_NETWORK})"
  fi

  export WSL_GATEWAY_IP
  log "Gateway detectado: ${WSL_GATEWAY_IP}"
}

#######################################
# ☸️ Kubernetes helpers
#######################################

delete_namespace_if_exists() {
  log "Removendo namespace '${NAMESPACE}' (se existir)..."
  kubectl delete namespace "$NAMESPACE" --ignore-not-found

  log "Aguardando remoção completa do namespace..."
  while kubectl get ns "$NAMESPACE" &>/dev/null; do
    sleep 1
  done
}

create_namespace() {
  log "Criando namespace '${NAMESPACE}'..."
  kubectl create namespace "$NAMESPACE"
}

apply_external_databases() {
  log "Gerando manifests de databases externas..."
  envsubst < "$KONG_DB_TEMPLATE" > "$KONG_DB_RENDERED"

  kubectl apply -f "$KONG_DB_RENDERED"

  log "Validando endpoints criados..."
  kubectl -n "$NAMESPACE" get endpoints mongo-external
  kubectl -n "$NAMESPACE" get endpoints postgres-external
}

#######################################
# 🚀 Instalação do Kong
#######################################

install_kong() {
  log "Preparando diretório temporário..."
  mkdir -p "$TMP_DIR"

  log "Baixando Helm chart do Kong (${KONG_VERSION})..."
  helm repo add kong https://charts.konghq.com >/dev/null || true
  helm repo update >/dev/null

  helm pull kong/kong \
    --version "$KONG_VERSION" \
    --untar \
    --untardir "$TMP_DIR"

  local CRD_PATH="${TMP_DIR}/kong/crds"

  [[ -d "$CRD_PATH" ]] || error "Diretório de CRDs não encontrado: $CRD_PATH"

  log "Aplicando CRDs..."
  kubectl apply -f "$CRD_PATH"

  log "Instalando Kong via Helm..."
  helm install "$RELEASE_NAME" kong/kong \
    --version "$KONG_VERSION" \
    -n "$NAMESPACE" \
    -f "$VALUES_FILE"

  log "Kong instalado com sucesso"
}

install_konga() {
  log "Aplicando Konga UI..."
  kubectl apply -f "$KONGA_FILE" -n "$NAMESPACE"
}

cleanup() {
  log "Limpando arquivos temporários..."
  rm -rf "$TMP_DIR"
}

#######################################
# 🧭 Main
#######################################

main() {
  detect_wsl_gateway

  if ! confirm "Deseja reinstalar completamente o Kong e o Konga?"; then
    log "Instalação cancelada."
    exit 0
  fi

  delete_namespace_if_exists
  create_namespace
  apply_external_databases
  install_kong
  install_konga
  cleanup

  log "Instalação finalizada com sucesso!"
  echo "🌐 Acesse o Konga via: http://localhost:8081 (ou a porta mapeada via k3d)"  
  echo "🌐 Access Kong Admin at: http://localhost:8085"
  echo "🌐 Pra conectar seu Kong em seu UI (Konga), crie uma nova conexão no seguinte endereço: http://kong-kong-admin:30085"
}

main