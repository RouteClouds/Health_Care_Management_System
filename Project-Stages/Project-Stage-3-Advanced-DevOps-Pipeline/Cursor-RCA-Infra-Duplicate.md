## Cursor RCA: Infrastructure Duplicates During Stage-3 Pipeline

### Context
Multiple pipeline runs (while iterating on fixes) created duplicate AWS resources (VPCs, subnets, NAT gateways, log groups, KMS aliases, S3 buckets). Expected behavior is idempotent: detect/reuse existing resources and skip creation.

### Evidence (from latest audit)
- File: `scripts/cleanup/aws-resources-audit-20250820-133100.txt`
  - VPCs (same name): `healthcare-eks-stage3-dev-vpc` → 3 distinct VPC IDs
  - Subnets/RouteTables: copies across multiple VPCs with identical naming
  - NAT Gateways: 3 gateways (one per AZ) across a duplicate VPC
  - EKS cluster: 1 (`healthcare-eks-stage3-dev`)
  - RDS instance: 1 (`healthcare-eks-stage3-dev-db`)
  - S3 buckets: state + assets buckets exist

### Root Causes
1) Backend state non-idempotent (initially)
   - Behavior: New random suffix for backend bucket on each run created new state → Terraform did not “see” previously created resources.
   - Impact: Subsequent `terraform apply` planned “new” resources → duplicates.
   - Files implicated (historical): `.github/workflows/stage3-ci.yml` (Terraform backend setup section).

2) No import/use of already-existing resources
   - Behavior: When a resource (KMS alias, CW log group, RDS subnet group, S3 bucket) existed outside current state, apply attempted to create it again → AlreadyExists errors or drift.
   - Impact: Re-runs either fail or (for resources without uniqueness constraints) create parallel infra (e.g., additional networking constructs).
   - Files: Terraform modules under `terraform/modules/healthcare-platform` and EKS module dependencies.

3) VPC/NAT configuration not constrained for CI limits
   - Behavior: Default VPC module created multiple NAT gateways and EIPs; repeated runs hit EIP limits or left extra gateways in duplicate VPCs.
   - Impact: `AddressLimitExceeded` and cost increase.
   - Files: VPC variables in `terraform/environments/dev` (values) and/or module defaults.

4) Mixed LB creation paths during transition to ALB
   - Behavior: Service type `LoadBalancer` and other components could result in NLB/Classic LBs depending on controller; duplicates persisted between runs.
   - Impact: Extra load balancers remained when app redeployed with different exposure method.
   - Files: GitOps manifests prior to standardization.

5) Workflow orchestration lacked conflict handling
   - Behavior: Pipeline stages continued with creation paths even when AWS already had the resource and it was not yet in state.
   - Impact: Failures or duplicates instead of importing/using existing.
   - Files: `.github/workflows/stage3-ci.yml` (pre-apply checks/imports were missing initially).

### Fixes Implemented
1) Backend bucket discovery (idempotent)
   - File: `.github/workflows/stage3-ci.yml`
   - Change: Discover existing `healthcare-terraform-state-stage3-{accountId}-*` bucket; only create a new one if none found. Output bucket/table and reuse for init.

2) ALB-only exposure
   - Files:
     - `gitops/environments/dev/frontend.yaml` → Service `ClusterIP` (was `LoadBalancer`).
     - `gitops/environments/dev/ingress.yaml` → ALB annotations set (`kubernetes.io/ingress.class: alb`, etc.).
     - `.github/workflows/stage3-ci.yml` → Install eksctl + ALB controller.

3) DB setup hardening (prevents sed errors and wrong endpoints)
   - Files:
     - `scripts/deployment/update-database-config.sh` → Validate Terraform output, AWS CLI fallback, hostname validation, prefer live Secret update.
     - `.github/workflows/stage3-ci.yml` → Prefetch RDS endpoint override; Terraform state/outputs validation step.

