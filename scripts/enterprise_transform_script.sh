#!/bin/bash
# enterprise-transform.sh - Transform existing ~/ai into enterprise repository

set -euo pipefail

BASE_DIR="$HOME/ai"
BACKUP_DIR="$HOME/ai-backup-$(date +%Y%m%d-%H%M%S)"

echo "🚀 Transforming ~/ai into enterprise repository structure..."

# Create backup
echo "💾 Creating backup at $BACKUP_DIR..."
cp -r "$BASE_DIR" "$BACKUP_DIR"
echo "✅ Backup created successfully"

cd "$BASE_DIR"

# 1. Create enterprise directory structure
echo "📁 Creating enterprise directory structure..."
mkdir -p .github/{workflows,ISSUE_TEMPLATE}
mkdir -p docs/{architecture,deployment,operations,development}
mkdir -p charts tests/{integration,unit,fixtures} examples
mkdir -p scripts/monitoring

# 2. Move existing content to proper locations
echo "📦 Reorganizing existing content..."

# Move Helm chart to charts directory
if [ -d "helm/ollama-stack" ]; then
    mv helm/ollama-stack charts/
    echo "✅ Moved helm/ollama-stack → charts/ollama-stack"
fi

# Clean up empty helm directory
if [ -d "helm" ] && [ -z "$(ls -A helm)" ]; then
    rmdir helm
    echo "✅ Removed empty helm directory"
fi

# Move old files to archive
if [ -d "old" ]; then
    mv old archive
    echo "✅ Moved old/ → archive/"
fi

# Move manifests to legacy
if [ -d "manifest" ]; then
    mv manifest legacy
    echo "✅ Moved manifest/ → legacy/"
fi

# 3. Create enhanced README.md
echo "📝 Creating enterprise README..."
cat > README.md << 'EOF'
# Ollama Kubernetes Stack

🚀 **Enterprise-ready Kubernetes deployment for Ollama AI stack**

