# Stage-3 Enhancement Summary & Roadmap

## Purpose
This document consolidates Stage-3 enhancement summaries and the action roadmap into a single source of truth for the Advanced DevOps Pipeline restoration.

## Current Status (25-Aug)
- EKS cluster not found in target AWS account (first-time creation path)
- CI workflow now includes:
  - Preflight collision detection before Terraform plan (fail-fast / optional import)
  - Ansible gated by repository variable ENABLE_ANSIBLE (disabled by default)
  - Post-failure duplicate diagnostics job (dry-run)
- Terraform env/dev prepared for first-time EKS creation (preserve=false)

## Immediate Goals
1) Create EKS cluster and core infra cleanly (no duplicates)
2) Deploy application via GitOps and validate DB seeding
3) Switch to preserve=true and wire ARNs/SGs for idempotent re-runs

## Key Changes
- Terraform preservation toggling strategy documented in env/dev
- Preflight script integrated into CI to avoid collisions and guide imports
- Cleanup diagnostics for visibility without destructive actions

## Verification
- terraform plan shows EKS create (preserve=false)
- CI safety guard within threshold
- App health checks: /api/health 200; seeded data available

## Next Steps
- After first successful run:
  - Retrieve EKS role ARN, KMS key ARN, and SG IDs
  - Set preserve_existing_cluster=true and wire values in env/dev
  - Re-run plan; confirm no control plane replacement

## References
- .github/workflows/stage3-ci.yml
- terraform/environments/dev/main.tf
- scripts/preflight/check-collisions.sh
- scripts/cleanup/enhanced-duplicate-cleanup.sh



---

## Merged Sources (Consolidation)
The following Stage-3 summary documents have been consolidated here and preserved in the archive for full reference:
- docs/archive/Augment-23-Aug-Summary.md
- docs/archive/25-Aug-Augment-Summary-Changes.md
- docs/archive/Augment-Pipeline-Enhancement-Recommendations.md

Notes:
- Full original content is available in docs/archive; this roadmap reflects the current single source of truth.


---

## Appendix: Augment-23-Aug-Summary.md

# Augment Summary - 23 Aug

## 1) Current Project Status Overview

- Stage-3 pipeline intermittently fails during Deploy Infrastructure with ResourceInUseException for EKS: "Cluster already exists with name: healthcare-eks-stage3-dev".
- Duplicate infrastructure detected (multiple VPCs/NAT GWs/ELBs created from previous failed runs) causes:
  - Terraform plans to propose fresh creates instead of managing existing
  - AWS EIP quota pressure and higher costs (≈ $135/month per extra NAT GW; ≈ $450/month total observed)
  - Drift/conflicts when cluster/VPC already exist but are not in state
- Terraform state management gaps:
  - Backend existed but state lock/table sometimes recreated per run; lacking consistent backend key usage
  - Existing EKS control plane not imported before apply
  - KMS alias/role paths not aligned with actual module addresses

## 2) Work Completed So Far

- Implemented 4-phase remediation plan and executed key parts:
  - Phase 1: Critical State Management Fixes [COMPLETED]
    - Added explicit backend block in dev: environments/dev/main.tf now contains `terraform { backend "s3" {} }` ensuring remote state
    - Performed terraform init -reconfigure and verified plan
    - Imported existing EKS cluster into state to remove duplicate-creation error
  - Phase 2: Pipeline Robustness Improvements [IN PROGRESS]
    - New preflight collision detection script: `scripts/preflight/check-collisions.sh`
      - Detects existing EKS, DB subnet groups and VPCs; FAIL_FAST by default; optional AUTO_IMPORT
    - Began aligning module inputs to preserve existing control plane (avoid replacement)
  - Phase 3: CI/CD Hardening [PARTIAL]
    - Added workflow `concurrency` guard: single in-flight run per environment
    - Planned post-failure cleanup guardrail using `scripts/cleanup/enhanced-duplicate-cleanup.sh` (dry-run by default)
  - Phase 4: Validation & Deployment [PENDING]
    - Local terraform plan after import runs clean; continues to show creates for missing infra but no duplicate-cluster error

- EKS Preservation Approach
  - Introduced preserve_existing_cluster pattern in module wrapper to prevent control plane replacement
  - Parameterized cluster IAM role, KMS key, and SGs when preserving
  - Ensures pipeline manages node groups and surrounding infra without tearing down control plane

