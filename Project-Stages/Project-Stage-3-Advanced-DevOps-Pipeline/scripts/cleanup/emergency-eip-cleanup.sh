#!/bin/bash

# Emergency EIP Cleanup Script
# Cleans up unassociated EIPs and duplicate NAT Gateways to resolve EIP limit issue

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

AWS_REGION="${AWS_REGION:-us-east-1}"

# Check current EIP usage
check_eip_usage() {
    log_info "🔍 Checking current EIP usage..."
    
    local eip_limit eip_used
    eip_limit=$(aws ec2 describe-account-attributes --attribute-names max-elastic-ips --query 'AccountAttributes[0].AttributeValues[0].AttributeValue' --output text)
    eip_used=$(aws ec2 describe-addresses --query 'Addresses | length(@)')
    
    log_info "📊 EIP Usage: $eip_used / $eip_limit"
    
    # List all EIPs with their status
    log_info "📋 Current EIP allocation:"
    aws ec2 describe-addresses --query 'Addresses[].{AllocationId:AllocationId,PublicIp:PublicIp,Associated:AssociationId,Usage:join(``, [InstanceId || ``, NetworkInterfaceId || ``])}' --output table
    
    return 0
}

# Find and release unassociated EIPs
cleanup_unassociated_eips() {
    log_info "🧹 Cleaning up unassociated EIPs..."
    
    # Get unassociated EIPs
    local unassociated_eips
    unassociated_eips=$(aws ec2 describe-addresses --query 'Addresses[?AssociationId==null].AllocationId' --output text)
    
    if [[ -z "$unassociated_eips" || "$unassociated_eips" == "None" ]]; then
        log_info "✅ No unassociated EIPs found"
        return 0
    fi
    
    log_warning "⚠️ Found unassociated EIPs: $unassociated_eips"
    
    for eip in $unassociated_eips; do
        log_info "🗑️ Releasing unassociated EIP: $eip"
        if aws ec2 release-address --allocation-id "$eip" 2>/dev/null; then
            log_success "✅ Released EIP: $eip"
        else
            log_warning "⚠️ Failed to release EIP: $eip"
        fi
    done
}

# Identify duplicate VPCs and their resources
identify_duplicate_vpcs() {
    log_info "🔍 Identifying duplicate VPCs..."
    
    # Get all healthcare VPCs
    local vpc_data
    vpc_data=$(aws ec2 describe-vpcs --query 'Vpcs[].{VpcId:VpcId,Name:Tags[?Key==`Name`].Value|[0]}' --output json)
    
    # Find healthcare VPCs
    local healthcare_vpcs
    healthcare_vpcs=$(echo "$vpc_data" | jq -r '.[] | select(.Name == "healthcare-eks-stage3-dev-vpc") | .VpcId')
    
    log_info "📋 Found healthcare VPCs:"
    for vpc in $healthcare_vpcs; do
        log_info "  - VPC: $vpc"
        
        # Check if this VPC has EKS cluster
        local eks_subnets
        eks_subnets=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$vpc" --query 'Subnets[?Tags[?Key==`kubernetes.io/cluster/healthcare-eks-stage3-dev`]].SubnetId' --output text)
        
        if [[ -n "$eks_subnets" && "$eks_subnets" != "None" ]]; then
            log_success "    ✅ Active VPC (has EKS cluster subnets)"
            echo "$vpc" > /tmp/active_vpc_id
        else
            log_warning "    ⚠️ Duplicate VPC (no EKS cluster)"
            echo "$vpc" >> /tmp/duplicate_vpc_ids
        fi
        
        # List NAT Gateways in this VPC
        local nat_gateways
        nat_gateways=$(aws ec2 describe-nat-gateways --filter "Name=vpc-id,Values=$vpc" --query 'NatGateways[?State==`available`].{NatGatewayId:NatGatewayId,PublicIp:NatGatewayAddresses[0].PublicIp}' --output text)
        
        if [[ -n "$nat_gateways" && "$nat_gateways" != "None" ]]; then
            log_info "    📡 NAT Gateways:"
            echo "$nat_gateways" | while read -r nat_id public_ip; do
                log_info "      - $nat_id ($public_ip)"
            done
        fi
    done
}

