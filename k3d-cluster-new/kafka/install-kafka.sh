#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Function with countdown and key detection
confirm_with_countdown() {
    local prompt="$1"
    local timeout=10
    local default="y"
    local response=""

    echo -n "$prompt (y/N) [default: $default]"

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

    stty sane
    echo ""

    case "${response,,}" in
        y|yes|"") return 0 ;;
        *) return 1 ;;
    esac
}

# Ask for confirmation before doing anything
if ! confirm_with_countdown "❓ Do you want to install or upgrade Kafka in KRaft mode with NodePort?"; then
  echo "⚠️ Kafka installation skipped."
  exit 0
fi

echo "📂 Checking for 'kafka' namespace..."
if ! kubectl get ns kafka &> /dev/null; then
  echo "📂 Creating 'kafka' namespace..."
  kubectl create ns kafka
else
  echo "✅ Namespace 'kafka' already exists."
fi

echo "📦 Adding Bitnami repository..."
helm repo add bitnami https://charts.bitnami.com/bitnami || true
helm repo update

echo "🧠 Installing/Upgrading Kafka..."
helm upgrade --install kafka bitnami/kafka \
  -n kafka \
  -f "$SCRIPT_DIR/values-kafka-kraft.yaml" \
  --wait

echo "🔨 Running Kafka Connect custom build..."
"$SCRIPT_DIR/../docker/build-kafka-connect-custom.sh"

echo "📥 Applying Kafka manifests..."
kubectl apply -f "$SCRIPT_DIR/../manifests/kafka" -n kafka

echo "✅ Kafka successfully installed and configured!"

echo ""
echo "🔗 Available Endpoints:"
echo "Kafka Broker        => PLAINTEXT://localhost:9092"
echo "Kafka UI            => http://localhost:8080"
echo "Kafka Connect       => http://localhost:8083"