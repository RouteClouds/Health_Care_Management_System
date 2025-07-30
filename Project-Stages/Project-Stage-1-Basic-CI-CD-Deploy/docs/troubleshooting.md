# 🔧 Stage 1 Troubleshooting Guide
## Health Care Management System - Basic CI/CD Deployment

### 🎯 Overview
This guide provides solutions to common issues encountered during Stage 1 implementation.

---

## 🛠️ Tool Installation Issues

### **Docker Installation Problems**

#### **Issue: Permission Denied**
```bash
# Error: permission denied while trying to connect to Docker daemon
# Solution: Add user to docker group and restart session
sudo usermod -aG docker $USER
# Log out and log back in, or run:
newgrp docker
```

#### **Issue: Docker Service Not Running**
```bash
# Error: Cannot connect to the Docker daemon
# Solution: Start Docker service
sudo systemctl start docker
sudo systemctl enable docker
```

### **kubectl Installation Problems**

#### **Issue: Version Mismatch**
```bash
# Error: kubectl version doesn't match EKS version
# Solution: Your kubectl v1.33.3 is perfect for EKS 1.32!
# No action needed - kubectl supports ±1 version skew
kubectl version --short
# Should show: Client v1.33.3, Server v1.32.x
```

#### **Issue: kubectl Not Found**
```bash
# Error: kubectl: command not found
# Solution: Check PATH and reinstall
echo $PATH
which kubectl
# Reinstall if needed
sudo install kubectl /usr/local/bin/kubectl
```

### **AWS CLI Issues**

#### **Issue: AWS CLI v1 Installed**
```bash
# Error: Old AWS CLI version
# Solution: Remove v1 and install v2
sudo apt remove awscli
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

#### **Issue: Credentials Not Configured**
```bash
# Error: Unable to locate credentials
# Solution: Configure AWS credentials
aws configure
# Or set environment variables
export AWS_ACCESS_KEY_ID=your-key
export AWS_SECRET_ACCESS_KEY=your-secret
export AWS_DEFAULT_REGION=us-east-1
```

---

## ☁️ AWS EKS Issues

### **Cluster Creation Problems**

#### **Issue: Insufficient IAM Permissions**
```bash
# Error: User is not authorized to perform eks:CreateCluster
# Solution: Attach required IAM policies
# Required policies:
# - AmazonEKSClusterPolicy
# - AmazonEKSWorkerNodePolicy
# - AmazonEKS_CNI_Policy
# - AmazonEC2ContainerRegistryReadOnly
# - Custom policy with additional permissions (see setup guide)
```

#### **Issue: VPC Limits Exceeded**
```bash
# Error: VPC limit exceeded
# Solution: Delete unused VPCs or request limit increase
aws ec2 describe-vpcs --region us-east-1
aws ec2 delete-vpc --vpc-id vpc-xxxxxxxx
```

#### **Issue: Cluster Creation Timeout**
```bash
# Error: Cluster creation takes too long
# Solution: Check CloudFormation stack status
aws cloudformation describe-stacks --region us-east-1
# Monitor in AWS Console: CloudFormation > Stacks
```

### **Node Group Issues**

#### **Issue: Nodes Not Joining Cluster**
```bash
# Error: Nodes stuck in NotReady state
# Solution: Check node group status
eksctl get nodegroup --cluster healthcare-cluster --region us-east-1
kubectl get nodes
kubectl describe nodes

# Check node logs
aws logs describe-log-groups --region us-east-1
```

#### **Issue: Instance Type Not Available**
```bash
# Error: Insufficient capacity for instance type
# Solution: Try different instance type or availability zone
eksctl create nodegroup \
  --cluster healthcare-cluster \
  --name healthcare-nodes-alt \
  --node-type t3.small \
  --region us-east-1
