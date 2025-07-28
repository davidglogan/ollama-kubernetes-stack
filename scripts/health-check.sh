#!/bin/bash
# Ollama Stack Health Check Script
# Tests all endpoints and provides comprehensive status reporting
# GitHub Version - No hardcoded personal information
# FIXED: Uses Grafana health API to avoid login redirects

set -euo pipefail

# Configuration - Override these with environment variables or command line
NAMESPACE="${OLLAMA_NAMESPACE:-ollama-stack}"
GRAFANA_NAMESPACE="${GRAFANA_NAMESPACE:-observability}"
TIMEOUT="${HEALTH_CHECK_TIMEOUT:-10}"
RETRY_COUNT="${HEALTH_CHECK_RETRIES:-3}"
RETRY_DELAY="${HEALTH_CHECK_DELAY:-5}"

# Default endpoints - CHANGE THESE TO MATCH YOUR ENVIRONMENT
# Use auto-detection or environment variables for actual deployment
OPENWEBUI_URL="${OPENWEBUI_URL:-http://YOUR-OPENWEBUI-IP:8080}"
GRAFANA_URL="${GRAFANA_URL:-http://YOUR-GRAFANA-IP:3000}"
TAILSCALE_IP="${TAILSCALE_IP:-YOUR-TAILSCALE-IP}"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

# Icons
CHECK="✅"
CROSS="❌"
WARNING="⚠️"
INFO="ℹ️"
ROCKET="🚀"
NETWORK="🌐"
MONITOR="📊"
SECURE="🔒"

print_header() {
    echo -e "${BOLD}${BLUE}$1${NC}"
    echo -e "${BLUE}$(printf '=%.0s' {1..60})${NC}"
}

print_status() {
    local status="$1"
    local message="$2"
    local icon="$3"
    
    case "$status" in
        "OK")     echo -e "${icon} ${GREEN}${message}${NC}" ;;
        "WARN")   echo -e "${icon} ${YELLOW}${message}${NC}" ;;
        "ERROR")  echo -e "${icon} ${RED}${message}${NC}" ;;
        "INFO")   echo -e "${icon} ${CYAN}${message}${NC}" ;;
    esac
}

check_prerequisites() {
    print_header "🔍 Prerequisites Check"
    
    local all_good=true
    
    # Check kubectl
    if command -v kubectl >/dev/null 2>&1; then
        print_status "OK" "kubectl is available" "$CHECK"
    else
        print_status "ERROR" "kubectl not found" "$CROSS"
        all_good=false
    fi
    
    # Check cluster connectivity
    if kubectl cluster-info >/dev/null 2>&1; then
        print_status "OK" "Kubernetes cluster accessible" "$CHECK"
    else
        print_status "ERROR" "Cannot connect to Kubernetes cluster" "$CROSS"
        all_good=false
    fi
    
    # Check curl
    if command -v curl >/dev/null 2>&1; then
        print_status "OK" "curl is available" "$CHECK"
    else
        print_status "ERROR" "curl not found" "$CROSS"
        all_good=false
    fi
    
    if [ "$all_good" = false ]; then
        echo ""
        print_status "ERROR" "Prerequisites check failed. Please fix the issues above." "$CROSS"
        exit 1
    fi
    
    echo ""
}

