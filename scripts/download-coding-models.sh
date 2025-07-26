#!/bin/bash

echo "🤖 Downloading Best Coding Models for AI Development"
echo "===================================================="

MODELS=(
    "codellama:34b"
    "deepseek-coder:33b" 
    "codeqwen:32b"
    "codellama:13b"
)

for model in "${MODELS[@]}"; do
    echo ""
    echo "📥 Downloading $model..."
    echo "💾 Storage before download:"
    df -h /mnt/evo4t | tail -1
    
    microk8s kubectl exec -n ollama-stack deployment/ollama -- ollama pull "$model"
    
    echo "✅ $model downloaded successfully!"
done

echo ""
echo "🎉 All coding models downloaded!"
echo "📋 Available models:"
microk8s kubectl exec -n ollama-stack deployment/ollama -- ollama list

echo ""
echo "💾 Final storage usage:"
df -h /mnt/evo4t
