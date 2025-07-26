#!/bin/bash

# Ollama Model Management Script
# Usage: ./add-model.sh [OPTIONS] [model-name]
# Examples: 
#   ./add-model.sh -list
#   ./add-model.sh -add llama3.2:7b
#   ./add-model.sh -delete codellama:13b
#   ./add-model.sh -potential

set -e

# Configuration
NAMESPACE="ollama-stack"
DEPLOYMENT="ollama"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to show usage
show_usage() {
    echo "🤖 Ollama Model Management Script"
    echo "================================"
    echo ""
    echo "Usage: $0 [OPTIONS] [model-name]"
    echo ""
    echo "OPTIONS:"
    echo "  -list                       List currently installed models"
    echo "  -add <model-name>          Add/download a new model"
    echo "  -delete <model-name>       Delete an existing model"
    echo "  -potential                 Show popular models that can be installed"
    echo "  -h, --help                 Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 -list                    # Show installed models"
    echo "  $0 -add llama3.2:7b         # Download Llama 3.2 7B"
    echo "  $0 -delete codellama:13b    # Remove CodeLlama 13B"
    echo "  $0 -potential               # Show available models"
    echo ""
    echo "Quick usage (backwards compatible):"
    echo "  $0 llama3.2:7b              # Same as -add llama3.2:7b"
    echo ""
    echo "Model Size Reference:"
    echo "  • 3b models    ~2GB     (Fast, good for chat)"
    echo "  • 7b models    ~4GB     (Balanced performance)"
    echo "  • 13b models   ~7GB     (High quality)"
    echo "  • 34b models   ~19GB    (Excellent, needs lots of RAM)"
    echo ""
}

# Function to check prerequisites
check_prerequisites() {
    print_info "Checking prerequisites..."
    
    # Check if microk8s is available
    if ! command -v microk8s &> /dev/null; then
        print_error "microk8s command not found. Please ensure MicroK8s is installed."
        exit 1
    fi
    
    # Check if microk8s is running
    if ! microk8s kubectl get nodes &> /dev/null; then
        print_error "MicroK8s is not running or not configured properly."
        exit 1
    fi
    
    # Check if ollama-stack namespace exists
    if ! microk8s kubectl get namespace "$NAMESPACE" &> /dev/null; then
        print_error "Namespace '$NAMESPACE' not found. Please deploy the Ollama stack first."
        exit 1
    fi
    
    # Check if ollama deployment exists
    if ! microk8s kubectl get deployment "$DEPLOYMENT" -n "$NAMESPACE" &> /dev/null; then
        print_error "Ollama deployment not found in namespace '$NAMESPACE'."
        exit 1
    fi
    
    # Check if ollama pod is running
    if ! microk8s kubectl get pods -n "$NAMESPACE" -l app=ollama | grep -q "Running"; then
        print_error "Ollama pod is not running. Please check the deployment status."
        exit 1
    fi
    
    print_success "Prerequisites check passed"
}

# Function to show current storage usage
show_storage_info() {
    print_info "Current storage usage:"
    
    # Show overall storage usage
    if [ -d "/mnt/evo4t" ]; then
        df -h /mnt/evo4t | tail -1
        echo ""
        print_info "Ollama model storage details:"
        du -sh /mnt/evo4t/microk8s-storage/ollama-* 2>/dev/null || print_warning "Model storage details not available"
    else
        print_warning "Storage mount /mnt/evo4t not found"
    fi
}

# Function to list installed models
list_models() {
    print_info "Currently installed models:"
    echo ""
    
    if microk8s kubectl exec -n "$NAMESPACE" deployment/"$DEPLOYMENT" -- ollama list 2>/dev/null; then
        echo ""
        show_storage_info
    else
        print_error "Could not retrieve model list. Ollama might not be running."
        return 1
    fi
}

