
# Current System Status

```
Service Status Check Results:
┌──────────────────┬─────────────────┬────────────┬─────────┐
│ Component        │ External Access │ Namespace  │ Status  │
├──────────────────┼─────────────────┼────────────┼─────────┤
│ OpenWebUI        │ 192.168.1.101   │ ollama-st. │   ✅    │
│ Ollama API       │ Internal Only   │ ollama-st. │   ✅    │
│ Grafana          │ 192.168.1.102   │ observab.  │   ✅    │
│ Prometheus       │ Internal Only   │ observab.  │   ✅    │
│ Tailscale        │ 100.102.114.95  │ Mesh       │   ✅    │
└──────────────────┴─────────────────┴────────────┴─────────┘

LoadBalancer Services:
• open-webui-service-local   → 192.168.1.101:8080
• grafana-external           → 192.168.1.102:3000

AI Models Available:
• CodeLlama     - Code generation and completion
• Llama3.2:3b   - General purpose conversations  
• Gemma2:4b     - Efficient inference and reasoning

Storage Configuration:
• Physical: 1TB NVMe SSD at /mnt/evo4t
• Kubernetes: Custom StorageClass with local-path
• Models: ~500GB persistent volume
• WebUI Data: ~100GB persistent volume
• Monitoring: ~50GB persistent volume
```
