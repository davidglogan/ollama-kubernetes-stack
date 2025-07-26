#!/bin/bash
# install.sh - One-click Ollama Stack installer

set -euo pipefail

NAMESPACE="ollama-stack"
CHART_PATH="charts/ollama-stack"
RELEASE_NAME="ollama-stack"

echo "🚀 Installing Ollama Kubernetes Stack..."

# ASCII Art Banner
cat << 'BANNER'
   ___  _ _                   _  __    _        
  / _ \| | | __ _ _ __ ___   __ _  \ \  / |  _   
 | | | | | |/ _` | '_ ` _ \ / _` |  \ \/ /| | |  
 | |_| | | | (_| | | | | | | (_| |   \  / | | |  
  \___/|_|_|\__,_|_| |_| |_|\__,_|    \/  |_|_|  
                                                 
 Enterprise Kubernetes Stack
BANNER

# Check prerequisites
echo "🔍 Checking prerequisites..."
command -v kubectl >/dev/null 2>&1 || { echo "❌ kubectl is required but not installed"; exit 1; }
command -v helm >/dev/null 2>&1 || { echo "❌ helm is required but not installed"; exit 1; }

# Check cluster connectivity
if ! kubectl cluster-info >/dev/null 2>&1; then
    echo "❌ Cannot connect to Kubernetes cluster"
    echo "💡 Try: microk8s kubectl config view --raw > ~/.kube/config"
    exit 1
fi

echo "✅ Prerequisites validated"

# Check if chart exists
if [ ! -d "$CHART_PATH" ]; then
    echo "❌ Helm chart not found at $CHART_PATH"
    exit 1
fi

# Install/upgrade the Helm chart
echo "📦 Installing Helm chart..."
helm upgrade --install "$RELEASE_NAME" "$CHART_PATH" \
    --create-namespace \
    --namespace "$NAMESPACE" \
    --wait \
    --timeout 10m

# Wait for pods to be ready
echo "⏳ Waiting for pods to be ready..."
kubectl wait --for=condition=ready pod -l app=ollama -n "$NAMESPACE" --timeout=300s
kubectl wait --for=condition=ready pod -l app=openwebui -n "$NAMESPACE" --timeout=300s

echo ""
echo "🎉 Ollama Stack installation complete!"
echo ""
echo "📋 Access Information:"
echo "  🌐 OpenWebUI:  http://192.168.1.101:8080"
echo "  📊 Grafana:    http://192.168.1.102:3000" 
echo "  🔒 Tailscale:  http://100.102.114.95:8080"
echo ""
echo "📊 Status Commands:"
echo "  kubectl get pods -n $NAMESPACE"
echo "  kubectl get services -n $NAMESPACE"
echo "  kubectl logs -n $NAMESPACE -l app=ollama"
echo ""
echo "🔧 Management:"
echo "  ./scripts/system-status.sh     # System overview"
echo "  ./scripts/add-ollama-model-script.sh  # Add AI models"
echo ""
echo "🚀 Happy AI chatting!"
