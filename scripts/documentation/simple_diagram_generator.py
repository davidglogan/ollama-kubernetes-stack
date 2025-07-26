#!/usr/bin/env python3
"""
Simple ASCII Architecture Diagram Generator
No external dependencies required
"""

def generate_ascii_architecture():
    """Generate ASCII art architecture diagram"""
    
    ascii_diagram = '''
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
'''
    
    return ascii_diagram

def generate_network_flow_ascii():
    """Generate ASCII network flow diagram"""
    
    flow_diagram = '''
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
'''
    
    return flow_diagram

def generate_component_status():
    """Generate current system status"""
    
    status = '''
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
'''
    
    return status

def main():
    """Generate all ASCII diagrams"""
    print("🎨 Generating ASCII architecture diagrams...")
    
    # Create output files
    diagrams = {
        "docs/architecture/diagrams/ascii_architecture.md": generate_ascii_architecture(),
        "docs/architecture/diagrams/ascii_network_flow.md": generate_network_flow_ascii(),
        "docs/architecture/diagrams/system_status.md": generate_component_status()
    }
    
    for filename, content in diagrams.items():
        with open(filename, 'w') as f:
            f.write(content)
        print(f"✅ Generated: {filename}")
    
    print("\n✅ ASCII diagrams generated successfully!")
    print("\n📁 Generated files:")
    for filename in diagrams.keys():
        print(f"   📄 {filename}")
    
    print("\n🎯 These diagrams work everywhere:")
    print("   • GitHub README display")
    print("   • Terminal viewing")
    print("   • Documentation sites")
    print("   • Email and chat")

if __name__ == "__main__":
    main()
