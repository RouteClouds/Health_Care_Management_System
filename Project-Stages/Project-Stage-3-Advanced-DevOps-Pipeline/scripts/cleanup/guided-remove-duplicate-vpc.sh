#!/usr/bin/env bash
set -euo pipefail

# Guided, opt-in cleanup for duplicate VPC created by prior pipeline runs
# This script DOES NOT delete anything unless you explicitly confirm.
# Usage: ./guided-remove-duplicate-vpc.sh <vpc-id-to-remove>

VPC_ID_TO_REMOVE="${1:-}"
AWS_REGION="${AWS_REGION:-us-east-1}"
CLUSTER_NAME="${CLUSTER_NAME:-healthcare-eks-stage3-dev}"
EXPECTED_VPC_NAME="${CLUSTER_NAME}-vpc"

if [[ -z "$VPC_ID_TO_REMOVE" ]]; then
  echo "Usage: $0 <vpc-id-to-remove>" >&2
  exit 2
fi

# Verify the VPC is actually a duplicate by Name tag
NAME=$(aws ec2 describe-vpcs --vpc-ids "$VPC_ID_TO_REMOVE" --region "$AWS_REGION" \
  --query 'Vpcs[0].Tags[?Key==`Name`].Value | [0]' --output text 2>/dev/null || echo "")
if [[ "$NAME" != "$EXPECTED_VPC_NAME" ]]; then
  echo "Refusing to proceed: VPC $VPC_ID_TO_REMOVE Name tag '$NAME' does not match expected '$EXPECTED_VPC_NAME'" >&2
  exit 3
fi

# Check if this VPC is referenced by any EKS cluster, ELB, RDS, or ENIs
echo "Inspecting dependent resources in $VPC_ID_TO_REMOVE ..."
ELBS=$(aws elbv2 describe-load-balancers --region "$AWS_REGION" --query 'LoadBalancers[].{Arn:LoadBalancerArn,VpcId:VpcId}' --output text | awk -v v="$VPC_ID_TO_REMOVE" '$2==v{print $1}')
ENIS=$(aws ec2 describe-network-interfaces --filters "Name=vpc-id,Values=$VPC_ID_TO_REMOVE" --region "$AWS_REGION" --query 'NetworkInterfaces[].NetworkInterfaceId' --output text)
RDS=$(aws rds describe-db-subnet-groups --region "$AWS_REGION" --query 'DBSubnetGroups[].VpcId' --output text | tr '\t' '\n' | grep -Fx "$VPC_ID_TO_REMOVE" || true)

if [[ -n "$ELBS" || -n "$ENIS" || -n "$RDS" ]]; then
  echo "VPC has dependencies and cannot be deleted safely now. Details:" >&2
  [[ -n "$ELBS" ]] && echo "  ALBs in VPC: $ELBS" >&2
  [[ -n "$ENIS" ]] && echo "  ENIs in VPC: $ENIS" >&2
  [[ -n "$RDS"  ]] && echo "  RDS subnet groups in VPC: $RDS" >&2
  echo "Resolve dependencies (delete ALBs/ENIs/DB subnet groups) before proceeding." >&2
  exit 4
fi

cat <<CONFIRM
About to delete duplicate VPC: $VPC_ID_TO_REMOVE
Region: $AWS_REGION
Cluster name (expected naming): $CLUSTER_NAME

This will:
  - Detach and delete Internet Gateway
  - Delete route tables (non-main) and routes
  - Delete subnets (public/private)
  - Delete the VPC

Type 'DELETE $VPC_ID_TO_REMOVE' to proceed: 
CONFIRM

read -r CONF
if [[ "$CONF" != "DELETE $VPC_ID_TO_REMOVE" ]]; then
  echo "Aborted by user."
  exit 0
fi

# Detach & delete IGW
IGW=$(aws ec2 describe-internet-gateways --filters "Name=attachment.vpc-id,Values=$VPC_ID_TO_REMOVE" --region "$AWS_REGION" --query 'InternetGateways[0].InternetGatewayId' --output text || echo "")
if [[ -n "$IGW" && "$IGW" != "None" ]]; then
  aws ec2 detach-internet-gateway --internet-gateway-id "$IGW" --vpc-id "$VPC_ID_TO_REMOVE" --region "$AWS_REGION"
  aws ec2 delete-internet-gateway --internet-gateway-id "$IGW" --region "$AWS_REGION"
fi

# Delete non-main route tables in the VPC
RTBS=$(aws ec2 describe-route-tables --filters "Name=vpc-id,Values=$VPC_ID_TO_REMOVE" --region "$AWS_REGION" --query 'RouteTables[?Associations[?Main==`false`]].RouteTableId' --output text)
for rtb in $RTBS; do
  # Disassociate subnets
  ASSOCS=$(aws ec2 describe-route-tables --route-table-ids "$rtb" --region "$AWS_REGION" --query 'RouteTables[0].Associations[?Main==`false`].RouteTableAssociationId' --output text)
  for assoc in $ASSOCS; do
    aws ec2 disassociate-route-table --association-id "$assoc" --region "$AWS_REGION"
  done
  aws ec2 delete-route-table --route-table-id "$rtb" --region "$AWS_REGION"
done

# Delete subnets
SUBNETS=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID_TO_REMOVE" --region "$AWS_REGION" --query 'Subnets[].SubnetId' --output text)
for s in $SUBNETS; do
  aws ec2 delete-subnet --subnet-id "$s" --region "$AWS_REGION"
done

# Finally delete the VPC
aws ec2 delete-vpc --vpc-id "$VPC_ID_TO_REMOVE" --region "$AWS_REGION"
echo "Deleted VPC $VPC_ID_TO_REMOVE"

