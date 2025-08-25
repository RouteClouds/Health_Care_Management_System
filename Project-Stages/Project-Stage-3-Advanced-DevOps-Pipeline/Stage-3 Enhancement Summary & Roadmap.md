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

