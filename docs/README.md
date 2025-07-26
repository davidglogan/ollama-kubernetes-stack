# Ollama Kubernetes Stack Documentation

Welcome to the comprehensive documentation for the Ollama Kubernetes Stack.

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
- **OpenWebUI**: http://192.168.1.101:8080
- **Grafana**: http://192.168.1.102:3000
- **Tailscale**: http://100.102.114.95:8080

### System Information
- **Hardware**: AMD Ryzen AI 9 HX 370, 96GB
- **Storage**: 1TB NVMe SSD at /mnt/evo4t
- **Namespaces**: ollama-stack, observability
- **AI Models**: CodeLlama, Llama3.2:3b, Gemma2:4b

### Key Commands
```bash
# System status
./scripts/system-status.sh

# Install/upgrade
./scripts/install.sh

# Check pods
kubectl get pods -n ollama-stack

# View logs
kubectl logs -n ollama-stack deployment/ollama
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

**Generated on**: 2025-07-26  
**Version**: 1.0.0
