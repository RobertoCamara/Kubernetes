#!/bin/bash
set -e

echo "🧪 Verificando e instalando pré-requisitos..."

# Instala kubectl se não existir
if ! command -v kubectl &> /dev/null; then
  echo "📥 Instalando kubectl..."
  curl -LO "https://dl.k8s.io/release/$(curl -sL https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  chmod +x kubectl
  sudo mv kubectl /usr/local/bin/
else
  echo "✅ kubectl já instalado."
fi

# Instala k3d se não existir
if ! command -v k3d &> /dev/null; then
  echo "📥 Instalando k3d..."
  curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
else
  echo "✅ k3d já instalado."
fi

# Instala helm se não existir
if ! command -v helm &> /dev/null; then
  echo "📥 Instalando Helm..."
  curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
else
  echo "✅ Helm já instalado."
fi

echo "✅ Todos pré-requisitos conferidos e instalados!"
