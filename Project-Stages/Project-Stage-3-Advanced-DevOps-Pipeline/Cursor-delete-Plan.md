## Stage-3 Resource Deletion and Cleanup Plan

This plan guides a safe, systematic deletion of duplicate/stray AWS resources created during prior failed runs. It also outlines config changes to standardize on AWS Application Load Balancer (ALB) and avoid Classic/NLB usage.

### Goals
- Remove duplicate VPCs, subnets, NAT gateways, internet gateways, EKS, RDS, ELBs
- Standardize ingress to ALB via Kubernetes Ingress
- Ensure cleanup scripts delete older resources, not just the latest

### High-level Order (to respect dependencies)
1) Application-level cleanup (Kubernetes)
2) Load balancers and target groups
3) EKS (node groups → cluster)
4) RDS (instances → subnet groups → parameter groups)
5) ECR (optional if repos should be kept)
6) VPC networking (NAT gateways → route tables → subnets → IGW → VPC)
7) CloudWatch log groups and KMS aliases/keys (if provisioned)
8) S3 buckets used for assets (optional) and Terraform state (only after moving/archiving state)

### Identification: Duplicate Resources
- VPCs: filter by project tags and names (e.g., healthcare-stage3, stage3, healthcare-eks-stage3-dev)
- Subnets/NAT/IGW/Route tables: discover via VPC IDs
- Load balancers: list all (classic/NLB/ALB); keep only the ALB owned by Ingress
- EKS: list clusters matching naming prefix; confirm the one referenced by current kubeconfig is the keeper
- RDS: list instances with identifier prefix `healthcare-eks-stage3-dev-db`; keep the one referenced by Terraform/current deployment
- S3: asset buckets and terraform state buckets; do not delete the active backend bucket unless migrating state

### Concrete Commands (read-only discovery)
```bash
# VPCs (tag/name contains healthcare or stage3)
aws ec2 describe-vpcs --filters "Name=tag:Name,Values=*healthcare*" --query 'Vpcs[].{VpcId:VpcId,Name:Tags[?Key==`Name`]|[0].Value}' --output table

# Subnets per VPC
aws ec2 describe-subnets --filters Name=vpc-id,Values=<vpc-abc> --query 'Subnets[].{SubnetId:SubnetId,CIDR:CidrBlock,Name:Tags[?Key==`Name`]|[0].Value}' --output table

# Internet/NAT gateways
aws ec2 describe-internet-gateways --filters Name=attachment.vpc-id,Values=<vpc-abc>
aws ec2 describe-nat-gateways --filter Name=vpc-id,Values=<vpc-abc> --query 'NatGateways[].{Id:NatGatewayId,State:State}' --output table

# Load balancers
aws elb describe-load-balancers --output table   # Classic
aws elbv2 describe-load-balancers --output table # ALB/NLB

# EKS
aws eks list-clusters --output table

# RDS
aws rds describe-db-instances --query 'DBInstances[?contains(DBInstanceIdentifier, `healthcare-eks-stage3-dev-db`)].{Id:DBInstanceIdentifier,Status:DBInstanceStatus}' --output table

# CloudWatch log groups
aws logs describe-log-groups --log-group-name-prefix '/aws/eks/healthcare-eks-stage3-dev' --output table
```

### Deletion Order and Commands (example per VPC you decide to delete)
1) Delete dependent compute and LBs tied to the VPC:
```bash
# For each unwanted ALB/NLB in the VPC
aws elbv2 describe-load-balancers --query 'LoadBalancers[?VpcId==`<vpc-abc>`].LoadBalancerArn' --output text | xargs -r -n1 aws elbv2 delete-load-balancer --load-balancer-arn

# For classic ELBs in the VPC (map names first)
aws elb describe-load-balancers --query 'LoadBalancerDescriptions[].{Name:LoadBalancerName,VPC:VPCId}' --output text | awk '$2=="<vpc-abc>"{print $1}' | xargs -r -n1 aws elb delete-load-balancer --load-balancer-name
```

2) EKS cluster(s) (AFTER you are sure which cluster to keep):
```bash
# Node groups first
for ng in $(aws eks list-nodegroups --cluster-name <cluster> --output text); do
  aws eks delete-nodegroup --cluster-name <cluster> --nodegroup-name "$ng"
  aws eks wait nodegroup-deleted --cluster-name <cluster> --nodegroup-name "$ng"
done

# Cluster
aws eks delete-cluster --name <cluster>
aws eks wait cluster-deleted --name <cluster>
```