check_kubernetes_resources() {
    print_header "☸️  Kubernetes Resources"
    
    # Check namespace
    if kubectl get namespace "$NAMESPACE" >/dev/null 2>&1; then
        print_status "OK" "Namespace '$NAMESPACE' exists" "$CHECK"
    else
        print_status "ERROR" "Namespace '$NAMESPACE' not found" "$CROSS"
        return 1
    fi
    
    # Check deployments
    local deployments=("ollama" "open-webui")
    for deployment in "${deployments[@]}"; do
        if kubectl get deployment "$deployment" -n "$NAMESPACE" >/dev/null 2>&1; then
            local ready=$(kubectl get deployment "$deployment" -n "$NAMESPACE" -o jsonpath='{.status.readyReplicas}')
            local desired=$(kubectl get deployment "$deployment" -n "$NAMESPACE" -o jsonpath='{.spec.replicas}')
            
            if [ "${ready:-0}" = "${desired:-0}" ] && [ "${ready:-0}" -gt 0 ]; then
                print_status "OK" "Deployment '$deployment' is ready ($ready/$desired)" "$CHECK"
            else
                print_status "WARN" "Deployment '$deployment' not ready ($ready/$desired)" "$WARNING"
            fi
        else
            print_status "ERROR" "Deployment '$deployment' not found" "$CROSS"
        fi
    done
    
    # Check services
    local services=("ollama-service" "open-webui-service-local")
    for service in "${services[@]}"; do
        if kubectl get service "$service" -n "$NAMESPACE" >/dev/null 2>&1; then
            print_status "OK" "Service '$service' exists" "$CHECK"
            
            # Show LoadBalancer IP if available
            local external_ip=$(kubectl get service "$service" -n "$NAMESPACE" -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null)
            if [ -n "$external_ip" ]; then
                print_status "INFO" "  External IP: $external_ip" "$INFO"
            fi
        else
            print_status "ERROR" "Service '$service' not found" "$CROSS"
        fi
    done
    
    # Check PVCs
    local pvcs=("ollama-pvc" "open-webui-data-pvc")
    for pvc in "${pvcs[@]}"; do
        if kubectl get pvc "$pvc" -n "$NAMESPACE" >/dev/null 2>&1; then
            local status=$(kubectl get pvc "$pvc" -n "$NAMESPACE" -o jsonpath='{.status.phase}')
            local size=$(kubectl get pvc "$pvc" -n "$NAMESPACE" -o jsonpath='{.spec.resources.requests.storage}')
            if [ "$status" = "Bound" ]; then
                print_status "OK" "PVC '$pvc' is bound ($size)" "$CHECK"
            else
                print_status "WARN" "PVC '$pvc' status: $status" "$WARNING"
            fi
        else
            print_status "ERROR" "PVC '$pvc' not found" "$CROSS"
        fi
    done
    
    echo ""
}

test_endpoint() {
    local name="$1"
    local url="$2"
    local expected_code="${3:-200}"
    local icon="$4"
    
    print_status "INFO" "Testing $name: $url" "$INFO"
    
    for attempt in $(seq 1 $RETRY_COUNT); do
        local response=$(curl -s -o /dev/null -w "%{http_code}:%{time_total}" \
                        --connect-timeout $TIMEOUT \
                        --max-time $((TIMEOUT * 2)) \
                        "$url" 2>/dev/null || echo "000:0")
        
        local http_code=$(echo "$response" | cut -d: -f1)
        local time_total=$(echo "$response" | cut -d: -f2)
        
        if [ "$http_code" = "$expected_code" ]; then
            print_status "OK" "$name is responding (${http_code}, ${time_total}s)" "$icon"
            return 0
        elif [ "$http_code" = "000" ]; then
            print_status "ERROR" "$name connection failed (attempt $attempt/$RETRY_COUNT)" "$CROSS"
        else
            print_status "WARN" "$name returned HTTP $http_code (attempt $attempt/$RETRY_COUNT)" "$WARNING"
        fi
        
        if [ $attempt -lt $RETRY_COUNT ]; then
            sleep $RETRY_DELAY
        fi
    done
    
    print_status "ERROR" "$name health check failed after $RETRY_COUNT attempts" "$CROSS"
    return 1
}

