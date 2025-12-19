#!/bin/bash
set -e

chmod +x ./*.sh

echo "🚀 Iniciando setup completo..."

#./00-check-requirements.sh

#./01-create-cluster.sh

#./02-install-cert-manager.sh

#./ui/setup-ui.sh

./kong/install-full-kong.sh

#./kafka/00-install-kafka.sh



echo ""
echo "🎉 Setup completo executado com sucesso!"