3) RDS instance(s):
```bash
aws rds delete-db-instance --db-instance-identifier <db-id> --skip-final-snapshot --delete-automated-backups
aws rds wait db-instance-deleted --db-instance-identifier <db-id>

# Then related subnet groups if orphaned
aws rds delete-db-subnet-group --db-subnet-group-name <subnet-group>
```

4) VPC networking (sequence matters):
```bash
# Detach & delete IGW
IGW=$(aws ec2 describe-internet-gateways --filters Name=attachment.vpc-id,Values=<vpc-abc> --query 'InternetGateways[0].InternetGatewayId' --output text)
if [ "$IGW" != "None" ]; then
  aws ec2 detach-internet-gateway --internet-gateway-id "$IGW" --vpc-id <vpc-abc>
  aws ec2 delete-internet-gateway --internet-gateway-id "$IGW"
fi

# Delete NAT gateways
for nat in $(aws ec2 describe-nat-gateways --filter Name=vpc-id,Values=<vpc-abc> --query 'NatGateways[].NatGatewayId' --output text); do
  aws ec2 delete-nat-gateway --nat-gateway-id "$nat"
done
aws ec2 wait nat-gateway-available --filter Name=vpc-id,Values=<vpc-abc> || true

# Delete route tables (non-main)
for rtb in $(aws ec2 describe-route-tables --filters Name=vpc-id,Values=<vpc-abc> --query 'RouteTables[].RouteTableId' --output text); do
  # Skip main route table
  MAIN=$(aws ec2 describe-route-tables --route-table-ids "$rtb" --query 'RouteTables[0].Associations[?Main].Main' --output text)
  if [ "$MAIN" != "True" ]; then
    # Disassociate
    for assoc in $(aws ec2 describe-route-tables --route-table-ids "$rtb" --query 'RouteTables[0].Associations[].RouteTableAssociationId' --output text); do
      aws ec2 disassociate-route-table --association-id "$assoc" || true
    done
    aws ec2 delete-route-table --route-table-id "$rtb"
  fi
done

# Delete subnets
for sn in $(aws ec2 describe-subnets --filters Name=vpc-id,Values=<vpc-abc> --query 'Subnets[].SubnetId' --output text); do
  aws ec2 delete-subnet --subnet-id "$sn"
done

# Finally, delete the VPC
aws ec2 delete-vpc --vpc-id <vpc-abc>
```

5) CloudWatch Log Groups & KMS (optional):
```bash
aws logs delete-log-group --log-group-name /aws/eks/healthcare-eks-stage3-dev/cluster || true

# KMS alias example
aws kms delete-alias --alias-name alias/eks/healthcare-eks-stage3-dev || true
# If key is dedicated, schedule deletion (dangerous if shared!)
# aws kms schedule-key-deletion --key-id <key-id> --pending-window-in-days 7
```

6) S3 Buckets (assets and state) – handle with care:
```bash
# Assets
aws s3 rm s3://<assets-bucket> --recursive || true
aws s3 rb s3://<assets-bucket> --force || true

# Terraform state bucket – DO NOT DELETE if it holds active state
# Only after migrating/archiving state somewhere safe
# aws s3 rm s3://<state-bucket> --recursive
# aws s3 rb s3://<state-bucket> --force
```

### Standardize on ALB (Configuration Changes)
- Frontend Service switched to `ClusterIP` (was `LoadBalancer`).
- Added `Ingress` with `kubernetes.io/ingress.class: alb` and ALB annotations to ensure ALB is provisioned.
- Ensure AWS Load Balancer Controller is installed in the cluster.

Install ALB Controller (if missing):
```bash
helm repo add eks https://aws.github.io/eks-charts
helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=healthcare-eks-stage3-dev
```

### Improvements to Cleanup Scripts
- Enhance scripts under `scripts/cleanup/` to:
  - Accept `--all` or `--prefix <name>` to discover and delete older resources by name/tag prefix (not only the latest IDs)
  - Implement dry-run mode for review
  - Serialize deletions with waits and retries for long-running operations (EKS, NAT)
  - Log every deleted resource with timestamps

### Review Checklist Before Deletion
- Confirm which cluster and RDS to keep (if any)
- Ensure no production data loss (RDS snapshots if needed)
- Confirm Terraform state location and whether it references any of the to-be-deleted resources
- Use dry-run wherever possible

### Roll-forward After Cleanup
- Re-run pipeline; ALB Ingress should provision a single ALB
- Verify DNS/hostname and update any external references if needed
- Confirm only one VPC remains (the desired one), with sane subnets/NAT/IGW counts


