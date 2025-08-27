#!/bin/bash

# Complete Infrastructure Destruction Script
# Destroys ALL Stage-3 healthcare infrastructure resources
# Based on audit findings: aws-resources-audit-20250820-133100.txt

REGION="${AWS_REGION:-us-east-1}"
DRY_RUN="${1:-false}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} ✅ $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} ⚠️  $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} ❌ $1"; }
log_phase() { echo -e "${PURPLE}[PHASE]${NC} 🚀 $1"; }

# Execute command with dry run support
execute_command() {
    local cmd="$1"
    local description="$2"

    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "[DRY-RUN] $description"
        log_info "[DRY-RUN] Command: $cmd"
    else
        log_info "$description"
        if eval "$cmd" 2>/dev/null; then
            log_success "$description completed"
        else
            log_warning "$description failed (may not exist)"
        fi
    fi
}

# Phase 1: Kubernetes Applications Cleanup
cleanup_kubernetes_applications() {
    log_phase "Phase 1: Kubernetes Applications Cleanup"

    # Check if kubectl is available and cluster is accessible
    if ! command -v kubectl >/dev/null 2>&1; then
        log_warning "kubectl not found, skipping Kubernetes cleanup"
        return 0
    fi

    if ! kubectl cluster-info >/dev/null 2>&1; then
        log_warning "Cannot connect to Kubernetes cluster, skipping application cleanup"
        return 0
    fi

    # Delete healthcare applications
    execute_command "kubectl delete namespace healthcare-stage3-dev --ignore-not-found=true" \
        "Delete healthcare namespace"

    # Delete ArgoCD applications
    execute_command "kubectl delete namespace argocd --ignore-not-found=true" \
        "Delete ArgoCD namespace"

    # Delete monitoring stack
    execute_command "kubectl delete namespace monitoring --ignore-not-found=true" \
        "Delete monitoring namespace"

    # Delete logging stack
    execute_command "kubectl delete namespace logging --ignore-not-found=true" \
        "Delete logging namespace"

    # Wait for namespace deletion
    if [[ "$DRY_RUN" == "false" ]]; then
        log_info "⏳ Waiting for namespaces to be fully deleted..."
        sleep 30
    fi
}

# Phase 2: Load Balancers Cleanup
cleanup_load_balancers() {
    log_phase "Phase 2: Load Balancers Cleanup"

    # Get all Application Load Balancers
    local albs
    albs=$(aws elbv2 describe-load-balancers --region "$REGION" --query 'LoadBalancers[?contains(LoadBalancerName, `healthcare`) || contains(LoadBalancerName, `stage3`)].LoadBalancerArn' --output text 2>/dev/null || echo "")

    if [[ -n "$albs" ]]; then
        for alb in $albs; do
            execute_command "aws elbv2 delete-load-balancer --load-balancer-arn '$alb' --region '$REGION'" \
                "Delete Application Load Balancer $alb"
        done
    else
        log_info "No Application Load Balancers found"
    fi

    # Get all Classic Load Balancers
    local clbs
    clbs=$(aws elb describe-load-balancers --region "$REGION" --query 'LoadBalancerDescriptions[?contains(LoadBalancerName, `healthcare`) || contains(LoadBalancerName, `stage3`)].LoadBalancerName' --output text 2>/dev/null || echo "")

    if [[ -n "$clbs" ]]; then
        for clb in $clbs; do
            execute_command "aws elb delete-load-balancer --load-balancer-name '$clb' --region '$REGION'" \
                "Delete Classic Load Balancer $clb"
        done
    else
        log_info "No Classic Load Balancers found"
    fi

    # Wait for load balancers to be deleted
    if [[ "$DRY_RUN" == "false" ]]; then
        log_info "⏳ Waiting for load balancers to be deleted..."
        sleep 60
    fi
}

