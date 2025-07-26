#!/bin/bash

echo "🖥️  System Status - $(date)"
echo "================================"

echo "📂 Project Directory: $(pwd)"
echo "👤 User: $(whoami)@$(hostname)"
echo "🖥️  OS: $(lsb_release -d | cut -f2)"
echo "🖥️  Desktop: $XDG_CURRENT_DESKTOP"

echo ""
echo "🌐 Network Configuration:"
echo "Local IP: $(ip route get 1 | awk '{print $7}' | head -1)"
echo "Tailscale IP: $(tailscale ip -4 2>/dev/null || echo 'Not connected')"

echo ""
echo "🚀 Kubernetes Status:"
microk8s status --wait-ready --timeout 5 2>/dev/null || echo "MicroK8s not ready"

echo ""
echo "🤖 Ollama Stack:"
microk8s kubectl get pods -n ollama-stack 2>/dev/null || echo "Ollama stack not deployed"

echo ""
echo "💾 Storage Usage:"
df -h /mnt/evo4t 2>/dev/null || echo "/mnt/evo4t not mounted"

echo ""
echo "📊 Access URLs:"
echo "OpenWebUI: http://192.168.1.101:8080"
echo "Grafana: http://192.168.1.102:3000"
