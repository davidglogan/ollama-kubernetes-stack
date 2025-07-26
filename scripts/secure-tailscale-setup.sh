#!/bin/bash
# Secure Tailscale key setup - NEVER commits keys to Git

set -euo pipefail

echo "🔑 Secure Tailscale Setup"
echo "========================"
echo "This creates a Kubernetes secret WITHOUT saving to files"
echo ""

# Get key securely (doesn't echo to terminal)
read -s -p "Enter NEW Tailscale auth key (format: tskey-auth-xxx): " NEW_KEY
echo ""

# Validate format
if [[ ! "$NEW_KEY" =~ ^tskey-auth- ]]; then
    echo "❌ Invalid format. Should start with 'tskey-auth-'"
    exit 1
fi

echo "🔄 Creating Kubernetes secret..."

# Create Kubernetes secret
kubectl create secret generic tailscale-auth \
    --from-literal=authkey="$NEW_KEY" \
    --namespace=ollama-stack \
    --dry-run=client -o yaml | kubectl apply -f -

# Clear from memory
unset NEW_KEY

echo "✅ New Tailscale secret created securely"
echo "🔒 No keys saved to disk or Git"
echo ""
echo "🔄 Next steps:"
echo "1. Test Tailscale connectivity: tailscale status"
echo "2. Revoke the old exposed key at: https://login.tailscale.com/admin/settings/keys"
echo "3. Monitor your network at: https://login.tailscale.com/admin/machines"
