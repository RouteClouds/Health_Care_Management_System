# 🛠️ **Stage 2 Operations Guide**
## **Healthcare Management System - CI/CD Pipeline Operations & Maintenance**

### **🎯 Purpose**

This guide covers **operational procedures** for Stage 2 automated CI/CD pipeline including workflow monitoring, environment management, deployment strategies, and maintenance procedures.

**Use this guide for**:
- 📊 Pipeline monitoring and health checks
- 🌍 Environment management (Dev, Staging, Production)
- 🔄 Deployment strategies and rollback procedures
- 🧹 Pipeline maintenance and optimization

---

## **📊 Pipeline Monitoring & Health Checks**

### **🔍 Workflow Status Monitoring**

#### **GitHub Actions Dashboard**
```bash
# View all workflow runs
gh run list --limit 20

# View specific workflow runs
gh run list --workflow=ci-cd-pipeline.yml

# View workflow details
gh run view <run-id>

# View workflow logs
gh run view <run-id> --log

# Download workflow logs
gh run download <run-id>
```

#### **Real-time Monitoring**
```bash
# Watch workflow status
gh run watch <run-id>

# Monitor specific job
gh run view <run-id> --job=<job-id> --log

# Check workflow triggers
gh api repos/:owner/:repo/actions/runs --jq '.workflow_runs[0:5] | .[] | {id, status, conclusion, event, head_branch}'
```

### **📈 Pipeline Metrics**

#### **Success Rate Monitoring**
```bash
# Get workflow success rate (last 30 runs)
gh api repos/:owner/:repo/actions/runs --jq '
  .workflow_runs[0:30] | 
  group_by(.conclusion) | 
  map({conclusion: .[0].conclusion, count: length}) | 
  sort_by(.count) | 
  reverse'

# Average build time
gh api repos/:owner/:repo/actions/runs --jq '
  .workflow_runs[0:10] | 
  map((.updated_at | strptime("%Y-%m-%dT%H:%M:%SZ") | mktime) - (.created_at | strptime("%Y-%m-%dT%H:%M:%SZ") | mktime)) | 
  add / length'
```

#### **Deployment Frequency**
```bash
# Deployments per day (last 7 days)
gh api repos/:owner/:repo/actions/runs --jq '
  .workflow_runs[] | 
  select(.conclusion == "success" and .name == "CI/CD Pipeline") | 
  .created_at | 
  strptime("%Y-%m-%dT%H:%M:%SZ") | 
  strftime("%Y-%m-%d")' | 
  sort | uniq -c
```

---

## **🌍 Environment Management**

### **🔧 Development Environment**

#### **Auto-deployment Configuration**
```bash
# Development environment deploys automatically on main branch push
# Configuration in .github/workflows/ci-cd-pipeline.yml

deploy-dev:
  needs: build
  runs-on: ubuntu-latest
  environment: development
  if: github.ref == 'refs/heads/main'
  
  steps:
  - name: Deploy to development
    run: |
      kubectl apply -f k8s/development/ -n healthcare-dev
      kubectl rollout status deployment/healthcare-backend -n healthcare-dev
```

#### **Development Environment Health Check**
```bash
# Check development deployment
kubectl get pods -n healthcare-dev
kubectl get services -n healthcare-dev

# Test development application
DEV_URL=$(kubectl get service frontend-service -n healthcare-dev -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
curl -s $DEV_URL/api/health | jq '.'

# View development logs
kubectl logs -l app=healthcare-backend -n healthcare-dev --tail=50
```

### **🧪 Staging Environment**

#### **Manual Deployment Trigger**
```bash
# Trigger staging deployment manually
gh workflow run ci-cd-pipeline.yml -f environment=staging

# Deploy specific commit to staging
gh workflow run deploy.yml -f environment=staging -f commit_sha=abc123

# Check staging deployment status
gh run list --workflow=ci-cd-pipeline.yml | grep staging
```

#### **Staging Environment Verification**
```bash
# Comprehensive staging verification
kubectl get all -n healthcare-staging

# Run E2E tests against staging
cd src-code
npm run test:e2e -- --env staging

# Performance testing
curl -w "@curl-format.txt" -o /dev/null -s http://staging-url/api/health
```

### **🚀 Production Environment**

