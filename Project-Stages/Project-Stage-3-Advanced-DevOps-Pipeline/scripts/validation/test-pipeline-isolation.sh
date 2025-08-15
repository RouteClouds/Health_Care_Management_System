#!/bin/bash

# Pipeline Isolation Testing Script
# Validates that Stage-2 and Stage-3 pipelines trigger independently

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if we're in the right directory
check_directory() {
    if [[ ! -f "../../.github/workflows/stage2-ci.yml" ]] || [[ ! -f "../../.github/workflows/stage3-ci.yml" ]]; then
        log_error "GitHub Actions workflow files not found"
        log_info "Please run this script from the Stage-3 root directory"
        exit 1
    fi
}

# Analyze Stage-2 pipeline triggers
analyze_stage2_triggers() {
    log_info "Analyzing Stage-2 pipeline triggers..."
    
    local stage2_file="../../.github/workflows/stage2-ci.yml"
    
    echo "Stage-2 Pipeline Trigger Paths:"
    grep -A 20 "paths:" "$stage2_file" | grep -E "^\s*-" | head -10
    
    # Check if Stage-3 paths are excluded
    if grep -q "Project-Stage-3" "$stage2_file"; then
        log_warning "Stage-2 pipeline still references Stage-3 paths"
        return 1
    else
        log_success "✅ Stage-2 pipeline properly isolated from Stage-3"
        return 0
    fi
}

# Analyze Stage-3 pipeline triggers
analyze_stage3_triggers() {
    log_info "Analyzing Stage-3 pipeline triggers..."
    
    local stage3_file="../../.github/workflows/stage3-ci.yml"
    
    echo "Stage-3 Pipeline Trigger Paths:"
    grep -A 20 "paths:" "$stage3_file" | grep -E "^\s*-" | head -10
    
    # Check if Stage-2 paths are excluded
    if grep -q "Project-Stage-2" "$stage3_file"; then
        log_warning "Stage-3 pipeline references Stage-2 paths"
        return 1
    else
        log_success "✅ Stage-3 pipeline properly isolated from Stage-2"
        return 0
    fi
}

# Test path overlap
test_path_overlap() {
    log_info "Testing for path overlap between pipelines..."
    
    local stage2_file="../../.github/workflows/stage2-ci.yml"
    local stage3_file="../../.github/workflows/stage3-ci.yml"
    
    # Extract paths from both files
    local stage2_paths=$(grep -A 20 "paths:" "$stage2_file" | grep -E "^\s*-" | sed 's/^\s*-\s*//' | grep -v "workflows")
    local stage3_paths=$(grep -A 20 "paths:" "$stage3_file" | grep -E "^\s*-" | sed 's/^\s*-\s*//' | grep -v "workflows")
    
    local overlap_found=false
    
    # Check for overlapping paths
    while IFS= read -r stage2_path; do
        while IFS= read -r stage3_path; do
            if [[ "$stage2_path" == "$stage3_path" ]]; then
                log_error "❌ Overlapping path found: $stage2_path"
                overlap_found=true
            fi
        done <<< "$stage3_paths"
    done <<< "$stage2_paths"
    
    if [[ "$overlap_found" == false ]]; then
        log_success "✅ No overlapping paths found between pipelines"
        return 0
    else
        log_error "❌ Path overlap detected - pipelines may trigger simultaneously"
        return 1
    fi
}

# Simulate trigger scenarios
simulate_triggers() {
    log_info "Simulating trigger scenarios..."
    
    echo ""
    echo "📋 Trigger Simulation Results:"
    echo "=============================="
    
    # Scenario 1: Stage-2 src-code change
    echo "1. Change in Stage-2 src-code:"
    echo "   File: Project-Stages/Project-Stage-2-Automated-CI-CD-Pipeline/src-code/app.js"
    echo "   Expected: ✅ Stage-2 pipeline triggers, ❌ Stage-3 pipeline does NOT trigger"
    
    # Scenario 2: Stage-3 src-code change
    echo ""
    echo "2. Change in Stage-3 src-code:"
    echo "   File: Project-Stages/Project-Stage-3-Advanced-DevOps-Pipeline/src-code/README.md"
    echo "   Expected: ❌ Stage-2 pipeline does NOT trigger, ✅ Stage-3 pipeline triggers"
    
    # Scenario 3: Stage-3 terraform change
    echo ""
    echo "3. Change in Stage-3 terraform:"
    echo "   File: Project-Stages/Project-Stage-3-Advanced-DevOps-Pipeline/terraform/main.tf"
    echo "   Expected: ❌ Stage-2 pipeline does NOT trigger, ✅ Stage-3 pipeline triggers"
    
    # Scenario 4: Documentation change
    echo ""
    echo "4. Change in Stage-3 documentation:"
    echo "   File: Project-Stages/Project-Stage-3-Advanced-DevOps-Pipeline/MASTER-SETUP-GUIDE.md"
    echo "   Expected: ❌ Stage-2 pipeline does NOT trigger, ✅ Stage-3 pipeline triggers"
    
    echo ""
}

# Provide recommendations
provide_recommendations() {
    log_info "Pipeline Isolation Recommendations:"
    echo ""
    echo "✅ BEST PRACTICES:"
    echo "1. Use specific directory paths instead of wildcards"
    echo "2. Avoid using both 'paths' and 'paths-ignore' together"
    echo "3. Test pipeline triggers with small changes"
    echo "4. Monitor GitHub Actions to verify only intended pipelines trigger"
    echo ""
    echo "🔍 MONITORING:"
    echo "- Check GitHub Actions after each commit"
    echo "- Verify only the expected pipeline runs"
    echo "- Look for simultaneous pipeline executions"
    echo ""
    echo "🚨 WARNING SIGNS:"
    echo "- Both pipelines running simultaneously"
    echo "- Unexpected pipeline triggers"
    echo "- Resource conflicts in AWS (Terraform state locks)"
}

# Main function
main() {
    echo "🔍 Pipeline Isolation Testing"
    echo "============================="
    echo ""
    
    check_directory
    
    local errors=0
    
    # Run all tests
    analyze_stage2_triggers || ((errors++))
    echo ""
    analyze_stage3_triggers || ((errors++))
    echo ""
    test_path_overlap || ((errors++))
    echo ""
    simulate_triggers
    echo ""
    provide_recommendations
    
    echo ""
    echo "📊 Test Results Summary"
    echo "======================="
    if [ $errors -eq 0 ]; then
        log_success "🎉 All pipeline isolation tests PASSED!"
        log_info "Pipelines are properly isolated and should not trigger simultaneously"
        return 0
    else
        log_error "❌ $errors pipeline isolation issues found"
        log_warning "Please review and fix the issues above before proceeding"
        return 1
    fi
}

# Execute main function
main "$@"