# Phase 2.1: ELB Target Groups and Listeners Cleanup (post-ALB delete)
cleanup_elbv2_target_groups() {
    log_phase "Phase 2.1: Target Groups and Listeners Cleanup"

    # Delete orphan target groups created by the controller
    local tgs
    tgs=$(aws elbv2 describe-target-groups --region "$REGION" \
      --query 'TargetGroups[?contains(TargetGroupName, `k8s`) || contains(TargetGroupName, `healthcare`) || contains(TargetGroupName, `stage3`)].TargetGroupArn' \
      --output text 2>/dev/null || echo "")

    if [[ -n "$tgs" ]]; then
        for tg in $tgs; do
            execute_command "aws elbv2 delete-target-group --target-group-arn '$tg' --region '$REGION'" \
                "Delete ELBv2 target group $tg"
        done
    else
        log_info "No ELBv2 target groups found"
    fi
}


# Phase 3: EKS Cluster Cleanup
cleanup_eks_cluster() {
    log_phase "Phase 3: EKS Cluster Cleanup"

    local cluster_name="healthcare-eks-stage3-dev"

    # Check if cluster exists
    if ! aws eks describe-cluster --name "$cluster_name" --region "$REGION" >/dev/null 2>&1; then
        log_info "EKS cluster $cluster_name not found"
        return 0
    fi

    # Delete node groups first
    local node_groups
    node_groups=$(aws eks list-nodegroups --cluster-name "$cluster_name" --region "$REGION" --query 'nodegroups' --output text 2>/dev/null || echo "")

    if [[ -n "$node_groups" ]]; then
        for ng in $node_groups; do
            execute_command "aws eks delete-nodegroup --cluster-name '$cluster_name' --nodegroup-name '$ng' --region '$REGION'" \
                "Delete EKS node group $ng"
        done

        # Wait for node groups to be deleted
        if [[ "$DRY_RUN" == "false" ]]; then
            log_info "⏳ Waiting for node groups to be deleted..."
            sleep 300  # Node groups take longer to delete
        fi
    fi

    # Delete the cluster
    execute_command "aws eks delete-cluster --name '$cluster_name' --region '$REGION'" \
        "Delete EKS cluster $cluster_name"

    # Wait for cluster deletion
    if [[ "$DRY_RUN" == "false" ]]; then
        log_info "⏳ Waiting for EKS cluster to be deleted..."
        sleep 900
    fi
}

# Phase 4: RDS Database Cleanup
cleanup_rds_database() {
    log_phase "Phase 4: RDS Database Cleanup"

    local db_instance="healthcare-eks-stage3-dev-db"

    # Check if RDS instance exists
    if ! aws rds describe-db-instances --db-instance-identifier "$db_instance" --region "$REGION" >/dev/null 2>&1; then
        log_info "RDS instance $db_instance not found"
        return 0
    fi

    # Delete RDS instance (skip final snapshot for complete destruction)
    execute_command "aws rds delete-db-instance --db-instance-identifier '$db_instance' --skip-final-snapshot --region '$REGION'" \
        "Delete RDS instance $db_instance"

    # Wait for RDS deletion
    if [[ "$DRY_RUN" == "false" ]]; then
        log_info "⏳ Waiting for RDS instance to be deleted..."
        sleep 600
    fi

    # Delete DB subnet groups
    local subnet_groups
    subnet_groups=$(aws rds describe-db-subnet-groups --region "$REGION" --query 'DBSubnetGroups[?contains(DBSubnetGroupName, `healthcare`) || contains(DBSubnetGroupName, `stage3`)].DBSubnetGroupName' --output text 2>/dev/null || echo "")

    if [[ -n "$subnet_groups" ]]; then
        for sg in $subnet_groups; do
            execute_command "aws rds delete-db-subnet-group --db-subnet-group-name '$sg' --region '$REGION'" \
                "Delete DB subnet group $sg"
        done
    fi
}