#### **Production Deployment Process**
```bash
# 1. Verify staging is healthy
kubectl get pods -n healthcare-staging
curl -s http://staging-url/api/health

# 2. Create production deployment PR
gh pr create --title "Deploy to Production" --body "Staging verified, ready for production"

# 3. Manual approval required (configured in GitHub Environments)
# 4. Deploy to production
gh workflow run deploy.yml -f environment=production -f commit_sha=$(git rev-parse HEAD)

# 5. Verify production deployment
kubectl get pods -n healthcare-prod
curl -s http://production-url/api/health
```

#### **Production Health Monitoring**
```bash
# Production health dashboard
kubectl top pods -n healthcare-prod
kubectl get hpa -n healthcare-prod

# Application metrics
curl -s http://production-url/metrics | grep -E "(response_time|error_rate|throughput)"

# Database health
kubectl exec -it postgres-pod -n healthcare-prod -- pg_isready
```

---

## **🔄 Deployment Strategies & Rollback Procedures**

### **🚀 Deployment Strategies**

#### **Rolling Deployment (Default)**
```bash
# Rolling deployment configuration in k8s manifests
spec:
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1
      maxSurge: 1

# Monitor rolling deployment
kubectl rollout status deployment/healthcare-backend -n healthcare-prod --timeout=300s
```

#### **Blue-Green Deployment**
```bash
# Blue-green deployment script
./scripts/blue-green-deploy.sh production v2.0

# Switch traffic to new version
kubectl patch service frontend-service -n healthcare-prod -p '{"spec":{"selector":{"version":"v2.0"}}}'

# Verify new version
curl -s http://production-url/api/version
```

#### **Canary Deployment**
```bash
# Deploy canary version (10% traffic)
kubectl apply -f k8s/canary/canary-deployment.yaml -n healthcare-prod

# Monitor canary metrics
kubectl get pods -l version=canary -n healthcare-prod
kubectl logs -l version=canary -n healthcare-prod

# Promote canary to full deployment
./scripts/promote-canary.sh production
```

### **🔙 Rollback Procedures**

#### **Automatic Rollback**
```bash
# Configure automatic rollback in deployment
spec:
  progressDeadlineSeconds: 600
  revisionHistoryLimit: 10

# Automatic rollback triggers:
# - Health check failures
# - Deployment timeout
# - Error rate threshold exceeded
```

#### **Manual Rollback**
```bash
# View deployment history
kubectl rollout history deployment/healthcare-backend -n healthcare-prod

# Rollback to previous version
kubectl rollout undo deployment/healthcare-backend -n healthcare-prod

# Rollback to specific revision
kubectl rollout undo deployment/healthcare-backend -n healthcare-prod --to-revision=3

# Verify rollback
kubectl rollout status deployment/healthcare-backend -n healthcare-prod
```

#### **Emergency Rollback**
```bash
# Emergency rollback script
./scripts/emergency-rollback.sh production

# This script:
# 1. Immediately scales down new version
# 2. Scales up previous version
# 3. Updates service selectors
# 4. Verifies application health
# 5. Sends notifications
```

---

## **🧹 Pipeline Maintenance & Optimization**

### **🔧 Workflow Optimization**

#### **Build Performance**
```bash
# Enable build caching
- name: Cache Docker layers
  uses: actions/cache@v3
  with:
    path: /tmp/.buildx-cache
    key: ${{ runner.os }}-buildx-${{ github.sha }}
    restore-keys: |
      ${{ runner.os }}-buildx-

# Parallel job execution
jobs:
  test:
    strategy:
      matrix:
        node-version: [18, 20]
        test-type: [unit, integration]
```

#### **Resource Optimization**
```bash
# Optimize runner resources
runs-on: ubuntu-latest-4-cores  # For faster builds

# Use self-hosted runners for cost optimization
runs-on: [self-hosted, linux, x64]

# Conditional job execution
if: github.event_name == 'push' && github.ref == 'refs/heads/main'
```

### **📊 Performance Monitoring**

