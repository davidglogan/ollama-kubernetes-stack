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
kubectl get pods -n ollama-stack
kubectl get services -n ollama-stack
```

## Manual Installation

If you prefer step-by-step installation:

### 1. Install Helm Chart
```bash
helm install ollama-stack charts/ollama-stack \
  --create-namespace \
  --namespace ollama-stack \
  --wait
```

### 2. Configure Load Balancer
```bash
# MetalLB configuration is included in the chart
kubectl get services -n ollama-stack
```

### 3. Access Services
- OpenWebUI: http://192.168.1.101:8080
- Grafana: http://192.168.1.102:3000

## Verification

### System Health Check
```bash
# Check all pods are running
kubectl get pods --all-namespaces

# Test endpoints
curl -s -o /dev/null -w "OpenWebUI: %{http_code}\n" http://192.168.1.101:8080
curl -s -o /dev/null -w "Grafana: %{http_code}\n" http://192.168.1.102:3000
```

### LoadBalancer Status
```bash
kubectl get services --all-namespaces | grep LoadBalancer
```

## Troubleshooting

### Common Issues

**Pods not starting:**
```bash
kubectl describe pods -n ollama-stack
kubectl logs -n ollama-stack -l app=ollama
```

**Storage issues:**
```bash
kubectl get pv,pvc -n ollama-stack
ls -la /mnt/evo4t/
```

**Network connectivity:**
```bash
kubectl get services -n ollama-stack
kubectl get endpoints -n ollama-stack
```

### Recovery Commands
```bash
# Restart deployment
kubectl rollout restart deployment/ollama -n ollama-stack
kubectl rollout restart deployment/openwebui -n ollama-stack

# Check system status
./scripts/system-status.sh
```

---

**Generated on**: 2025-07-26
