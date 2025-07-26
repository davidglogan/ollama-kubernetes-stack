#!/bin/bash

# Setup script for Ollama + OpenWebUI with Tailscale on MicroK8s
set -e

echo "🚀 Setting up Ollama Stack with Tailscale..."

# Check if microk8s is running
if ! microk8s status --wait-ready; then
    echo "❌ MicroK8s is not ready. Please start it first."
    exit 1
fi

# Enable required MicroK8s addons
echo "📦 Enabling MicroK8s addons..."
microk8s enable dns storage metallb

# Install Tailscale Operator
echo "🔧 Installing Tailscale Operator..."
microk8s kubectl apply -f https://github.com/tailscale/tailscale/releases/latest/download/tailscale-operator.yaml

# Wait for operator to be ready
echo "⏳ Waiting for Tailscale operator to be ready..."
microk8s kubectl wait --for=condition=available --timeout=300s deployment/operator -n tailscale-system

# Create namespace
echo "📁 Creating namespace..."
microk8s kubectl create namespace ollama-stack --dry-run=client -o yaml | microk8s kubectl apply -f -

# Check if Tailscale auth key is set
if [ -z "$TAILSCALE_AUTH_KEY" ]; then
    echo "⚠️  Please set your Tailscale auth key:"
    echo "   export TAILSCALE_AUTH_KEY='your-auth-key-here'"
    echo "   Then run this script again."
    exit 1
fi

# Create Tailscale secret
echo "🔐 Creating Tailscale secret..."
microk8s kubectl create secret generic tailscale-auth \
    --from-literal=TS_AUTHKEY="$TAILSCALE_AUTH_KEY" \
    --namespace=ollama-stack \
    --dry-run=client -o yaml | microk8s kubectl apply -f -

# Apply manifests
echo "🎯 Applying Kubernetes manifests..."
microk8s kubectl apply -f ollama-manifests.yaml

# Wait for deployments
echo "⏳ Waiting for deployments to be ready..."
microk8s kubectl wait --for=condition=available --timeout=600s deployment/ollama -n ollama-stack
microk8s kubectl wait --for=condition=available --timeout=300s deployment/open-webui -n ollama-stack

# Get service information
echo "✅ Setup complete!"
echo ""
echo "📊 Service Information:"
echo "Local access: http://192.168.1.100:8080"
echo ""
echo "🔗 Tailscale access:"
microk8s kubectl get svc -n ollama-stack open-webui-tailscale -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || echo "Tailscale hostname will appear once the service is ready"
echo ""
echo "📋 To check status:"
echo "   microk8s kubectl get pods -n ollama-stack"
echo "   microk8s kubectl get svc -n ollama-stack"
echo ""
echo "🔍 To troubleshoot:"
echo "   microk8s kubectl logs -n ollama-stack deployment/open-webui"
echo "   microk8s kubectl logs -n tailscale-system deployment/operator"
