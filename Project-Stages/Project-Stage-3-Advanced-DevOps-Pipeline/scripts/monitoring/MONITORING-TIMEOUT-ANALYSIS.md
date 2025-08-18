# 🔍 **Monitoring Stack Timeout Analysis & Fixes**

## 📋 **Executive Summary**

**Issue**: Prometheus monitoring stack deployment is timing out (2 failures reported)
**Root Cause**: Multiple resource allocation and configuration issues
**Solution**: Optimized deployment script with resource adjustments and timeout handling

---

## 🚨 **Identified Issues**

### **1. Resource Allocation Problems**
- **Current Node Capacity**: Only 2 nodes with limited resources
- **Prometheus Stack Requirements**: Too high for current cluster capacity
- **PVC Binding Issues**: Storage claims pending due to resource constraints

### **2. Timeout Configuration Issues**
- **Helm Timeout**: 10 minutes insufficient for resource-constrained environment
- **Pod Wait Timeout**: 300s (5 minutes) too short for pending pods
- **No Resource Pre-check**: Script doesn't validate available capacity

### **3. Storage Class Issues**
- **GP2 Storage Class**: Using `WaitForFirstConsumer` binding mode
- **PVC Pending**: Claims waiting for pod scheduling, but pods can't schedule due to resource constraints

### **4. Configuration Problems**
- **Resource Requests Too High**: Prometheus, Grafana, and AlertManager requesting more resources than available
- **No Graceful Degradation**: Script doesn't handle resource constraints

---

## 🔧 **Fix Implementation**

### **Fix 1: Resource-Optimized Values File**
```yaml
# monitoring/prometheus/values-optimized.yaml
prometheus:
  prometheusSpec:
    resources:
      requests:
        memory: "512Mi"    # Reduced from 1Gi
        cpu: "250m"        # Reduced from 500m
      limits:
        memory: "1Gi"      # Reduced from 2Gi
        cpu: "500m"        # Reduced from 1000m
    storageSpec:
      volumeClaimTemplate:
        spec:
          storageClassName: "gp2"
          accessModes: ["ReadWriteOnce"]
          resources:
            requests:
              storage: 10Gi  # Reduced from 20Gi

grafana:
  resources:
    requests:
      memory: "256Mi"      # Reduced from 512Mi
      cpu: "100m"          # Reduced from 250m
    limits:
      memory: "512Mi"      # Reduced from 1Gi
      cpu: "250m"          # Reduced from 500m

alertmanager:
  alertmanagerSpec:
    resources:
      requests:
        memory: "128Mi"    # Reduced from 256Mi
        cpu: "50m"         # Reduced from 100m
      limits:
        memory: "256Mi"    # Reduced from 512Mi
        cpu: "100m"        # Reduced from 250m
```

