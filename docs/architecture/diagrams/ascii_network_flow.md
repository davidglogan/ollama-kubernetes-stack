
# Network Flow (ASCII)

```
👤 User Request Flow:

1. User → Internet/LAN → MetalLB (192.168.1.101:8080)
   │
   ▼
2. MetalLB → open-webui-service-local → OpenWebUI Pod
   │
   ▼  
3. OpenWebUI → ollama-service (ClusterIP) → Ollama Pod
   │
   ▼
4. Ollama Pod → AI Model Processing → Response
   │
   ▼
5. Response → OpenWebUI → MetalLB → User

📊 Monitoring Flow (Parallel):

Ollama Pod ────┐
               ├──► Prometheus → Grafana (192.168.1.102:3000)
OpenWebUI ─────┘

🔒 Tailscale Direct Access:

User → Tailscale (100.102.114.95) → OpenWebUI Pod
```
