#!/bin/bash

# Comprehensive Cleanup Orchestrator
# Implements the dependency-aware deletion order from Cursor delete plan
# Handles both duplicate cleanup and complete infrastructure destruction

set -euo pipefail

REGION="${AWS_REGION:-us-east-1}"
MODE="${1:-duplicates}"  # duplicates, complete, or audit
DRY_RUN="${2:-false}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_phase() { echo -e "${CYAN}[PHASE]${NC} $1"; }

# Display usage
show_usage() {
    cat << EOF
🧹 Comprehensive Cleanup Orchestrator

Based on your audit findings and Cursor delete plan best practices.

USAGE:
  $0 <mode> [dry-run]

MODES:
  audit       - Run resource audit and cost analysis
  duplicates  - Remove duplicate VPCs and resources (saves ~\$135/month)
  complete    - Complete infrastructure destruction (saves ~\$450/month)

OPTIONS:
  dry-run     - true/false (default: false)

EXAMPLES:
  $0 audit                    # Discover resources and costs
  $0 duplicates true          # Dry run duplicate cleanup
  $0 duplicates false         # Actually remove duplicates
  $0 complete true            # Dry run complete cleanup
  $0 complete false           # Complete infrastructure destruction

CURRENT AUDIT FINDINGS:
  🌐 VPCs: 2 healthcare VPCs (1 duplicate)
  🚪 NAT Gateways: 6 total (3 duplicates, \$135/month waste)
  🔗 Load Balancers: 0 duplicates (ALB working correctly!)
  🏷️ EKS Clusters: 1 (healthcare-eks-stage3-dev)
  🗄️ RDS Instances: 1 (healthcare-eks-stage3-dev-db)
  💰 Total Monthly Cost: ~\$450

RECOMMENDED CLEANUP ORDER:
  1. Run 'audit' to see current state
  2. Run 'duplicates' to remove waste (saves \$135/month)
  3. Run 'audit' again to verify
  4. When project complete: run 'complete' (saves remaining \$315/month)

EOF
}

# Run resource audit
run_audit() {
    log_phase "🔍 Running Resource Audit and Cost Analysis"
    
    if [[ -f "$SCRIPT_DIR/audit-aws-resources.sh" ]]; then
        "$SCRIPT_DIR/audit-aws-resources.sh"
    else
        log_error "Audit script not found: $SCRIPT_DIR/audit-aws-resources.sh"
        return 1
    fi
    
    log_success "Audit completed - check the generated report"
}

# Clean up duplicate resources
cleanup_duplicates() {
    log_phase "🗑️ Removing Duplicate Resources (High Cost Savings)"
    
    if [[ -f "$SCRIPT_DIR/enhanced-duplicate-cleanup.sh" ]]; then
        "$SCRIPT_DIR/enhanced-duplicate-cleanup.sh" "$DRY_RUN"
    else
        log_error "Enhanced duplicate cleanup script not found"
        return 1
    fi
    
    log_success "Duplicate cleanup completed"
}

# Complete infrastructure destruction
complete_cleanup() {
    log_phase "💥 Complete Infrastructure Destruction"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log_warning "[DRY-RUN] Would run complete infrastructure destruction"
        log_info "[DRY-RUN] This would delete:"
        log_info "[DRY-RUN]   - EKS cluster (healthcare-eks-stage3-dev)"
        log_info "[DRY-RUN]   - RDS instance (healthcare-eks-stage3-dev-db)"
        log_info "[DRY-RUN]   - Remaining VPC and networking"
        log_info "[DRY-RUN]   - ECR repositories"
        log_info "[DRY-RUN]   - S3 buckets (with confirmation)"
        log_info "[DRY-RUN]   - CloudWatch logs"
        return 0
    fi
    
    # Use existing comprehensive cleanup script
    if [[ -f "$SCRIPT_DIR/destroy-complete-infrastructure.sh" ]]; then
        "$SCRIPT_DIR/destroy-complete-infrastructure.sh"
    else
        log_error "Complete destruction script not found"
        return 1
    fi
    
    log_success "Complete infrastructure destruction completed"
}

