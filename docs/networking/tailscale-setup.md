# Tailscale Configuration for Ollama Stack

This document describes how to configure Tailscale access for the Ollama Stack components.

## Overview

The Ollama Stack supports Tailscale for secure remote access to:
- **OpenWebUI**: AI chat interface with remote access
- **Grafana**: Monitoring dashboard with remote access

Each service gets its own dedicated Tailscale proxy with a unique hostname and IP address.

## Prerequisites

1. **Tailscale Operator**: Must be installed and configured in your Kubernetes cluster
2. **OAuth Credentials**: Tailscale OAuth app with proper scopes
3. **Tag Permissions**: Proper ACL configuration for tagged devices

## Configuration

### 1. Helm Values Configuration

Add the following to your `values-local.yaml`:

```yaml
openwebui:
  tailscale:
    enabled: true
    hostname: "your-openwebui-hostname"

monitoring:
  grafana:
    tailscale:
      enabled: true
      hostname: "your-grafana-hostname"
```

### 2. Service Creation

When enabled, the Helm chart creates dedicated Tailscale services:

- `openwebui-tailscale`: Exposes OpenWebUI via Tailscale
- `grafana-tailscale`: Exposes Grafana via Tailscale (in observability namespace)

### 3. Environment Variables

The OpenWebUI deployment automatically configures environment variables for remote access:

```yaml
env:
- name: WEBUI_URL
  value: "http://[tailscale-ip]:8080"
- name: ORIGIN
  value: "http://[tailscale-ip]:8080"
```

## Access Methods

### Direct IP Access
Each service receives a unique Tailscale IP:
- OpenWebUI: `http://100.x.x.x:8080`
- Grafana: `http://100.x.x.x:3000`

### Hostname Access
MagicDNS provides hostname resolution:
- OpenWebUI: `http://your-openwebui-hostname:8080`
- Grafana: `http://your-grafana-hostname:3000`

## Troubleshooting

### Check Tailscale Status
```bash
tailscale status
```

### Verify Service Creation
```bash
kubectl get services -n ollama-stack | grep tailscale
kubectl get services -n observability | grep tailscale
```

### Check Proxy Pods
```bash
kubectl get pods -n tailscale
```

### Verify Service Annotations
```bash
kubectl get service openwebui-tailscale -n ollama-stack -o yaml
```

Look for:
- `tailscale.com/expose: "true"`
- `tailscale.com/hostname: "your-hostname"`
- Status condition: `TailscaleProxyReady: True`

## Security Considerations

1. **Authentication**: Ensure OpenWebUI authentication is enabled for remote access
2. **ACLs**: Configure Tailscale ACLs to restrict access as needed
3. **Tags**: Use appropriate tags for service discovery and access control
4. **Network Policies**: Consider Kubernetes NetworkPolicies for additional security

## Integration with System Status

The `system-status.sh` script automatically detects and displays Tailscale access URLs:

```bash
./scripts/system-status.sh
```

This shows both local MetalLB IPs and remote Tailscale access points.