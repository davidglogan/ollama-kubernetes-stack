#!/usr/bin/env python3
"""
Ollama Kubernetes Stack Documentation Generator
Generates all documentation files for the enterprise repository
"""

import os
import json
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Any

class DocumentationGenerator:
    """Generate comprehensive documentation for Ollama Kubernetes Stack"""
    
    def __init__(self, base_dir: str = "."):
        self.base_dir = Path(base_dir)
        self.timestamp = datetime.now().strftime("%Y-%m-%d")
        self.config = self._load_config()
    
    def _load_config(self) -> Dict[str, Any]:
        """Load configuration for documentation generation"""
        return {
            "project_name": "Ollama Kubernetes Stack",
            "description": "Enterprise-ready Kubernetes deployment for Ollama AI stack",
            "version": "1.0.0",
            "author": "Enterprise DevOps Team",
            "license": "MIT",
            "kubernetes": {
                "cluster_type": "MicroK8s",
                "namespaces": ["ollama-stack", "observability"]
            },
            "services": {
                "openwebui": {
                    "external_ip": "192.168.1.101",
                    "port": 8080,
                    "namespace": "ollama-stack"
                },
                "grafana": {
                    "external_ip": "192.168.1.102", 
                    "port": 3000,
                    "namespace": "observability"
                },
                "tailscale": {
                    "ip": "100.102.114.95",
                    "port": 8080
                }
            },
            "hardware": {
                "cpu": "AMD Ryzen AI 9 HX 370",
                "ram": "96GB",
                "storage": "1TB NVMe SSD",
                "mount_path": "/mnt/evo4t"
            },
            "ai_models": ["CodeLlama", "Llama3.2:3b", "Gemma2:4b"]
        }
    
    def create_directory_structure(self):
        """Create the complete documentation directory structure"""
        directories = [
            "docs",
            "docs/architecture",
            "docs/architecture/diagrams",
            "docs/architecture/diagrams/generated",
            "docs/architecture/diagrams/mermaid", 
            "docs/architecture/diagrams/plantuml",
            "docs/deployment",
            "docs/operations",
            "docs/development",
            "scripts/documentation"
        ]
        
        for dir_path in directories:
            (self.base_dir / dir_path).mkdir(parents=True, exist_ok=True)
        
        print("✅ Created documentation directory structure")
    
    def generate_main_readme(self) -> str:
        """Generate the main README.md file"""
        config = self.config
        
        readme_content = f"""# {config['project_name']}

🚀 **Enterprise-ready Kubernetes deployment for Ollama AI stack**

[![CI](https://github.com/your-org/ollama-kubernetes-stack/workflows/CI/badge.svg)](https://github.com/your-org/ollama-kubernetes-stack/actions)
[![Helm](https://img.shields.io/badge/Helm-v3.12+-blue.svg)](https://helm.sh)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-v1.28+-blue.svg)](https://kubernetes.io)
[![License](https://img.shields.io/badge/License-{config['license']}-green.svg)](LICENSE)

## ✨ Features

- 🤖 **Ollama AI Server** - Local LLM inference ({', '.join(config['ai_models'])})
- 🌐 **OpenWebUI** - Beautiful web interface for AI interactions
- 📊 **Grafana** - Real-time monitoring and metrics dashboard
- 🔒 **Tailscale** - Secure remote access via mesh networking
- ☸️ **Kubernetes** - Cloud-native orchestration and scaling
- 📦 **Helm** - Professional package management
- 🔄 **GitOps** - Infrastructure as Code with CI/CD

## 🚀 Quick Start

```bash
# One-click installation
./scripts/install.sh

# Access your AI stack
open http://{config['services']['openwebui']['external_ip']}:{config['services']['openwebui']['port']}  # OpenWebUI
open http://{config['services']['grafana']['external_ip']}:{config['services']['grafana']['port']}  # Grafana
```

## 🏗️ Architecture

Your stack runs on:
- **Hardware**: {config['hardware']['cpu']}, {config['hardware']['ram']}
- **Storage**: {config['hardware']['storage']} at `{config['hardware']['mount_path']}`
- **Network**: LoadBalancer services + Tailscale mesh
- **Monitoring**: Prometheus + Grafana dashboards

```mermaid
graph TB
    subgraph "External Access"
        U[👥 Users] 
        I[🌐 Internet/LAN]
        T[🔒 Tailscale<br/>{config['services']['tailscale']['ip']}]
    end
    
    subgraph "Kubernetes Cluster ({config['kubernetes']['cluster_type']})"
        subgraph "Load Balancer (MetalLB)"
            LB1[🌐 OpenWebUI LB<br/>{config['services']['openwebui']['external_ip']}:{config['services']['openwebui']['port']}]
            LB2[📊 Grafana LB<br/>{config['services']['grafana']['external_ip']}:{config['services']['grafana']['port']}]
        end
        
        subgraph "{config['services']['openwebui']['namespace']} namespace"
            WP[🖥️ OpenWebUI Pod]
            OP[🧠 Ollama Pod<br/>Models: {', '.join(config['ai_models'])}]
        end
        
        subgraph "{config['services']['grafana']['namespace']} namespace"
            GP[📊 Grafana Pod]
            PP[📈 Prometheus]
        end
    end
    
    U --> I --> LB1 --> WP
    U --> T --> WP
    I --> LB2 --> GP
    WP --> OP
    OP -.->|metrics| PP --> GP
```

## 📋 Current Status

✅ **Phase 1 Complete**: Infrastructure as Code deployed  
✅ **Phase 2 Complete**: Enterprise repository structure  
✅ **Phase 3 Complete**: Architecture diagrams & documentation  

## 📖 Documentation

- **[Installation Guide](docs/deployment/installation.md)** - Complete setup instructions
- **[Architecture Overview](docs/architecture/overview.md)** - System design and components
- **[Operations Manual](docs/operations/)** - Day-2 operations and maintenance
- **[Development Guide](docs/development/)** - Contributing and development setup

## 🛠️ Available Models

Your deployment includes these AI models:
{chr(10).join(f'- **{model}** - AI model capabilities' for model in config['ai_models'])}

## 🔧 Management Commands

```bash
# Check system status
./scripts/system-status.sh

# Add new AI models
./scripts/add-ollama-model-script.sh

# Download coding models
./scripts/download-coding-models.sh

# View deployment status
kubectl get pods -n {config['services']['openwebui']['namespace']}
kubectl get services -n {config['services']['openwebui']['namespace']}
```

## 🤝 Contributing

We welcome contributions! See [CONTRIBUTING.md](CONTRIBUTING.md) for:
- Development setup
- Code standards
- Testing procedures
- Release process

## 📄 License

This project is licensed under the {config['license']} License - see [LICENSE](LICENSE) for details.

## 🆘 Support

- 📖 **Documentation**: Check the `docs/` directory
- 🐛 **Issues**: [GitHub Issues](https://github.com/your-org/ollama-kubernetes-stack/issues)
- 💬 **Discussions**: [GitHub Discussions](https://github.com/your-org/ollama-kubernetes-stack/discussions)

---

**Generated on**: {self.timestamp}  
**Powered by**: Kubernetes • Helm • Ollama • OpenWebUI • Grafana • Tailscale
"""
        return readme_content
    
    def generate_architecture_overview(self) -> str:
        """Generate architecture overview documentation"""
        config = self.config
        
        content = f"""# Architecture Overview

## 🏗️ Multi-Namespace Architecture

The {config['project_name']} uses a **clean multi-namespace design** separating application and monitoring concerns:

### Core Namespaces

1. **`{config['services']['openwebui']['namespace']}`** - Application tier
   - OpenWebUI web interface
   - Ollama AI processing engine
   - Application-specific storage

2. **`{config['services']['grafana']['namespace']}`** - Monitoring tier  
   - Grafana dashboards
   - Prometheus metrics collection
   - Monitoring storage

### External Access Points

- **OpenWebUI**: http://{config['services']['openwebui']['external_ip']}:{config['services']['openwebui']['port']} (LoadBalancer)
- **Grafana**: http://{config['services']['grafana']['external_ip']}:{config['services']['grafana']['port']} (LoadBalancer)  
- **Tailscale**: http://{config['services']['tailscale']['ip']}:{config['services']['tailscale']['port']} (Mesh network)

### System Components

#### Core Services
- **Ollama**: AI model server and inference engine
- **OpenWebUI**: Web-based user interface
- **Grafana**: Monitoring and visualization

#### Infrastructure
- **Kubernetes**: Container orchestration ({config['kubernetes']['cluster_type']})
- **Helm**: Package management
- **Tailscale**: Secure networking

## 🔄 Data Flow

```
User Request → MetalLB → OpenWebUI → Ollama API → AI Models
     ↓
Metrics Collection → Prometheus → Grafana Dashboards
```

## 💾 Storage Architecture

- **Physical**: {config['hardware']['storage']} at `{config['hardware']['mount_path']}`
- **Kubernetes**: Custom StorageClass with local-path provisioner
- **Applications**: Persistent volumes for models and chat data
- **Monitoring**: Dedicated storage for metrics and dashboards

## 🛡️ Security & Access

- **Internal Communication**: ClusterIP services
- **External Access**: MetalLB LoadBalancer
- **Secure Remote**: Tailscale mesh networking
- **Namespace Isolation**: RBAC and network policies

## 🎯 Hardware Specifications

- **CPU**: {config['hardware']['cpu']}
- **Memory**: {config['hardware']['ram']}
- **Storage**: {config['hardware']['storage']}
- **Mount Point**: {config['hardware']['mount_path']}

---

**Generated on**: {self.timestamp}
"""
        return content
    
    def generate_installation_guide(self) -> str:
        """Generate installation guide"""
        config = self.config
        
        content = f"""# Installation Guide

## Prerequisites

### Hardware Requirements
- **CPU**: {config['hardware']['cpu']} (or equivalent)
- **RAM**: {config['hardware']['ram']} (minimum 16GB for smaller models)
- **Storage**: {config['hardware']['storage']} mounted at `{config['hardware']['mount_path']}`
- **Network**: Stable internet connection

### Software Requirements
- **OS**: Ubuntu 24.04+ (or compatible Linux)
- **Kubernetes**: {config['kubernetes']['cluster_type']} or equivalent cluster
- **Helm**: v3.12+
- **kubectl**: Compatible with your cluster version

## Quick Installation

### 1. Clone Repository
```bash
git clone https://github.com/your-org/ollama-kubernetes-stack.git
cd ollama-kubernetes-stack
```

### 2. One-Click Install
```bash
./scripts/install.sh
```

### 3. Verify Installation
```bash
kubectl get pods -n {config['services']['openwebui']['namespace']}
kubectl get services -n {config['services']['openwebui']['namespace']}
```

## Manual Installation

If you prefer step-by-step installation:

### 1. Install Helm Chart
```bash
helm install ollama-stack charts/ollama-stack \\
  --create-namespace \\
  --namespace {config['services']['openwebui']['namespace']} \\
  --wait
```

### 2. Configure Load Balancer
```bash
# MetalLB configuration is included in the chart
kubectl get services -n {config['services']['openwebui']['namespace']}
```

### 3. Access Services
- OpenWebUI: http://{config['services']['openwebui']['external_ip']}:{config['services']['openwebui']['port']}
- Grafana: http://{config['services']['grafana']['external_ip']}:{config['services']['grafana']['port']}

## Verification

### System Health Check
```bash
# Check all pods are running
kubectl get pods --all-namespaces

# Test endpoints
curl -s -o /dev/null -w "OpenWebUI: %{{http_code}}\\n" http://{config['services']['openwebui']['external_ip']}:{config['services']['openwebui']['port']}
curl -s -o /dev/null -w "Grafana: %{{http_code}}\\n" http://{config['services']['grafana']['external_ip']}:{config['services']['grafana']['port']}
```

### LoadBalancer Status
```bash
kubectl get services --all-namespaces | grep LoadBalancer
```

## Troubleshooting

### Common Issues

**Pods not starting:**
```bash
kubectl describe pods -n {config['services']['openwebui']['namespace']}
kubectl logs -n {config['services']['openwebui']['namespace']} -l app=ollama
```

**Storage issues:**
```bash
kubectl get pv,pvc -n {config['services']['openwebui']['namespace']}
ls -la {config['hardware']['mount_path']}/
```

**Network connectivity:**
```bash
kubectl get services -n {config['services']['openwebui']['namespace']}
kubectl get endpoints -n {config['services']['openwebui']['namespace']}
```

### Recovery Commands
```bash
# Restart deployment
kubectl rollout restart deployment/ollama -n {config['services']['openwebui']['namespace']}
kubectl rollout restart deployment/openwebui -n {config['services']['openwebui']['namespace']}

# Check system status
./scripts/system-status.sh
```

---

**Generated on**: {self.timestamp}
"""
        return content
    
    def generate_operations_guide(self) -> str:
        """Generate operations and maintenance guide"""
        config = self.config
        
        content = f"""# Operations Guide

## Daily Operations

### System Health Monitoring

```bash
# Check overall system health
kubectl get nodes
kubectl get pods --all-namespaces
kubectl get services --all-namespaces | grep LoadBalancer

# Check specific services
kubectl get pods -n {config['services']['openwebui']['namespace']}
kubectl get pods -n {config['services']['grafana']['namespace']}
```

### Service Status Verification

```bash
# Test external endpoints
curl -s -o /dev/null -w "OpenWebUI: %{{http_code}}\\n" http://{config['services']['openwebui']['external_ip']}:{config['services']['openwebui']['port']}
curl -s -o /dev/null -w "Grafana: %{{http_code}}\\n" http://{config['services']['grafana']['external_ip']}:{config['services']['grafana']['port']}

# Check Tailscale connectivity
ping {config['services']['tailscale']['ip']}
```

## Maintenance Tasks

### AI Model Management

```bash
# List available models
kubectl exec -n {config['services']['openwebui']['namespace']} deployment/ollama -- ollama list

# Pull new models
kubectl exec -n {config['services']['openwebui']['namespace']} deployment/ollama -- ollama pull <model-name>

# Remove old models
kubectl exec -n {config['services']['openwebui']['namespace']} deployment/ollama -- ollama rm <model-name>
```

### Storage Management

```bash
# Check storage usage
kubectl exec -n {config['services']['openwebui']['namespace']} deployment/ollama -- df -h {config['hardware']['mount_path']}

# Check PVC status
kubectl get pvc -n {config['services']['openwebui']['namespace']}

# Storage cleanup (if needed)
kubectl exec -n {config['services']['openwebui']['namespace']} deployment/ollama -- find {config['hardware']['mount_path']} -name "*.tmp" -delete
```

### Log Management

```bash
# View recent logs
kubectl logs -n {config['services']['openwebui']['namespace']} deployment/ollama --tail=100
kubectl logs -n {config['services']['openwebui']['namespace']} deployment/openwebui --tail=100

# Follow logs in real-time
kubectl logs -n {config['services']['openwebui']['namespace']} deployment/ollama -f
```

## Backup and Recovery

### Data Backup

```bash
# Backup Ollama models
kubectl exec -n {config['services']['openwebui']['namespace']} deployment/ollama -- \\
  tar -czf /tmp/ollama-models-backup.tar.gz {config['hardware']['mount_path']}/ollama

# Backup OpenWebUI data
kubectl exec -n {config['services']['openwebui']['namespace']} deployment/openwebui -- \\
  tar -czf /tmp/openwebui-data-backup.tar.gz /app/backend/data
```

### Configuration Backup

```bash
# Export Helm values
helm get values ollama-stack -n {config['services']['openwebui']['namespace']} > backup-values.yaml

# Export Kubernetes manifests
kubectl get all -n {config['services']['openwebui']['namespace']} -o yaml > backup-manifests.yaml
```

## Scaling Operations

### Horizontal Scaling

```bash
# Scale OpenWebUI (if needed)
kubectl scale deployment/openwebui --replicas=2 -n {config['services']['openwebui']['namespace']}

# Note: Ollama typically runs as single instance due to model loading
```

### Resource Monitoring

```bash
# Check resource usage
kubectl top pods -n {config['services']['openwebui']['namespace']}
kubectl top nodes

# View resource requests/limits
kubectl describe pods -n {config['services']['openwebui']['namespace']}
```

## Security Operations

### Access Control

```bash
# Review RBAC
kubectl get rolebindings -n {config['services']['openwebui']['namespace']}
kubectl get clusterrolebindings | grep ollama

# Check network policies
kubectl get networkpolicies -n {config['services']['openwebui']['namespace']}
```

### Certificate Management

```bash
# Check TLS certificates (if using HTTPS)
kubectl get secrets -n {config['services']['openwebui']['namespace']} | grep tls
```

## Performance Tuning

### Resource Optimization

```bash
# Monitor CPU/Memory usage
kubectl top pods -n {config['services']['openwebui']['namespace']}

# Adjust resource limits if needed
kubectl patch deployment ollama -n {config['services']['openwebui']['namespace']} -p \\
  '{{"spec":{{"template":{{"spec":{{"containers":[{{"name":"ollama","resources":{{"limits":{{"memory":"8Gi","cpu":"4"}}}}}}]}}}}}}}}' 
```

### Storage Performance

```bash
# Test storage performance
kubectl exec -n {config['services']['openwebui']['namespace']} deployment/ollama -- \\
  dd if=/dev/zero of={config['hardware']['mount_path']}/test bs=1M count=1000 conv=fsync

# Clean up test file
kubectl exec -n {config['services']['openwebui']['namespace']} deployment/ollama -- \\
  rm {config['hardware']['mount_path']}/test
```

## Monitoring and Alerting

### Grafana Dashboard Access

- **URL**: http://{config['services']['grafana']['external_ip']}:{config['services']['grafana']['port']}
- **Default credentials**: Check Grafana documentation

### Key Metrics to Monitor

1. **Pod Health**: Pod restart counts and status
2. **Resource Usage**: CPU, memory, and storage utilization
3. **API Response Times**: OpenWebUI and Ollama response latencies
4. **Model Performance**: Inference times and throughput
5. **Storage Usage**: Disk space and I/O metrics

---

**Generated on**: {self.timestamp}
"""
        return content
    
    def generate_mermaid_diagrams(self) -> str:
        """Generate comprehensive Mermaid diagrams"""
        config = self.config
        
        content = f"""# System Architecture - Mermaid Diagrams

## 🏗️ Complete System Architecture

```mermaid
graph TB
    subgraph "External Access"
        U[👥 Users] 
        I[🌐 Internet/LAN]
        T[🔒 Tailscale<br/>{config['services']['tailscale']['ip']}]
    end
    
    subgraph "Kubernetes Cluster ({config['kubernetes']['cluster_type']})"
        subgraph "Load Balancer (MetalLB)"
            LB1[🌐 OpenWebUI LB<br/>{config['services']['openwebui']['external_ip']}:{config['services']['openwebui']['port']}]
            LB2[📊 Grafana LB<br/>{config['services']['grafana']['external_ip']}:{config['services']['grafana']['port']}]
        end
        
        subgraph "{config['services']['openwebui']['namespace']} namespace"
            subgraph "Web Tier"
                WS[⚡ open-webui-service-local]
                WP[🖥️ OpenWebUI Pod<br/>Status: Running]
            end
            
            subgraph "AI Processing Tier"
                OS[🤖 ollama-service<br/>ClusterIP]
                OP[🧠 Ollama Pod<br/>Models: {', '.join(config['ai_models'])}]
            end
            
            subgraph "Storage Layer"
                SC[💾 Custom StorageClass<br/>{config['hardware']['mount_path']}]
                PVC1[📦 Models PVC<br/>{config['hardware']['storage']}]
                PVC2[💬 WebUI Data PVC]
            end
        end
        
        subgraph "{config['services']['grafana']['namespace']} namespace"
            subgraph "Monitoring Stack"
                GS1[📊 grafana-external<br/>LoadBalancer]
                GP[📊 Grafana Pod<br/>Dashboards]
                PS[📈 Prometheus Stack<br/>Metrics Collection]
            end
        end
    end
    
    subgraph "Physical Infrastructure"
        HW[🖥️ {config['hardware']['cpu']}<br/>{config['hardware']['ram']} • {config['hardware']['storage']}]
    end
    
    %% External Access Flow
    U --> I
    U --> T
    I --> LB1
    I --> LB2
    T -.->|Direct Access| WP
    
    %% Application Flow
    LB1 --> WS --> WP
    WP --> OS --> OP
    
    %% Monitoring Flow  
    LB2 --> GS1 --> GP
    OP -.->|📊 AI Metrics| PS
    WP -.->|📊 Usage Metrics| PS
    PS --> GP
    
    %% Storage Connections
    SC --> PVC1 --> OP
    SC --> PVC2 --> WP
    SC --> HW
    
    %% Styling
    classDef userClass fill:#e1f5fe,stroke:#0277bd,stroke-width:2px
    classDef ollamaClass fill:#f3e5f5,stroke:#7b1fa2,stroke-width:2px
    classDef observabilityClass fill:#e8f5e8,stroke:#388e3c,stroke-width:2px
    classDef storageClass fill:#fff3e0,stroke:#f57c00,stroke-width:2px
    classDef aiClass fill:#ffebee,stroke:#c62828,stroke-width:3px
    
    class U,I,T userClass
    class WS,WP,OS,OP ollamaClass
    class GS1,GP,PS observabilityClass
    class SC,PVC1,PVC2,HW storageClass
    class OP aiClass
```

## 🔄 Request Processing Flow

```mermaid
sequenceDiagram
    participant U as 👤 User
    participant I as 🌐 Internet/LAN  
    participant LB as ⚖️ MetalLB ({config['services']['openwebui']['external_ip']})
    participant WS as ⚡ WebUI Service
    participant WP as 🖥️ OpenWebUI Pod
    participant OS as 🤖 Ollama Service
    participant OP as 🧠 Ollama Pod
    participant PS as 📈 Prometheus
    participant GP as 📊 Grafana ({config['services']['grafana']['external_ip']})
    
    Note over U,GP: AI Chat Request with Monitoring
    
    U->>+I: 💬 Chat Request
    I->>+LB: Route to {config['services']['openwebui']['external_ip']}:{config['services']['openwebui']['port']}
    LB->>+WS: Forward to open-webui-service-local
    WS->>+WP: Route to OpenWebUI Pod
    
    Note over WP: Process chat interface
    WP->>+OS: 🚀 API call to ollama-service
    OS->>+OP: Forward to Ollama Pod
    
    Note over OP: AI Model Processing<br/>({', '.join(config['ai_models'])})
    OP->>OP: 🤖 Run AI inference
    OP-->>-OS: Generated response
    OS-->>-WP: Return AI response
    WP-->>-WS: HTTP response
    WS-->>-LB: Forward response
    LB-->>-I: Send to user
    I-->>-U: 💬 AI Response
    
    %% Monitoring Flow (Parallel)
    par Metrics Collection
        OP--)PS: 📊 AI performance metrics
        WP--)PS: 📊 Usage & response metrics
        PS--)GP: 📈 Store metrics
    end
    
    Note over GP: Real-time dashboards available at {config['services']['grafana']['external_ip']}:{config['services']['grafana']['port']}
```

## 🗄️ Storage & Data Architecture

```mermaid
graph TB
    subgraph "Physical Storage"
        NVMe[💾 {config['hardware']['storage']}<br/>{config['hardware']['mount_path']}<br/>High-Performance Storage]
    end
    
    subgraph "Kubernetes Storage Layer"
        SC[⚙️ Custom StorageClass<br/>local-path provisioner]
    end
    
    subgraph "Persistent Volumes"
        PV1[📦 Ollama Models PV<br/>~500GB for AI models]
        PV2[💬 OpenWebUI Data PV<br/>~100GB for chat data]
        PV3[📊 Prometheus Data PV<br/>~50GB for metrics]
    end
    
    subgraph "Application Data"
        subgraph "{config['services']['openwebui']['namespace']} namespace"
            D1[🤖 AI Models<br/>{', '.join(config['ai_models'])}]
            D2[💬 Chat History<br/>User conversations & settings]
        end
        
        subgraph "{config['services']['grafana']['namespace']} namespace"
            D3[📈 Metrics Database<br/>Performance & usage data]
            D4[📊 Grafana Config<br/>Dashboards & alerts]
        end
    end
    
    %% Storage Flow
    NVMe --> SC
    SC --> PV1 --> D1
    SC --> PV2 --> D2
    SC --> PV3 --> D3
    D3 --> D4
    
    %% Data Processing Flow
    D2 -.->|API calls| D1
    D1 -.->|metrics| D3
    D2 -.->|usage stats| D3
```

## 📊 Namespace Overview

```mermaid
graph LR
    subgraph "Kubernetes Cluster"
        subgraph "{config['services']['openwebui']['namespace']} namespace"
            subgraph "Application Layer"
                A1[🖥️ OpenWebUI Pod]
                A2[🤖 Ollama Pod]
            end
            
            subgraph "Service Layer"
                S1[⚡ open-webui-service-local<br/>LoadBalancer: {config['services']['openwebui']['external_ip']}:{config['services']['openwebui']['port']}]
                S2[🔗 ollama-service<br/>ClusterIP]
            end
            
            subgraph "Storage Layer"
                ST1[💾 Ollama Models PVC]
                ST2[💬 OpenWebUI Data PVC]
            end
        end
        
        subgraph "{config['services']['grafana']['namespace']} namespace"
            subgraph "Monitoring Services"
                M1[📊 grafana-external<br/>LoadBalancer: {config['services']['grafana']['external_ip']}:{config['services']['grafana']['port']}]
                M2[📈 kube-prom-stack-grafana<br/>ClusterIP]
            end
            
            subgraph "Monitoring Pods"
                MP1[📊 Grafana Pod]
                MP2[📈 Prometheus Stack]
            end
        end
    end
    
    %% Internal Connections
    S1 --> A1
    S2 --> A2
    A1 --> S2
    ST1 --> A2
    ST2 --> A1
    
    M1 --> MP1
    M2 --> MP1
    A2 -.->|metrics| MP2
    A1 -.->|metrics| MP2
    MP2 --> MP1
    
    %% External Access
    EXT1[🌐 External Access<br/>{config['services']['openwebui']['external_ip']}:{config['services']['openwebui']['port']}] --> S1
    EXT2[📊 External Monitoring<br/>{config['services']['grafana']['external_ip']}:{config['services']['grafana']['port']}] --> M1
```

---

**Generated on**: {self.timestamp}
"""
        return content
    
    def generate_changelog(self) -> str:
        """Generate changelog"""
        content = f"""# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Planned
- Automated backup and restore procedures
- Advanced security policies and RBAC
- Multi-cluster deployment support
- Enhanced monitoring and alerting

## [1.0.0] - {self.timestamp}

### Added
- Initial enterprise Kubernetes deployment
- Multi-namespace architecture ({', '.join(self.config['kubernetes']['namespaces'])})
- Ollama AI server with persistent storage
- OpenWebUI web interface at {self.config['services']['openwebui']['external_ip']}:{self.config['services']['openwebui']['port']}
- Grafana monitoring at {self.config['services']['grafana']['external_ip']}:{self.config['services']['grafana']['port']}
- Tailscale integration for secure remote access at {self.config['services']['tailscale']['ip']}
- LoadBalancer services for external access (MetalLB)
- Custom StorageClass for high-performance storage at {self.config['hardware']['mount_path']}
- Comprehensive Helm chart with professional templates
- Enterprise repository structure with CI/CD automation

### Infrastructure
- {self.config['hardware']['cpu']} hardware optimization
- {self.config['hardware']['ram']} memory configuration
- {self.config['hardware']['storage']} high-performance storage
- Namespace isolation and RBAC security
- Professional Helm chart templates

### AI Models
{chr(10).join(f'- {model} for specialized AI tasks' for model in self.config['ai_models'])}
- Automated model management scripts
- Persistent model storage with fast NVMe access

### Operations
- System status monitoring scripts
- Model download automation
- Health check and maintenance tools
- Comprehensive documentation suite
- Architecture diagrams and visual documentation

### Documentation
- Complete installation guides
- Architecture overview and diagrams
- Operations and maintenance procedures
- Development and contribution guidelines
- Automated documentation generation
"""
        return content
    
    def generate_contributing_guide(self) -> str:
        """Generate contributing guidelines"""
        content = f"""# Contributing to {self.config['project_name']}

We welcome contributions to the {self.config['project_name']}! This document provides guidelines for contributing to the project.

## 🚀 Quick Start for Contributors

### Prerequisites
- Kubernetes cluster ({self.config['kubernetes']['cluster_type']} or equivalent)
- Helm v3.12+
- kubectl configured for your cluster
- Git and GitHub account

### Development Setup

1. **Fork and Clone**
```bash
git clone https://github.com/your-username/ollama-kubernetes-stack.git
cd ollama-kubernetes-stack
```

2. **Create Development Branch**
```bash
git checkout -b feature/your-feature-name
```

3. **Test Your Changes**
```bash
# Lint Helm charts
helm lint charts/ollama-stack

# Dry run deployment
helm template test charts/ollama-stack --dry-run

# Test installation
./scripts/install.sh
```

## 📝 Contribution Types

### 🐛 Bug Reports
- Use GitHub Issues with the bug report template
- Include system information and error logs
- Provide steps to reproduce the issue

### ✨ Feature Requests  
- Use GitHub Issues with the feature request template
- Describe the use case and expected behavior
- Consider backward compatibility

### 📚 Documentation
- Improve existing documentation
- Add examples and tutorials
- Update architecture diagrams

### 🔧 Code Contributions
- Helm chart improvements
- Script enhancements
- CI/CD pipeline updates

## 🛠️ Development Guidelines

### Code Standards

**Helm Charts:**
- Follow Helm best practices
- Use consistent naming conventions
- Include proper labels and annotations
- Add resource limits and requests

**Scripts:**
- Use bash with set -euo pipefail
- Include error handling
- Add helpful output messages
- Follow shell script best practices

**Documentation:**
- Use clear, concise language
- Include code examples
- Update diagrams when architecture changes
- Regenerate docs using: `python scripts/documentation/generate_docs.py`

### Testing Requirements

**Before Submitting:**
```bash
# 1. Lint Helm charts
helm lint charts/ollama-stack

# 2. Test template rendering
helm template ollama-test charts/ollama-stack

# 3. Test actual deployment
./scripts/install.sh

# 4. Verify functionality
curl -s http://{self.config['services']['openwebui']['external_ip']}:{self.config['services']['openwebui']['port']}
curl -s http://{self.config['services']['grafana']['external_ip']}:{self.config['services']['grafana']['port']}

# 5. Run system checks
./scripts/system-status.sh
```

## 📋 Pull Request Process

### 1. Preparation
- Ensure your fork is up to date
- Create a feature branch from main
- Make your changes with clear, atomic commits

### 2. Testing
- Test changes in a real Kubernetes environment
- Verify all services remain functional
- Update documentation if needed

### 3. Submission
- Create pull request with clear description
- Reference any related issues
- Include testing steps and verification

### 4. Review Process
- Address reviewer feedback
- Keep discussions focused and constructive
- Update PR based on review comments

## 🔄 Release Process

### Version Management
- Follow Semantic Versioning (SemVer)
- Update CHANGELOG.md for all changes
- Tag releases with proper version numbers

### Release Checklist
- [ ] All tests pass
- [ ] Documentation updated
- [ ] CHANGELOG.md updated
- [ ] Version bumped in Chart.yaml
- [ ] Release notes prepared

## 🏗️ Architecture Guidelines

### Namespace Organization
- Keep application and monitoring separated
- Use consistent naming conventions
- Follow Kubernetes best practices

### Storage Patterns
- Use PersistentVolumeClaims for data
- Configure appropriate storage classes
- Plan for backup and recovery

### Service Design
- Use appropriate service types
- Configure health checks
- Plan for scaling requirements

## 📊 Monitoring and Observability

### Metrics Guidelines
- Expose meaningful metrics
- Use standard metric names
- Include proper labels and tags

### Logging Standards
- Use structured logging
- Include correlation IDs
- Avoid logging sensitive data

## 🔒 Security Considerations

### Security Best Practices
- Follow least privilege principle
- Use RBAC appropriately
- Secure service communication
- Regular security updates

### Secrets Management
- Never commit secrets to git
- Use Kubernetes secrets appropriately
- Consider external secret management

## 🆘 Getting Help

### Communication Channels
- **GitHub Issues**: Bug reports and feature requests
- **GitHub Discussions**: General questions and ideas
- **Documentation**: Check docs/ directory first

### Mentorship
- New contributors are welcome
- Ask questions in discussions
- Pair programming sessions available

## 📄 License

By contributing, you agree that your contributions will be licensed under the {self.config['license']} License.

---

**Thank you for contributing to {self.config['project_name']}!**

Generated on: {self.timestamp}
"""
        return content
    
    def generate_python_diagram_script(self) -> str:
        """Generate Python script for creating diagrams"""
        config = self.config
        
        content = f'''#!/usr/bin/env python3
"""
System Architecture Diagram Generator
Requires: pip install diagrams
"""

from diagrams import Diagram, Cluster, Edge
from diagrams.k8s.compute import Pod, Deployment
from diagrams.k8s.network import Service, Ingress
from diagrams.k8s.storage import PV, PVC, StorageClass
from diagrams.onprem.client import Users
from diagrams.onprem.network import Internet
from diagrams.programming.language import Python
from diagrams.onprem.monitoring import Grafana, Prometheus
from diagrams.generic.network import VPN
from diagrams.aws.storage import EBS

def create_system_architecture():
    """Generate complete system architecture diagram"""
    
    with Diagram("{config['project_name']} - System Architecture", 
                 filename="docs/architecture/diagrams/generated/system_architecture",
                 show=False, direction="TB"):
        
        # External Access
        users = Users("Users")
        internet = Internet("Internet/LAN")
        tailscale = VPN("Tailscale Mesh\\n{config['services']['tailscale']['ip']}")
        
        with Cluster("Kubernetes Cluster ({config['kubernetes']['cluster_type']})"):
            
            with Cluster("LoadBalancer (MetalLB)"):
                webui_lb = Service("OpenWebUI LB\\n{config['services']['openwebui']['external_ip']}:{config['services']['openwebui']['port']}")
                grafana_lb = Service("Grafana LB\\n{config['services']['grafana']['external_ip']}:{config['services']['grafana']['port']}")
            
            with Cluster("{config['services']['openwebui']['namespace']} Namespace"):
                
                with Cluster("AI Processing"):
                    ollama_svc = Service("Ollama Service\\nClusterIP")
                    ollama_pod = Pod("Ollama Pod\\nAI Inference")
                    
                with Cluster("Web Interface"):
                    webui_svc = Service("WebUI Service")
                    webui_pod = Pod("OpenWebUI Pod\\nWeb Interface")
                
                with Cluster("Storage"):
                    storage_class = StorageClass("Custom StorageClass\\n{config['hardware']['mount_path']}")
                    ollama_pvc = PVC("Models PVC\\n{config['hardware']['storage']}")
                    webui_pvc = PVC("WebUI PVC\\nChat Data")
            
            with Cluster("{config['services']['grafana']['namespace']} Namespace"):
                prometheus = Prometheus("Prometheus\\nMetrics Collection")
                grafana_pod = Pod("Grafana Pod\\nDashboards")
        
        # Hardware Layer
        with Cluster("Hardware Infrastructure"):
            nvme_storage = EBS("{config['hardware']['storage']}\\n{config['hardware']['mount_path']}")
            cpu = Python("{config['hardware']['cpu']}\\n{config['hardware']['ram']}")
        
        # Connections
        users >> internet >> webui_lb
        users >> tailscale >> webui_pod
        users >> internet >> grafana_lb
        
        webui_lb >> webui_svc >> webui_pod
        webui_pod >> ollama_svc >> ollama_pod
        
        grafana_lb >> grafana_pod
        prometheus >> grafana_pod
        ollama_pod >> Edge(label="metrics") >> prometheus
        
        storage_class >> ollama_pvc >> ollama_pod
        storage_class >> webui_pvc >> webui_pod
        storage_class >> nvme_storage
        
        ollama_pod >> cpu

def create_network_flow():
    """Generate network flow diagram"""
    
    with Diagram("Network Flow Architecture", 
                 filename="docs/architecture/diagrams/generated/network_flow",
                 show=False, direction="LR"):
        
        users = Users("External Users")
        
        with Cluster("Entry Points"):
            internet = Internet("Internet/LAN")
            tailscale = VPN("Tailscale\\n{config['services']['tailscale']['ip']}")
        
        with Cluster("Load Balancing"):
            metallb = Service("MetalLB\\nBare Metal LB")
        
        with Cluster("Kubernetes Services"):
            webui_svc = Service("OpenWebUI\\n{config['services']['openwebui']['external_ip']}:{config['services']['openwebui']['port']}")
            grafana_svc = Service("Grafana\\n{config['services']['grafana']['external_ip']}:{config['services']['grafana']['port']}")
            ollama_internal = Service("Ollama Internal\\nClusterIP")
        
        with Cluster("Application Pods"):
            webui_pod = Pod("OpenWebUI")
            ollama_pod = Pod("Ollama AI")
            grafana_pod = Pod("Grafana")
        
        # Flow connections
        users >> internet >> metallb
        users >> tailscale >> webui_pod
        
        metallb >> webui_svc >> webui_pod
        metallb >> grafana_svc >> grafana_pod
        
        webui_pod >> ollama_internal >> ollama_pod

def create_data_flow():
    """Generate data flow and processing diagram"""
    
    with Diagram("AI Data Processing Flow", 
                 filename="docs/architecture/diagrams/generated/data_flow",
                 show=False, direction="TB"):
        
        user_input = Users("User Input\\nChat/API Requests")
        
        with Cluster("Web Layer"):
            webui = Pod("OpenWebUI\\nRequest Processing")
        
        with Cluster("AI Processing Layer"):
            ollama_api = Service("Ollama API\\nModel Management")
            ai_models = Pod("AI Models\\n{', '.join(config['ai_models'])}")
        
        with Cluster("Storage Layer"):
            model_storage = PVC("Model Storage\\n{config['hardware']['storage']}")
            chat_storage = PVC("Chat History\\nWebUI Data")
        
        with Cluster("Monitoring Layer"):
            metrics = Prometheus("Metrics\\nCollection")
            dashboards = Grafana("Dashboards\\nVisualization")
        
        # Data flow
        user_input >> webui >> ollama_api >> ai_models
        ai_models >> model_storage
        webui >> chat_storage
        
        ai_models >> Edge(label="performance metrics") >> metrics
        webui >> Edge(label="usage metrics") >> metrics
        metrics >> dashboards

if __name__ == "__main__":
    print("🎨 Generating Python architecture diagrams...")
    create_system_architecture()
    create_network_flow() 
    create_data_flow()
    print("✅ Python diagrams generated successfully!")
    print("📁 Generated files:")
    print("   - docs/architecture/diagrams/generated/system_architecture.png")
    print("   - docs/architecture/diagrams/generated/network_flow.png") 
    print("   - docs/architecture/diagrams/generated/data_flow.png")
'''
        return content
    
    def write_file(self, path: str, content: str):
        """Write content to file with proper error handling"""
        file_path = self.base_dir / path
        file_path.parent.mkdir(parents=True, exist_ok=True)
        
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
        
        print(f"✅ Generated: {path}")
    
    def generate_all_documentation(self):
        """Generate all documentation files"""
        print(f"🚀 Generating comprehensive documentation for {self.config['project_name']}...")
        
        # Create directory structure
        self.create_directory_structure()
        
        # Generate main documentation files
        self.write_file("README.md", self.generate_main_readme())
        self.write_file("CHANGELOG.md", self.generate_changelog())
        self.write_file("CONTRIBUTING.md", self.generate_contributing_guide())
        
        # Generate architecture documentation
        self.write_file("docs/architecture/overview.md", self.generate_architecture_overview())
        self.write_file("docs/architecture/diagrams/mermaid/system_diagrams.md", self.generate_mermaid_diagrams())
        
        # Generate operational documentation
        self.write_file("docs/deployment/installation.md", self.generate_installation_guide())
        self.write_file("docs/operations/maintenance.md", self.generate_operations_guide())
        
        # Generate diagram generation script
        self.write_file("docs/architecture/diagrams/generate_python_diagrams.py", self.generate_python_diagram_script())
        
        # Make diagram script executable
        script_path = self.base_dir / "docs/architecture/diagrams/generate_python_diagrams.py"
        os.chmod(script_path, 0o755)
        
        # Generate documentation index
        self.write_file("docs/README.md", self.generate_docs_index())
        
        print(f"\n✅ Documentation generation complete!")
        print(f"\n📊 Generated {len([f for f in Path('.').rglob('*.md') if 'docs' in str(f)])} documentation files")
        print(f"\n📁 Documentation structure:")
        self.print_docs_tree()
        
    def generate_docs_index(self) -> str:
        """Generate documentation index"""
        content = f"""# {self.config['project_name']} Documentation

Welcome to the comprehensive documentation for the {self.config['project_name']}.

## 📖 Documentation Structure

### 🚀 Getting Started
- **[Installation Guide](deployment/installation.md)** - Complete setup instructions
- **[Quick Start](../README.md#quick-start)** - One-click deployment

### 🏗️ Architecture  
- **[Architecture Overview](architecture/overview.md)** - System design and components
- **[System Diagrams](architecture/diagrams/mermaid/system_diagrams.md)** - Visual architecture documentation
- **[Diagram Generation](architecture/diagrams/)** - Automated diagram creation

### 🛠️ Operations
- **[Maintenance Guide](operations/maintenance.md)** - Day-2 operations and monitoring
- **[Troubleshooting](operations/troubleshooting.md)** - Common issues and solutions

### 👩‍💻 Development
- **[Contributing Guide](../CONTRIBUTING.md)** - How to contribute to the project
- **[Development Setup](development/setup.md)** - Local development environment

## 🎯 Quick Reference

### Current System Status
- **OpenWebUI**: http://{self.config['services']['openwebui']['external_ip']}:{self.config['services']['openwebui']['port']}
- **Grafana**: http://{self.config['services']['grafana']['external_ip']}:{self.config['services']['grafana']['port']}
- **Tailscale**: http://{self.config['services']['tailscale']['ip']}:{self.config['services']['tailscale']['port']}

### System Information
- **Hardware**: {self.config['hardware']['cpu']}, {self.config['hardware']['ram']}
- **Storage**: {self.config['hardware']['storage']} at {self.config['hardware']['mount_path']}
- **Namespaces**: {', '.join(self.config['kubernetes']['namespaces'])}
- **AI Models**: {', '.join(self.config['ai_models'])}

### Key Commands
```bash
# System status
./scripts/system-status.sh

# Install/upgrade
./scripts/install.sh

# Check pods
kubectl get pods -n {self.config['services']['openwebui']['namespace']}

# View logs
kubectl logs -n {self.config['services']['openwebui']['namespace']} deployment/ollama
```

## 🔄 Documentation Updates

This documentation is automatically generated. To update:

```bash
# Regenerate all documentation
python scripts/documentation/generate_docs.py

# Generate architecture diagrams
python docs/architecture/diagrams/generate_python_diagrams.py
```

---

**Generated on**: {self.timestamp}  
**Version**: {self.config['version']}
"""
        return content
    
    def print_docs_tree(self):
        """Print documentation tree structure"""
        docs_path = self.base_dir / "docs"
        if docs_path.exists():
            for root, dirs, files in os.walk(docs_path):
                level = root.replace(str(docs_path), '').count(os.sep)
                indent = ' ' * 2 * level
                print(f'{indent}📁 {os.path.basename(root)}/')
                subindent = ' ' * 2 * (level + 1)
                for file in files:
                    if file.endswith('.md'):
                        print(f'{subindent}📄 {file}')

def main():
    """Main function to generate all documentation"""
    import argparse
    
    parser = argparse.ArgumentParser(description='Generate comprehensive documentation')
    parser.add_argument('--base-dir', '-d', default='.', 
                       help='Base directory for documentation generation')
    parser.add_argument('--config', '-c', help='Configuration file path (JSON)')
    
    args = parser.parse_args()
    
    generator = DocumentationGenerator(args.base_dir)
    
    if args.config:
        with open(args.config, 'r') as f:
            custom_config = json.load(f)
        generator.config.update(custom_config)
    
    generator.generate_all_documentation()
    
    print(f"\n🎉 All documentation generated successfully!")
    print(f"\n🚀 Next steps:")
    print(f"1. Review generated documentation in docs/")
    print(f"2. Generate diagrams: python docs/architecture/diagrams/generate_python_diagrams.py")
    print(f"3. Commit changes: git add . && git commit -m 'Add comprehensive documentation'")

if __name__ == "__main__":
    main()