# Phase 5: ECR Repositories Cleanup
cleanup_ecr_repositories() {
    log_phase "Phase 5: ECR Repositories Cleanup"

    # Get all ECR repositories for healthcare/stage3
    local repos
    repos=$(aws ecr describe-repositories --region "$REGION" --query 'repositories[?contains(repositoryName, `healthcare`) || contains(repositoryName, `stage3`)].repositoryName' --output text 2>/dev/null || echo "")

    if [[ -n "$repos" ]]; then
        for repo in $repos; do
            # Delete all images in repository first
            if [[ "$DRY_RUN" == "true" ]]; then
                log_info "[DRY-RUN] Delete all images in ECR repository $repo"
            else
                log_info "Delete all images in ECR repository $repo"
                # Get image IDs first
                local image_ids
                image_ids=$(aws ecr list-images --repository-name "$repo" --region "$REGION" --query 'imageIds[*]' --output json 2>/dev/null || echo "[]")
                if [[ "$image_ids" != "[]" && -n "$image_ids" ]]; then
                    aws ecr batch-delete-image --repository-name "$repo" --image-ids "$image_ids" --region "$REGION" >/dev/null 2>&1 || true
                    log_success "Delete all images in ECR repository $repo completed"
                else
                    log_info "No images found in ECR repository $repo"
                fi
            fi

            # Delete the repository
            execute_command "aws ecr delete-repository --repository-name '$repo' --force --region '$REGION'" \
                "Delete ECR repository $repo"
        done
    else
        log_info "No ECR repositories found"
    fi
}

# Phase 6: S3 Buckets Cleanup
cleanup_s3_buckets() {
    log_phase "Phase 6: S3 Buckets Cleanup"

    # Get all S3 buckets for healthcare/stage3
    local buckets
    buckets=$(aws s3api list-buckets --query 'Buckets[?contains(Name, `healthcare`) || contains(Name, `stage3`)].Name' --output text 2>/dev/null || echo "")

    if [[ -n "$buckets" ]]; then
        for bucket in $buckets; do
            # Empty bucket first
            execute_command "aws s3 rm s3://'$bucket' --recursive --region '$REGION'" \
                "Empty S3 bucket $bucket"

            # Delete the bucket
            execute_command "aws s3api delete-bucket --bucket '$bucket' --region '$REGION'" \
                "Delete S3 bucket $bucket"
        done
    else
        log_info "No S3 buckets found"
    fi
}


# Phase 8.5: IAM Resources Cleanup (ALB Controller, Stage-3 roles/policies)
cleanup_iam_resources() {
    log_phase "Phase 8.5: IAM Resources Cleanup"

    # Delete ALB Controller role and its inline/attached policies
    local role_name="AmazonEKSLoadBalancerControllerRole"
    if aws iam get-role --role-name "$role_name" >/dev/null 2>&1; then
        log_info "🧹 Cleaning IAM role $role_name"
        # Detach attached policies
        local attached
        attached=$(aws iam list-attached-role-policies --role-name "$role_name" --query 'AttachedPolicies[].PolicyArn' --output text 2>/dev/null || echo "")
        if [[ -n "$attached" ]]; then
            for p in $attached; do
                execute_command "aws iam detach-role-policy --role-name '$role_name' --policy-arn '$p'" \
                    "Detach policy $p from role $role_name"
            done
        fi
        # Delete inline policies
        local inline
        inline=$(aws iam list-role-policies --role-name "$role_name" --query 'PolicyNames[]' --output text 2>/dev/null || echo "")
        if [[ -n "$inline" ]]; then
            for ip in $inline; do
                execute_command "aws iam delete-role-policy --role-name '$role_name' --policy-name '$ip'" \
                    "Delete inline policy $ip from role $role_name"
            done
        fi
        # Delete the role
        execute_command "aws iam delete-role --role-name '$role_name'" \
            "Delete IAM role $role_name"
    else
        log_info "IAM role $role_name not found"
    fi

    # Delete customer-managed policies we may have created
    for pol in "ALBControllerExtraPermissions" "AWSLoadBalancerControllerIAMPolicy"; do
        local arn
        arn=$(aws iam list-policies --scope Local --query "Policies[?PolicyName=='$pol'].Arn" --output text 2>/dev/null || echo "")
        if [[ -n "$arn" ]]; then
            # Delete non-default versions first
            local versions
            versions=$(aws iam list-policy-versions --policy-arn "$arn" --query 'Versions[?IsDefaultVersion==`false`].VersionId' --output text 2>/dev/null || echo "")
            if [[ -n "$versions" ]]; then
                for v in $versions; do
                    execute_command "aws iam delete-policy-version --policy-arn '$arn' --version-id '$v'" \
                        "Delete policy version $v for $pol"
                done
            fi
            execute_command "aws iam delete-policy --policy-arn '$arn'" \
                "Delete customer managed policy $pol"
        fi
    done

    # Delete EKS OIDC providers for this region
    local providers
    providers=$(aws iam list-open-id-connect-providers --query 'OpenIDConnectProviderList[].Arn' --output text 2>/dev/null || echo "")
    if [[ -n "$providers" ]]; then
        for prov in $providers; do
            if [[ "$prov" == *"oidc.eks.$REGION.amazonaws.com"* ]]; then
                execute_command "aws iam delete-open-id-connect-provider --open-id-connect-provider-arn '$prov'" \
                    "Delete OIDC provider $prov"
            fi
        done
    fi
}

