# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is the **Ollama Kubernetes Stack** - an enterprise-ready Kubernetes deployment for the Ollama AI stack. The project provides Infrastructure as Code for deploying Ollama (LLM inference), OpenWebUI (web interface), and Grafana (monitoring) on Kubernetes with Helm charts.

**Key Technologies:** Kubernetes, Helm, Ollama, OpenWebUI, Grafana, Tailscale, MetalLB
**Hardware:** AMD Ryzen AI 9 HX 370, 96GB RAM, 1TB NVMe at `/mnt/evo4t`
**Network:** 192.168.1.x with MetalLB LoadBalancer range 100-110

## Essential Commands

### Installation and Deployment
```bash
# One-click installation of the entire stack
./scripts/install.sh

# Check system status and health
./scripts/system-status.sh

# Add new AI models to Ollama
./scripts/add-ollama-model-script.sh

# Download pre-configured coding models
./scripts/download-coding-models.sh
```

### Helm Operations
```bash
# Lint Helm charts before deployment
helm lint charts/ollama-stack

# Test template rendering (dry run)
helm template test charts/ollama-stack --dry-run

# Deploy the stack manually
helm upgrade --install ollama-stack charts/ollama-stack \
    --create-namespace --namespace ollama-stack --wait --timeout 10m

# Check Helm release status
helm status ollama-stack -n ollama-stack
```

### Kubernetes Management
```bash
# Check pod status in ollama-stack namespace
kubectl get pods -n ollama-stack

# View service endpoints and LoadBalancer IPs
kubectl get services -n ollama-stack

# Check logs for Ollama service
kubectl logs -n ollama-stack -l app=ollama --tail=100

# Check logs for OpenWebUI service
kubectl logs -n ollama-stack -l app=openwebui --tail=100

# Monitor resource usage
kubectl top pods -n ollama-stack
```

### Development Workflow
```bash
# Create feature branch using standard naming
git checkout -b feature/description-$(date +%Y%m%d)

# Testing sequence after changes
helm lint charts/ollama-stack
helm template test charts/ollama-stack --dry-run
./scripts/install.sh
curl -s http://192.168.1.101:8080  # Verify OpenWebUI
curl -s http://192.168.1.102:3000  # Verify Grafana
```

## Architecture Overview

### Repository Structure
```
├── charts/ollama-stack/          # Main Helm chart
│   ├── Chart.yaml               # Chart metadata and version
│   ├── values.yaml              # Default configuration values
│   ├── values-local.yaml        # Local development overrides
│   └── templates/               # Kubernetes resource templates
├── scripts/                     # Automation and management scripts
├── docs/                        # Comprehensive documentation
│   ├── architecture/            # System design and diagrams
│   ├── deployment/              # Installation guides
│   └── operations/              # Maintenance procedures
└── legacy/                      # Deprecated configurations
```

### Helm Chart Architecture
The main chart (`charts/ollama-stack/`) deploys:
- **Ollama Pod**: AI model inference server with persistent storage
- **OpenWebUI Pod**: Web interface for AI interactions
- **Grafana External Service**: Monitoring dashboard access via LoadBalancer
- **Storage Classes**: Custom storage configuration for `/mnt/evo4t`
- **MetalLB Configuration**: LoadBalancer services for external access

### Key Configuration Files
- `charts/ollama-stack/values.yaml`: Production configuration with resource limits, storage settings, and networking
- `charts/ollama-stack/values-local.yaml`: Local development overrides
- `charts/ollama-stack/Chart.yaml`: Chart version 2.0.0, appVersion latest

### Network Architecture
- **OpenWebUI**: http://192.168.1.101:8080 (MetalLB LoadBalancer)
- **Grafana**: http://192.168.1.102:3000 (MetalLB LoadBalancer)
- **Tailscale**: http://100.102.114.95:8080 (Secure remote access)
- **IP Pool**: 192.168.1.100-192.168.1.110 (MetalLB range)

## Development Guidelines

### Resource Configuration
- **Ollama**: 16Gi-64Gi memory, 4-20 CPU cores, 1Ti storage
- **OpenWebUI**: 512Mi-4Gi memory, 250m-2 CPU cores, 50Gi storage
- **Storage Class**: `evo4t-storage` using `/mnt/evo4t/microk8s-storage`

### Testing and Validation
Always run this sequence before committing changes:
1. `helm lint charts/ollama-stack` - Validate chart syntax
2. `helm template test charts/ollama-stack --dry-run` - Test rendering
3. `./scripts/install.sh` - Deploy and verify functionality
4. `./scripts/system-status.sh` - Check overall system health

### Git Workflow
This project uses feature branch workflow with semantic commit messages:
- `feat(scope): description` - New features
- `fix(scope): description` - Bug fixes  
- `docs(scope): description` - Documentation updates
- `chore(scope): description` - Maintenance tasks

### Script Categories
- **Installation**: `install.sh`, `setup.sh` - Initial deployment
- **Management**: `system-status.sh`, `add-ollama-model-script.sh` - Operations
- **Monitoring**: `health-check.sh`, `health_check_script.sh` - Health checks
- **Security**: `security_cleanup.sh`, `manage-secrets.sh` - Security operations
- **Development**: `dev-workflow.sh`, Git workflow scripts - Development support

## Troubleshooting

### Common Access Points
- If services are unreachable, check MetalLB IP assignments: `kubectl get services -n ollama-stack`
- If pods won't start, check storage availability: `df -h /mnt/evo4t`
- For Tailscale issues, verify connection: `tailscale status`

### Log Locations
- Ollama logs: `kubectl logs -n ollama-stack -l app=ollama`
- OpenWebUI logs: `kubectl logs -n ollama-stack -l app=openwebui`
- System status: `./scripts/system-status.sh`

### Recovery Procedures
- Full reinstall: `helm uninstall ollama-stack -n ollama-stack && ./scripts/install.sh`
- Storage issues: Check `/mnt/evo4t` mount and permissions
- Network issues: Verify MetalLB configuration and IP pool availability

## AI Models and Usage

### Included Models
- **CodeLlama**: Code generation and analysis
- **Llama3.2:3b**: General purpose conversation
- **Gemma2:4b**: Efficient inference model

### Model Management
```bash
# Add new models via Ollama API
./scripts/add-ollama-model-script.sh

# Check available models
kubectl exec -n ollama-stack deployment/ollama -- ollama list

# Download additional coding models
./scripts/download-coding-models.sh
```

This stack is designed for enterprise AI workloads with comprehensive monitoring, security, and operational tooling.