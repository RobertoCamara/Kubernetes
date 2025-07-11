#!/bin/bash
set -e

AGENT_NAME="portainer_agent"
AGENT_IMAGE="portainer/agent:2.27.6"
PORT=9001

echo "🧹 Removing container '${AGENT_NAME}' if it exists..."
docker rm -f "${AGENT_NAME}" >/dev/null 2>&1 || true

echo "🚀 Creating container '${AGENT_NAME}'..."
docker run -d \
  -p ${PORT}:9001 \
  --name "${AGENT_NAME}" \
  --restart=always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /var/lib/docker/volumes:/var/lib/docker/volumes \
  -v /:/host \
  "${AGENT_IMAGE}"

echo ""
echo "🌐 Detecting local IP address to use in Portainer Server..."
IP=$(ip route get 8.8.8.8 | awk '{print $7; exit}')

echo ""
echo "🔗 Use the following address in the Portainer Server to add the environment:"
echo "👉  ${IP}:${PORT}"

echo ""
echo "✅ Portainer Agent installed and running."

echo ""
echo "📋 Container status:"
docker ps --filter "name=${AGENT_NAME}" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"