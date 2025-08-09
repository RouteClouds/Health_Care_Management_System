# 🛠️ Stage-2 EKS Cleanup Scripts Documentation

## 📍 Location
- Scripts: Project-Stages/Project-Stage-2-Automated-CI-CD-Pipeline/scripts/
- Deployment Scripts: Project-Stages/Project-Stage-2-Automated-CI-CD-Pipeline/scripts/deployment/
- Troubleshooting Reference: /home/ubuntu/Projects/Health_Care_Management_System/Troubleshoot-EKS-Cluster-Stuck.md

---

## 🎯 Purpose
These scripts mirror Stage-1 cleanup capabilities but target the Stage-2 EKS cluster (healthcare-cluster-stage2) and resource naming. Use them to fully remove EKS and dependent AWS resources so you can recreate a clean cluster and avoid ongoing costs.

---

## 📋 Scripts Overview

| Script | Purpose | Typical Use |
|-------|---------|-------------|
| diagnose-aws-resources.sh | Discover Stage-2 resources (read-only) | First step: understand current state |
| cleanup-cloudformation.sh | Main cleanup: delete stacks and dependent AWS resources | Standard cleanup |
| force-delete-failed-stack.sh | Force-remove DELETE_FAILED stack with retain | When stack blocks recreation |
| manual-cleanup-stuck-resources.sh | Advanced: delete specific stuck resources | After a failed/partial cleanup |

---

## 🚀 Usage

1) Initialize and review
```bash
cd Project-Stages/Project-Stage-2-Automated-CI-CD-Pipeline/scripts
chmod +x *.sh deployment/*.sh
./diagnose-aws-resources.sh
```

2) Main cleanup
```bash
./cleanup-cloudformation.sh
```
- Deletes nodegroup stacks first, then cluster stacks, then others
- Terminates tagged EC2 instances, deletes LBs, NAT GWs, releases EIPs
- Cleans ENIs, SGs, Subnets, IGWs, Route Tables, and VPCs
- Performs final verification

3) If stack is DELETE_FAILED
```bash
./force-delete-failed-stack.sh
```
- Uses --retain-resources for failed logical IDs to remove the stack record
- Re-run cleanup-cloudformation.sh after

4) If resources remain stuck
```bash
./manual-cleanup-stuck-resources.sh
```
- Targets Stage-2 VPCs and dependent resources directly

5) Recreate cluster
```bash
./deployment/create-eks-cluster.sh
```

---

## ⚙️ Configuration
- Default REGION: us-east-1
- Default CLUSTER_NAME: healthcare-cluster-stage2
- eksctl naming prefix: eksctl-healthcare-cluster-stage2

You can override region/cluster in manual-cleanup-stuck-resources.sh using flags:
```bash
./manual-cleanup-stuck-resources.sh --region us-east-1 --cluster healthcare-cluster-stage2
```

---

## ✅ Prerequisites
- AWS CLI v2 with credentials configured (aws sts get-caller-identity)
- Permissions for EC2, EKS, CloudFormation, ELB, VPC
- eksctl and kubectl only needed for (re)creation and verification

---

## 🔎 Verification
After cleanup:
```bash
aws eks list-clusters --region us-east-1
aws cloudformation list-stacks --region us-east-1 --stack-status-filter DELETE_FAILED DELETE_IN_PROGRESS | grep healthcare
```
Read the detailed steps and real-world resolution here:
- Troubleshoot-EKS-Cluster-Stuck.md

---

## ⚠️ Notes
- Cost hotspots: NAT Gateways and Load Balancers — scripts prioritize these
- Allow 5–10 minutes for AWS to propagate deletions; re-run cleanup if needed
- Do not create a new cluster until final verification shows clean state

