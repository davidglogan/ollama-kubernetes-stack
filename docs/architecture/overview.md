# Architecture Overview

## 🏗️ Multi-Namespace Architecture

The Ollama Kubernetes Stack uses a **clean multi-namespace design** separating application and monitoring concerns:

### Core Namespaces

1. **`ollama-stack`** - Application tier
   - OpenWebUI web interface
   - Ollama AI processing engine
   - Application-specific storage

2. **`observability`** - Monitoring tier  
   - Grafana dashboards
   - Prometheus metrics collection
   - Monitoring storage

### External Access Points

- **OpenWebUI**: http://192.168.1.101:8080 (LoadBalancer)
- **Grafana**: http://192.168.1.102:3000 (LoadBalancer)  
- **Tailscale**: http://100.102.114.95:8080 (Mesh network)

### System Components

#### Core Services
- **Ollama**: AI model server and inference engine
- **OpenWebUI**: Web-based user interface
- **Grafana**: Monitoring and visualization

#### Infrastructure
- **Kubernetes**: Container orchestration (MicroK8s)
- **Helm**: Package management
- **Tailscale**: Secure networking

## 🔄 Data Flow

```
User Request → MetalLB → OpenWebUI → Ollama API → AI Models
     ↓
Metrics Collection → Prometheus → Grafana Dashboards
```

## 💾 Storage Architecture

- **Physical**: 1TB NVMe SSD at `/mnt/evo4t`
- **Kubernetes**: Custom StorageClass with local-path provisioner
- **Applications**: Persistent volumes for models and chat data
- **Monitoring**: Dedicated storage for metrics and dashboards

## 🛡️ Security & Access

- **Internal Communication**: ClusterIP services
- **External Access**: MetalLB LoadBalancer
- **Secure Remote**: Tailscale mesh networking
- **Namespace Isolation**: RBAC and network policies

## 🎯 Hardware Specifications

- **CPU**: AMD Ryzen AI 9 HX 370
- **Memory**: 96GB
- **Storage**: 1TB NVMe SSD
- **Mount Point**: /mnt/evo4t

---

**Generated on**: 2025-07-26
