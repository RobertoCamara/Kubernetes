#!/bin/bash

set -e

NAMESPACE="kubernetes-dashboard"
DASHBOARD_URL="https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml"
TEMP_FILE="/tmp/k8s-dashboard.yaml"
NODE_PORT=30084

echo "🎛️ INSTALAÇÃO DO KUBERNETES DASHBOARD"
echo

# Pergunta interativa
read -p "Deseja apagar referências antigas no namespace '$NAMESPACE'? [s/N]: " RESPOSTA

if [[ "$RESPOSTA" =~ ^[Ss]$ ]]; then
  echo "🔻 Limpando recursos antigos no namespace '$NAMESPACE'..."

  if kubectl get ns "$NAMESPACE" &>/dev/null; then
    echo "🧼 Deletando todos os recursos do namespace $NAMESPACE..."
    kubectl delete all --all -n "$NAMESPACE" --ignore-not-found

    echo "🧽 Deletando admin-user (ServiceAccount e Secret)..."
    kubectl delete sa admin-user -n "$NAMESPACE" --ignore-not-found

    SECRET_NAME=$(kubectl get secret -n "$NAMESPACE" | grep admin-user | awk '{print $1}')
    if [ -n "$SECRET_NAME" ]; then
      kubectl delete secret "$SECRET_NAME" -n "$NAMESPACE" --ignore-not-found
    fi
  fi

  echo "🚮 Deletando ClusterRoleBinding admin-user (se existir)..."
  kubectl delete clusterrolebinding admin-user --ignore-not-found

  echo "✅ Limpeza concluída."
else
  echo "⚠️  Pulando limpeza de recursos antigos."
fi

echo
echo "🔧 Criando namespace $NAMESPACE (se necessário)..."
kubectl get ns "$NAMESPACE" &>/dev/null || kubectl create ns "$NAMESPACE"

echo "📥 Baixando YAML oficial do Kubernetes Dashboard..."
curl -sSL "$DASHBOARD_URL" -o "$TEMP_FILE"

echo "📦 Aplicando YAML no namespace padrão..."
kubectl apply -f "$TEMP_FILE"

echo "🔁 Alterando tipo do serviço para NodePort (porta $NODE_PORT)..."
kubectl patch svc kubernetes-dashboard -n "$NAMESPACE" \
  -p "{\"spec\": {\"type\": \"NodePort\", \"ports\": [{\"port\": 443, \"targetPort\": 8443, \"nodePort\": $NODE_PORT}]}}"

echo "👤 Criando ServiceAccount admin-user (se necessário)..."
kubectl get sa admin-user -n "$NAMESPACE" &>/dev/null || cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: $NAMESPACE
EOF

echo "🔗 Criando ClusterRoleBinding admin-user (se necessário)..."
kubectl get clusterrolebinding admin-user &>/dev/null || cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: $NAMESPACE
EOF

echo -e "\n🔑 Token de acesso (válido por tempo limitado):"
TOKEN=$(kubectl -n "$NAMESPACE" create token admin-user 2>/dev/null || true)

if [[ -z "$TOKEN" ]]; then
  echo "⚠️ 'kubectl create token' não disponível. Criando token manualmente..."

  cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: admin-user-token
  namespace: $NAMESPACE
  annotations:
    kubernetes.io/service-account.name: admin-user
type: kubernetes.io/service-account-token
EOF
  sleep 2
  TOKEN=$(kubectl -n "$NAMESPACE" get secret admin-user-token -o jsonpath="{.data.token}" | base64 -d)
fi

echo -e "\n🔑 Token de acesso:\n$TOKEN"

echo "✅ Kubernetes Dashboard instalado com sucesso!"
echo ""
echo "🔗 Endpoints disponíveis:"
echo "Kubernetes Dashboard       => http://localhost:8084"