# Phase 7: CloudFormation Stacks Cleanup
cleanup_cloudformation_stacks() {
    log_phase "Phase 7: CloudFormation Stacks Cleanup"

    # Get all CloudFormation stacks for healthcare/stage3/eksctl
    local stacks
    stacks=$(aws cloudformation list-stacks --region "$REGION" --stack-status-filter CREATE_COMPLETE UPDATE_COMPLETE --query 'StackSummaries[?contains(StackName, `healthcare`) || contains(StackName, `stage3`) || contains(StackName, `eksctl`)].StackName' --output text 2>/dev/null || echo "")

    if [[ -n "$stacks" ]]; then
        for stack in $stacks; do
            execute_command "aws cloudformation delete-stack --stack-name '$stack' --region '$REGION'" \
                "Delete CloudFormation stack $stack"
        done

        # Wait for stacks to be deleted
        if [[ "$DRY_RUN" == "false" && -n "$stacks" ]]; then
            log_info "⏳ Waiting for CloudFormation stacks to be deleted..."
            sleep 120
        fi
    else
        log_info "No CloudFormation stacks found"
    fi
}

# Phase 8: Terraform Infrastructure Destruction
cleanup_terraform_infrastructure() {
    log_phase "Phase 8: Terraform Infrastructure Destruction"

    local terraform_dir="$SCRIPT_DIR/../../terraform/environments/dev"

    if [[ ! -d "$terraform_dir" ]]; then
        log_warning "Terraform directory not found: $terraform_dir"
        return 0
    fi

    cd "$terraform_dir"

    # Initialize Terraform
    execute_command "terraform init" \
        "Initialize Terraform"

    # Run Terraform destroy
    if [[ "$DRY_RUN" == "true" ]]; then
        execute_command "terraform plan -destroy" \
            "Terraform destroy plan"
    else
        execute_command "terraform destroy -auto-approve" \
            "Terraform infrastructure destruction"
    fi

    cd - >/dev/null
}

# Phase 9: NAT Gateways and Elastic IPs Cleanup
cleanup_nat_gateways_and_eips() {
    log_phase "Phase 9: NAT Gateways and Elastic IPs Cleanup"

    # Delete NAT Gateways from audit findings
    local nat_gateways=("nat-0bd2cb827f3788132" "nat-02feafd3ad2c2dfd1" "nat-05a5f982db8d10308")

    # Delete VPC link endpoints and NACLs rules if any
    local vpc_endpoints
    vpc_endpoints=$(aws ec2 describe-vpc-endpoints --region "$REGION" --filters "Name=vpc-id,Values=$vpc_id" --query 'VpcEndpoints[].VpcEndpointId' --output text 2>/dev/null || echo "")
    if [[ -n "$vpc_endpoints" ]]; then
        for vpe in $vpc_endpoints; do
            execute_command "aws ec2 delete-vpc-endpoints --vpc-endpoint-ids '$vpe' --region '$REGION'" \
                "Delete VPC endpoint $vpe"
        done
    fi


    for nat_gw in "${nat_gateways[@]}"; do
        execute_command "aws ec2 delete-nat-gateway --nat-gateway-id '$nat_gw' --region '$REGION'" \
            "Delete NAT Gateway $nat_gw"
    done

    # Wait for NAT gateways to be deleted
    if [[ "$DRY_RUN" == "false" ]]; then
        log_info "⏳ Waiting for NAT gateways to be deleted..."
        sleep 180
    fi

    # Release Elastic IPs from audit findings
    local eips=("eipalloc-06b6563c114600b1b" "eipalloc-01d9b0ba4dc90f83e" "eipalloc-046f7b5ec45c5edb6" "eipalloc-03500c5cff4425584" "eipalloc-0354e329f2995c794")

    for eip in "${eips[@]}"; do
        execute_command "aws ec2 release-address --allocation-id '$eip' --region '$REGION'" \
            "Release Elastic IP $eip"
    done
}