```

---

## 🐳 Docker Issues

### **Image Build Problems**

#### **Issue: Build Context Too Large**
```bash
# Error: Build context is too large
# Solution: Use .dockerignore file
echo "node_modules" >> .dockerignore
echo ".git" >> .dockerignore
echo "*.log" >> .dockerignore
```

#### **Issue: Out of Disk Space**
```bash
# Error: No space left on device
# Solution: Clean up Docker resources
docker system prune -a -f
docker volume prune -f
df -h
```

### **Image Push Problems**

#### **Issue: Authentication Failed**
```bash
# Error: unauthorized: authentication required
# Solution: Login to Docker Hub
docker login
# Enter username and password
```

#### **Issue: Repository Not Found**
```bash
# Error: repository does not exist
# Solution: Create repository on Docker Hub first
# Go to https://hub.docker.com and create repositories:
# - your-username/healthcare-frontend
# - your-username/healthcare-backend
```

---

## 🚀 Deployment Issues

### **Pod Startup Problems**

#### **Issue: ImagePullBackOff**
```bash
# Error: Failed to pull image
# Solution: Check image name and accessibility
kubectl describe pod <pod-name> -n healthcare
# Verify image exists and is public
docker pull your-username/healthcare-frontend:v1.0
```

#### **Issue: CrashLoopBackOff**
```bash
# Error: Pod keeps restarting
# Solution: Check pod logs and configuration
kubectl logs <pod-name> -n healthcare
kubectl describe pod <pod-name> -n healthcare
# Common causes:
# - Wrong environment variables
# - Missing dependencies
# - Port conflicts
```

#### **Issue: Pending Pods**
```bash
# Error: Pods stuck in Pending state
# Solution: Check resource availability
kubectl describe pod <pod-name> -n healthcare
kubectl get nodes
kubectl top nodes
# Common causes:
# - Insufficient CPU/memory
# - Node selector issues
# - Volume mounting problems
```

### **Service Access Problems**

#### **Issue: External IP Pending**
```bash
# Error: LoadBalancer external IP shows <pending>
# Solution: Wait for AWS Load Balancer provisioning (5-10 minutes)
kubectl get service frontend-service -n healthcare -w
# Check AWS Console: EC2 > Load Balancers
```

#### **Issue: Service Not Accessible**
```bash
# Error: Cannot access application via external IP
# Solution: Check service configuration and security groups
kubectl describe service frontend-service -n healthcare
kubectl get endpoints -n healthcare
# Test internal connectivity
kubectl exec -it <pod-name> -n healthcare -- curl http://backend-service:3002/api/health
```

### **Database Connection Issues**

#### **Issue: Backend Cannot Connect to Database**
```bash
# Error: Connection refused to postgres-service
# Solution: Check database pod and service
kubectl get pods -n healthcare | grep postgres
kubectl logs deployment/postgres-db -n healthcare
kubectl get service postgres-service -n healthcare
kubectl get endpoints postgres-service -n healthcare
```

#### **Issue: Database Initialization Failed**
```bash
# Error: Database not ready
# Solution: Check database logs and environment variables
kubectl logs deployment/postgres-db -n healthcare
kubectl describe deployment postgres-db -n healthcare
# Verify environment variables match between backend and database
```

---

## 🔍 Debugging Commands

### **General Debugging**
```bash
# Get comprehensive status
kubectl get all -n healthcare

# Check events
kubectl get events -n healthcare --sort-by='.lastTimestamp'

# Describe resources
kubectl describe deployment <deployment-name> -n healthcare
kubectl describe pod <pod-name> -n healthcare
kubectl describe service <service-name> -n healthcare
```

### **Log Analysis**
```bash
# View logs
kubectl logs deployment/<deployment-name> -n healthcare
kubectl logs <pod-name> -n healthcare

# Follow logs in real-time
kubectl logs -f deployment/<deployment-name> -n healthcare

# Get previous container logs (if pod restarted)
kubectl logs <pod-name> -n healthcare --previous
```

### **Network Debugging**
```bash
# Test internal connectivity
kubectl exec -it <pod-name> -n healthcare -- /bin/sh
# Inside pod:
curl http://backend-service:3002/api/health
nslookup backend-service
ping postgres-service

# Port forwarding for local testing
kubectl port-forward service/backend-service 3002:3002 -n healthcare
kubectl port-forward service/frontend-service 8080:80 -n healthcare
```

---

## 💰 Cost Issues

### **Unexpected High Costs**

#### **Issue: Higher Than Expected AWS Charges**
```bash
# Solution: Check resource usage and optimize
# 1. Check running instances
aws ec2 describe-instances --region us-east-1 --query 'Reservations[*].Instances[*].[InstanceId,InstanceType,State.Name]'