# Validate current state based on audit findings
validate_current_state() {
    log_info "🔍 Validating current state based on audit findings..."
    
    # Check for duplicate VPCs
    local healthcare_vpcs
    healthcare_vpcs=$(aws ec2 describe-vpcs --region "$REGION" \
        --filters "Name=tag:Name,Values=*healthcare*" \
        --query 'Vpcs[].VpcId' --output text | wc -w)
    
    # Check NAT Gateway count
    local nat_count
    nat_count=$(aws ec2 describe-nat-gateways --region "$REGION" \
        --query 'NatGateways[?State==`available`]' --output text | wc -l)
    
    # Check EKS cluster
    local eks_exists
    eks_exists=$(aws eks describe-cluster --name "healthcare-eks-stage3-dev" --region "$REGION" &>/dev/null && echo "true" || echo "false")
    
    log_info "Current State:"
    log_info "  🌐 Healthcare VPCs: $healthcare_vpcs"
    log_info "  🚪 NAT Gateways: $nat_count"
    log_info "  🏷️ EKS Cluster: $eks_exists"
    
    # Provide recommendations
    if [[ $healthcare_vpcs -gt 1 ]]; then
        log_warning "⚠️  Multiple healthcare VPCs detected - consider 'duplicates' cleanup"
        log_info "💰 Potential savings: ~\$135/month"
    fi
    
    if [[ $nat_count -gt 3 ]]; then
        log_warning "⚠️  Excessive NAT Gateways detected ($nat_count, should be 3)"
        log_info "💰 Waste: ~\$$(( (nat_count - 3) * 45 ))/month"
    fi
}

# Main execution
main() {
    case "$MODE" in
        "audit")
            validate_current_state
            echo ""
            run_audit
            ;;
        "duplicates")
            if [[ "$DRY_RUN" == "true" ]]; then
                log_warning "🔍 DRY RUN: Duplicate Resources Cleanup"
            else
                log_warning "🚨 LIVE: Duplicate Resources Cleanup"
                echo ""
                echo "Based on audit findings, this will:"
                echo "  🗑️ Remove 1 duplicate VPC (vpc-0a86b53a910003112)"
                echo "  🚪 Remove 3 duplicate NAT Gateways (saves \$135/month)"
                echo "  🌍 Remove 1 duplicate Internet Gateway"
                echo "  🏠 Remove ~8 duplicate subnets"
                echo "  🔐 Remove duplicate security groups"
                echo ""
                echo "✅ Will preserve:"
                echo "  🏷️ Active EKS cluster (healthcare-eks-stage3-dev)"
                echo "  🗄️ Active RDS instance (healthcare-eks-stage3-dev-db)"
                echo "  🌐 Active VPC (vpc-073b79bb3c4bf4156)"
                echo ""
            fi
            cleanup_duplicates
            ;;
        "complete")
            if [[ "$DRY_RUN" == "true" ]]; then
                log_warning "🔍 DRY RUN: Complete Infrastructure Destruction"
            else
                log_warning "🚨 LIVE: Complete Infrastructure Destruction"
                echo ""
                echo "⚠️  WARNING: This will delete ALL Stage-3 infrastructure:"
                echo "  💥 EKS cluster and all workloads"
                echo "  💥 RDS database (all data will be lost)"
                echo "  💥 VPC and all networking"
                echo "  💥 ECR repositories and container images"
                echo "  💥 S3 buckets (with confirmation)"
                echo "  💥 CloudWatch logs"
                echo ""
                echo "💰 This will stop ALL AWS charges (~\$450/month)"
                echo ""
                read -p "Type 'DESTROY-EVERYTHING' to confirm complete destruction: " -r
                if [[ ! $REPLY == "DESTROY-EVERYTHING" ]]; then
                    echo "Complete destruction cancelled."
                    exit 0
                fi
            fi
            complete_cleanup
            ;;
        "--help"|"-h"|"help")
            show_usage
            exit 0
            ;;
        *)
            log_error "Invalid mode: $MODE"
            echo ""
            show_usage
            exit 1
            ;;
    esac
}

# Validate dependencies
validate_dependencies() {
    local missing_deps=()
    
    if ! command -v aws &> /dev/null; then
        missing_deps+=("aws")
    fi
    
    if ! command -v kubectl &> /dev/null; then
        missing_deps+=("kubectl")
    fi
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        log_error "Missing dependencies: ${missing_deps[*]}"
        exit 1
    fi
    
    # Check AWS credentials
    if ! aws sts get-caller-identity &> /dev/null; then
        log_error "AWS credentials not configured"
        exit 1
    fi
}

# Pre-flight checks
log_info "🚀 Comprehensive Cleanup Orchestrator"
log_info "Mode: $MODE | Dry Run: $DRY_RUN | Region: $REGION"
echo ""

# Validate dependencies
validate_dependencies

# Show usage if no arguments
if [[ $# -eq 0 ]]; then
    show_usage
    exit 0
fi

# Run main function
main "$@"