[![CI](https://github.com/your-org/ollama-kubernetes-stack/workflows/CI/badge.svg)](https://github.com/your-org/ollama-kubernetes-stack/actions)
[![Helm](https://img.shields.io/badge/Helm-v3.12+-blue.svg)](https://helm.sh)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-v1.28+-blue.svg)](https://kubernetes.io)

## ✨ Features

- 🤖 **Ollama AI Server** - Local LLM inference (CodeLlama, Llama3.2, Gemma2)
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
open http://192.168.1.101:8080  # OpenWebUI
open http://192.168.1.102:3000  # Grafana
```

## 🏗️ Architecture

Your stack runs on:
- **Hardware**: AMD Ryzen AI 9 HX 370, 96GB RAM
- **Storage**: 1TB NVMe at `/mnt/evo4t` 
- **Network**: LoadBalancer services + Tailscale mesh
- **Monitoring**: Prometheus + Grafana dashboards

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   OpenWebUI     │────│   Ollama API    │────│   AI Models     │
│  192.168.1.101  │    │  ClusterIP Svc  │    │   (1TB NVMe)    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
         ┌─────────────────┐     │     ┌─────────────────┐
         │    Grafana      │─────┼─────│   Prometheus    │
         │  192.168.1.102  │     │     │   Monitoring    │
         └─────────────────┘     │     └─────────────────┘
                                 │
         ┌─────────────────┐     │
         │   Tailscale     │─────┘
         │ 100.102.114.95  │
         └─────────────────┘
```

## 📋 Current Status

✅ **Phase 1 Complete**: Infrastructure as Code deployed  
🔄 **Phase 2 Active**: Enterprise repository structure  
📋 **Phase 3 Next**: Architecture diagrams & documentation  

## 📖 Documentation

- **[Installation Guide](docs/deployment/installation.md)** - Complete setup instructions
- **[Architecture Overview](docs/architecture/overview.md)** - System design and components
- **[Operations Manual](docs/operations/)** - Day-2 operations and maintenance
- **[Development Guide](docs/development/)** - Contributing and development setup

## 🛠️ Available Models

Your deployment includes these AI models:
- **CodeLlama** - Code generation and completion
- **Llama3.2:3b** - General purpose conversations
- **Gemma2:4b** - Efficient inference and reasoning

## 🔧 Management Commands

```bash
# Check system status
./scripts/system-status.sh

# Add new AI models
./scripts/add-ollama-model-script.sh

# Download coding models
./scripts/download-coding-models.sh

# View deployment status
kubectl get pods -n ollama
kubectl get services -n ollama
```

## 🤝 Contributing

We welcome contributions! See [CONTRIBUTING.md](CONTRIBUTING.md) for:
- Development setup
- Code standards
- Testing procedures
- Release process

## 📄 License

This project is licensed under the MIT License - see [LICENSE](LICENSE) for details.

## 🆘 Support

- 📖 **Documentation**: Check the `docs/` directory
- 🐛 **Issues**: [GitHub Issues](https://github.com/your-org/ollama-kubernetes-stack/issues)
- 💬 **Discussions**: [GitHub Discussions](https://github.com/your-org/ollama-kubernetes-stack/discussions)

---

**Powered by**: Kubernetes • Helm • Ollama • OpenWebUI • Grafana • Tailscale
EOF

# 4. Create CHANGELOG.md
echo "📅 Creating CHANGELOG..."
cat > CHANGELOG.md << 'EOF'
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Enterprise repository structure
- Comprehensive documentation framework
- CI/CD automation with GitHub Actions
- Architecture diagrams and visual documentation

## [1.0.0] - 2025-07-25

### Added
- Initial Kubernetes deployment with Helm
- Ollama AI server with persistent storage (1TB NVMe)
- OpenWebUI web interface at 192.168.1.101:8080
- Grafana monitoring at 192.168.1.102:3000
- Tailscale integration for secure remote access
- LoadBalancer services for external access
- Custom StorageClass for high-performance storage
- Prometheus ServiceMonitor for metrics collection

### Infrastructure
- AMD Ryzen AI 9 HX 370 hardware optimization
- 96GB RAM configuration
- Namespace isolation and RBAC security
- Professional Helm chart templates

### AI Models
- CodeLlama for code generation
- Llama3.2:3b for general conversations  
- Gemma2:4b for efficient inference
- Automated model management scripts

### Operations
- System status monitoring scripts
- Model download automation
- Health check and maintenance tools
- Backup and restore procedures
EOF

# 5. Create GitHub Actions workflow
echo "🔄 Creating CI/CD workflows..."
cat > .github/workflows/ci.yml << 'EOF'
name: CI/CD Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  helm-lint:
    name: Helm Chart Validation
    runs-on: ubuntu-latest
    steps:
    - name: Checkout Code
      uses: actions/checkout@v4
    
    - name: Set up Helm
      uses: azure/setup-helm@v3
      with:
        version: '3.12.0'
    
    - name: Lint Helm Charts
      run: |
        helm lint charts/ollama-stack
        echo "✅ Helm chart validation passed"
    
    - name: Template Validation
      run: |
        helm template ollama-test charts/ollama-stack --dry-run
        echo "✅ Template rendering successful"

  security-scan:
    name: Security Scanning
    runs-on: ubuntu-latest
    steps:
    - name: Checkout Code
      uses: actions/checkout@v4
    
    - name: Run Trivy Security Scanner
      uses: aquasecurity/trivy-action@master
      with:
        scan-type: 'fs'
        scan-ref: '.'
        format: 'sarif'
        output: 'trivy-results.sarif'
    
    - name: Upload Security Results
      uses: github/codeql-action/upload-sarif@v2
      if: always()
      with:
        sarif_file: 'trivy-results.sarif'

  documentation:
    name: Documentation Check
    runs-on: ubuntu-latest
    steps:
    - name: Checkout Code
      uses: actions/checkout@v4
    
    - name: Check Documentation
      run: |
        # Check that key documentation files exist
        test -f README.md || { echo "❌ README.md missing"; exit 1; }
        test -f CHANGELOG.md || { echo "❌ CHANGELOG.md missing"; exit 1; }
        test -d docs/ || { echo "❌ docs/ directory missing"; exit 1; }
        echo "✅ Documentation structure validated"
EOF

# 6. Create install script
echo "🛠️ Creating installation script..."
cat > scripts/install.sh << 'EOF'
#!/bin/bash
# install.sh - One-click Ollama Stack installer

set -euo pipefail

NAMESPACE="ollama"
CHART_PATH="charts/ollama-stack"
RELEASE_NAME="ollama-stack"

echo "🚀 Installing Ollama Kubernetes Stack..."

# ASCII Art Banner
cat << 'BANNER'
   ___  _ _                   _  __    _        
  / _ \| | | __ _ _ __ ___   __ _  \ \  / |  _   
 | | | | | |/ _` | '_ ` _ \ / _` |  \ \/ /| | |  
 | |_| | | | (_| | | | | | | (_| |   \  / | | |  
  \___/|_|_|\__,_|_| |_| |_|\__,_|    \/  |_|_|  
                                                 
 Enterprise Kubernetes Stack
BANNER

# Check prerequisites
echo "🔍 Checking prerequisites..."
command -v kubectl >/dev/null 2>&1 || { echo "❌ kubectl is required but not installed"; exit 1; }
command -v helm >/dev/null 2>&1 || { echo "❌ helm is required but not installed"; exit 1; }

# Check cluster connectivity
if ! kubectl cluster-info >/dev/null 2>&1; then
    echo "❌ Cannot connect to Kubernetes cluster"
    echo "💡 Try: microk8s kubectl config view --raw > ~/.kube/config"
    exit 1
fi

echo "✅ Prerequisites validated"

# Check if chart exists
if [ ! -d "$CHART_PATH" ]; then
    echo "❌ Helm chart not found at $CHART_PATH"
    exit 1
fi

# Install/upgrade the Helm chart
echo "📦 Installing Helm chart..."
helm upgrade --install "$RELEASE_NAME" "$CHART_PATH" \
    --create-namespace \
    --namespace "$NAMESPACE" \
    --wait \
    --timeout 10m

# Wait for pods to be ready
echo "⏳ Waiting for pods to be ready..."
kubectl wait --for=condition=ready pod -l app=ollama -n "$NAMESPACE" --timeout=300s
kubectl wait --for=condition=ready pod -l app=openwebui -n "$NAMESPACE" --timeout=300s

echo ""
echo "🎉 Ollama Stack installation complete!"
echo ""
echo "📋 Access Information:"
echo "  🌐 OpenWebUI:  http://192.168.1.101:8080"
echo "  📊 Grafana:    http://192.168.1.102:3000" 
echo "  🔒 Tailscale:  http://100.102.114.95:8080"
echo ""
echo "📊 Status Commands:"
echo "  kubectl get pods -n $NAMESPACE"
echo "  kubectl get services -n $NAMESPACE"
echo "  kubectl logs -n $NAMESPACE -l app=ollama"
echo ""
echo "🔧 Management:"
echo "  ./scripts/system-status.sh     # System overview"
echo "  ./scripts/add-ollama-model-script.sh  # Add AI models"
echo ""
echo "🚀 Happy AI chatting!"
EOF

chmod +x scripts/install.sh

# 7. Create .gitignore
cat > .gitignore << 'EOF'
# IDE and Editor
.vscode/
.idea/
*.swp
*.swo
*~

# OS Generated
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db

# Kubernetes
*.log
*.tmp
.kube/
kubeconfig

# Helm
*.tgz
charts/*/charts/
requirements.lock

# Secrets and Keys
secrets/
*.key
*.pem
*.p12
*.crt
authkey
tailscale-*.yaml

# Terraform
*.tfstate
*.tfstate.backup
.terraform/
.terraform.lock.hcl

# Local Development
.env
.env.local
.env.*.local
override.yaml
local-values.yaml
debug.yaml

# Build and Dependencies
node_modules/
dist/
build/
*.tar.gz

# Backup files
*-backup-*
*.backup
EOF

# 8. Create basic documentation structure
echo "📚 Creating documentation structure..."

cat > docs/architecture/overview.md << 'EOF'
# Architecture Overview

## System Architecture

The Ollama Kubernetes Stack is designed as a cloud-native AI platform with the following key components:

### Core Components

1. **Ollama Server**
   - AI model inference engine
   - Supports multiple LLM models
   - RESTful API for interactions
   - Persistent storage for models

2. **OpenWebUI** 
   - Modern web interface
   - Real-time chat interface
   - Model management
   - User session handling

3. **Grafana Monitoring**
   - System metrics visualization
   - Performance dashboards
   - Alert management
   - Prometheus integration

### Infrastructure Layer

- **Kubernetes**: Container orchestration and service mesh
- **Helm**: Package management and templating
- **MetalLB**: Load balancer for bare metal
- **Tailscale**: Secure mesh networking

### Storage Architecture

```
Storage Layout:
├── /mnt/evo4t/ollama-models/     # AI model storage (1TB NVMe)
├── /var/lib/openwebui/           # Web UI data and chat history  
└── /var/lib/prometheus/          # Metrics and time-series data
```

### Network Architecture

```
Network Flow:
Internet/LAN → MetalLB → Kubernetes Services → Pods
                    ↓
Tailscale Mesh → Direct Pod Access (100.102.114.95)
```

## Deployment Model

- **High Availability**: Single-node with persistent storage
- **Scalability**: Horizontal pod scaling capability
- **Security**: Network policies and RBAC
- **Monitoring**: Full observability stack
EOF

cat > docs/deployment/installation.md << 'EOF'
# Installation Guide

## Prerequisites

### Hardware Requirements
- **CPU**: AMD Ryzen AI 9 HX 370 (or equivalent)
- **RAM**: 96GB (minimum 16GB for smaller models)
- **Storage**: 1TB NVMe SSD mounted at `/mnt/evo4t`
- **Network**: Stable internet connection

### Software Requirements
- **OS**: Ubuntu 24.04+ (or compatible Linux)
- **Kubernetes**: MicroK8s or equivalent cluster
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
kubectl get pods -n ollama
kubectl get services -n ollama
```

## Manual Installation

If you prefer step-by-step installation:

### 1. Install Helm Chart
```bash
helm install ollama-stack charts/ollama-stack \
  --create-namespace \
  --namespace ollama \
  --wait
```

### 2. Configure Load Balancer
```bash
# MetalLB configuration is included in the chart
kubectl get services -n ollama
```

### 3. Access Services
- OpenWebUI: http://192.168.1.101:8080
- Grafana: http://192.168.1.102:3000

## Troubleshooting

### Common Issues

**Pods not starting:**
```bash
kubectl describe pods -n ollama
kubectl logs -n ollama -l app=ollama
```

**Storage issues:**
```bash
kubectl get pv,pvc -n ollama
ls -la /mnt/evo4t/
```

**Network connectivity:**
```bash
kubectl get services -n ollama
kubectl get endpoints -n ollama
```

### Recovery Commands
```bash
# Restart deployment
kubectl rollout restart deployment/ollama -n ollama
kubectl rollout restart deployment/openwebui -n ollama

# Check system status
./scripts/system-status.sh
```
EOF

echo ""
echo "✅ Enterprise transformation completed successfully!"
echo ""
echo "📁 Your ~/ai directory is now enterprise-ready with:"
echo "   ✅ Professional directory structure"
echo "   ✅ GitHub Actions CI/CD pipeline"
echo "   ✅ Comprehensive documentation framework"
echo "   ✅ One-click installer script"
echo "   ✅ Security scanning and linting"
echo "   ✅ Proper .gitignore and project files"
echo ""
echo "🚀 Next steps:"
echo "1. Test the new installer: ./scripts/install.sh"
echo "2. Initialize Git repository: git init && git add . && git commit -m 'Enterprise transformation'"
echo "3. Create GitHub repository and push"
echo "4. Ready for Phase 3: Architecture Diagrams!"
echo ""
echo "💾 Backup created at: $BACKUP_DIR"