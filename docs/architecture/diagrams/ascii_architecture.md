
# System Architecture (ASCII)

```
                     🌐 Internet/LAN
                           │
                           ▼
                    ┌─────────────────┐
                    │   MetalLB LB    │
                    │  192.168.1.101  │
                    │  192.168.1.102  │
                    └─────────┬───────┘
                              │
                 ┌────────────┴────────────┐
                 ▼                         ▼
        ┌─────────────────┐       ┌─────────────────┐
        │   OpenWebUI     │       │    Grafana      │
        │ :8080 (Web UI)  │       │ :3000 (Monitor) │
        └─────────┬───────┘       └─────────────────┘
                  │
                  ▼
        ┌─────────────────┐
        │  Ollama Service │
        │   (ClusterIP)   │
        └─────────┬───────┘
                  │
                  ▼
        ┌─────────────────┐       🔒 Tailscale
        │   Ollama Pod    │◄──────  100.102.114.95
        │ AI Models:      │
        │ • CodeLlama     │
        │ • Llama3.2:3b   │       ┌─────────────────┐
        │ • Gemma2:4b     │       │ Physical Storage│
        └─────────┬───────┘       │   1TB NVMe SSD  │
                  │               │  /mnt/evo4t     │
                  └───────────────┤ AMD Ryzen AI    │
                                  │ 96GB RAM        │
                                  └─────────────────┘

Namespaces:
├── ollama-stack     (Application Tier)
│   ├── OpenWebUI Pod
│   ├── Ollama Pod
│   └── Storage PVCs
└── observability    (Monitoring Tier)
    ├── Grafana Pod
    └── Prometheus Stack
```