#### **Build Time Analysis**
```bash
# Analyze build times
gh api repos/:owner/:repo/actions/runs --jq '
  .workflow_runs[0:20] | 
  map({
    id: .id,
    duration: ((.updated_at | strptime("%Y-%m-%dT%H:%M:%SZ") | mktime) - (.created_at | strptime("%Y-%m-%dT%H:%M:%SZ") | mktime)),
    conclusion: .conclusion
  }) | 
  sort_by(.duration)'

# Identify slow jobs
gh run view <run-id> --json jobs --jq '.jobs[] | {name: .name, duration: .conclusion_time}'
```

#### **Resource Usage Monitoring**
```bash
# Monitor GitHub Actions usage
gh api user/settings/billing/actions

# Monitor runner usage
gh api repos/:owner/:repo/actions/runners

# Cost optimization recommendations
gh api repos/:owner/:repo/actions/runs --jq '
  .workflow_runs[0:100] | 
  map(select(.conclusion == "success")) | 
  length as $successful |
  map(select(.conclusion == "failure")) | 
  length as $failed |
  {success_rate: ($successful / ($successful + $failed) * 100)}'
```

---

## **🚨 Incident Response & Troubleshooting**

### **🔍 Common Issues & Quick Fixes**

#### **Pipeline Failures**
```bash
# Quick diagnosis
gh run list --status=failure --limit=5

# View failure details
gh run view <failed-run-id> --log | grep -i error

# Retry failed workflow
gh run rerun <run-id>

# Retry specific job
gh run rerun <run-id> --job=<job-id>
```

#### **Deployment Issues**
```bash
# Check deployment status
kubectl get events -n healthcare-prod --sort-by='.lastTimestamp' | tail -10

# Debug pod issues
kubectl describe pod <pod-name> -n healthcare-prod
kubectl logs <pod-name> -n healthcare-prod --previous

# Service connectivity issues
kubectl exec -it <pod-name> -n healthcare-prod -- nslookup backend-service
```

### **🆘 Emergency Procedures**
For complex issues, refer to the comprehensive troubleshooting guide:
📖 [STAGE-2-TROUBLESHOOTING-REFERENCE.md](./STAGE-2-TROUBLESHOOTING-REFERENCE.md)

**Emergency Quick Links**:
- **Pipeline failures**: [Issue #1](./STAGE-2-TROUBLESHOOTING-REFERENCE.md#issue-1)
- **Build failures**: [Issue #2](./STAGE-2-TROUBLESHOOTING-REFERENCE.md#issue-2)
- **Test failures**: [Issue #3](./STAGE-2-TROUBLESHOOTING-REFERENCE.md#issue-3)
- **Deployment failures**: [Issue #4](./STAGE-2-TROUBLESHOOTING-REFERENCE.md#issue-4)

---

## **📈 Operational Metrics & KPIs**

### **Pipeline Performance KPIs**
- **Build Success Rate**: Target >95%
- **Average Build Time**: Target <10 minutes
- **Deployment Frequency**: Target >5 deployments/day
- **Lead Time**: Target <2 hours (commit to production)
- **Mean Time to Recovery**: Target <30 minutes

### **Application Performance KPIs**
- **Deployment Success Rate**: Target >98%
- **Rollback Rate**: Target <5%
- **Application Uptime**: Target >99.9%
- **Response Time**: Target <2 seconds
- **Error Rate**: Target <1%

---

## **🔗 Cross-References**

### **Related Documentation**
- **Setup Guide**: [STAGE-2-MASTER-GUIDE.md](./STAGE-2-MASTER-GUIDE.md)
- **Troubleshooting**: [STAGE-2-TROUBLESHOOTING-REFERENCE.md](./STAGE-2-TROUBLESHOOTING-REFERENCE.md)
- **Documentation Index**: [STAGE-2-INDEX.md](./STAGE-2-INDEX.md)

### **External Resources**
- **GitHub Actions Monitoring**: [GitHub Actions Documentation](https://docs.github.com/en/actions/monitoring-and-troubleshooting-workflows)
- **Kubernetes Operations**: [Kubernetes Best Practices](https://kubernetes.io/docs/concepts/cluster-administration/)
- **CI/CD Metrics**: [DORA Metrics](https://cloud.google.com/blog/products/devops-sre/using-the-four-keys-to-measure-your-devops-performance)

---

**Operations Guide Version**: 1.0  
**Last Updated**: August 1, 2025  
**Coverage**: Pipeline monitoring, environment management, deployment strategies  
**Reliability**: Production-tested operational procedures