# 2. Check load balancers
aws elbv2 describe-load-balancers --region us-east-1

# 3. Use AWS Cost Explorer
# Go to AWS Console > Billing > Cost Explorer

# 4. Set up billing alerts
aws budgets create-budget --account-id $(aws sts get-caller-identity --query Account --output text) --budget file://budget.json
```

#### **Issue: Resources Not Cleaned Up**
```bash
# Solution: Verify all resources are deleted
eksctl get cluster --region us-east-1
aws ec2 describe-instances --region us-east-1 --filters "Name=instance-state-name,Values=running"
aws elbv2 describe-load-balancers --region us-east-1
```

---

## 🔧 Performance Issues

### **Slow Application Response**

#### **Issue: High Response Times**
```bash
# Solution: Check resource usage and scaling
kubectl top nodes
kubectl top pods -n healthcare

# Check pod resource limits
kubectl describe pod <pod-name> -n healthcare | grep -A 5 Limits

# Scale deployments if needed
kubectl scale deployment healthcare-backend --replicas=3 -n healthcare
kubectl scale deployment healthcare-frontend --replicas=3 -n healthcare
```

#### **Issue: Database Performance**
```bash
# Solution: Check database resources and connections
kubectl logs deployment/postgres-db -n healthcare
kubectl exec -it <postgres-pod> -n healthcare -- psql -U healthcare_user -d healthcare_db -c "SELECT * FROM pg_stat_activity;"

# Note: We use PostgreSQL 16-alpine which provides:
# • Better performance than PostgreSQL 15
# • Enhanced query optimization
# • Improved indexing capabilities
# • Perfect compatibility with your system PostgreSQL 16.9
```

---

## 🆘 Emergency Procedures

### **Complete System Failure**

#### **Nuclear Option: Full Cleanup and Restart**
```bash
# 1. Delete everything
./scripts/cleanup.sh

# 2. Wait for complete cleanup (10-15 minutes)
watch -n 30 'eksctl get cluster --region us-east-1'

# 3. Start fresh
./scripts/setup-tools.sh
aws configure
# Follow setup guide from beginning
```

### **Partial Recovery**

#### **Application Only Reset**
```bash
# Delete application but keep cluster
kubectl delete namespace healthcare

# Redeploy application
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/database-deployment.yaml
kubectl apply -f k8s/backend-deployment.yaml
kubectl apply -f k8s/frontend-deployment.yaml
```

---

## 📞 Getting Help

### **Useful Resources**
- **AWS EKS Documentation**: https://docs.aws.amazon.com/eks/
- **Kubernetes Documentation**: https://kubernetes.io/docs/
- **Docker Documentation**: https://docs.docker.com/
- **eksctl Documentation**: https://eksctl.io/

### **Community Support**
- **AWS Forums**: https://forums.aws.amazon.com/
- **Kubernetes Slack**: https://kubernetes.slack.com/
- **Stack Overflow**: Use tags `amazon-eks`, `kubernetes`, `docker`

### **AWS Support**
- **Basic Support**: Included with AWS account
- **Developer Support**: $29/month
- **Business Support**: $100/month

---

## 🎯 Prevention Tips

### **Best Practices**
1. **Always verify tool versions** before starting
2. **Check AWS service limits** before creating resources
3. **Monitor costs regularly** during deployment
4. **Keep backups** of working configurations
5. **Document customizations** for future reference
6. **Test in smaller environments** first
7. **Use version control** for all configuration files

### **Monitoring Setup**
```bash
# Set up basic monitoring
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# Check metrics
kubectl top nodes
kubectl top pods -n healthcare
```

---

## 🎉 Success Indicators

### **Healthy System Checklist**
- [ ] All pods in Running state
- [ ] External IP assigned to frontend service
- [ ] Application accessible via browser
- [ ] All health checks passing
- [ ] No error messages in logs
- [ ] Resource usage within limits
- [ ] AWS costs as expected

**If all items are checked, your Stage 1 deployment is successful!** 🚀