- Preflight Collision Detection Script (new)
  - Path: `Project-Stages/Project-Stage-3-Advanced-DevOps-Pipeline/scripts/preflight/check-collisions.sh`
  - Behavior:
    - Checks for EKS cluster existence: if present and AUTO_IMPORT=false (default), exits non‑zero to avoid destructive actions
    - Reports DB subnet groups and VPCs that match cluster naming
    - AUTO_IMPORT=true will attempt targeted terraform import for the EKS cluster

## 3) Root Cause Analysis

- Primary failure: EKS control plane already existed from a prior run; Terraform attempted to create another, triggering `ResourceInUseException`.
- Duplicate infrastructure:
  - Repeated pipeline runs without idempotent guards created multiple VPCs, NAT GWs, and load balancers
  - Direct cost impact: ~3 extra NAT gateways (~$135/month each) + associated EIPs and LBs → ≈ $450/month
- Terraform state issues:
  - Inconsistent initialization across runs led to state not reflecting existing resources
  - Missing import steps for pre-existing EKS cluster/KMS alias → plan tried create instead of adopt
  - Safety checks not enforcing limits on creates per run

## 4) Clear Next Steps Roadmap

- Priority 1: Make control plane preservation the default and finalize inputs
  - Update module variables and env/dev to set `preserve_existing_cluster=true`
  - Ensure exact IAM Role ARN, KMS Key ARN, and SG IDs are wired via variables
  - Verify `terraform plan` shows no replacement of `aws_eks_cluster.this[0]`

- Priority 2: Wire preflight into CI and enforce fail-fast
  - Insert step before first terraform plan: `./scripts/preflight/check-collisions.sh`
  - Default `FAIL_FAST=true`, `AUTO_IMPORT=false`; enable AUTO_IMPORT via repo var if desired

- Priority 3: Guardrails and cleanup
  - Add post-failure job step to run `scripts/cleanup/enhanced-duplicate-cleanup.sh true` (dry-run) and post results in logs
  - Document manual live cleanup `scripts/cleanup/enhanced-duplicate-cleanup.sh false` (only upon explicit approval)

- Priority 4: Final validation and pipeline rerun
  - Commands:
    - cd terraform/environments/dev
    - terraform init -reconfigure -backend-config ...
    - terraform plan
  - Confirm no EKS control plane replacement and only expected creates/updates
  - Re-run pipelines from Actions UI or via `gh run rerun <run_id>`

- Files to update
  - `terraform/modules/healthcare-platform/variables.tf` (ensure preservation inputs are exposed)
  - `terraform/modules/healthcare-platform/main.tf` (use preservation variables and avoid replacement)
  - `terraform/environments/dev/main.tf` (set preserve_existing_cluster=true)
  - `.github/workflows/stage3-ci.yml` (add preflight + cleanup guardrail)

- Timeline
  - Same day: finalize module inputs + preflight wiring + guardrails
  - Next day: end-to-end pipeline validation, drift check, and documentation polish

## 5) Project Context

- Stage-3 Advanced DevOps Pipeline goals:
  - Fully automated CI/CD with idempotent infra provisioning and GitOps image rollout
  - Trigger only on src-code changes; use ArgoCD for app deployment coherence
  - Cost-aware infrastructure (single NAT GW, ALB by default), robust rollback and cleanup
- Broader healthcare system context:
  - This stage ensures a production-like, student-friendly, automated pipeline that can be reliably re‑run
  - Emphasizes zero-manual intervention and clear troubleshooting
- Definition of success for this phase:
  - Pipeline runs end-to-end without manual fixes, reuses existing infra where present, creates missing pieces
  - No duplicate resources; safety guards prevent unintended mass creates
  - GitOps manifests consistently updated with latest image tags and ArgoCD syncs successfully

---

Actionable Checklist
- [ ] Finalize preserve_existing_cluster inputs and set in env/dev
- [ ] Add preflight check into workflow before Terraform planning
- [ ] Add post-failure dry-run cleanup step and document live cleanup
- [ ] Re-run pipeline and validate no cluster replacement
- [ ] Update docs (MASTER-SETUP-GUIDE.md, OPERATIONS.md, TROUBLESHOOTING.md) with commands and outcomes



---

## Appendix: 25-Aug-Augment-Summary-Changes.md

# 25-Aug Augment Summary of Changes and Plan