auto_detect_endpoints() {
    print_status "INFO" "Auto-detecting service endpoints..." "$INFO"
    
    # Try to get actual LoadBalancer IPs from Kubernetes
    local openwebui_ip=$(kubectl get service open-webui-service-local -n "$NAMESPACE" -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null)
    local grafana_ip=$(kubectl get service grafana-external -n "$GRAFANA_NAMESPACE" -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null)
    
    if [ -n "$openwebui_ip" ]; then
        OPENWEBUI_URL="http://$openwebui_ip:8080"
        print_status "INFO" "Detected OpenWebUI IP: $openwebui_ip" "$INFO"
    fi
    
    if [ -n "$grafana_ip" ]; then
        GRAFANA_URL="http://$grafana_ip:3000"
        print_status "INFO" "Detected Grafana IP: $grafana_ip" "$INFO"
    fi
    
    echo ""
}

check_endpoints() {
    print_header "🌐 Endpoint Health Check"
    
    local all_endpoints_ok=true
    
    # Check if URLs are still placeholders
    if [[ "$OPENWEBUI_URL" == *"YOUR-"* ]]; then
        print_status "WARN" "OpenWebUI URL not configured. Use --auto-detect or set OPENWEBUI_URL" "$WARNING"
        all_endpoints_ok=false
    else
        # Test OpenWebUI
        if ! test_endpoint "OpenWebUI" "$OPENWEBUI_URL" "200" "$ROCKET"; then
            all_endpoints_ok=false
        fi
    fi
    
    if [[ "$GRAFANA_URL" == *"YOUR-"* ]]; then
        print_status "WARN" "Grafana URL not configured. Use --auto-detect or set GRAFANA_URL" "$WARNING"
        all_endpoints_ok=false
    else
        # FIXED: Test Grafana using health API endpoint to avoid login redirect
        local grafana_health_url="${GRAFANA_URL%/}/api/health"
        if ! test_endpoint "Grafana Health API" "$grafana_health_url" "200" "$MONITOR"; then
            all_endpoints_ok=false
        fi
    fi
    
    # Test Tailscale (if configured and not placeholder)
    if [[ "$TAILSCALE_IP" != "YOUR-TAILSCALE-IP" ]] && [[ "$TAILSCALE_IP" != *"YOUR-"* ]]; then
        if ping -c 1 -W 3 "$TAILSCALE_IP" >/dev/null 2>&1; then
            if ! test_endpoint "Tailscale WebUI" "http://$TAILSCALE_IP:8080" "200" "$SECURE"; then
                print_status "WARN" "Tailscale IP reachable but WebUI not responding" "$WARNING"
            fi
        else
            print_status "WARN" "Tailscale IP ($TAILSCALE_IP) not reachable" "$WARNING"
        fi
    else
        print_status "INFO" "Tailscale IP not configured (set TAILSCALE_IP env var)" "$INFO"
    fi
    
    echo ""
    return $([ "$all_endpoints_ok" = true ] && echo 0 || echo 1)
}

check_ai_models() {
    print_header "🤖 AI Models Check"
    
    # Check if ollama pod is ready
    if ! kubectl get pods -n "$NAMESPACE" -l app=ollama --field-selector=status.phase=Running >/dev/null 2>&1; then
        print_status "WARN" "Ollama pod not running, skipping model check" "$WARNING"
        echo ""
        return 1
    fi
    
    # List available models
    local models_output
    if models_output=$(kubectl exec -n "$NAMESPACE" deployment/ollama -- ollama list 2>/dev/null); then
        local model_count=$(echo "$models_output" | grep -c ":" 2>/dev/null || echo "0")
        
        if [ "$model_count" -gt 0 ]; then
            print_status "OK" "Found $model_count AI models" "$CHECK"
            echo "$models_output" | tail -n +2 | while read -r line; do
                if [ -n "$line" ]; then
                    local model_name=$(echo "$line" | awk '{print $1}')
                    local model_size=$(echo "$line" | awk '{print $2}')
                    print_status "INFO" "  Model: $model_name ($model_size)" "$INFO"
                fi
            done
        else
            print_status "WARN" "No AI models found" "$WARNING"
            print_status "INFO" "Run: kubectl exec -n $NAMESPACE deployment/ollama -- ollama pull llama3.2:3b" "$INFO"
        fi
    else
        print_status "ERROR" "Could not retrieve model list" "$CROSS"
        return 1
    fi
    
    echo ""
}