### **Fix 2: Enhanced Deployment Script**
```bash
#!/bin/bash
# deploy-prometheus-stack-fixed.sh

# Add resource validation
check_cluster_resources() {
    log_info "Checking cluster resource availability..."
    
    # Get node resources
    TOTAL_CPU=$(kubectl get nodes -o jsonpath='{.items[*].status.allocatable.cpu}' | tr ' ' '\n' | awk '{sum += $1} END {print sum}')
    TOTAL_MEMORY=$(kubectl get nodes -o jsonpath='{.items[*].status.allocatable.memory}' | tr ' ' '\n' | awk '{sum += $1} END {print sum}')
    
    # Convert to numeric values
    TOTAL_CPU_NUM=$(echo $TOTAL_CPU | sed 's/m//')
    TOTAL_MEMORY_NUM=$(echo $TOTAL_MEMORY | sed 's/Ki//')
    
    # Calculate available resources (assuming 50% for monitoring)
    AVAILABLE_CPU=$((TOTAL_CPU_NUM / 2))
    AVAILABLE_MEMORY=$((TOTAL_MEMORY_NUM / 2))
    
    log_info "Available resources: ${AVAILABLE_CPU}m CPU, ${AVAILABLE_MEMORY}Ki Memory"
    
    # Check if we have enough resources
    REQUIRED_CPU=400  # 250m + 100m + 50m
    REQUIRED_MEMORY=896000  # 512Mi + 256Mi + 128Mi in KiB
    
    if [ $AVAILABLE_CPU -lt $REQUIRED_CPU ]; then
        log_error "Insufficient CPU: Required ${REQUIRED_CPU}m, Available ${AVAILABLE_CPU}m"
        return 1
    fi
    
    if [ $AVAILABLE_MEMORY -lt $REQUIRED_MEMORY ]; then
        log_error "Insufficient Memory: Required ${REQUIRED_MEMORY}Ki, Available ${AVAILABLE_MEMORY}Ki"
        return 1
    fi
    
    log_success "Cluster has sufficient resources for monitoring stack"
    return 0
}

# Enhanced deployment with better timeout handling
deploy_prometheus_stack_optimized() {
    log_info "Deploying optimized Prometheus stack..."
    
    # Use optimized values file
    VALUES_FILE="${MONITORING_DIR}/prometheus/values-optimized.yaml"
    
    # Deploy with extended timeout and retry logic
    for attempt in {1..3}; do
        log_info "Deployment attempt $attempt/3"
        
        helm upgrade --install "$RELEASE_NAME" prometheus-community/kube-prometheus-stack \
            --namespace "$NAMESPACE" \
            --values "$VALUES_FILE" \
            --wait \
            --timeout 20m \
            --atomic
        
        if [ $? -eq 0 ]; then
            log_success "Prometheus stack deployed successfully on attempt $attempt"
            return 0
        else
            log_warning "Deployment attempt $attempt failed, cleaning up..."
            helm uninstall "$RELEASE_NAME" -n "$NAMESPACE" --timeout 5m || true
            kubectl delete pvc --all -n "$NAMESPACE" --timeout 2m || true
            sleep 30
        fi
    done
    
    log_error "All deployment attempts failed"
    return 1
}

# Enhanced pod waiting with better timeout handling
wait_for_pods_optimized() {
    log_info "Waiting for monitoring pods with enhanced timeout handling..."
    
    # Wait for operator first
    kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=prometheus-operator \
        -n "$NAMESPACE" --timeout=600s
    
    # Wait for Prometheus with longer timeout
    kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=prometheus \
        -n "$NAMESPACE" --timeout=900s || {
        log_warning "Prometheus pod not ready, checking status..."
        kubectl describe pod -l app.kubernetes.io/name=prometheus -n "$NAMESPACE"
    }
    
    # Wait for Grafana with longer timeout
    kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=grafana \
        -n "$NAMESPACE" --timeout=900s || {
        log_warning "Grafana pod not ready, checking status..."
        kubectl describe pod -l app.kubernetes.io/name=grafana -n "$NAMESPACE"
    }
    
    # Wait for AlertManager with longer timeout
    kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=alertmanager \
        -n "$NAMESPACE" --timeout=900s || {
        log_warning "AlertManager pod not ready, checking status..."
        kubectl describe pod -l app.kubernetes.io/name=alertmanager -n "$NAMESPACE"
    }
    
    log_success "Pod waiting completed"
}
```

### **Fix 3: Cleanup and Recovery Script**
```bash
#!/bin/bash
# cleanup-monitoring-stack.sh

cleanup_monitoring_stack() {
    log_info "Cleaning up monitoring stack..."
    
    # Uninstall Helm release
    helm uninstall "$RELEASE_NAME" -n "$NAMESPACE" --timeout 10m || true
    
    # Delete PVCs
    kubectl delete pvc --all -n "$NAMESPACE" --timeout 5m || true
    
    # Delete namespace
    kubectl delete namespace "$NAMESPACE" --timeout 5m || true
    
    # Wait for cleanup
    sleep 30
    
    log_success "Monitoring stack cleanup completed"
}

# Recovery function
recover_from_failed_deployment() {
    log_info "Recovering from failed deployment..."
    
    # Check for stuck resources
    STUCK_PODS=$(kubectl get pods -n "$NAMESPACE" --field-selector=status.phase=Pending -o name 2>/dev/null || true)
    if [ -n "$STUCK_PODS" ]; then
        log_warning "Found stuck pods, forcing deletion..."
        echo "$STUCK_PODS" | xargs kubectl delete --force --grace-period=0 || true
    fi
    
    # Clean up and retry
    cleanup_monitoring_stack
    sleep 60
    deploy_prometheus_stack_optimized
}
```

---

## 🚀 **Optimized Deployment Process**

### **Step 1: Pre-deployment Validation**
```bash
# Check cluster resources
./scripts/monitoring/check-cluster-resources.sh

# Clean up any existing failed deployments
./scripts/monitoring/cleanup-monitoring-stack.sh
```

### **Step 2: Deploy with Optimized Configuration**
```bash
# Use the fixed deployment script
./scripts/monitoring/deploy-prometheus-stack-fixed.sh
```