## 1) Context and Goal
- Goal: Restore Stage-3 Advanced DevOps Pipeline so it runs end-to-end idempotently:
  - Deploys infrastructure without duplicate resources or EKS "already exists" errors
  - Deploys application (frontend + backend) with working DB connectivity and auto-seeding
- Current blocker: Duplicate infra and state drift causing ResourceInUseException and cost overruns

---

## 2) Suggestions made in prior sessions (key items)
- Make control-plane preservation the default (avoid replacing existing EKS cluster)
- Add a preflight collision detection step before Terraform planning/apply
- Add safety guardrails and post-failure diagnostics (dry-run cleanup) instead of auto-deleting
- Keep pipeline simple until infra stabilizes (temporarily disable Ansible)
- Ensure backend handles DB schema+seeding automatically (Prisma + seed scripts)
- Update GitOps to reference image tags by commit SHA, automate Argo sync

---

## 3) Changes implemented (as of 25-Aug)
- Terraform env/dev uses remote S3 backend block (consistent state store)
- Concurrency guard for Stage-3 workflow (prevents overlapping runs)
- Safety guard in workflow to analyze Terraform plan (create/update/delete counts)
- New preflight script created at: `scripts/preflight/check-collisions.sh`
- CI/CD workflow updates (now applied):
  - Preflight Collision Detection step added before Terraform Plan in deploy-infrastructure
  - Ansible job gated behind `vars.ENABLE_ANSIBLE == 'true'` (disabled by default)
  - deploy-application no longer requires ansible-configuration
  - duplicate-cleanup-dryrun job added to surface duplicates on failure (dry-run)
- EKS Preservation in module:
  - Module `main.tf` updated to reference variables when `preserve_existing_cluster=true`
  - Variables: `eks_cluster_role_arn`, `eks_cluster_kms_key_arn`, `eks_cluster_security_group_id`, `eks_cluster_additional_sg_ids`
- Environment wiring in env/dev:
  - Initially parameterized with ARNs/SGs; adjusted for first-time creation (see strategy below)

---

## 4) First-time EKS creation strategy (no-existing-cluster scenario)
- For the initial deployment when the cluster does not exist:
  - Set `preserve_existing_cluster = false`
  - Comment out/remove `eks_cluster_role_arn`, `eks_cluster_kms_key_arn`, `eks_cluster_security_group_id`, `eks_cluster_additional_sg_ids`
  - After successful creation, switch `preserve_existing_cluster = true` and wire the actual ARNs/SG IDs from the created cluster to prevent future replacement

Verification steps (first-time):
- cd terraform/environments/dev
- terraform init -reconfigure
- terraform plan
- Expectation: EKS control plane to be created; no ResourceInUseException; preflight passes

Verification steps (subsequent runs):
- Set preserve to true, wire actual ARNs/SGs, rerun plan → expect no replacement of `aws_eks_cluster.this[0]` and minimal changes

---

## 5) Documentation and scripts consolidation plan

Documentation (proposed consolidation):
- Keep as primary:
  - README.md, MASTER-SETUP-GUIDE.md, ARCHITECTURE-guide.md, OPERATIONS.md, TROUBLESHOOTING.md, Project-Tracker.md
- Merge into "Stage-3 Enhancement Summary & Roadmap.md":
  - Augment-23-Aug-Summary.md
  - 25-Aug-Augment-Summary-Changes.md
  - Augment-Pipeline-Enhancement-Recommendations.md
- Merge into "RCA - Duplicate Infra & State Drift.md":
  - Augment-RCA-Infra-Duplicate.md
  - Aug-Deep-Dive-Analysis-Soln-Dup-Resrc-Pipe.md
  - Cursor-RCA-Infra-Duplicate.md
