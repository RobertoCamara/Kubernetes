#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NAMESPACE="vault"
RELEASE_NAME="vault"
VALUES_FILE="${SCRIPT_DIR}/values-vault.yaml"
HELM_REPO_CONFIG="${TMPDIR:-/tmp}/helm-repos-kind-$(id -u).yaml"
HELM_REPO_CACHE="${TMPDIR:-/tmp}/helm-cache-kind-$(id -u)"
HOST_VAULT_DIR="/var/lib/kind-data/vault"
BOOTSTRAP_FILE="/var/lib/kind-data/vault-bootstrap.json"

mkdir -p "${HELM_REPO_CACHE}"
export HELM_REPOSITORY_CONFIG="${HELM_REPO_CONFIG}"
export HELM_REPOSITORY_CACHE="${HELM_REPO_CACHE}"

ensure_vault_data_dir() {
  sudo mkdir -p "${HOST_VAULT_DIR}"
  sudo chown -R 100:1000 "${HOST_VAULT_DIR}"
  sudo chmod -R 0770 "${HOST_VAULT_DIR}"
}

bootstrap_vault_if_needed() {
  echo "⏳ Waiting for Vault pod to start..."
  kubectl wait --for=jsonpath='{.status.phase}'=Running pod/${RELEASE_NAME}-0 -n "${NAMESPACE}" --timeout=180s >/dev/null

  local vault_status
  vault_status="$(kubectl exec -n "${NAMESPACE}" pod/${RELEASE_NAME}-0 -- vault status -format=json 2>/dev/null || true)"
  local initialized sealed
  initialized="$(printf '%s' "${vault_status}" | python3 -c 'import json, sys; print(json.load(sys.stdin).get("initialized", False))' 2>/dev/null || echo false)"
  sealed="$(printf '%s' "${vault_status}" | python3 -c 'import json, sys; print(json.load(sys.stdin).get("sealed", True))' 2>/dev/null || echo true)"

  local unseal_key="" root_token=""
  if [[ "${initialized}" == "False" ]]; then
    echo "🚀 Vault is not initialized yet. Running first-time bootstrap..."
    local init_output
    init_output="$(kubectl exec -n "${NAMESPACE}" pod/${RELEASE_NAME}-0 -- vault operator init -key-shares=1 -key-threshold=1 -format=json)"

    printf '%s\n' "${init_output}" | sudo install -m 600 /dev/stdin "${BOOTSTRAP_FILE}"
    unseal_key="$(printf '%s' "${init_output}" | python3 -c 'import sys, json; print(json.load(sys.stdin)["unseal_keys_b64"][0])')"
    root_token="$(printf '%s' "${init_output}" | python3 -c 'import sys, json; print(json.load(sys.stdin)["root_token"])')"
  elif [[ "${sealed}" == "True" ]]; then
    echo "🔒 Vault is initialized but sealed. Loading the persisted bootstrap result..."
    if ! sudo test -r "${BOOTSTRAP_FILE}"; then
      echo "❌ Vault is sealed but ${BOOTSTRAP_FILE} is missing. Restore the unseal key or remove the persistent data and initialize again."
      return 1
    fi
    unseal_key="$(sudo python3 -c 'import json, sys; print(json.load(open(sys.argv[1]))["unseal_keys_b64"][0])' "${BOOTSTRAP_FILE}")"
    root_token="$(sudo python3 -c 'import json, sys; print(json.load(open(sys.argv[1]))["root_token"])' "${BOOTSTRAP_FILE}")"
  else
    echo "✅ Vault is already initialized and unsealed."
    if ! sudo test -r "${BOOTSTRAP_FILE}"; then
      echo "⚠️ Bootstrap file not found. The access token cannot be displayed."
      return 0
    fi
    root_token="$(sudo python3 -c 'import json, sys; print(json.load(open(sys.argv[1]))["root_token"])' "${BOOTSTRAP_FILE}")"
    echo ""
    echo "🔑 Access Token: ${root_token}"
    echo "🌐 Login: http://localhost:8200/ui"
    echo "🔐 Credentials stored at: ${BOOTSTRAP_FILE}"
    return 0
  fi

  kubectl exec -n "${NAMESPACE}" pod/${RELEASE_NAME}-0 -- vault operator unseal "${unseal_key}"

  kubectl exec -n "${NAMESPACE}" pod/${RELEASE_NAME}-0 -- vault status >/dev/null

  echo ""
  echo "🔑 Root Token: ${root_token}"
  echo "🗝️ Unseal Key: ${unseal_key}"
  echo "🔐 Credentials stored at: ${BOOTSTRAP_FILE}"
  echo "✅ Vault initialized and unsealed successfully."
  echo "🌐 Open: http://localhost:8200/ui"
}

confirm_with_countdown() {
    local prompt="$1"
    local timeout=10
    local default="y"
    local response=""

    echo -n "$prompt (y/N) [default: $default]"

    if [[ -t 0 ]]; then
        stty -echo -icanon time 0 min 0
        tput sc

        for ((i=timeout; i>0; i--)); do
            tput rc
            tput el
            echo -n " - waiting... ${i}s"
            read -t 1 -n 1 response
            if [[ -n "$response" ]]; then
                echo ""
                break
            fi
        done

        stty sane
        echo ""
    else
        response="y"
        echo ""
    fi

    case "${response,,}" in
        y|yes|"") return 0 ;;
        *) return 1 ;;
    esac
}

if ! confirm_with_countdown "❓ Do you want to install or upgrade Vault with persistent storage in /var/lib/kind-data?"; then
  echo "⚠️ Vault installation skipped."
  exit 0
fi

ensure_vault_data_dir

if ! kubectl get namespace "${NAMESPACE}" >/dev/null 2>&1; then
  echo "📂 Creating namespace '${NAMESPACE}'..."
  kubectl create namespace "${NAMESPACE}"
else
  echo "✅ Namespace '${NAMESPACE}' already exists."
fi

if ! helm repo list 2>/dev/null | awk '{print $1}' | grep -qx "hashicorp"; then
  echo "📦 Adding HashiCorp Helm repository..."
  helm repo add hashicorp https://helm.releases.hashicorp.com
fi

helm repo update

echo "🚀 Installing Vault with Helm..."
helm upgrade --install "${RELEASE_NAME}" hashicorp/vault \
  --namespace "${NAMESPACE}" \
  --create-namespace \
  -f "${VALUES_FILE}" \
  --wait

kubectl get pods -n "${NAMESPACE}"
kubectl get svc -n "${NAMESPACE}"

bootstrap_vault_if_needed

echo ""
echo "✅ Vault installed successfully!"
echo "🌐 API: http://localhost:8200"
echo "🌐 UI: http://localhost:8200/ui"
echo "🧪 Health check: curl http://localhost:8200/v1/sys/health"
