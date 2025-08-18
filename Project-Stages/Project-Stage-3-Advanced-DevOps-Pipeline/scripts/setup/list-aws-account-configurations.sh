#!/bin/bash

# List AWS Account ID Configuration Files
# This script identifies all files that contain AWS Account ID references

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Logging functions
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Configuration
OLD_ACCOUNT_ID="867344452513"
SEARCH_PATTERNS=(
    "867344452513"
    "healthcare-terraform-state-stage3-867344452513"
    "867344452513.dkr.ecr.us-east-1.amazonaws.com"
)

# Search for AWS Account ID references
search_aws_account_references() {
    log_info "Searching for AWS Account ID references..."
    
    local total_files=0
    local total_references=0
    
    echo "📋 AWS Account ID Configuration Files Report"
    echo "=============================================="
    echo
    
    for pattern in "${SEARCH_PATTERNS[@]}"; do
        echo "🔍 Searching for pattern: $pattern"
        echo "-------------------------------------------"
        
        local pattern_files=0
        local pattern_refs=0
        
        # Search in different file types
        local file_types=(
            "*.tf"
            "*.tfvars"
            "*.yaml"
            "*.yml"
            "*.sh"
            "*.md"
            "*.json"
        )
        
        for file_type in "${file_types[@]}"; do
            while IFS= read -r -d '' file; do
                if [[ -f "$file" ]] && grep -q "$pattern" "$file" 2>/dev/null; then
                    local ref_count=$(grep -c "$pattern" "$file" 2>/dev/null || echo "0")
                    if [[ $ref_count -gt 0 ]]; then
                        echo "  📄 $file ($ref_count references)"
                        ((pattern_files++))
                        ((pattern_refs+=ref_count))
                    fi
                fi
            done < <(find . -path "./Test-Archive" -prune -o -path "./.git" -prune -o -path "./node_modules" -prune -o -name "$file_type" -type f -print0 2>/dev/null)
        done
        
        echo "  📊 Pattern Summary: $pattern_files files, $pattern_refs references"
        echo
        
        ((total_files+=pattern_files))
        ((total_references+=pattern_refs))
    done
    
    echo "📈 Total Summary: $total_files files, $total_references references"
    echo
}

# List critical configuration files
list_critical_files() {
    log_info "Listing critical configuration files that MUST be updated..."
    
    echo "🎯 Critical Configuration Files"
    echo "================================"
    echo
    
    # Define critical files with descriptions
    declare -A critical_files=(
        ["terraform/backend.tf"]="Terraform backend S3 bucket configuration"
        ["terraform/environments/dev/providers.tf"]="Development environment backend configuration"
        ["terraform/environments/dev/terraform.tfvars"]="Development environment variables"
        ["k8s/applications/frontend/deployment.yaml"]="Frontend Kubernetes deployment"
        ["k8s/applications/backend/deployment.yaml"]="Backend Kubernetes deployment"
        ["gitops/environments/dev/frontend.yaml"]="GitOps frontend configuration"
        ["gitops/environments/dev/backend.yaml"]="GitOps backend configuration"
        ["scripts/setup/create-aws-backend.sh"]="AWS backend creation script"
        ["scripts/setup/create-ecr-repositories.sh"]="ECR repositories creation script"
        [".github/workflows/stage3-ci.yml"]="GitHub Actions CI/CD workflow"
    )
    
    local found_files=0
    local missing_files=0
    
    for file in "${!critical_files[@]}"; do
        if [[ -f "$file" ]]; then
            local has_old_id=""
            if grep -q "$OLD_ACCOUNT_ID" "$file" 2>/dev/null; then
                has_old_id=" ⚠️ NEEDS UPDATE"
            else
                has_old_id=" ✅ UPDATED"
            fi
            echo "  📄 $file$has_old_id"
            echo "     Description: ${critical_files[$file]}"
            ((found_files++))
        else
            echo "  ❌ $file (MISSING)"
            echo "     Description: ${critical_files[$file]}"
            ((missing_files++))
        fi
        echo
    done
    
    echo "📊 Critical Files Summary: $found_files found, $missing_files missing"
    echo
}