- Archive to docs/archive/ (retain links from consolidated docs):
  - RoadMap-For-Stage-3-OLD.md
  - Test-Archive/* contents

Scripts (proposed consolidation):
- Keep entrypoints: preflight/check-collisions.sh, deployment/handle-infrastructure-conflicts.sh, cleanup/enhanced-duplicate-cleanup.sh, deployment/build-and-push-images.sh, test-frontend-backend-connectivity.sh, fix-gitops-sync.sh, verify-deployment.sh
- Merge:
  - Stage-2 validators and scattered checks → scripts/validation/validate-stage3-setup.sh
  - deploy-healthcare.sh + quick-update.sh → unified scripts/deploy.sh (subcommands: build, push, deploy, verify)
- Archive/annotate legacy Stage-2-only scripts; centralize utilities in scripts/lib/common.sh

---

## 6) Updated verification plan
- Terraform plan (dev) should show EKS create when preserve=false and no conflicts
- Preflight output should report cluster not found and continue
- CI safety guard thresholds not exceeded
- App validation:
  - /api/health returns 200
  - /api/doctors returns seeded data (backend auto-seeds)

---

## 7) Follow-up backlog (post-stabilization)
- Switch preserve_existing_cluster to true; capture ARNs/SG IDs; re-run plan to confirm no replacement
- Re-enable Ansible with corrected Stage-3 DB names/variables
- Expand drift detection and targeted imports for RDS/subnet groups/SGs
- Complete documentation and scripts consolidation with index updates

---

## 8) Artifacts and References
- Workflow: `.github/workflows/stage3-ci.yml`
- Terraform env: `terraform/environments/dev/main.tf`
- Terraform module: `terraform/modules/healthcare-platform/{main.tf,variables.tf}`
- Preflight: `scripts/preflight/check-collisions.sh`
- Cleanup: `scripts/cleanup/enhanced-duplicate-cleanup.sh`


---

## Appendix: Augment-Pipeline-Enhancement-Recommendations.md

# 🚀 Pipeline Enhancement Recommendations

**Document**: Augment-Pipeline-Enhancement-Recommendations.md
**Date**: August 20, 2025
**Purpose**: Enhance the troubleshooting analysis with additional recommendations
**Based on**: Cursor-Troubleshooting-Deploy-Infra-App.md analysis

---

## 📋 Assessment of Current Troubleshooting Analysis

### **✅ Excellent Analysis Points**

Your troubleshooting document demonstrates:
- ✅ **Accurate root cause identification** for all three pipeline failures
- ✅ **Practical, implementable solutions** with code snippets
- ✅ **Systematic approach** to problem documentation
- ✅ **Idempotent thinking** for robust pipeline design

### **🔧 Enhanced Recommendations**

## **Issue 1: AWS Load Balancer Controller - GOOD SOLUTION**

Your fix is correct. Consider adding:

```yaml
# Enhanced eksctl installation with version pinning
- name: Install eksctl
  run: |
    EKSCTL_VERSION="0.165.0"  # Pin version for consistency
    curl -sLO "https://github.com/weaveworks/eksctl/releases/download/v${EKSCTL_VERSION}/eksctl_Linux_amd64.tar.gz"
    tar -xzf eksctl_Linux_amd64.tar.gz -C /tmp && sudo mv /tmp/eksctl /usr/local/bin
    eksctl version

    # Verify AWS credentials work with eksctl
    eksctl get cluster --region ${{ env.AWS_REGION }} || echo "No existing clusters"
```

## **Issue 2: Database Setup - EXCELLENT SOLUTION**

Your validation approach is perfect. Consider adding:

```bash
# Additional validation in the script
validate_rds_connectivity() {
    local endpoint="$1"
    echo "🔍 Testing RDS connectivity..."

    # Test DNS resolution
    if nslookup "$endpoint" >/dev/null 2>&1; then
        echo "✅ RDS endpoint DNS resolves"
    else
        echo "⚠️ RDS endpoint DNS resolution failed"
        return 1
    fi

    # Test port connectivity (if nc is available)
    if command -v nc >/dev/null 2>&1; then
        if timeout 5 nc -z "$endpoint" 5432; then
            echo "✅ RDS port 5432 is reachable"
        else
            echo "⚠️ RDS port 5432 not reachable"
        fi
    fi
}
```

## **Issue 3: Infrastructure Conflicts - NEEDS ENHANCEMENT**

Your import approach is good, but here are critical improvements:

### **🚨 Critical Issue: Module Path Accuracy**

Your import paths may be incorrect. Let me check the actual module structure:

```bash
# WRONG (your current approach):
terraform import module.healthcare_infrastructure.module.eks.module.kms.aws_kms_alias.this["cluster"]

# LIKELY CORRECT (based on EKS module structure):
terraform import module.healthcare_infrastructure.module.eks.aws_kms_alias.this["cluster"]
```

### **🔧 Enhanced Pre-Import Strategy**

```bash
# More robust pre-import with error handling
pre_import_existing_resources() {
    echo "🔍 Detecting and importing existing resources..."

    # Get current Terraform state resources
    EXISTING_RESOURCES=$(terraform state list 2>/dev/null || echo "")

    # KMS Alias - Check if already in state
    if ! echo "$EXISTING_RESOURCES" | grep -q "aws_kms_alias"; then
        if aws kms list-aliases --query "Aliases[?AliasName=='alias/eks/healthcare-eks-stage3-dev']" --output text | grep -q alias/eks/healthcare-eks-stage3-dev; then
            echo "📥 Importing KMS alias..."
            # Try multiple possible paths
            terraform import module.healthcare_infrastructure.module.eks.aws_kms_alias.this["cluster"] alias/eks/healthcare-eks-stage3-dev 2>/dev/null || \
            terraform import module.healthcare_infrastructure.aws_kms_alias.eks alias/eks/healthcare-eks-stage3-dev 2>/dev/null || \
            echo "⚠️ KMS alias import failed - may need manual intervention"
        fi
    fi

    # CloudWatch Log Group
    if ! echo "$EXISTING_RESOURCES" | grep -q "aws_cloudwatch_log_group"; then
        if aws logs describe-log-groups --log-group-name-prefix "/aws/eks/healthcare-eks-stage3-dev" --query 'logGroups[0].logGroupName' --output text 2>/dev/null | grep -q '/aws/eks/healthcare-eks-stage3-dev'; then
            echo "📥 Importing CloudWatch log group..."
            terraform import module.healthcare_infrastructure.module.eks.aws_cloudwatch_log_group.this[0] /aws/eks/healthcare-eks-stage3-dev/cluster 2>/dev/null || \
            echo "⚠️ CloudWatch log group import failed"
        fi
    fi

    # RDS Subnet Group
    if ! echo "$EXISTING_RESOURCES" | grep -q "aws_db_subnet_group"; then
        if aws rds describe-db-subnet-groups --db-subnet-group-name healthcare-eks-stage3-dev-db-subnet-group >/dev/null 2>&1; then
            echo "📥 Importing RDS subnet group..."
            terraform import module.healthcare_infrastructure.aws_db_subnet_group.healthcare healthcare-eks-stage3-dev-db-subnet-group 2>/dev/null || \
            echo "⚠️ RDS subnet group import failed"
        fi
    fi

    # S3 Assets Bucket
    if ! echo "$EXISTING_RESOURCES" | grep -q "aws_s3_bucket.*healthcare_assets"; then
        ASSETS_BUCKET="healthcare-assets-stage3-dev-$(aws sts get-caller-identity --query Account --output text)"
        if aws s3api head-bucket --bucket "$ASSETS_BUCKET" 2>/dev/null; then
            echo "📥 Importing S3 assets bucket..."
            terraform import module.healthcare_infrastructure.aws_s3_bucket.healthcare_assets "$ASSETS_BUCKET" 2>/dev/null || \
            echo "⚠️ S3 bucket import failed"
        fi
    fi
}
```

### **🔄 Alternative: Cleanup Strategy**

Instead of importing, consider a cleanup approach:

```bash
# Alternative: Clean up conflicting resources before apply
cleanup_conflicting_resources() {
    echo "🧹 Cleaning up conflicting resources..."

    # Only clean if not managed by current Terraform state
    EXISTING_RESOURCES=$(terraform state list 2>/dev/null || echo "")

    # Clean KMS alias if not in state
    if ! echo "$EXISTING_RESOURCES" | grep -q "aws_kms_alias"; then
        if aws kms list-aliases --query "Aliases[?AliasName=='alias/eks/healthcare-eks-stage3-dev']" --output text | grep -q alias/eks/healthcare-eks-stage3-dev; then
            echo "🗑️ Deleting existing KMS alias..."
            aws kms delete-alias --alias-name alias/eks/healthcare-eks-stage3-dev || echo "KMS alias deletion failed"
        fi
    fi

    # Clean CloudWatch log group if not in state
    if ! echo "$EXISTING_RESOURCES" | grep -q "aws_cloudwatch_log_group"; then
        if aws logs describe-log-groups --log-group-name-prefix "/aws/eks/healthcare-eks-stage3-dev" --query 'logGroups[0].logGroupName' --output text 2>/dev/null | grep -q '/aws/eks/healthcare-eks-stage3-dev'; then
            echo "🗑️ Deleting existing CloudWatch log group..."
            aws logs delete-log-group --log-group-name /aws/eks/healthcare-eks-stage3-dev/cluster || echo "Log group deletion failed"
        fi
    fi
}
```

## **🚨 Critical: NAT Gateway EIP Limit Solution**

Your NAT Gateway solution needs immediate implementation:

```hcl
# In terraform/modules/healthcare-platform/main.tf
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.cluster_name}-vpc"
  cidr = var.vpc_cidr

  azs             = slice(data.aws_availability_zones.available.names, 0, 3)
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway = true
  single_nat_gateway = true  # 🔧 ADD THIS - Uses only 1 NAT Gateway instead of 3
  enable_vpn_gateway = false
  enable_dns_hostnames = true
  enable_dns_support = true

  # Alternative: Reuse existing EIPs
  # reuse_nat_ips = true
  # external_nat_ip_ids = ["eip-12345", "eip-67890"]  # If you have existing EIPs
}
```

## **📋 Enhanced Pipeline Implementation**

Add this comprehensive step to your pipeline:

```yaml
- name: Handle Existing Infrastructure Conflicts
  working-directory: ${{ env.TERRAFORM_PATH }}/environments/dev
  run: |
    echo "🔍 Checking for infrastructure conflicts..."

    # Source the enhanced functions
    source ../../../scripts/deployment/handle-infrastructure-conflicts.sh

    # Choose strategy based on environment variable
    CONFLICT_STRATEGY="${{ vars.INFRASTRUCTURE_CONFLICT_STRATEGY || 'import' }}"

    case "$CONFLICT_STRATEGY" in
      "import")
        echo "📥 Using import strategy..."
        pre_import_existing_resources
        ;;
      "cleanup")
        echo "🧹 Using cleanup strategy..."
        cleanup_conflicting_resources
        ;;
      "skip")
        echo "⏭️ Skipping conflict handling..."
        ;;
      *)
        echo "❌ Invalid conflict strategy: $CONFLICT_STRATEGY"
        exit 1
        ;;
    esac

    echo "✅ Infrastructure conflict handling completed"
```

## **🎯 Recommended Implementation Order**

1. **Immediate (High Priority)**:
   ```bash
   # Fix NAT Gateway EIP limit
   # Add single_nat_gateway = true to VPC module
   ```

2. **Next (Medium Priority)**:
   ```bash
   # Implement enhanced pre-import logic
   # Add comprehensive error handling
   ```

3. **Future (Low Priority)**:
   ```bash
   # Add connectivity testing
   # Implement cleanup strategy option
   ```

## **🔧 Additional Monitoring**

Add pipeline monitoring for early detection:

```yaml
- name: Infrastructure Health Check
  run: |
    echo "🏥 Running infrastructure health check..."

    # Check EIP usage
    EIP_LIMIT=$(aws ec2 describe-account-attributes --attribute-names max-elastic-ips --query 'AccountAttributes[0].AttributeValues[0].AttributeValue' --output text)
    EIP_USED=$(aws ec2 describe-addresses --query 'Addresses | length(@)')
    echo "📊 EIP Usage: $EIP_USED / $EIP_LIMIT"

    if [[ $EIP_USED -ge $EIP_LIMIT ]]; then
      echo "⚠️ EIP limit reached - NAT Gateway creation will fail"
      echo "💡 Consider using single_nat_gateway = true"
    fi

    # Check for existing conflicting resources
    echo "🔍 Checking for potential conflicts..."
    aws kms list-aliases --query "Aliases[?AliasName=='alias/eks/healthcare-eks-stage3-dev']" --output table || echo "No KMS alias conflict"
    aws logs describe-log-groups --log-group-name-prefix "/aws/eks/healthcare-eks-stage3-dev" --query 'logGroups[].logGroupName' --output table || echo "No log group conflict"
```

---

## 🎯 Conclusion

Your troubleshooting analysis is **excellent** and shows deep understanding. The main enhancements needed are:

1. **✅ Immediate**: Fix NAT Gateway EIP limit with `single_nat_gateway = true`
2. **🔧 Important**: Enhance import logic with better error handling
3. **📊 Useful**: Add infrastructure health monitoring

**Your approach is fundamentally sound - these enhancements will make it production-ready!**