# Clean up duplicate NAT Gateways (keep only 1 per VPC)
cleanup_excess_nat_gateways() {
    log_info "🧹 Cleaning up excess NAT Gateways..."
    
    # Get active VPC
    if [[ ! -f /tmp/active_vpc_id ]]; then
        log_warning "⚠️ No active VPC identified, skipping NAT cleanup"
        return 0
    fi
    
    local active_vpc
    active_vpc=$(cat /tmp/active_vpc_id)
    
    # Get NAT Gateways in active VPC
    local nat_gateways
    nat_gateways=$(aws ec2 describe-nat-gateways --filter "Name=vpc-id,Values=$active_vpc" --query 'NatGateways[?State==`available`].NatGatewayId' --output text)
    
    if [[ -z "$nat_gateways" || "$nat_gateways" == "None" ]]; then
        log_info "✅ No NAT Gateways found in active VPC"
        return 0
    fi
    
    # Convert to array
    local nat_array=($nat_gateways)
    local nat_count=${#nat_array[@]}
    
    log_info "📊 Found $nat_count NAT Gateways in active VPC: $active_vpc"
    
    if [[ $nat_count -le 1 ]]; then
        log_success "✅ Only 1 NAT Gateway found, no cleanup needed"
        return 0
    fi
    
    # Keep the first NAT Gateway, delete the rest
    log_warning "⚠️ Found $nat_count NAT Gateways, keeping first one and deleting excess"
    
    for ((i=1; i<nat_count; i++)); do
        local nat_id="${nat_array[$i]}"
        log_info "🗑️ Deleting excess NAT Gateway: $nat_id"
        
        if aws ec2 delete-nat-gateway --nat-gateway-id "$nat_id" 2>/dev/null; then
            log_success "✅ Initiated deletion of NAT Gateway: $nat_id"
        else
            log_warning "⚠️ Failed to delete NAT Gateway: $nat_id"
        fi
    done
    
    log_info "⏳ Waiting for NAT Gateway deletions to complete..."
    sleep 30
}

# Main cleanup function
emergency_cleanup() {
    log_info "🚨 Starting emergency EIP cleanup..."
    
    # Clean up temporary files
    rm -f /tmp/active_vpc_id /tmp/duplicate_vpc_ids
    
    # Step 1: Check current usage
    check_eip_usage
    
    # Step 2: Clean up unassociated EIPs immediately
    cleanup_unassociated_eips
    
    # Step 3: Identify VPC structure
    identify_duplicate_vpcs
    
    # Step 4: Clean up excess NAT Gateways
    cleanup_excess_nat_gateways
    
    # Step 5: Check final usage
    log_info "🔍 Final EIP usage check..."
    check_eip_usage
    
    # Clean up temporary files
    rm -f /tmp/active_vpc_id /tmp/duplicate_vpc_ids
    
    log_success "✅ Emergency EIP cleanup completed"
}

# Dry run mode
dry_run() {
    log_info "🔍 DRY RUN: Analyzing EIP usage without making changes..."
    
    check_eip_usage
    identify_duplicate_vpcs
    
    log_info "📋 Actions that would be taken:"
    
    # Check unassociated EIPs
    local unassociated_eips
    unassociated_eips=$(aws ec2 describe-addresses --query 'Addresses[?AssociationId==null].AllocationId' --output text)
    
    if [[ -n "$unassociated_eips" && "$unassociated_eips" != "None" ]]; then
        log_info "  🗑️ Would release unassociated EIPs: $unassociated_eips"
    fi
    
    # Check excess NAT Gateways
    if [[ -f /tmp/active_vpc_id ]]; then
        local active_vpc
        active_vpc=$(cat /tmp/active_vpc_id)
        local nat_count
        nat_count=$(aws ec2 describe-nat-gateways --filter "Name=vpc-id,Values=$active_vpc" --query 'NatGateways[?State==`available`] | length(@)')
        
        if [[ $nat_count -gt 1 ]]; then
            log_info "  🗑️ Would delete $((nat_count - 1)) excess NAT Gateways"
        fi
    fi
    
    rm -f /tmp/active_vpc_id /tmp/duplicate_vpc_ids
    log_info "✅ Dry run completed"
}

# Main execution
main() {
    local mode="${1:-cleanup}"
    
    case "$mode" in
        "dry-run"|"dryrun"|"check")
            dry_run
            ;;
        "cleanup"|"clean")
            emergency_cleanup
            ;;
        *)
            log_error "❌ Invalid mode: $mode"
            log_info "Usage: $0 [cleanup|dry-run]"
            exit 1
            ;;
    esac
}

# Execute if run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