check_storage() {
    print_header "💾 Storage Check"
    
    # Check storage class
    local storage_class=$(kubectl get pvc ollama-pvc -n "$NAMESPACE" -o jsonpath='{.spec.storageClassName}' 2>/dev/null)
    if [ -n "$storage_class" ]; then
        print_status "OK" "Using storage class: $storage_class" "$CHECK"
    else
        print_status "WARN" "No storage class specified" "$WARNING"
    fi
    
    # Check PV usage within pods
    if kubectl get pods -n "$NAMESPACE" -l app=ollama --field-selector=status.phase=Running >/dev/null 2>&1; then
        local storage_usage
        if storage_usage=$(kubectl exec -n "$NAMESPACE" deployment/ollama -- df -h /root/.ollama 2>/dev/null); then
            local used_percent=$(echo "$storage_usage" | tail -1 | awk '{print $5}' | sed 's/%//')
            local available=$(echo "$storage_usage" | tail -1 | awk '{print $4}')
            
            if [ "$used_percent" -lt 80 ]; then
                print_status "OK" "Ollama storage usage: ${used_percent}%, Available: $available" "$CHECK"
            elif [ "$used_percent" -lt 90 ]; then
                print_status "WARN" "Ollama storage usage: ${used_percent}%, Available: $available" "$WARNING"
            else
                print_status "ERROR" "Ollama storage usage critical: ${used_percent}%, Available: $available" "$CROSS"
            fi
        fi
    fi
    
    echo ""
}

generate_summary() {
    print_header "📋 Health Check Summary"
    
    local overall_status="OK"
    local recommendations=()
    
    # Check if endpoints are configured
    if [[ "$OPENWEBUI_URL" == *"YOUR-"* ]]; then
        print_status "WARN" "Endpoints not configured. Run with --auto-detect or set environment variables" "$WARNING"
        overall_status="WARN"
        recommendations+=("Use --auto-detect flag to automatically discover service IPs")
        recommendations+=("Or set OPENWEBUI_URL and GRAFANA_URL environment variables")
    else
        # Basic connectivity test
        if curl -s -o /dev/null -w "%{http_code}" --connect-timeout 5 "$OPENWEBUI_URL" | grep -q "200"; then
            print_status "OK" "System is operational and ready for AI interactions" "$ROCKET"
        else
            print_status "ERROR" "System is not fully operational" "$CROSS"
            overall_status="ERROR"
            recommendations+=("Check OpenWebUI deployment and service configuration")
        fi
    fi
    
    # Access information
    echo ""
    print_status "INFO" "Access URLs:" "$NETWORK"
    if [[ "$OPENWEBUI_URL" != *"YOUR-"* ]]; then
        echo "    OpenWebUI:  $OPENWEBUI_URL"
    else
        echo "    OpenWebUI:  [Not configured - use --auto-detect]"
    fi
    
    if [[ "$GRAFANA_URL" != *"YOUR-"* ]]; then
        echo "    Grafana:    $GRAFANA_URL"
    else
        echo "    Grafana:    [Not configured - use --auto-detect]"
    fi
    
    if [[ "$TAILSCALE_IP" != "YOUR-TAILSCALE-IP" ]] && [[ "$TAILSCALE_IP" != *"YOUR-"* ]]; then
        echo "    Tailscale:  http://$TAILSCALE_IP:8080"
    else
        echo "    Tailscale:  [Not configured - set TAILSCALE_IP]"
    fi
    
    # Configuration info
    echo ""
    print_status "INFO" "Configuration:" "$INFO"
    echo "    Namespace:  $NAMESPACE"
    echo "    Timeout:    ${TIMEOUT}s"
    echo "    Retries:    $RETRY_COUNT"
    
    # Recommendations
    if [ ${#recommendations[@]} -gt 0 ]; then
        echo ""
        print_status "INFO" "Recommendations:" "$INFO"
        for rec in "${recommendations[@]}"; do
            echo "  • $rec"
        done
    fi
    
    echo ""
    case "$overall_status" in
        "OK")
            print_status "OK" "All systems operational! 🎉" "$CHECK"
            ;;
        "WARN")
            print_status "WARN" "System functional but needs configuration" "$WARNING"
            ;;
        "ERROR")
            print_status "ERROR" "Issues detected. See details above." "$CROSS"
            exit 1
            ;;
    esac
}

