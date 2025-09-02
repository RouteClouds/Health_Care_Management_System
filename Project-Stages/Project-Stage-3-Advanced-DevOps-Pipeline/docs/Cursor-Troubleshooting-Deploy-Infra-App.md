## Cursor Troubleshooting: Deploy Infra & App

This document captures the last two pipeline issues and the current Deploy Infrastructure failure, with root causes and implemented/proposed fixes.

### Issue 1: AWS Load Balancer Controller install failed (eksctl missing)
- Symptoms: `eksctl: command not found`, `helm upgrade ... context deadline exceeded`.
- Root cause: Controller install script requires eksctl to create the IAM service account; runner lacked eksctl.
- Fix (implemented):
  - Install eksctl in the workflow before running the controller script.
  - Keep Helm `--wait` and verify controller rollout.

### Issue 2: Deploy App with Automated DB Setup failed (Terraform outputs → sed error)
- Symptoms: Terraform printed `Warning: No outputs found`; script captured warning as RDS endpoint; `sed ... unterminated 's'`.
- Root cause: Script treated stdout (warning) as endpoint; no validation; unsafe sed.
- Fix (implemented):
  - Validate Terraform output strictly; accept only values ending with `.rds.amazonaws.com`.
  - Add AWS CLI fallback (direct identifier + pattern search).
  - Validate hostname format before sed; exit if invalid.
  - Update live Secret when available, else update manifest.
  - Added pipeline step to prefetch RDS endpoint via AWS CLI and pass `RDS_ENDPOINT_OVERRIDE`.
  - Added Terraform state/outputs validation step before DB setup.

### Issue 3: Deploy Infrastructure failed with AlreadyExists and limits
- Errors:
  - KMS Alias: `AlreadyExistsException: alias/eks/healthcare-eks-stage3-dev`.
  - CloudWatch Log Group: `ResourceAlreadyExistsException: /aws/eks/healthcare-eks-stage3-dev/cluster`.
  - EC2 EIP: `AddressLimitExceeded` during NAT EIP allocation.
  - RDS DB Subnet Group: `DBSubnetGroupAlreadyExists`.
  - S3 Bucket: `BucketAlreadyExists` for `healthcare-assets-stage3-dev-867344452513`.
- Root cause: Resources created by earlier run(s) exist outside current Terraform state; apply tries to recreate. NAT EIP limit reached.
- Solutions (proposed, idempotent):
  1) Pre-import existing resources before `terraform apply`:
     - Detect with AWS CLI; `terraform import` known addresses if present.
     - Examples (adjust module paths to your code):
       - KMS alias: `terraform import module.healthcare_infrastructure.module.eks.module.kms.aws_kms_alias.this["cluster"] alias/eks/healthcare-eks-stage3-dev`
       - CW log group: `terraform import module.healthcare_infrastructure.module.eks.aws_cloudwatch_log_group.this[0] /aws/eks/healthcare-eks-stage3-dev/cluster`
       - RDS subnet group: `terraform import module.healthcare_infrastructure.aws_db_subnet_group.healthcare healthcare-eks-stage3-dev-db-subnet-group`
       - S3 assets bucket: `terraform import module.healthcare_infrastructure.aws_s3_bucket.healthcare_assets healthcare-assets-stage3-dev-ACCOUNT_ID`
  2) For NAT EIP `AddressLimitExceeded`:
     - Prefer reducing NAT gateways: set `single_nat_gateway = true` in VPC module variables.
     - Or reuse existing NAT EIPs: set `reuse_nat_ips = true` and provide `external_nat_ip_ids`.
     - Alternatively, clean up unused EIPs (audit script can help).
  3) Optional module flags to avoid recreation where supported:
     - If the EKS module exposes flags (e.g., `create_cloudwatch_log_group`, `create_kms_key`), disable creation and reference existing via data sources.

### What was done so far
- Added eksctl install step; controller install succeeds with rollout checks.
- Hardened DB setup script; added AWS CLI override; added Terraform state/output validation.
- ALB-only ingress path implemented (Service=ClusterIP + Ingress annotations).

### Next steps
1) Add a pre-import step before `terraform apply` in Deploy Infrastructure to import existing KMS alias, CW log group, RDS subnet group, and S3 bucket when detected.
2) Set `single_nat_gateway = true` (or reuse NAT EIPs) to avoid EIP allocation limit.
3) Re-run the pipeline.

### Optional: Pre-import step snippet (in workflow)
```bash
# Detect and import existing infra to prevent AlreadyExists errors
set -e

# KMS alias
if aws kms list-aliases --query "Aliases[?AliasName=='alias/eks/healthcare-eks-stage3-dev']" --output text | grep -q alias/eks/healthcare-eks-stage3-dev; then
  terraform import -no-color \
    module.healthcare_infrastructure.module.eks.module.kms.aws_kms_alias.this["cluster"] \
    alias/eks/healthcare-eks-stage3-dev || true
fi

# CloudWatch log group
if aws logs describe-log-groups --log-group-name-prefix "/aws/eks/healthcare-eks-stage3-dev/cluster" --query 'logGroups[0].logGroupName' --output text | grep -q '/aws/eks/healthcare-eks-stage3-dev/cluster'; then
  terraform import -no-color \
    module.healthcare_infrastructure.module.eks.aws_cloudwatch_log_group.this[0] \
    /aws/eks/healthcare-eks-stage3-dev/cluster || true
fi

# RDS subnet group
if aws rds describe-db-subnet-groups --db-subnet-group-name healthcare-eks-stage3-dev-db-subnet-group >/dev/null 2>&1; then
  terraform import -no-color \
    module.healthcare_infrastructure.aws_db_subnet_group.healthcare \
    healthcare-eks-stage3-dev-db-subnet-group || true
fi

# S3 assets bucket
ASSETS_BUCKET="healthcare-assets-stage3-dev-$(aws sts get-caller-identity --query Account --output text)"
if aws s3api head-bucket --bucket "$ASSETS_BUCKET" 2>/dev/null; then
  terraform import -no-color \
    module.healthcare_infrastructure.aws_s3_bucket.healthcare_assets \
    "$ASSETS_BUCKET" || true
fi
```


