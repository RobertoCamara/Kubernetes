#!/bin/bash
set -e

find . -name "*.sh" -exec chmod +x {} +

echo "🚀 Starting full setup..."

./setup/00-check-requirements.sh
./setup/01-create-cluster.sh
./ui/setup-ui.sh
./kong/install-full-kong.sh
./vault/install-vault.sh
# ./kafka/install-kafka.sh

echo ""
echo "🎉 Full setup completed successfully!"
