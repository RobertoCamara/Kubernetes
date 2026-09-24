#!/bin/bash
set -e

chmod +x ./*.sh

echo "🚀 Starting full setup..."

./setup/00-check-requirements.sh
./setup/01-create-cluster.sh
./ui/setup-ui.sh
./kong/install-full-kong.sh
# ./kafka/install-kafka.sh

echo ""
echo "🎉 Full setup completed successfully!"
