#!/bin/bash

# Enhanced Infrastructure Conflicts Handler
# Prevents duplicate resource creation by importing existing resources
# Addresses the root cause identified in Cursor-RCA-Infra-Duplicate.md

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $1"; }

# Retry function with exponential backoff
retry_with_backoff() {
    local max_attempts="$1"
    local delay="$2"
    local command="$3"
    local attempt=1

    while [[ $attempt -le $max_attempts ]]; do
        log_info "Attempt $attempt/$max_attempts: $command"
        if eval "$command"; then
            log_success "Command succeeded on attempt $attempt"
            return 0
        else
            if [[ $attempt -eq $max_attempts ]]; then
                log_error "Command failed after $max_attempts attempts"
                return 1
            fi
            log_warning "Command failed, retrying in ${delay}s..."
            sleep "$delay"
            delay=$((delay * 2))  # Exponential backoff
            attempt=$((attempt + 1))
        fi
    done
}
# Retry function that accepts command and args (avoids eval and quoting issues)
retry_with_backoff_args() {
    local max_attempts="$1"
    local delay="$2"
    shift 2
    local attempt=1

    while [[ $attempt -le $max_attempts ]]; do
        log_info "Attempt $attempt/$max_attempts: $*"
        if "$@"; then
            log_success "Command succeeded on attempt $attempt"
            return 0
        else
            if [[ $attempt -eq $max_attempts ]]; then
                log_error "Command failed after $max_attempts attempts"
                return 1
            fi
            log_warning "Command failed, retrying in ${delay}s..."
            sleep "$delay"
            delay=$((delay * 2))  # Exponential backoff
            attempt=$((attempt + 1))
        fi
    done
}


AWS_REGION="${AWS_REGION:-us-east-1}"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
CLUSTER_NAME="${CLUSTER_NAME:-healthcare-eks-stage3-dev}"


