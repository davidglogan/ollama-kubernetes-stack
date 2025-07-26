# System Configuration Reference

## Hardware Specifications
- **System**: Minisforum AI X1 Pro-370 Mini PC
- **CPU**: AMD Ryzen AI 9 HX 370 (12C/24T)
- **RAM**: 96GB DDR5
- **Storage**: 2TB SSD + 1TB mounted at `/mnt/evo4t`
- **Graphics**: AMD Radeon 890M Graphics

## Software Environment
- **OS**: Ubuntu 25.04
- **Desktop**: KDE
- **Terminal**: Konsole (default KDE terminal)

## Project Configuration
- **Project Directory**: `~/ai` (`/home/dlogan/ai`)
- **User**: `dlogan`
- **Hostname**: `dlogan-ai-series`

## Network Configuration
- **Local Network**: 192.168.1.x
- **MetalLB IP Range**: 192.168.1.100-192.168.1.110
- **OpenWebUI**: 192.168.1.101:8080
- **Grafana**: 192.168.1.102:3000
- **Tailscale IP**: 100.102.114.95

## Installed Software
### Snap Packages
- microk8s (classic)
- tailscale (1.86.0)

### APT Packages
- helm
- curl
- git
- konsole
- iptables-persistent
- socat

## Storage Configuration
- **AI Models Storage**: `/mnt/evo4t/microk8s-storage/`
- **Default Storage Class**: `evo4t-storage`
- **Storage Provisioner**: `microk8s.io/hostpath`

## Authentication
- **Tailscale Account**: dlogan1970@
- **OpenWebUI**: Authentication enabled (admin account created)

## Development Preferences
- **Terminal**: Konsole with KDE integration
- **Editor**: (specify your preference)
- **Shell**: bash (default)

## Current Status
- **Last Updated**: $(date)
- **Ollama Stack**: Deployed and running
- **Models Downloaded**: codellama, llama3.2:3b, gemma2:4b
- **Monitoring**: Grafana accessible
- **Remote Access**: Tailscale working

