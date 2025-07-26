# System Architecture - Mermaid Diagrams

## 🏗️ Complete System Architecture

```mermaid
graph TB
    subgraph "External Access"
        U[👥 Users] 
        I[🌐 Internet/LAN]
        T[🔒 Tailscale<br/>100.102.114.95]
    end
    
    subgraph "Kubernetes Cluster (MicroK8s)"
        subgraph "Load Balancer (MetalLB)"
            LB1[🌐 OpenWebUI LB<br/>192.168.1.101:8080]
            LB2[📊 Grafana LB<br/>192.168.1.102:3000]
        end
        
        subgraph "ollama-stack namespace"
            subgraph "Web Tier"
                WS[⚡ open-webui-service-local]
                WP[🖥️ OpenWebUI Pod<br/>Status: Running]
            end
            
            subgraph "AI Processing Tier"
                OS[🤖 ollama-service<br/>ClusterIP]
                OP[🧠 Ollama Pod<br/>Models: CodeLlama, Llama3.2:3b, Gemma2:4b]
            end
            
            subgraph "Storage Layer"
                SC[💾 Custom StorageClass<br/>/mnt/evo4t]
                PVC1[📦 Models PVC<br/>1TB NVMe SSD]
                PVC2[💬 WebUI Data PVC]
            end
        end
        
        subgraph "observability namespace"
            subgraph "Monitoring Stack"
                GS1[📊 grafana-external<br/>LoadBalancer]
                GP[📊 Grafana Pod<br/>Dashboards]
                PS[📈 Prometheus Stack<br/>Metrics Collection]
            end
        end
    end
    
    subgraph "Physical Infrastructure"
        HW[🖥️ AMD Ryzen AI 9 HX 370<br/>96GB • 1TB NVMe SSD]
    end
    
    %% External Access Flow
    U --> I
    U --> T
    I --> LB1
    I --> LB2
    T -.->|Direct Access| WP
    
    %% Application Flow
    LB1 --> WS --> WP
    WP --> OS --> OP
    
    %% Monitoring Flow  
    LB2 --> GS1 --> GP
    OP -.->|📊 AI Metrics| PS
    WP -.->|📊 Usage Metrics| PS
    PS --> GP
    
    %% Storage Connections
    SC --> PVC1 --> OP
    SC --> PVC2 --> WP
    SC --> HW
    
    %% Styling
    classDef userClass fill:#e1f5fe,stroke:#0277bd,stroke-width:2px
    classDef ollamaClass fill:#f3e5f5,stroke:#7b1fa2,stroke-width:2px
    classDef observabilityClass fill:#e8f5e8,stroke:#388e3c,stroke-width:2px
    classDef storageClass fill:#fff3e0,stroke:#f57c00,stroke-width:2px
    classDef aiClass fill:#ffebee,stroke:#c62828,stroke-width:3px
    
    class U,I,T userClass
    class WS,WP,OS,OP ollamaClass
    class GS1,GP,PS observabilityClass
    class SC,PVC1,PVC2,HW storageClass
    class OP aiClass
```

## 🔄 Request Processing Flow