# Check infrastructure health and limits
check_infrastructure_health() {
    log_info "🏥 Running infrastructure health check..."

    # Check EIP usage and limits
    local eip_limit eip_used
    eip_limit=$(aws ec2 describe-account-attributes --attribute-names max-elastic-ips --query 'AccountAttributes[0].AttributeValues[0].AttributeValue' --output text)
    eip_used=$(aws ec2 describe-addresses --query 'Addresses | length(@)')

    log_info "📊 EIP Usage: $eip_used / $eip_limit"

    if [[ $eip_used -ge $eip_limit ]]; then
        log_error "❌ EIP limit reached - NAT Gateway creation will fail"
        log_info "💡 Run emergency cleanup: ./scripts/cleanup/emergency-eip-cleanup.sh cleanup"
        return 1
    fi

    # Check for duplicate VPCs
    local healthcare_vpcs
    healthcare_vpcs=$(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=healthcare-eks-stage3-dev-vpc" --query 'Vpcs[].VpcId' --output text)
    local vpc_count
    vpc_count=$(echo "$healthcare_vpcs" | wc -w)

    if [[ $vpc_count -gt 1 ]]; then
        log_warning "⚠️ Found $vpc_count duplicate VPCs - this indicates previous duplicate creation"
        log_info "💡 Consider running comprehensive cleanup to remove duplicates"
    fi

    # Check for available EIPs that can be reused
    local available_eips
    # Query unassociated VPC EIPs correctly (AssociationId == null)
    available_eips=$(aws ec2 describe-addresses \
        --filters "Name=domain,Values=vpc" \
        --query 'Addresses[?AssociationId==`null`].AllocationId' \
        --output text)
    local eip_count
    eip_count=$(echo "$available_eips" | wc -w)

    if [[ $eip_count -gt 0 ]]; then
        log_info "📍 Found $eip_count available EIPs for reuse: $available_eips"

        # Update terraform.tfvars with available EIPs
        if [[ -f terraform.tfvars ]]; then
            # Remove existing EIP configuration
            sed -i '/existing_eip_ids/d' terraform.tfvars
        fi

        # Add EIP configuration
        echo "existing_eip_ids = [$(echo "$available_eips" | sed 's/ /", "/g' | sed 's/^/"/' | sed 's/$/"/' | sed 's/""//g')]" >> terraform.tfvars
        log_success "✅ Updated terraform.tfvars with available EIPs for reuse"
    else
        log_info "ℹ️ No available EIPs found - new EIPs will be created if needed"
    fi

    log_success "✅ Infrastructure health check completed"
}

# Enhanced pre-import with conflict resolution
enhanced_pre_import() {
    log_info "📥 Enhanced pre-import with conflict resolution..."

    # Get current Terraform state resources
    local existing_resources
    existing_resources=$(terraform state list 2>/dev/null || echo "")

    # KMS Alias with enhanced error handling
    if ! echo "$existing_resources" | grep -q "aws_kms_alias"; then
        log_info "🔍 Checking for existing KMS alias..."
        if retry_with_backoff 3 2 "aws kms list-aliases --query \"Aliases[?AliasName=='alias/eks/healthcare-eks-stage3-dev']\" --output text | grep -q alias/eks/healthcare-eks-stage3-dev"; then
            log_info "📥 Importing KMS alias with retry logic..."

            local kms_paths=(
                "module.healthcare_infrastructure.module.eks.aws_kms_alias.this[\"cluster\"]"
                "module.healthcare_infrastructure.module.eks.module.kms.aws_kms_alias.this[\"cluster\"]"
                "module.healthcare_infrastructure.aws_kms_alias.eks"
            )

            local imported=false
            for path in "${kms_paths[@]}"; do
                log_info "Trying import path: $path"
                if retry_with_backoff_args 2 1 terraform import "$path" "alias/eks/healthcare-eks-stage3-dev"; then
                    log_success "✅ KMS alias imported via path: $path"
                    imported=true
                    break
                else
                    log_warning "Import failed for path: $path"
                fi
            done

            if [[ "$imported" == "false" ]]; then
                log_warning "⚠️ KMS alias import failed for all paths - may need manual intervention"
            fi
        else
            log_info "ℹ️ No existing KMS alias found - will be created"
        fi
    else
        log_info "✅ KMS alias already in Terraform state"
    fi

    # CloudWatch Log Group with enhanced error handling
    if ! echo "$existing_resources" | grep -q "aws_cloudwatch_log_group"; then
        log_info "🔍 Checking for existing CloudWatch log group..."
        local log_group_name="/aws/eks/healthcare-eks-stage3-dev/cluster"
        if retry_with_backoff 3 2 "aws logs describe-log-groups --log-group-name-prefix \"/aws/eks/healthcare-eks-stage3-dev\" --query 'logGroups[0].logGroupName' --output text 2>/dev/null | grep -q '/aws/eks/healthcare-eks-stage3-dev'"; then
            log_info "📥 Importing CloudWatch log group with retry logic..."

            local cw_paths=(
                "module.healthcare_infrastructure.module.eks.aws_cloudwatch_log_group.this[0]"
                "module.healthcare_infrastructure.module.eks.aws_cloudwatch_log_group.cluster[0]"
            )

            local imported=false
            for path in "${cw_paths[@]}"; do
                log_info "Trying import path: $path"
                if retry_with_backoff_args 2 1 terraform import "$path" "$log_group_name"; then
                    log_success "✅ CloudWatch log group imported via path: $path"
                    imported=true
                    break
                else
                    log_warning "Import failed for path: $path"
                fi
            done

            if [[ "$imported" == "false" ]]; then
                log_warning "⚠️ CloudWatch log group import failed for all paths"
            fi
        else
            log_info "ℹ️ No existing CloudWatch log group found - will be created"
        fi
    else
        log_info "✅ CloudWatch log group already in Terraform state"
    fi

        # If resource is already in state but name differs from expected, remove it to avoid modifying wrong DB subnet group
        # Ensure subnet_group_name is set before comparing
        local expected_subnet_group_name="healthcare-eks-stage3-dev-db-subnet-group-${ACCOUNT_ID}"
        if terraform state show module.healthcare_infrastructure.aws_db_subnet_group.healthcare >/dev/null 2>&1; then
            current_name=$(terraform state show module.healthcare_infrastructure.aws_db_subnet_group.healthcare | awk -F' = ' '/^\s*name\s*=/{print $2}' | tr -d '"')
            if [[ -n "$current_name" && "$current_name" != "$expected_subnet_group_name" ]]; then
                log_warning "⚠️ Terraform state has DB subnet group '$current_name' but expected '$expected_subnet_group_name' - removing from state to allow correct creation"
                terraform state rm module.healthcare_infrastructure.aws_db_subnet_group.healthcare || true
            fi
        fi

    # RDS Subnet Group with enhanced error handling
    if ! echo "$existing_resources" | grep -q "aws_db_subnet_group"; then
        log_info "🔍 Checking for existing RDS subnet group..."
        local subnet_group_name="healthcare-eks-stage3-dev-db-subnet-group-${ACCOUNT_ID}"
        if retry_with_backoff 3 2 "aws rds describe-db-subnet-groups --db-subnet-group-name \"$subnet_group_name\" >/dev/null 2>&1"; then
            log_info "📥 Importing RDS subnet group with retry logic..."
            # Only import if not already in state
            if ! (terraform state list 2>/dev/null || true) | grep -q "module\.healthcare_infrastructure\.aws_db_subnet_group\.healthcare"; then
                if retry_with_backoff_args 2 1 terraform import module.healthcare_infrastructure.aws_db_subnet_group.healthcare "$subnet_group_name"; then
                    log_success "✅ RDS subnet group imported successfully"
                else
                    log_warning "⚠️ RDS subnet group import failed - may need manual intervention"
                fi
            else
                log_info "ℹ️ RDS subnet group already in Terraform state; skipping import"
            fi
        else
            log_info "ℹ️ No existing RDS subnet group found - will be created"
        fi
    else
        log_info "✅ RDS subnet group already in Terraform state"
    fi

    # S3 Assets Bucket with enhanced error handling and conditional creation support
    if ! echo "$existing_resources" | grep -q "aws_s3_bucket.*healthcare_assets"; then
        log_info "🔍 Checking for existing S3 assets bucket..."
        local assets_bucket="healthcare-assets-stage3-dev-${ACCOUNT_ID}"
        if retry_with_backoff 3 2 "aws s3api head-bucket --bucket \"$assets_bucket\" 2>/dev/null"; then
            log_info "📥 Importing S3 assets bucket with retry logic..."

            # Try both conditional and non-conditional resource paths
            local s3_paths=(
                "module.healthcare_infrastructure.aws_s3_bucket.healthcare_assets[0]"
                "module.healthcare_infrastructure.aws_s3_bucket.healthcare_assets"
            )

            local imported=false
            for path in "${s3_paths[@]}"; do
                log_info "Trying import path: $path"
                if retry_with_backoff_args 2 1 terraform import "$path" "$assets_bucket"; then
                    log_success "✅ S3 assets bucket imported via path: $path"
                    imported=true
                    break
                else
                    log_warning "Import failed for path: $path"
                fi
            done

            if [[ "$imported" == "false" ]]; then
                log_warning "⚠️ S3 assets bucket import failed for all paths"
            fi
        else
            log_info "ℹ️ No existing S3 assets bucket found - will be created"
        fi
    else
        log_info "✅ S3 assets bucket already in Terraform state"
    fi

    log_success "✅ Enhanced pre-import completed"

# Import existing VPC networking (VPC, public/private subnets, IGW)
import_vpc_networking() {
    log_info "🌐 Importing existing VPC networking if present..."

    local vpc_name="${CLUSTER_NAME}-vpc"
    local vpc_id
    vpc_id=$(aws ec2 describe-vpcs \
      --filters "Name=tag:Name,Values=${vpc_name}" \
      --query 'Vpcs[0].VpcId' --output text 2>/dev/null || echo "")

    if [[ -z "$vpc_id" || "$vpc_id" == "None" ]]; then
        log_info "ℹ️ No existing VPC found with Name ${vpc_name} — skipping VPC imports"
        return 0
    fi

    log_info "📍 Found VPC: ${vpc_id} (${vpc_name})"

    # Ensure the VPC resource is tracked in state
    if ! (terraform state list 2>/dev/null || true) | grep -q "module\.healthcare_infrastructure\.module\.vpc\.aws_vpc\.this\[0\]\$"; then
        retry_with_backoff_args 2 1 terraform import \
          module.healthcare_infrastructure.module.vpc.aws_vpc.this[0] "$vpc_id" || true
    else
        log_info "✅ VPC already in Terraform state"
    fi

    # Determine first three AZs (module uses first 3 AZs)
    local azs
    azs=$(aws ec2 describe-availability-zones --all-availability-zones \
      --query 'AvailabilityZones[?State==`available`].ZoneName' --output text | awk '{print $1, $2, $3}')
    if [[ -z "$azs" ]]; then
        # Fallback to standard us-east-1 subset
        azs="us-east-1a us-east-1b us-east-1c"
    fi
    log_info "🗺️ Using AZ order: $azs"

    # Import public/private subnets by Name convention: "${vpc_name}-public-<az>" and "${vpc_name}-private-<az>"
    local idx=0
    for az in $azs; do
        if [[ $idx -ge 3 ]]; then break; fi
        local pub_name="${vpc_name}-public-${az}"
        local prv_name="${vpc_name}-private-${az}"
        local pub_id prv_id
        pub_id=$(aws ec2 describe-subnets --filters \
          "Name=vpc-id,Values=${vpc_id}" "Name=tag:Name,Values=${pub_name}" \
          --query 'Subnets[0].SubnetId' --output text 2>/dev/null || echo "")
        prv_id=$(aws ec2 describe-subnets --filters \
          "Name=vpc-id,Values=${vpc_id}" "Name=tag:Name,Values=${prv_name}" \
          --query 'Subnets[0].SubnetId' --output text 2>/dev/null || echo "")

        if [[ -n "$pub_id" && "$pub_id" != "None" ]]; then
            local pub_addr="module.healthcare_infrastructure.module.vpc.aws_subnet.public[${idx}]"
            if ! (terraform state list 2>/dev/null || true) | grep -q "$pub_addr"; then
                retry_with_backoff_args 2 1 terraform import "$pub_addr" "$pub_id" || true
            else
                log_info "✅ Public subnet index ${idx} already in state"
            fi
        else
            log_info "ℹ️ No public subnet found with Name ${pub_name}"
        fi

        if [[ -n "$prv_id" && "$prv_id" != "None" ]]; then
            local prv_addr="module.healthcare_infrastructure.module.vpc.aws_subnet.private[${idx}]"
            if ! (terraform state list 2>/devnull || true) | grep -q "$prv_addr"; then
                retry_with_backoff_args 2 1 terraform import "$prv_addr" "$prv_id" || true
            else
                log_info "✅ Private subnet index ${idx} already in state"
            fi
        else
            log_info "ℹ️ No private subnet found with Name ${prv_name}"
        fi

        idx=$((idx+1))
    done

    # Import Internet Gateway attached to the VPC
    local igw_id
    igw_id=$(aws ec2 describe-internet-gateways --filters "Name=attachment.vpc-id,Values=${vpc_id}" \
      --query 'InternetGateways[0].InternetGatewayId' --output text 2>/dev/null || echo "")
    if [[ -n "$igw_id" && "$igw_id" != "None" ]]; then
        local igw_addr="module.healthcare_infrastructure.module.vpc.aws_internet_gateway.this[0]"
        if ! (terraform state list 2>/dev/null || true) | grep -q "$igw_addr"; then
            retry_with_backoff_args 2 1 terraform import "$igw_addr" "$igw_id" || true
        else
            log_info "✅ Internet Gateway already in Terraform state"
        fi
    else
        log_info "ℹ️ No Internet Gateway found attached to ${vpc_id}"
    fi

    log_success "✅ VPC networking import attempt completed"
}



# Main execution function
handle_infrastructure_conflicts() {
    local strategy="${1:-import}"

    log_info "🔧 Handling infrastructure conflicts with strategy: $strategy"

    # Always run health check first
    if ! check_infrastructure_health; then
        log_error "❌ Infrastructure health check failed"
        exit 1
    fi

    case "$strategy" in
        "import")
            log_info "📥 Using enhanced import strategy..."
            enhanced_pre_import
            ;;
        "skip")
            log_info "⏭️ Skipping conflict handling..."
            ;;
        *)
            log_error "❌ Invalid conflict strategy: $strategy"
            log_info "Valid strategies: import, skip"
            exit 1
            ;;
    esac

    log_success "✅ Infrastructure conflict handling completed"
}

# If script is run directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    STRATEGY="${1:-import}"
    handle_infrastructure_conflicts "$STRATEGY"
fi
