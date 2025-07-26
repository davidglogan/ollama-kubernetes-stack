#!/bin/bash

# Complete Ollama K8s Stack Setup Script
set -e

echo "🚀 Ollama Kubernetes Stack Setup"
echo "================================="

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    print_error "Please do not run this script as root"
    exit 1
fi

# Check for required environment variables
if [ -z "$TAILSCALE_AUTH_KEY" ]; then
    print_error "TAILSCALE_AUTH_KEY environment variable is not set"
    print_warning "Please set it with: export TAILSCALE_AUTH_KEY='your-auth-key'"
    exit 1
fi

print_status "Starting setup process..."

# Step 1: Install MicroK8s if not present
if ! command -v microk8s &> /dev/null; then
    print_status "Installing MicroK8s..."
    sudo snap install microk8s --classic
    sudo usermod -a -G microk8s $USER
    newgrp microk8s
else
    print_status "MicroK8s already installed"
fi

# Step 2: Wait for MicroK8s to be ready
print_status "Waiting for MicroK8s to be ready..."
microk8s status --wait-ready

# Step 3: Enable addons
print_status "Enabling MicroK8s addons..."
microk8s enable dns storage metallb

# Step 4: Install Helm if not present
if ! command -v helm &> /dev/null; then
    print_status "Installing Helm..."
    curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
    chmod 700 get_helm.sh
    ./get_helm.sh
    rm get_helm.sh
else
    print_status "Helm already installed"
fi

# In scripts/setup.sh, replace the operator step with this:

# Step 5: Install Tailscale Operator
print_status "Downloading Tailscale Operator manifest..."
# Download from the main tailscale/tailscale repository's raw content URL
curl -fL -o tailscale-operator.yaml "https://raw.githubusercontent.com/tailscale/tailscale/main/cmd/k8s-operator/deploy/manifests/operator.yaml"

print_status "Installing Tailscale Operator from local file..."
microk8s kubectl apply -f tailscale-operator.yaml
microk8s kubectl wait --for=condition=available --timeout=300s deployment/operator -n tailscale

# Step 6: Create namespace and secret
print_status "Creating namespace and Tailscale secret..."
microk8s kubectl create namespace ollama-stack --dry-run=client -o yaml | microk8s kubectl apply -f -
microk8s kubectl create secret generic tailscale-auth \
    --from-literal=TS_AUTHKEY="$TAILSCALE_AUTH_KEY" \
    --namespace=ollama-stack \
    --dry-run=client -o yaml | microk8s kubectl apply -f -

# Step 7: Deploy with Helm
print_status "Deploying Ollama stack with Helm..."
helm upgrade --install ollama-stack helm/ollama-stack \
    --namespace ollama-stack \
    --create-namespace

# Step 8: Wait for deployments
print_status "Waiting for deployments to be ready..."
microk8s kubectl wait --for=condition=available --timeout=600s deployment/ollama -n ollama-stack
microk8s kubectl wait --for=condition=available --timeout=600s deployment/open-webui -n ollama-stack

# Step 9: Download models
print_status "Downloading AI models (this may take a while)..."
./scripts/update-models.sh setup

print_status "Setup complete! 🎉"
echo ""
echo "Access Information:"
echo "=================="
echo "Local: http://192.168.1.100:8080"
echo "Tailscale: Check your Tailscale admin panel for 'ollama-webui'"
echo ""
echo "Available Models:"
echo "- llama3.2:3b (General purpose)"
echo "- gemma2:4b (Google's model)"  
echo "- dolphin-llama3:latest (Uncensored)"
echo ""
echo "Useful Commands:"
echo "==============="
echo "Check status: microk8s kubectl get pods -n ollama-stack"
echo "View logs: microk8s kubectl logs -n ollama-stack deployment/open-webui"
echo "Manage models: ./scripts/update-models.sh list"