```mermaid
sequenceDiagram
    participant U as 👤 User
    participant I as 🌐 Internet/LAN  
    participant LB as ⚖️ MetalLB (192.168.1.101)
    participant WS as ⚡ WebUI Service
    participant WP as 🖥️ OpenWebUI Pod
    participant OS as 🤖 Ollama Service
    participant OP as 🧠 Ollama Pod
    participant PS as 📈 Prometheus
    participant GP as 📊 Grafana (192.168.1.102)
    
    Note over U,GP: AI Chat Request with Monitoring
    
    U->>+I: 💬 Chat Request
    I->>+LB: Route to 192.168.1.101:8080
    LB->>+WS: Forward to open-webui-service-local
    WS->>+WP: Route to OpenWebUI Pod
    
    Note over WP: Process chat interface
    WP->>+OS: 🚀 API call to ollama-service
    OS->>+OP: Forward to Ollama Pod
    
    Note over OP: AI Model Processing<br/>(CodeLlama, Llama3.2:3b, Gemma2:4b)
    OP->>OP: 🤖 Run AI inference
    OP-->>-OS: Generated response
    OS-->>-WP: Return AI response
    WP-->>-WS: HTTP response
    WS-->>-LB: Forward response
    LB-->>-I: Send to user
    I-->>-U: 💬 AI Response
    
    %% Monitoring Flow (Parallel)
    par Metrics Collection
        OP--)PS: 📊 AI performance metrics
        WP--)PS: 📊 Usage & response metrics
        PS--)GP: 📈 Store metrics
    end
    
    Note over GP: Real-time dashboards available at 192.168.1.102:3000
```

## 🗄️ Storage & Data Architecture

```mermaid
graph TB
    subgraph "Physical Storage"
        NVMe[💾 1TB NVMe SSD<br/>/mnt/evo4t<br/>High-Performance Storage]
    end
    
    subgraph "Kubernetes Storage Layer"
        SC[⚙️ Custom StorageClass<br/>local-path provisioner]
    end
    
    subgraph "Persistent Volumes"
        PV1[📦 Ollama Models PV<br/>~500GB for AI models]
        PV2[💬 OpenWebUI Data PV<br/>~100GB for chat data]
        PV3[📊 Prometheus Data PV<br/>~50GB for metrics]
    end
    
    subgraph "Application Data"
        subgraph "ollama-stack namespace"
            D1[🤖 AI Models<br/>CodeLlama, Llama3.2:3b, Gemma2:4b]
            D2[💬 Chat History<br/>User conversations & settings]
        end
        
        subgraph "observability namespace"
            D3[📈 Metrics Database<br/>Performance & usage data]
            D4[📊 Grafana Config<br/>Dashboards & alerts]
        end
    end
    
    %% Storage Flow
    NVMe --> SC
    SC --> PV1 --> D1
    SC --> PV2 --> D2
    SC --> PV3 --> D3
    D3 --> D4
    
    %% Data Processing Flow
    D2 -.->|API calls| D1
    D1 -.->|metrics| D3
    D2 -.->|usage stats| D3
```

## 📊 Namespace Overview

```mermaid
graph LR
    subgraph "Kubernetes Cluster"
        subgraph "ollama-stack namespace"
            subgraph "Application Layer"
                A1[🖥️ OpenWebUI Pod]
                A2[🤖 Ollama Pod]
            end
            
            subgraph "Service Layer"
                S1[⚡ open-webui-service-local<br/>LoadBalancer: 192.168.1.101:8080]
                S2[🔗 ollama-service<br/>ClusterIP]
            end
            
            subgraph "Storage Layer"
                ST1[💾 Ollama Models PVC]
                ST2[💬 OpenWebUI Data PVC]
            end
        end
        
        subgraph "observability namespace"
            subgraph "Monitoring Services"
                M1[📊 grafana-external<br/>LoadBalancer: 192.168.1.102:3000]
                M2[📈 kube-prom-stack-grafana<br/>ClusterIP]
            end
            
            subgraph "Monitoring Pods"
                MP1[📊 Grafana Pod]
                MP2[📈 Prometheus Stack]
            end
        end
    end
    
    %% Internal Connections
    S1 --> A1
    S2 --> A2
    A1 --> S2
    ST1 --> A2
    ST2 --> A1
    
    M1 --> MP1
    M2 --> MP1
    A2 -.->|metrics| MP2
    A1 -.->|metrics| MP2
    MP2 --> MP1
    
    %% External Access
    EXT1[🌐 External Access<br/>192.168.1.101:8080] --> S1
    EXT2[📊 External Monitoring<br/>192.168.1.102:3000] --> M1
```

---

**Generated on**: 2025-07-26