show_usage() {
    cat << EOF
🏥 Ollama Stack Health Check

Usage: $0 [OPTIONS]

Options:
  -h, --help              Show this help message
  -q, --quick             Quick check (endpoints only)
  -v, --verbose           Verbose output
  -a, --auto-detect       Auto-detect service endpoints from Kubernetes
  --openwebui-url URL     Override OpenWebUI URL
  --grafana-url URL       Override Grafana URL
  --tailscale-ip IP       Override Tailscale IP
  --namespace NS          Override namespace (default: $NAMESPACE)
  --timeout SECONDS       Set request timeout (default: $TIMEOUT)

Environment Variables:
  OPENWEBUI_URL           OpenWebUI endpoint URL
  GRAFANA_URL             Grafana endpoint URL  
  TAILSCALE_IP            Tailscale mesh IP
  OLLAMA_NAMESPACE        Kubernetes namespace (default: ollama-stack)
  GRAFANA_NAMESPACE       Grafana namespace (default: observability)
  HEALTH_CHECK_TIMEOUT    Request timeout in seconds (default: 10)
  HEALTH_CHECK_RETRIES    Number of retries (default: 3)
  HEALTH_CHECK_DELAY      Delay between retries (default: 5)

Examples:
  $0                                    # Full health check with defaults
  $0 --quick                           # Quick endpoint test only
  $0 --auto-detect                     # Auto-detect service IPs
  $0 --openwebui-url http://10.0.0.100:8080  # Custom OpenWebUI URL
  
  # Using environment variables
  export OPENWEBUI_URL="http://10.0.0.100:8080"
  export GRAFANA_URL="http://10.0.0.101:3000"
  export TAILSCALE_IP="100.64.0.1"
  $0
  
  # For different network setups
  $0 --auto-detect --namespace my-ollama-stack
  
Configuration:
  This script expects placeholder URLs to be replaced with actual endpoints.
  Use --auto-detect to discover them automatically, or set environment variables.
  
EOF
}

# Parse command line arguments
QUICK_MODE=false
VERBOSE=false
AUTO_DETECT=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_usage
            exit 0
            ;;
        -q|--quick)
            QUICK_MODE=true
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -a|--auto-detect)
            AUTO_DETECT=true
            shift
            ;;
        --openwebui-url)
            OPENWEBUI_URL="$2"
            shift 2
            ;;
        --grafana-url)
            GRAFANA_URL="$2"
            shift 2
            ;;
        --tailscale-ip)
            TAILSCALE_IP="$2"
            shift 2
            ;;
        --namespace)
            NAMESPACE="$2"
            shift 2
            ;;
        --timeout)
            TIMEOUT="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Main execution
main() {
    local start_time=$(date +%s)
    
    print_header "🏥 Ollama Stack Health Check - $(date)"
    
    check_prerequisites
    
    if [ "$AUTO_DETECT" = true ]; then
        auto_detect_endpoints
    fi
    
    if [ "$QUICK_MODE" = false ]; then
        check_kubernetes_resources
        check_storage
        check_ai_models
    fi
    
    check_endpoints
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    echo ""
    generate_summary
    
    echo ""
    print_status "INFO" "Health check completed in ${duration}s" "$INFO"
}

main "$@"