# Phase 10: VPC and Networking Cleanup
cleanup_vpcs_and_networking() {
    log_phase "Phase 10: VPC and Networking Cleanup"

    # VPCs from audit findings (excluding default VPC)
    local vpcs=("vpc-091096720de6b6207" "vpc-08e8c3cfb17424e6a" "vpc-07f297f70eb26e9c8")

    for vpc_id in "${vpcs[@]}"; do
        log_info "🧹 Cleaning up VPC $vpc_id and its dependencies..."

        # Delete security groups (except default)
        local security_groups
        security_groups=$(aws ec2 describe-security-groups --region "$REGION" --filters "Name=vpc-id,Values=$vpc_id" --query 'SecurityGroups[?GroupName!=`default`].GroupId' --output text 2>/dev/null || echo "")

        if [[ -n "$security_groups" ]]; then
            for sg in $security_groups; do
                execute_command "aws ec2 delete-security-group --group-id '$sg' --region '$REGION'" \
                    "Delete security group $sg"
            done
        fi

        # Delete subnets
        local subnets
        subnets=$(aws ec2 describe-subnets --region "$REGION" --filters "Name=vpc-id,Values=$vpc_id" --query 'Subnets[].SubnetId' --output text 2>/dev/null || echo "")

        if [[ -n "$subnets" ]]; then
            for subnet in $subnets; do
                execute_command "aws ec2 delete-subnet --subnet-id '$subnet' --region '$REGION'" \
                    "Delete subnet $subnet"
            done
        fi

        # Detach and delete internet gateways

        # Delete network ACLs (except default)
        local nacls
        nacls=$(aws ec2 describe-network-acls --region "$REGION" --filters "Name=vpc-id,Values=$vpc_id" --query 'NetworkAcls[?IsDefault==`false`].NetworkAclId' --output text 2>/dev/null || echo "")
        if [[ -n "$nacls" ]]; then
            for nacl in $nacls; do
                execute_command "aws ec2 delete-network-acl --network-acl-id '$nacl' --region '$REGION'" \
                    "Delete network ACL $nacl"
            done
        fi

        # Delete NAT Gateways still attached to this VPC (catch-all)
        local vpc_nats
        vpc_nats=$(aws ec2 describe-nat-gateways --region "$REGION" --filter "Name=vpc-id,Values=$vpc_id" --query 'NatGateways[].NatGatewayId' --output text 2>/dev/null || echo "")
        if [[ -n "$vpc_nats" ]]; then
            for nat in $vpc_nats; do
                execute_command "aws ec2 delete-nat-gateway --nat-gateway-id '$nat' --region '$REGION'" \
                    "Delete NAT Gateway $nat (VPC catch-all)"
            done
        fi

        local igws
        igws=$(aws ec2 describe-internet-gateways --region "$REGION" --filters "Name=attachment.vpc-id,Values=$vpc_id" --query 'InternetGateways[].InternetGatewayId' --output text 2>/dev/null || echo "")

        if [[ -n "$igws" ]]; then
            for igw in $igws; do
                execute_command "aws ec2 detach-internet-gateway --internet-gateway-id '$igw' --vpc-id '$vpc_id' --region '$REGION'" \
                    "Detach internet gateway $igw from VPC $vpc_id"
                execute_command "aws ec2 delete-internet-gateway --internet-gateway-id '$igw' --region '$REGION'" \
                    "Delete internet gateway $igw"
            done
        fi

        # Delete route tables (except main)
        local route_tables
        route_tables=$(aws ec2 describe-route-tables --region "$REGION" --filters "Name=vpc-id,Values=$vpc_id" --query 'RouteTables[?Associations[0].Main!=`true`].RouteTableId' --output text 2>/dev/null || echo "")

        if [[ -n "$route_tables" ]]; then
            for rt in $route_tables; do
                execute_command "aws ec2 delete-route-table --route-table-id '$rt' --region '$REGION'" \
                    "Delete route table $rt"
            done
        fi

        # Finally delete the VPC
        execute_command "aws ec2 delete-vpc --vpc-id '$vpc_id' --region '$REGION'" \
            "Delete VPC $vpc_id"

        if [[ "$DRY_RUN" == "false" ]]; then
            log_info "⏳ Waiting for VPC $vpc_id to be deleted..."
            sleep 60
        fi
    done
}

