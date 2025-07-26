#!/bin/bash

echo "🏗️ Creating complete Helm chart structure for Ollama Stack..."

# Ensure we're in the right directory
cd ~/ai

# Create directories
echo "📁 Creating directory structure..."
mkdir -p helm/ollama-stack/templates/{infrastructure,monitoring,network}

# Function to create all templates
create_templates() {
    
    echo "📝 Creating Ollama PVC template..."
    cat > helm/ollama-stack/templates/ollama-pvc.yaml << 'TEMPLATE_EOF'
{{- if and .Values.ollama.enabled .Values.ollama.persistence.enabled }}
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: ollama-pvc
  namespace: {{ .Values.global.namespace }}
  labels:
    {{- include "ollama-stack.labels" . | nindent 4 }}
    app: ollama
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: {{ .Values.ollama.persistence.size }}
  storageClassName: {{ .Values.ollama.persistence.storageClass }}
{{- end }}
TEMPLATE_EOF

    echo "📝 Creating OpenWebUI PVC template..."
    cat > helm/ollama-stack/templates/openwebui-pvc.yaml << 'TEMPLATE_EOF'
{{- if and .Values.openwebui.enabled .Values.openwebui.persistence.enabled }}
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: open-webui-data-pvc
  namespace: {{ .Values.global.namespace }}
  labels:
    {{- include "ollama-stack.labels" . | nindent 4 }}
    app: open-webui
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: {{ .Values.openwebui.persistence.size }}
  storageClassName: {{ .Values.openwebui.persistence.storageClass }}
{{- end }}
TEMPLATE_EOF

    echo "📝 Creating Ollama Deployment template..."
    cat > helm/ollama-stack/templates/ollama-deployment.yaml << 'TEMPLATE_EOF'
{{- if .Values.ollama.enabled }}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ollama
  namespace: {{ .Values.global.namespace }}
  labels:
    {{- include "ollama-stack.labels" . | nindent 4 }}
    app: ollama
spec:
  replicas: 1
  selector:
    matchLabels:
      {{- include "ollama-stack.selectorLabels" . | nindent 6 }}
      app: ollama
  template:
    metadata:
      labels:
        {{- include "ollama-stack.selectorLabels" . | nindent 8 }}
        app: ollama
    spec:
      terminationGracePeriodSeconds: {{ .Values.ollama.terminationGracePeriodSeconds }}
      containers:
      - name: ollama
        image: {{ .Values.ollama.image.repository }}:{{ .Values.ollama.image.tag }}
        imagePullPolicy: {{ .Values.ollama.image.pullPolicy }}
        ports:
        - containerPort: 11434
          name: http
        resources:
          {{- toYaml .Values.ollama.resources | nindent 10 }}
        volumeMounts:
        - name: ollama-storage
          mountPath: /root/.ollama
        env:
        - name: OLLAMA_HOST
          value: {{ .Values.ollama.config.host | quote }}
        {{- if .Values.ollama.config.numParallel }}
        - name: OLLAMA_NUM_PARALLEL
          value: {{ .Values.ollama.config.numParallel | quote }}
        {{- end }}
        {{- if .Values.ollama.config.maxLoadedModels }}
        - name: OLLAMA_MAX_LOADED_MODELS
          value: {{ .Values.ollama.config.maxLoadedModels | quote }}
        {{- end }}
        {{- if .Values.ollama.config.flashAttention }}
        - name: OLLAMA_FLASH_ATTENTION
          value: "1"
        {{- end }}
        lifecycle:
          preStop:
            exec:
              command: ["/bin/sh", "-c", "sleep 10"]
        livenessProbe:
          httpGet:
            path: /
            port: 11434
          initialDelaySeconds: 30
          periodSeconds: 30
        readinessProbe:
          httpGet:
            path: /
            port: 11434
          initialDelaySeconds: 5
          periodSeconds: 5
      volumes:
      - name: ollama-storage
        {{- if .Values.ollama.persistence.enabled }}
        persistentVolumeClaim:
          claimName: ollama-pvc
        {{- else }}
        emptyDir: {}
        {{- end }}
{{- end }}
TEMPLATE_EOF

    echo "📝 Creating Ollama Service template..."
    cat > helm/ollama-stack/templates/ollama-service.yaml << 'TEMPLATE_EOF'
{{- if .Values.ollama.enabled }}
apiVersion: v1
kind: Service
metadata:
  name: ollama-service
  namespace: {{ .Values.global.namespace }}
  labels:
    {{- include "ollama-stack.labels" . | nindent 4 }}
    app: ollama
spec:
  selector:
    {{- include "ollama-stack.selectorLabels" . | nindent 4 }}
    app: ollama
  ports:
    - protocol: TCP
      port: 11434
      targetPort: 11434
      name: http
{{- end }}
TEMPLATE_EOF

    echo "📝 Creating OpenWebUI Deployment template..."
    cat > helm/ollama-stack/templates/openwebui-deployment.yaml << 'TEMPLATE_EOF'
{{- if .Values.openwebui.enabled }}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: open-webui
  namespace: {{ .Values.global.namespace }}
  labels:
    {{- include "ollama-stack.labels" . | nindent 4 }}
    app: open-webui
spec:
  replicas: 1
  selector:
    matchLabels:
      {{- include "ollama-stack.selectorLabels" . | nindent 6 }}
      app: open-webui
  template:
    metadata:
      labels:
        {{- include "ollama-stack.selectorLabels" . | nindent 8 }}
        app: open-webui
    spec:
      containers:
      - name: open-webui
        image: {{ .Values.openwebui.image.repository }}:{{ .Values.openwebui.image.tag }}
        imagePullPolicy: {{ .Values.openwebui.image.pullPolicy }}
        ports:
        - containerPort: 8080
          name: http
        env:
        - name: OLLAMA_BASE_URL
          value: "http://ollama-service.{{ .Values.global.namespace }}.svc.cluster.local:11434"
        - name: WEBUI_AUTH
          value: {{ .Values.openwebui.auth.enabled | quote }}
        resources:
          {{- toYaml .Values.openwebui.resources | nindent 10 }}
        volumeMounts:
        - name: open-webui-data
          mountPath: /app/backend/data
        livenessProbe:
          httpGet:
            path: /
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 30
        readinessProbe:
          httpGet:
            path: /
            port: 8080
          initialDelaySeconds: 5
          periodSeconds: 5
      volumes:
      - name: open-webui-data
        {{- if .Values.openwebui.persistence.enabled }}
        persistentVolumeClaim:
          claimName: open-webui-data-pvc
        {{- else }}
        emptyDir: {}
        {{- end }}
{{- end }}
TEMPLATE_EOF

    echo "📝 Creating OpenWebUI Service template..."
    cat > helm/ollama-stack/templates/openwebui-service-local.yaml << 'TEMPLATE_EOF'
{{- if and .Values.openwebui.enabled .Values.networking.metallb.enabled }}
apiVersion: v1
kind: Service
metadata:
  name: open-webui-service-local
  namespace: {{ .Values.global.namespace }}
  annotations:
    metallb.universe.tf/loadBalancerIPs: {{ .Values.networking.services.openwebui.ip }}
  labels:
    {{- include "ollama-stack.labels" . | nindent 4 }}
    app: open-webui
spec:
  type: LoadBalancer
  selector:
    {{- include "ollama-stack.selectorLabels" . | nindent 4 }}
    app: open-webui
  ports:
    - protocol: TCP
      port: {{ .Values.networking.services.openwebui.port }}
      targetPort: 8080
      name: http
{{- end }}
TEMPLATE_EOF

    echo "✅ Created all core application templates"
}