# Generate replacement commands
generate_replacement_commands() {
    log_info "Generating replacement commands..."
    
    echo "🔧 AWS Account ID Replacement Commands"
    echo "======================================"
    echo
    
    echo "# Option 1: Automated replacement using environment variables"
    echo "export NEW_AWS_ACCOUNT_ID=\$(aws sts get-caller-identity --query Account --output text)"
    echo "echo \"Your AWS Account ID: \$NEW_AWS_ACCOUNT_ID\""
    echo
    
    echo "# Replace in Terraform files"
    echo "find terraform/ -name \"*.tf\" -o -name \"*.tfvars\" | xargs sed -i \"s/$OLD_ACCOUNT_ID/\$NEW_AWS_ACCOUNT_ID/g\""
    echo
    
    echo "# Replace in Kubernetes manifests"
    echo "find k8s/ gitops/ -name \"*.yaml\" -o -name \"*.yml\" | xargs sed -i \"s/$OLD_ACCOUNT_ID/\$NEW_AWS_ACCOUNT_ID/g\""
    echo
    
    echo "# Replace in scripts"
    echo "find scripts/ -name \"*.sh\" | xargs sed -i \"s/$OLD_ACCOUNT_ID/\$NEW_AWS_ACCOUNT_ID/g\""
    echo
    
    echo "# Replace in documentation"
    echo "find . -name \"*.md\" | xargs sed -i \"s/$OLD_ACCOUNT_ID/\$NEW_AWS_ACCOUNT_ID/g\""
    echo
    
    echo "# Option 2: Use the automated environment setup script"
    echo "./scripts/setup/setup-environment-variables.sh"
    echo
}

# Validate current configuration
validate_configuration() {
    log_info "Validating current configuration..."
    
    echo "🔍 Configuration Validation"
    echo "==========================="
    echo
    
    # Check if AWS CLI is configured
    if aws sts get-caller-identity &>/dev/null; then
        local current_account=$(aws sts get-caller-identity --query Account --output text)
        echo "✅ AWS CLI configured"
        echo "   Current Account ID: $current_account"
        
        # Check if old account ID still exists
        local old_refs=$(find . -path "./Test-Archive" -prune -o -path "./.git" -prune -o -type f \( -name "*.tf" -o -name "*.yaml" -o -name "*.yml" -o -name "*.sh" \) -exec grep -l "$OLD_ACCOUNT_ID" {} \; 2>/dev/null | wc -l)
        
        if [[ $old_refs -gt 0 ]]; then
            echo "⚠️  Old Account ID found in $old_refs files"
            echo "   Action needed: Run replacement commands"
        else
            echo "✅ No old Account ID references found"
        fi
    else
        echo "❌ AWS CLI not configured"
        echo "   Action needed: Run 'aws configure'"
    fi
    echo
}

# Generate summary report
generate_summary_report() {
    log_info "Generating summary report..."
    
    echo "📋 AWS Account ID Configuration Summary"
    echo "======================================="
    echo
    
    echo "🎯 What needs to be updated:"
    echo "  • S3 bucket names in Terraform backend configurations"
    echo "  • ECR registry URLs in Kubernetes deployments"
    echo "  • AWS Account ID in scripts and documentation"
    echo "  • GitHub Actions secrets and environment variables"
    echo
    
    echo "🔧 How to update:"
    echo "  1. Run: ./scripts/setup/setup-environment-variables.sh (Automated)"
    echo "  2. Or use manual replacement commands shown above"
    echo "  3. Update GitHub secrets in repository settings"
    echo "  4. Verify with: grep -r \"$OLD_ACCOUNT_ID\" . --exclude-dir=Test-Archive"
    echo
    
    echo "⚠️  Important notes:"
    echo "  • S3 bucket names must be globally unique"
    echo "  • ECR registry URLs are region-specific"
    echo "  • GitHub secrets need manual update in repository settings"
    echo "  • Test all configurations after replacement"
    echo
}

# Main execution
main() {
    echo "🔍 AWS Account ID Configuration Analysis"
    echo "========================================"
    echo
    
    search_aws_account_references
    list_critical_files
    generate_replacement_commands
    validate_configuration
    generate_summary_report
    
    log_success "Analysis completed! Review the report above for next steps."
}

# Execute main function
main "$@"
