#!/bin/bash
set -e

# 🔧 Configuration
NAMESPACE="kong"
RELEASE_NAME="kong"
KONG_VERSION="2.50.0"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TMP_DIR="${SCRIPT_DIR}/.tmp-kong"
VALUES_FILE="${SCRIPT_DIR}/values-kong.yaml"
KONGA_FILE="${SCRIPT_DIR}/konga.yaml"

# Confirmation function with countdown and key detection
confirm_with_countdown() {
    local prompt="$1"
    local timeout=10
    local default="y"

    echo -n "$prompt (y/N) [default: $default]"

    # Prepare terminal for silent single-key read
    stty -echo -icanon time 0 min 0
    tput sc  # Save cursor position

    for ((i=timeout; i>0; i--)); do
        tput rc  # Restore cursor position
        tput el  # Clear to end of line
        echo -n " - waiting... ${i}s"
        read -t 1 -n 1 response
        if [[ -n "$response" ]]; then
            echo ""
            break
        fi
    done

    # Restore terminal
    stty sane
    echo ""

    # Evaluate response
    case "${response,,}" in  # lowercase
        y|yes|"") return 0 ;;
        *) return 1 ;;
    esac
}

# ❓ Reinstallation confirmation with countdown
if confirm_with_countdown "❓ Do you want to completely reinstall Kong and Konga?"; then
  echo "🧹 Deleting namespace '${NAMESPACE}' (if it exists)..."
  kubectl delete namespace ${NAMESPACE} --ignore-not-found

  echo "⌛ Waiting for namespace deletion..."
  while kubectl get ns ${NAMESPACE} &>/dev/null; do
    sleep 1
  done
else
  echo "⚠️ Reinstallation canceled. Exiting script."
  exit 0
fi

echo "🔧 Creating namespace '${NAMESPACE}'..."
kubectl create namespace ${NAMESPACE}

echo "📁 Creating temporary directory '${TMP_DIR}'..."
mkdir -p ${TMP_DIR}

echo "📦 Downloading Kong chart (version ${KONG_VERSION})..."
helm repo add kong https://charts.konghq.com || true
helm repo update
helm pull kong/kong --version ${KONG_VERSION} --untar --untardir ${TMP_DIR}

CRD_PATH="${TMP_DIR}/kong/crds"
if [ ! -d "${CRD_PATH}" ]; then
  echo "❌ CRDs directory not found at ${CRD_PATH}. Aborting."
  exit 1
fi

echo "📥 Applying CRDs to the Kubernetes cluster..."
kubectl apply -f ${CRD_PATH}

echo "🚀 Installing Kong with Helm..."
helm install ${RELEASE_NAME} kong/kong \
  --version ${KONG_VERSION} \
  -n ${NAMESPACE} \
  -f ${VALUES_FILE}

echo "✅ Kong installed successfully."

echo "🎨 Applying Konga UI..."
kubectl apply -f ${KONGA_FILE} -n ${NAMESPACE}

echo "🧹 Cleaning up temporary directory..."
rm -rf ${TMP_DIR}

echo "✅ Installation completed successfully!"
echo "🌐 To connect Kong in your UI (Konga), create a new connection to the following address: http://kong-kong-admin:8085"
echo "🌐 Access Konga at: http://localhost:8081"
echo "🌐 Access Kong Admin at: http://localhost:8085"