# Create monitoring ServiceMonitor template
create_monitoring_templates() {
    echo "📝 Creating Prometheus ServiceMonitor template..."
    cat > helm/ollama-stack/templates/monitoring/servicemonitor.yaml << 'TEMPLATE_EOF'
{{- if .Values.monitoring.prometheus.serviceMonitor.enabled }}
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: {{ include "ollama-stack.fullname" . }}-monitor
  namespace: {{ .Values.global.namespace }}
  labels:
    {{- include "ollama-stack.labels" . | nindent 4 }}
spec:
  selector:
    matchLabels:
      {{- include "ollama-stack.selectorLabels" . | nindent 6 }}
      app: ollama
  endpoints:
  {{- range .Values.monitoring.prometheus.serviceMonitor.endpoints }}
  - port: {{ .port }}
    interval: {{ .interval }}
    path: {{ .path }}
  {{- end }}
{{- end }}
TEMPLATE_EOF
}

# Run the functions
create_templates
create_monitoring_templates

echo ""
echo "🎉 All Helm templates created successfully!"
echo ""
echo "📁 Created structure:"
find helm/ollama-stack/templates -name "*.yaml" | sort

echo ""
echo "🧪 Validating Helm chart..."
if helm lint helm/ollama-stack; then
    echo "✅ Helm chart validation passed!"
else
    echo "❌ Helm chart validation failed - check the output above"
    exit 1
fi

echo ""
echo "🔍 Testing template rendering..."
if helm template test-release helm/ollama-stack --dry-run > /dev/null; then
    echo "✅ Template rendering successful!"
else
    echo "❌ Template rendering failed"
    exit 1
fi

echo ""
echo "🚀 Ready to deploy! Run:"
echo "   helm upgrade --install ollama-stack helm/ollama-stack --namespace ollama-stack --create-namespace"