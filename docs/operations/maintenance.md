# Operations Guide

## Daily Operations

### System Health Monitoring

```bash
# Check overall system health
kubectl get nodes
kubectl get pods --all-namespaces
kubectl get services --all-namespaces | grep LoadBalancer

# Check specific services
kubectl get pods -n ollama-stack
kubectl get pods -n observability
```

### Service Status Verification

```bash
# Test external endpoints
curl -s -o /dev/null -w "OpenWebUI: %{http_code}\n" http://192.168.1.101:8080
curl -s -o /dev/null -w "Grafana: %{http_code}\n" http://192.168.1.102:3000

# Check Tailscale connectivity
ping 100.102.114.95
```

## Maintenance Tasks

### AI Model Management

```bash
# List available models
kubectl exec -n ollama-stack deployment/ollama -- ollama list

# Pull new models
kubectl exec -n ollama-stack deployment/ollama -- ollama pull <model-name>

# Remove old models
kubectl exec -n ollama-stack deployment/ollama -- ollama rm <model-name>
```

### Storage Management

```bash
# Check storage usage
kubectl exec -n ollama-stack deployment/ollama -- df -h /mnt/evo4t

# Check PVC status
kubectl get pvc -n ollama-stack

# Storage cleanup (if needed)
kubectl exec -n ollama-stack deployment/ollama -- find /mnt/evo4t -name "*.tmp" -delete
```

### Log Management

```bash
# View recent logs
kubectl logs -n ollama-stack deployment/ollama --tail=100
kubectl logs -n ollama-stack deployment/openwebui --tail=100

# Follow logs in real-time
kubectl logs -n ollama-stack deployment/ollama -f
```

## Backup and Recovery

### Data Backup

```bash
# Backup Ollama models
kubectl exec -n ollama-stack deployment/ollama -- \
  tar -czf /tmp/ollama-models-backup.tar.gz /mnt/evo4t/ollama

# Backup OpenWebUI data
kubectl exec -n ollama-stack deployment/openwebui -- \
  tar -czf /tmp/openwebui-data-backup.tar.gz /app/backend/data
```

### Configuration Backup

```bash
# Export Helm values
helm get values ollama-stack -n ollama-stack > backup-values.yaml

# Export Kubernetes manifests
kubectl get all -n ollama-stack -o yaml > backup-manifests.yaml
```

## Scaling Operations

### Horizontal Scaling

```bash
# Scale OpenWebUI (if needed)
kubectl scale deployment/openwebui --replicas=2 -n ollama-stack

# Note: Ollama typically runs as single instance due to model loading
```

### Resource Monitoring

```bash
# Check resource usage
kubectl top pods -n ollama-stack
kubectl top nodes

# View resource requests/limits
kubectl describe pods -n ollama-stack
```

## Security Operations

### Access Control

```bash
# Review RBAC
kubectl get rolebindings -n ollama-stack
kubectl get clusterrolebindings | grep ollama

# Check network policies
kubectl get networkpolicies -n ollama-stack
```

### Certificate Management

```bash
# Check TLS certificates (if using HTTPS)
kubectl get secrets -n ollama-stack | grep tls
```

## Performance Tuning

### Resource Optimization

```bash
# Monitor CPU/Memory usage
kubectl top pods -n ollama-stack

# Adjust resource limits if needed
kubectl patch deployment ollama -n ollama-stack -p \
  '{"spec":{"template":{"spec":{"containers":[{"name":"ollama","resources":{"limits":{"memory":"8Gi","cpu":"4"}}}]}}}}' 
```

### Storage Performance

```bash
# Test storage performance
kubectl exec -n ollama-stack deployment/ollama -- \
  dd if=/dev/zero of=/mnt/evo4t/test bs=1M count=1000 conv=fsync

# Clean up test file
kubectl exec -n ollama-stack deployment/ollama -- \
  rm /mnt/evo4t/test
```

## Monitoring and Alerting

### Grafana Dashboard Access

- **URL**: http://192.168.1.102:3000
- **Default credentials**: Check Grafana documentation

### Key Metrics to Monitor

1. **Pod Health**: Pod restart counts and status
2. **Resource Usage**: CPU, memory, and storage utilization
3. **API Response Times**: OpenWebUI and Ollama response latencies
4. **Model Performance**: Inference times and throughput
5. **Storage Usage**: Disk space and I/O metrics

---

**Generated on**: 2025-07-26
