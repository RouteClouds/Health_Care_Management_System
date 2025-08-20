# 🔗 Application Load Balancer (ALB) Configuration Guide

## **Overview**

This guide ensures that Stage-3 infrastructure creates **only Application Load Balancers (ALBs)** instead of Classic or Network Load Balancers, which are more expensive and less feature-rich.

## **🚨 Previous Issues Fixed**

### **Problems Found:**
1. **Classic Load Balancer**: Created by old frontend services with `type: LoadBalancer`
2. **Network Load Balancer**: Created by Grafana monitoring with `type: LoadBalancer`

### **Root Causes:**
- Services using `type: LoadBalancer` without ALB annotations
- Missing AWS Load Balancer Controller configuration
- Grafana configured with LoadBalancer service type

## **✅ Current ALB Configuration**

### **1. AWS Load Balancer Controller**
The AWS Load Balancer Controller is installed via Helm:
```bash
# Installed in kube-system namespace
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  --set clusterName=healthcare-eks-stage3-dev \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller
```

### **2. Service Configuration (ClusterIP)**
All services now use `ClusterIP` type:

```yaml
# Frontend Service
apiVersion: v1
kind: Service
metadata:
  name: frontend-stage3-svc
spec:
  type: ClusterIP  # ✅ No LoadBalancer
  ports:
  - port: 80
    targetPort: 80
```

### **3. ALB Ingress Configuration**
ALBs are created via Ingress resources:

```yaml
# Main Application Ingress
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: healthcare-stage3-ingress
  annotations:
    kubernetes.io/ingress.class: alb
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTP":80}]'
spec:
  ingressClassName: alb
  rules:
  - host: healthcare-stage3.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: frontend-stage3-svc
            port:
              number: 80
```

### **4. Grafana ALB Configuration**
Grafana now uses ClusterIP + ALB Ingress:

```yaml
# Grafana Service (ClusterIP)
service:
  type: ClusterIP  # ✅ Changed from LoadBalancer

# Grafana Ingress (ALB)
ingress:
  enabled: true
  ingressClassName: alb
  annotations:
    kubernetes.io/ingress.class: alb
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip
```

## **🔧 Configuration Files Updated**

### **Files Modified:**
1. `monitoring/prometheus/values-optimized.yaml` - Grafana service type
2. `monitoring/prometheus/values-runtime.yaml` - Grafana service type  
3. `gitops/environments/dev/grafana-ingress.yaml` - New ALB ingress
4. `.github/workflows/stage3-ci.yml` - Apply Grafana ingress

### **Files to Avoid:**
- `k8s/frontend-deployment.yaml` (Stage-1 legacy)
- Any service with `type: LoadBalancer`
- Any service with `aws-load-balancer-type: "nlb"` annotations

## **🚀 Deployment Process**

### **1. Infrastructure Creation**
```bash
# Terraform creates VPC, EKS, RDS
terraform apply

# Install AWS Load Balancer Controller
./scripts/deployment/install-aws-load-balancer-controller.sh
```

### **2. Application Deployment**
```bash
# Deploy applications (ClusterIP services)
kubectl apply -f gitops/environments/dev/

# Deploy ALB ingresses
kubectl apply -f gitops/environments/dev/ingress.yaml
kubectl apply -f gitops/environments/dev/grafana-ingress.yaml
```

### **3. Verification**
```bash
# Check ALBs created
aws elbv2 describe-load-balancers --query 'LoadBalancers[?Type==`application`]'

# Check no Classic/Network LBs
aws elb describe-load-balancers  # Should be empty
aws elbv2 describe-load-balancers --query 'LoadBalancers[?Type==`network`]'  # Should be empty
```

## **💰 Cost Benefits**

### **ALB vs Classic/Network LB:**
- **ALB**: $0.0225/hour (~$16/month) + $0.008/LCU
- **Classic LB**: $0.025/hour (~$18/month) + data processing
- **Network LB**: $0.0225/hour (~$16/month) + $0.006/NLCU

### **Additional ALB Benefits:**
- ✅ HTTP/HTTPS routing
- ✅ Path-based routing
- ✅ Host-based routing
- ✅ WebSocket support
- ✅ HTTP/2 support
- ✅ Better health checks
- ✅ Integration with AWS WAF
- ✅ SSL termination

## **🔍 Troubleshooting**

### **Check Current Load Balancers:**
```bash
# Run comprehensive LB discovery
./scripts/cleanup/find-all-load-balancers.sh
```

### **Clean Up Wrong LB Types:**
```bash
# Remove Classic/Network LBs
./scripts/cleanup/final-orphaned-cleanup.sh
```

### **Verify ALB Controller:**
```bash
# Check controller status
kubectl get deployment aws-load-balancer-controller -n kube-system
kubectl logs -n kube-system deployment/aws-load-balancer-controller
```

### **Check Ingress Status:**
```bash
# Check ingress resources
kubectl get ingress -A
kubectl describe ingress healthcare-stage3-ingress -n healthcare-stage3-dev
kubectl describe ingress grafana-stage3-ingress -n monitoring
```

## **🎯 Best Practices**

### **DO:**
- ✅ Use `type: ClusterIP` for all services
- ✅ Create ALBs via Ingress resources
- ✅ Use AWS Load Balancer Controller
- ✅ Tag ALBs for cost tracking
- ✅ Use path-based routing when possible

### **DON'T:**
- ❌ Use `type: LoadBalancer` without ALB annotations
- ❌ Create Classic Load Balancers
- ❌ Use Network Load Balancers unless TCP/UDP required
- ❌ Skip AWS Load Balancer Controller installation

## **📋 Checklist for New Deployments**

- [ ] AWS Load Balancer Controller installed
- [ ] All services use `type: ClusterIP`
- [ ] Ingress resources have ALB annotations
- [ ] No `type: LoadBalancer` services
- [ ] No Classic/Network LBs created
- [ ] ALB health checks configured
- [ ] Cost tracking tags applied

This configuration ensures cost-effective, feature-rich load balancing using only Application Load Balancers.
