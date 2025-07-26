#!/usr/bin/env python3
"""
System Architecture Diagram Generator
Requires: pip install diagrams
"""

from diagrams import Diagram, Cluster, Edge
from diagrams.k8s.compute import Pod, Deployment
from diagrams.k8s.network import Service, Ingress
from diagrams.k8s.storage import PV, PVC, StorageClass
from diagrams.onprem.client import Users
from diagrams.onprem.network import Internet
from diagrams.programming.language import Python
from diagrams.onprem.monitoring import Grafana, Prometheus
from diagrams.generic.network import VPN
from diagrams.aws.storage import EBS

def create_system_architecture():
    """Generate complete system architecture diagram"""
    
    with Diagram("Ollama Kubernetes Stack - System Architecture", 
                 filename="docs/architecture/diagrams/generated/system_architecture",
                 show=False, direction="TB"):
        
        # External Access
        users = Users("Users")
        internet = Internet("Internet/LAN")
        tailscale = VPN("Tailscale Mesh\n100.102.114.95")
        
        with Cluster("Kubernetes Cluster (MicroK8s)"):
            
            with Cluster("LoadBalancer (MetalLB)"):
                webui_lb = Service("OpenWebUI LB\n192.168.1.101:8080")
                grafana_lb = Service("Grafana LB\n192.168.1.102:3000")
            
            with Cluster("ollama-stack Namespace"):
                
                with Cluster("AI Processing"):
                    ollama_svc = Service("Ollama Service\nClusterIP")
                    ollama_pod = Pod("Ollama Pod\nAI Inference")
                    
                with Cluster("Web Interface"):
                    webui_svc = Service("WebUI Service")
                    webui_pod = Pod("OpenWebUI Pod\nWeb Interface")
                
                with Cluster("Storage"):
                    storage_class = StorageClass("Custom StorageClass\n/mnt/evo4t")
                    ollama_pvc = PVC("Models PVC\n1TB NVMe SSD")
                    webui_pvc = PVC("WebUI PVC\nChat Data")
            
            with Cluster("observability Namespace"):
                prometheus = Prometheus("Prometheus\nMetrics Collection")
                grafana_pod = Pod("Grafana Pod\nDashboards")
        
        # Hardware Layer
        with Cluster("Hardware Infrastructure"):
            nvme_storage = EBS("1TB NVMe SSD\n/mnt/evo4t")
            cpu = Python("AMD Ryzen AI 9 HX 370\n96GB")
        
        # Connections
        users >> internet >> webui_lb
        users >> tailscale >> webui_pod
        users >> internet >> grafana_lb
        
        webui_lb >> webui_svc >> webui_pod
        webui_pod >> ollama_svc >> ollama_pod
        
        grafana_lb >> grafana_pod
        prometheus >> grafana_pod
        ollama_pod >> Edge(label="metrics") >> prometheus
        
        storage_class >> ollama_pvc >> ollama_pod
        storage_class >> webui_pvc >> webui_pod
        storage_class >> nvme_storage
        
        ollama_pod >> cpu

def create_network_flow():
    """Generate network flow diagram"""
    
    with Diagram("Network Flow Architecture", 
                 filename="docs/architecture/diagrams/generated/network_flow",
                 show=False, direction="LR"):
        
        users = Users("External Users")
        
        with Cluster("Entry Points"):
            internet = Internet("Internet/LAN")
            tailscale = VPN("Tailscale\n100.102.114.95")
        
        with Cluster("Load Balancing"):
            metallb = Service("MetalLB\nBare Metal LB")
        
        with Cluster("Kubernetes Services"):
            webui_svc = Service("OpenWebUI\n192.168.1.101:8080")
            grafana_svc = Service("Grafana\n192.168.1.102:3000")
            ollama_internal = Service("Ollama Internal\nClusterIP")
        
        with Cluster("Application Pods"):
            webui_pod = Pod("OpenWebUI")
            ollama_pod = Pod("Ollama AI")
            grafana_pod = Pod("Grafana")
        
        # Flow connections
        users >> internet >> metallb
        users >> tailscale >> webui_pod
        
        metallb >> webui_svc >> webui_pod
        metallb >> grafana_svc >> grafana_pod
        
        webui_pod >> ollama_internal >> ollama_pod

def create_data_flow():
    """Generate data flow and processing diagram"""
    
    with Diagram("AI Data Processing Flow", 
                 filename="docs/architecture/diagrams/generated/data_flow",
                 show=False, direction="TB"):
        
        user_input = Users("User Input\nChat/API Requests")
        
        with Cluster("Web Layer"):
            webui = Pod("OpenWebUI\nRequest Processing")
        
        with Cluster("AI Processing Layer"):
            ollama_api = Service("Ollama API\nModel Management")
            ai_models = Pod("AI Models\nCodeLlama, Llama3.2:3b, Gemma2:4b")
        
        with Cluster("Storage Layer"):
            model_storage = PVC("Model Storage\n1TB NVMe SSD")
            chat_storage = PVC("Chat History\nWebUI Data")
        
        with Cluster("Monitoring Layer"):
            metrics = Prometheus("Metrics\nCollection")
            dashboards = Grafana("Dashboards\nVisualization")
        
        # Data flow
        user_input >> webui >> ollama_api >> ai_models
        ai_models >> model_storage
        webui >> chat_storage
        
        ai_models >> Edge(label="performance metrics") >> metrics
        webui >> Edge(label="usage metrics") >> metrics
        metrics >> dashboards

if __name__ == "__main__":
    print("🎨 Generating Python architecture diagrams...")
    create_system_architecture()
    create_network_flow() 
    create_data_flow()
    print("✅ Python diagrams generated successfully!")
    print("📁 Generated files:")
    print("   - docs/architecture/diagrams/generated/system_architecture.png")
    print("   - docs/architecture/diagrams/generated/network_flow.png") 
    print("   - docs/architecture/diagrams/generated/data_flow.png")
