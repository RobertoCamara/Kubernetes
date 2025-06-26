#!/bin/bash
set -e

AGENT_NAME="portainer_agent"
AGENT_IMAGE="portainer/agent:2.27.6"
PORT=9001

echo "🧹 Removendo container '$AGENT_NAME' se existir..."
docker rm -f "$AGENT_NAME" >/dev/null 2>&1 || true

echo "🚀 Criando container '$AGENT_NAME'..."
docker run -d \
  -p ${PORT}:9001 \
  --name $AGENT_NAME \
  --restart=always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /var/lib/docker/volumes:/var/lib/docker/volumes \
  -v /:/host \
  $AGENT_IMAGE

echo ""
echo "🌐 Descobrindo IP local para usar no Portainer Server..."
IP=$(hostname -I | awk '{print $1}')

echo ""
echo "🔗 Use este endereço no Portainer Server para adicionar o ambiente:"
echo "👉  $IP:$PORT"

echo ""
echo "✅ Portainer Agent instalado e em execução."