# Function to show potential models that can be installed
show_potential_models() {
    print_info "Popular models available for installation:"
    echo ""
    
    cat << 'EOF'
🚀 GENERAL PURPOSE MODELS:
  llama3.2:3b              Fast, efficient chat model (~2GB)
  llama3.2:7b              Balanced performance (~4GB)  
  llama3.2:13b             High quality responses (~7GB)
  gemma2:4b                Google's efficient model (~2.5GB)
  gemma2:7b                Google's balanced model (~4GB)
  mistral:7b               High-quality instruction following (~4GB)
  qwen2.5:7b               Alibaba's multilingual model (~4GB)

💻 CODING MODELS:
  codellama:7b             Code generation and completion (~4GB)
  codellama:13b            Advanced code understanding (~7GB)
  codellama:34b            Professional coding assistant (~19GB)
  deepseek-coder:6.7b      Efficient code model (~4GB)
  deepseek-coder:33b       Advanced code optimization (~18GB)
  codeqwen:7b              Alibaba's coding model (~4GB)

🧠 SPECIALIZED MODELS:
  dolphin-llama3:8b        Uncensored conversational model (~4GB)
  orca-mini:3b             Fast reasoning model (~2GB)
  phi3:3.8b                Microsoft's efficient model (~2GB)
  neural-chat:7b           Optimized for dialogue (~4GB)

📊 ANALYSIS & REASONING:
  wizard-math:7b           Mathematical reasoning (~4GB)
  wizard-coder:15b         Advanced coding tasks (~8GB)
  openchat:7b              Optimized chat performance (~4GB)

📝 WRITING & CREATIVE:
  llama3.2-vision:11b      Text + image understanding (~6GB)
  yarn-llama2:7b           Long context conversations (~4GB)

Usage Examples:
  ./add-model.sh -add llama3.2:7b
  ./add-model.sh -add codellama:13b
  ./add-model.sh -add gemma2:4b

Note: Download times vary by model size and internet speed.
      Ensure sufficient storage space before downloading large models.
EOF
}

# Function to delete a model
delete_model() {
    local model_name="$1"
    
    if [ -z "$model_name" ]; then
        print_error "No model name provided for deletion."
        print_info "Usage: $0 -delete <model-name>"
        return 1
    fi
    
    print_info "Preparing to delete model: $model_name"
    
    # Check if model exists
    if ! microk8s kubectl exec -n "$NAMESPACE" deployment/"$DEPLOYMENT" -- ollama list | grep -q "$model_name"; then
        print_warning "Model '$model_name' not found in installed models."
        print_info "Use '$0 -list' to see installed models."
        return 1
    fi
    
    # Ask for confirmation
    print_warning "This will permanently delete the model '$model_name' and free up storage space."
    read -p "Are you sure you want to delete '$model_name'? (y/N): " -n 1 -r
    echo
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Deletion cancelled."
        return 0
    fi
    
    print_info "Deleting model '$model_name'..."
    
    if microk8s kubectl exec -n "$NAMESPACE" deployment/"$DEPLOYMENT" -- ollama rm "$model_name"; then
        print_success "Model '$model_name' deleted successfully!"
        echo ""
        print_info "Updated storage usage:"
        show_storage_info
    else
        print_error "Failed to delete model '$model_name'"
        return 1
    fi
}

# Function to estimate model size
estimate_model_size() {
    local model_name="$1"
    local size_estimate=""
    
    case "$model_name" in
        *"3b"*)    size_estimate="~2GB" ;;
        *"7b"*)    size_estimate="~4GB" ;;
        *"13b"*)   size_estimate="~7GB" ;;
        *"34b"*)   size_estimate="~19GB" ;;
        *"70b"*)   size_estimate="~40GB" ;;
        *"4b"*)    size_estimate="~2.5GB" ;;
        *"33b"*)   size_estimate="~18GB" ;;
        *"small"*) size_estimate="~1GB" ;;
        *"large"*) size_estimate="~10GB+" ;;
        *)         size_estimate="Unknown" ;;
    esac
    
    echo "$size_estimate"
}