4) Infrastructure existence checks
   - File: `.github/workflows/stage3-ci.yml` → Added explicit checks for existing EKS cluster, RDS instance, VPC to gate expectations and logs.

### Additional Remediations Proposed (to eliminate duplicates)
1) Pre-import existing resources before apply (idempotent recovery)
   - Add a pre-import step in Deploy Infrastructure to import known existing resources when detected by AWS CLI:
     - KMS Alias: `module.healthcare_infrastructure.module.eks.module.kms.aws_kms_alias.this["cluster"] ← alias/eks/healthcare-eks-stage3-dev`
     - CW Log Group: `module.healthcare_infrastructure.module.eks.aws_cloudwatch_log_group.this[0] ← /aws/eks/healthcare-eks-stage3-dev/cluster`
     - RDS Subnet Group: `module.healthcare_infrastructure.aws_db_subnet_group.healthcare ← healthcare-eks-stage3-dev-db-subnet-group`
     - S3 Assets Bucket: `module.healthcare_infrastructure.aws_s3_bucket.healthcare_assets ← healthcare-assets-stage3-dev-{ACCOUNT_ID}`
   - Benefit: Brings drifted/existing resources under state management; avoids AlreadyExists and duplicates.

2) Constrain NAT/EIP usage
   - Set VPC module variables to reduce NAT to single gateway for dev:
     - `single_nat_gateway = true`
     - Optionally `reuse_nat_ips = true` with `external_nat_ip_ids` to reuse EIPs.
   - Location: `terraform/environments/dev` values or module variable overrides.

3) Prefer data sources over resources for fixed/shared components
   - Where supported by modules, switch to `data` references for pre-provisioned items (e.g., existing S3 bucket, KMS alias, log group) or expose module flags to disable creation.

4) Defensive lifecycle controls (where necessary)
   - Add `lifecycle { prevent_destroy = true }` or `ignore_changes` on attributes that should not force recreation (only where safe and intentional).

### Expected Behavior After Remediation
1) First run: backend detected/created → infrastructure created → app deployed via ALB.
2) Subsequent runs: backend reused → resources detected/imported as needed → no duplicate creations → apply becomes no-op/small diffs.

### Conclusive Root Cause Summary
- Primary: Non-idempotent backend state creation initially caused Terraform to lose sight of existing resources.
- Secondary: Lack of import/conditional logic led to re-creation attempts and duplicates; networking defaults (multi-NAT) collided with EIP limits.
- Tertiary: Transitioning exposure to ALB while running caused mixed load balancer types to persist.

### Concrete File/Path Index
- Workflow orchestration:
  - `.github/workflows/stage3-ci.yml` → Backend detection, infra checks, ALB controller install, Terraform state/output validation, RDS endpoint override.
- GitOps exposure:
  - `gitops/environments/dev/frontend.yaml` → `spec.type: ClusterIP`
  - `gitops/environments/dev/ingress.yaml` → ALB annotations
- DB setup:
  - `scripts/deployment/update-database-config.sh` → Robust endpoint resolution and Secret update
- Terraform backend/config:
  - `terraform/backend.tf` (templated backend)
  - `terraform/environments/dev/providers.tf` (no hardcoded backend; providers)
- Cleanup/Audit:
  - `scripts/cleanup/audit-aws-resources.sh` and generated audit report (see Evidence)

### Verification Plan
1) Run pre-import step once; re-run `terraform plan` must show zero “to add” for imported resources.
2) Enable `single_nat_gateway = true`; re-run plan shows no new EIPs/NAT.
3) Re-run pipeline twice; verify no additional VPCs/NAT/Log Groups/ALBs created.
4) Confirm app remains accessible via a single ALB hostname.

### Notes
For long-lived drift, consider one-time execution of `scripts/cleanup/comprehensive-cleanup-orchestrator.sh` in `duplicates` mode to retire duplicate VPCs/NAT resources safely, then stabilize state imports.