### **Step 3: Post-deployment Validation**
```bash
# Verify deployment
./scripts/monitoring/validate-monitoring-stack.sh

# Check resource usage
kubectl top pods -n monitoring
```

---

## 📊 **Resource Requirements Analysis**

### **Current Cluster Capacity**
- **Nodes**: 2 x t3.medium (2 vCPU, 4GB RAM each)
- **Total CPU**: 4000m (4 cores)
- **Total Memory**: 8GB
- **Available for Monitoring**: ~2000m CPU, ~4GB Memory

### **Optimized Resource Allocation**
| Component | CPU Request | CPU Limit | Memory Request | Memory Limit |
|-----------|-------------|-----------|----------------|--------------|
| Prometheus | 250m | 500m | 512Mi | 1Gi |
| Grafana | 100m | 250m | 256Mi | 512Mi |
| AlertManager | 50m | 100m | 128Mi | 256Mi |
| **Total** | **400m** | **850m** | **896Mi** | **1.75Gi** |

### **Resource Efficiency**
- **CPU Utilization**: 20% of available (well within limits)
- **Memory Utilization**: 22% of available (well within limits)
- **Storage**: 10Gi total (reduced from 20Gi)

---

## 🔧 **Implementation Steps**

### **1. Create Optimized Values File**
```bash
# Copy and modify the values file
cp monitoring/prometheus/values.yaml monitoring/prometheus/values-optimized.yaml
# Edit the file to reduce resource requirements
```

### **2. Create Fixed Deployment Script**
```bash
# Create the enhanced deployment script
cp scripts/monitoring/deploy-prometheus-stack.sh scripts/monitoring/deploy-prometheus-stack-fixed.sh
# Add resource validation and better timeout handling
```

### **3. Create Cleanup Script**
```bash
# Create cleanup script for failed deployments
touch scripts/monitoring/cleanup-monitoring-stack.sh
# Add cleanup and recovery functions
```

### **4. Test Deployment**
```bash
# Run the fixed deployment
./scripts/monitoring/deploy-prometheus-stack-fixed.sh
```

---

## ✅ **Success Criteria**

### **Deployment Success**
- [ ] All pods start within 15 minutes
- [ ] No resource-related timeouts
- [ ] All services accessible
- [ ] Monitoring data collection working

### **Resource Efficiency**
- [ ] CPU usage < 50% of cluster capacity
- [ ] Memory usage < 50% of cluster capacity
- [ ] Storage usage < 20Gi total
- [ ] No resource pressure on nodes

### **Operational Health**
- [ ] Prometheus scraping metrics successfully
- [ ] Grafana dashboards loading
- [ ] AlertManager receiving alerts
- [ ] No pod restarts due to resource issues

---

## 🚨 **Troubleshooting Guide**

### **If Deployment Still Times Out**

1. **Check Resource Availability**
   ```bash
   kubectl describe nodes | grep -A 10 "Allocated resources"
   ```

2. **Check for Stuck PVCs**
   ```bash
   kubectl get pvc -n monitoring
   kubectl describe pvc <pvc-name> -n monitoring
   ```

3. **Check Pod Events**
   ```bash
   kubectl get events -n monitoring --sort-by='.lastTimestamp'
   ```

4. **Force Cleanup and Retry**
   ```bash
   ./scripts/monitoring/cleanup-monitoring-stack.sh
   sleep 60
   ./scripts/monitoring/deploy-prometheus-stack-fixed.sh
   ```

### **If Resources Are Still Insufficient**

1. **Scale Up Cluster**
   ```bash
   # Add more nodes or increase node size
   aws eks update-nodegroup-config --cluster-name healthcare-eks-stage3-dev \
     --nodegroup-name healthcare-nodes --scaling-config minSize=3,maxSize=5
   ```

2. **Use Minimal Monitoring**
   ```bash
   # Deploy only essential components
   helm install minimal-monitoring prometheus-community/kube-prometheus-stack \
     --set prometheus.enabled=false \
     --set grafana.enabled=true \
     --set alertmanager.enabled=false
   ```

---

## 📋 **Next Steps**

1. **Immediate**: Implement the optimized deployment script
2. **Short-term**: Test deployment with reduced resources
3. **Medium-term**: Monitor resource usage and adjust as needed
4. **Long-term**: Consider cluster scaling for production workloads

---

**Status**: 🔴 **Critical - Requires Immediate Action**
**Priority**: 🚨 **High - Blocking Monitoring Implementation**
**Estimated Fix Time**: 30-60 minutes


