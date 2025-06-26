#!/bin/bash
set -e

# Caminho absoluto da pasta onde este script está
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

chmod +x "$SCRIPT_DIR"/*.sh

echo "🚀 Iniciando setup UIs..."

"$SCRIPT_DIR/00-install-portainer.sh"
"$SCRIPT_DIR/01-install-kubernetes-dashboard.sh"
"$SCRIPT_DIR/02-install-kubevious.sh"
"$SCRIPT_DIR/03-create-portainer-agent.sh"

echo ""
echo "🎉 Setup UIs executado com sucesso!"
