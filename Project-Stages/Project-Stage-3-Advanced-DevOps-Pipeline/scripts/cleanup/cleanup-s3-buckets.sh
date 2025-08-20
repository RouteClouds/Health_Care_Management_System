#!/bin/bash

# S3 Buckets Cleanup Script
# Handles multiple Terraform state buckets and assets bucket cleanup
# Based on audit findings: 4 buckets total (3 Terraform state + 1 assets)

set -euo pipefail

REGION="${AWS_REGION:-us-east-1}"
DRY_RUN="${1:-false}"

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

# Discovered buckets from audit
BUCKETS=(
    "healthcare-assets-stage3-dev-867344452513"
    "healthcare-terraform-state-stage3-867344452513"
    "healthcare-terraform-state-stage3-867344452513-2738"
    "healthcare-terraform-state-stage3-867344452513-8840"
)

# Check if bucket exists and get info
check_bucket() {
    local bucket="$1"
    
    if aws s3api head-bucket --bucket "$bucket" --region "$REGION" 2>/dev/null; then
        local size
        size=$(aws s3 ls "s3://$bucket" --recursive --summarize 2>/dev/null | grep "Total Size" | awk '{print $3}' || echo "0")
        local objects
        objects=$(aws s3 ls "s3://$bucket" --recursive --summarize 2>/dev/null | grep "Total Objects" | awk '{print $3}' || echo "0")
        
        log_info "✅ Bucket exists: $bucket"
        log_info "   📊 Objects: $objects | Size: $size bytes"
        return 0
    else
        log_warning "❌ Bucket not found: $bucket"
        return 1
    fi
}

# Backup Terraform state before deletion
backup_terraform_state() {
    local bucket="$1"
    local backup_dir="terraform-state-backup-$(date +%Y%m%d-%H%M%S)"
    
    log_info "💾 Backing up Terraform state from $bucket..."
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "[DRY-RUN] Would backup Terraform state to $backup_dir/"
        return 0
    fi
    
    mkdir -p "$backup_dir"
    
    if aws s3 sync "s3://$bucket" "$backup_dir/" --region "$REGION" 2>/dev/null; then
        log_success "Terraform state backed up to: $backup_dir/"
        
        # Create backup info file
        cat > "$backup_dir/backup-info.txt" << EOF
Terraform State Backup
=====================
Source Bucket: $bucket
Backup Date: $(date)
Backup Directory: $backup_dir
Region: $REGION

Files backed up:
$(find "$backup_dir" -type f | grep -v backup-info.txt)

To restore:
aws s3 sync $backup_dir/ s3://NEW-BUCKET-NAME/ --region $REGION
EOF
        
        log_info "📋 Backup info saved to: $backup_dir/backup-info.txt"
    else
        log_error "Failed to backup Terraform state from $bucket"
        return 1
    fi
}

# Empty and delete bucket
delete_bucket() {
    local bucket="$1"
    local bucket_type="$2"
    
    log_warning "🗑️ Deleting $bucket_type bucket: $bucket"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "[DRY-RUN] Would empty and delete bucket: $bucket"
        return 0
    fi
    
    # Empty bucket first
    log_info "🧹 Emptying bucket: $bucket"
    if aws s3 rm "s3://$bucket" --recursive --region "$REGION" 2>/dev/null; then
        log_success "Bucket emptied: $bucket"
    else
        log_warning "Failed to empty bucket or bucket already empty: $bucket"
    fi
    
    # Delete bucket
    log_info "💥 Deleting bucket: $bucket"
    if aws s3 rb "s3://$bucket" --region "$REGION" 2>/dev/null; then
        log_success "Bucket deleted: $bucket"
    else
        log_error "Failed to delete bucket: $bucket"
        return 1
    fi
}

# Main cleanup function
cleanup_s3_buckets() {
    log_info "🗑️ S3 Buckets Cleanup Based on Audit Findings"
    log_info "Found 4 buckets: 3 Terraform state + 1 assets"
    echo ""
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log_warning "🔍 DRY RUN MODE - No buckets will be deleted"
    else
        log_warning "🚨 LIVE MODE - Buckets will be permanently deleted"
        echo ""
        echo "⚠️  This will delete ALL S3 buckets and their contents:"
        echo "   💾 3 Terraform state buckets (with backup)"
        echo "   📁 1 assets bucket"
        echo ""
        echo "💰 This will stop S3 storage charges"
        echo ""
        read -p "Type 'DELETE-S3-BUCKETS' to confirm: " -r
        if [[ ! $REPLY == "DELETE-S3-BUCKETS" ]]; then
            echo "S3 cleanup cancelled."
            exit 0
        fi
    fi
    
    echo ""
    
    # Check which buckets exist
    local existing_buckets=()
    for bucket in "${BUCKETS[@]}"; do
        if check_bucket "$bucket"; then
            existing_buckets+=("$bucket")
        fi
    done
    
    if [[ ${#existing_buckets[@]} -eq 0 ]]; then
        log_success "🎉 No healthcare S3 buckets found to clean up"
        return 0
    fi
    
    echo ""
    log_info "📋 Processing ${#existing_buckets[@]} existing buckets..."
    
    # Process each bucket
    for bucket in "${existing_buckets[@]}"; do
        echo ""
        log_info "🔄 Processing bucket: $bucket"
        
        if [[ "$bucket" == *"terraform-state"* ]]; then
            # Terraform state bucket - backup first
            log_info "📦 Terraform state bucket detected"
            backup_terraform_state "$bucket"
            delete_bucket "$bucket" "Terraform state"
        elif [[ "$bucket" == *"assets"* ]]; then
            # Assets bucket
            log_info "📁 Assets bucket detected"
            delete_bucket "$bucket" "Assets"
        else
            # Unknown bucket type
            log_warning "❓ Unknown bucket type, treating as general bucket"
            delete_bucket "$bucket" "General"
        fi
    done
    
    echo ""
    log_success "🎉 S3 buckets cleanup completed!"
    
    if [[ "$DRY_RUN" == "false" ]]; then
        log_info "💾 Terraform state backups saved locally"
        log_info "📊 Check AWS Cost Explorer for S3 cost reduction"
    fi
}

# Show usage
show_usage() {
    cat << EOF
🗑️ S3 Buckets Cleanup Script

Based on audit findings: 4 buckets total
- healthcare-assets-stage3-dev-867344452513
- healthcare-terraform-state-stage3-867344452513
- healthcare-terraform-state-stage3-867344452513-2738
- healthcare-terraform-state-stage3-867344452513-8840

USAGE:
  $0 [dry-run]

OPTIONS:
  dry-run     - true/false (default: false)

EXAMPLES:
  $0 true     # Dry run - show what would be deleted
  $0 false    # Actually delete buckets
  $0          # Actually delete buckets (default)

SAFETY FEATURES:
  ✅ Terraform state buckets are backed up locally before deletion
  ✅ Confirmation required for live deletion
  ✅ Dry run mode available for testing

EOF
}

# Main execution
main() {
    if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
        show_usage
        exit 0
    fi
    
    log_info "🚀 S3 Buckets Cleanup Script"
    log_info "Dry Run: $DRY_RUN | Region: $REGION"
    echo ""
    
    # Check AWS credentials
    if ! aws sts get-caller-identity &> /dev/null; then
        log_error "AWS credentials not configured"
        exit 1
    fi
    
    cleanup_s3_buckets
}

# Run main function
main "$@"