# Function to add the model
add_model() {
    local model_name="$1"
    local estimated_size=$(estimate_model_size "$model_name")
    
    print_info "Preparing to download model: $model_name"
    print_info "Estimated size: $estimated_size"
    echo ""
    
    # Ask for confirmation for large models
    if [[ "$estimated_size" == *"GB"* ]] && [[ ${estimated_size//[!0-9]/} -gt 10 ]]; then
        print_warning "This is a large model ($estimated_size). Download may take significant time."
        read -p "Continue? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_info "Download cancelled."
            exit 0
        fi
    fi
    
    print_info "Starting model download..."
    print_info "This may take several minutes depending on your internet connection."
    echo ""
    
    # Execute the ollama pull command
    if microk8s kubectl exec -n "$NAMESPACE" deployment/"$DEPLOYMENT" -- ollama pull "$model_name"; then
        print_success "Model '$model_name' downloaded successfully!"
    else
        print_error "Failed to download model '$model_name'"
        print_info "Please check:"
        print_info "  • Model name is correct and exists on ollama.com"
        print_info "  • Internet connection is stable"
        print_info "  • Sufficient storage space available"
        exit 1
    fi
    
    echo ""
    print_info "Updated model list:"
    microk8s kubectl exec -n "$NAMESPACE" deployment/"$DEPLOYMENT" -- ollama list
    
    echo ""
    print_info "Updated storage usage:"
    if [ -d "/mnt/evo4t" ]; then
        df -h /mnt/evo4t | tail -1
    fi
    
    echo ""
    print_success "Model '$model_name' is ready to use in OpenWebUI!"
    print_info "Access your AI stack at: http://192.168.1.101:8080"
}

# Function to validate model name
validate_model_name() {
    local model_name="$1"
    
    # Basic validation - model names should contain alphanumeric characters, hyphens, dots, and colons
    if [[ ! "$model_name" =~ ^[a-zA-Z0-9._:-]+$ ]]; then
        print_error "Invalid model name format: '$model_name'"
        print_info "Model names should contain only letters, numbers, dots, hyphens, and colons."
        print_info "Examples: llama3.2:7b, codellama:13b, mistral:latest"
        exit 1
    fi
    
    # Check if model name looks reasonable
    if [[ ${#model_name} -lt 3 ]]; then
        print_error "Model name too short: '$model_name'"
        exit 1
    fi
    
    print_success "Model name validation passed"
}

# Main script execution
main() {
    echo "🤖 Ollama Model Management Script"
    echo "================================="
    echo ""
    
    # Check if no arguments provided
    if [ $# -eq 0 ]; then
        print_error "No arguments provided."
        echo ""
        show_usage
        exit 1
    fi
    
    # Handle help flags
    if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
        show_usage
        exit 0
    fi
    
    # Check prerequisites for all operations
    check_prerequisites
    
    # Parse command line arguments
    case "$1" in
        -list)
            list_models
            ;;
        -potential)
            show_potential_models
            ;;
        -add)
            if [ -z "$2" ]; then
                print_error "No model name provided for addition."
                print_info "Usage: $0 -add <model-name>"
                exit 1
            fi
            validate_model_name "$2"
            show_storage_info
            echo ""
            add_model "$2"
            ;;
        -delete)
            if [ -z "$2" ]; then
                print_error "No model name provided for deletion."
                print_info "Usage: $0 -delete <model-name>"
                exit 1
            fi
            delete_model "$2"
            ;;
        -*)
            print_error "Unknown option: $1"
            echo ""
            show_usage
            exit 1
            ;;
        *)
            # Backwards compatibility - treat as model name to add
            print_info "Adding model (backwards compatibility mode): $1"
            validate_model_name "$1"
            show_storage_info
            echo ""
            add_model "$1"
            ;;
    esac
}

# Run the main function with all arguments
main "$@"