# Show usage information
show_usage() {
    echo "Complete Infrastructure Destruction Script"
    echo ""
    echo "⚠️  WARNING: This will destroy ALL Stage-3 infrastructure!"
    echo ""
    echo "Usage:"
    echo "  $0 [dry-run]     # Dry run mode (default: false)"
    echo "  $0 --help        # Show this help"
    echo ""
    echo "Examples:"
    echo "  $0 true          # Dry run - show what would be destroyed"
    echo "  $0 false         # Live run - actually destroy infrastructure"
    echo "  $0               # Live run (default)"
    echo ""
    echo "This script will destroy:"
    echo "  💥 Kubernetes applications and namespaces"
    echo "  💥 Load balancers (ALB/CLB)"
    echo "  💥 EKS cluster and node groups"
    echo "  💥 RDS database instance"
    echo "  💥 ECR repositories"
    echo "  💥 S3 buckets"
    echo "  💥 CloudFormation stacks"
    echo "  💥 Terraform-managed infrastructure"
    echo "  💥 NAT gateways and Elastic IPs"
    echo "  💥 VPCs, subnets, and networking"
    echo ""
    echo "💰 This will stop ALL AWS charges (~$450/month)"
}

# Main execution function
main() {
    if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
        show_usage
        exit 0
    fi

    echo "🚨 COMPLETE INFRASTRUCTURE DESTRUCTION"
    echo "======================================"
    echo ""

    if [[ "$DRY_RUN" == "true" ]]; then
        log_warning "🔍 DRY RUN MODE - No resources will be actually destroyed"
    else
        log_warning "🚨 LIVE DESTRUCTION MODE"
        echo ""
        echo "⚠️  This will permanently destroy ALL Stage-3 infrastructure:"
        echo "  💥 EKS cluster and all workloads"
        echo "  💥 RDS database (all data will be lost)"
        echo "  💥 VPC and all networking"
        echo "  💥 ECR repositories and container images"
        echo "  💥 S3 buckets and stored data"
        echo "  💥 All monitoring and logging"
        echo ""
        echo "💰 This will stop ALL AWS charges (~$450/month)"
        echo ""
        read -p "Type 'DESTROY-EVERYTHING' to confirm complete destruction: " -r
        if [[ ! $REPLY == "DESTROY-EVERYTHING" ]]; then
            echo "Complete destruction cancelled."
            exit 0
        fi
        echo ""
        read -p "Type 'YES' to confirm you understand this is irreversible: " -r
        if [[ ! $REPLY == "YES" ]]; then
            echo "Complete destruction cancelled."
            exit 0
        fi
    fi

    echo ""
    log_info "🚀 Starting complete infrastructure destruction..."
    echo ""

    # Execute destruction phases in dependency order
    cleanup_kubernetes_applications
    cleanup_load_balancers
    cleanup_elbv2_target_groups
    cleanup_eks_cluster
    cleanup_rds_database
    cleanup_ecr_repositories
    cleanup_s3_buckets
    cleanup_cloudformation_stacks
    cleanup_terraform_infrastructure
    cleanup_iam_resources
    cleanup_nat_gateways_and_eips
    cleanup_vpcs_and_networking

    echo ""
    log_success "🎉 Complete infrastructure destruction finished!"

    if [[ "$DRY_RUN" == "false" ]]; then
        echo ""
        log_info "💰 Expected monthly savings: ~$450"
        log_info "🔍 Run audit script to verify complete destruction:"
        log_info "    ./scripts/cleanup/audit-aws-resources.sh"
    fi
}

# Run main function
main "$@"
