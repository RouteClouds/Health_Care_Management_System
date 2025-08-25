# RCA - Duplicate Infrastructure & State Drift (Stage-3)

## Problem Statement
Repeated pipeline runs created duplicate resources (VPCs, NAT GWs, LBs) and failed with EKS ResourceInUseException due to control plane conflicts.

## Root Causes
- Terraform state not aligned with existing infrastructure (missing imports)
- No preflight collision checks → attempted fresh creates
- EKS cluster preservation not configured, leading to replacement attempts

## Impact
- Deployment failures and instability
- Cost overruns (duplicate NAT GWs/EIPs/LBs)

## Mitigations Implemented
- Preflight collision detection integrated in CI
- Safety guard to limit mass creates
- Post-failure diagnostics (dry-run cleanup job)
- Terraform module parameterized for preservation of existing EKS cluster

## Current Strategy
- First-time creation path: preserve=false → create cluster
- Post-creation: preserve=true with wired ARNs/SGs to avoid replacement

## Recommended Practices
- Always run preflight before plan/apply
- Import existing resources where appropriate; otherwise, preserve
- Keep Ansible disabled until infra is stable; rely on backend seeding

## Verification
- Plans show expected creates only; no EKS replacement after preservation
- App health checks succeed and data is seeded by backend

