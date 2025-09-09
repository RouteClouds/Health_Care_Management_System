## 9‑Sept Project Restart Strategy (Stage‑3 Advanced DevOps Pipeline)

### Executive Summary
We analyzed Stage‑3 across CI/CD, GitOps/Kubernetes, Terraform IaC, scripts, and documentation. The recurrent “Deploy Application” failures are primarily caused by mixing two ingress stacks (ALB + NGINX/NLB), fragile timing/ordering (ALB controller readiness, DB secret population), and brittle configuration (hardcoded FRONTEND_URL). To reduce cost and simplify operations, we removed NLB/ingress‑nginx from the pipeline and standardized on ALB only for the application. Observability UIs are now accessed via kubectl port‑forward by default (no external LB).

Immediate changes applied:
- Removed NLB installation and all NGINX ingress usage from CI workflow (cost + complexity reduction)
- Kept ALB ingress only for the app; GitOps ingress.yaml already uses `ingressClassName: alb`
- Eliminated hardcoded FRONTEND_URL in backend manifest; switched backend CORS to dynamic origin (reflects requester)
- Preserved existing DB secret creation and GitOps apply order; retained ALB controller installation earlier in pipeline

Result: A leaner, cheaper, and more reliable “Deploy Application” stage that avoids cross‑controller conflicts and fragile external URLs.

---

### 1) CI/CD Deep‑Dive — Why “Deploy Application” Fails
Key failure modes observed:
- Mixed ingress controllers (NGINX/NLB + AWS ALB)
  - Observability paths used NGINX ingress with path rewrites while the app used ALB. Provisioning both controllers leads to two LBs and flakiness when one is not fully ready.
- ALB controller readiness vs. app ingress timing
  - If ALB controller, CRDs, or IRSA permissions lag, app ingress provisioning fails/transitions to Error before the controller is stable.
- Fragile backend CORS configuration
  - backend.yaml hardcoded a previous ALB DNS in FRONTEND_URL; on a fresh environment this becomes invalid and blocks cross‑origin requests.
- Secrets/order sensitivity
  - Database Secret (RDS endpoint/credentials) must exist before Deployment rollout; otherwise readiness fails and the job times out.
- Dual apply sources
  - Workflow imperatively applied resources while ArgoCD also manages them. Poor sequencing can cause drift or rapid re‑conciliation.

Fixes implemented now:
- Removed NGINX/NLB from workflow; observability no longer exposes an external LB in CI. ALB remains the only external LB for the app.
- Kept app’s ALB ingress (ingress.yaml) and ensure controller is installed prior to apply.
- Backend CORS changed to dynamic (reflect request Origin) and manifest no longer hardcodes FRONTEND_URL.

Additional recommended hardening (proposed):
- Add explicit readiness gates:
  - `kubectl wait --for=condition=Available deployment/aws-load-balancer-controller -n kube-system --timeout=5m`
  - Wait for ingress to get an address: loop until `.status.loadBalancer.ingress[0].hostname` is set, with a bounded timeout.
- Ensure ArgoCD sync happens after imperative setup (namespace, secrets, CRDs) to avoid drift.
- Capture and print `kubectl describe ingress` and controller logs on failure for faster RCA.

---

### 2) IaC Idempotency & State Management Audit
Symptoms of duplicates:
- Re‑runs occasionally create extra VPCs, subnets, NAT gateways, or LBs when state and real infrastructure diverge.

Likely root causes:
- Partial or missing terraform import/guard for resources created outside Terraform (e.g., controllers creating LBs)
- Inconsistent tagging/naming not matching data lookups; data sources resolve to new resources instead of existing ones
- Backend state bootstrapping discrepancies when S3/table are recreated or read before consistent

Recommendations:
- Strengthen import guard in pipeline step (handle‑infrastructure‑conflicts.sh)
  - Before plan, scan for candidate resources by name/tags, try `terraform import` for any missing in state
  - Break the build on unimported conflicting resources rather than proceed to create duplicates
- Normalize tags and names across modules; prefer deterministic tags shared between data sources and resources
- Enforce one source of truth for cluster/VPC/subnets (no parallel creators)
- Ensure Terraform backend (S3 + DynamoDB) initialized once and reused; avoid generating random names on reruns
- Keep controller‑created cloud resources (ALB) strictly derived from managed Ingresses; avoid Services of type LoadBalancer

---

### 3) Scripts Audit & Classification
- Critical (Keep & improve)
  - scripts/cleanup/Script‑Destroy‑complete‑infrastructu.sh — now audit‑driven; verifies IDs; fallback discovery; final report
  - scripts/cleanup/audit‑aws‑resources.sh — source of truth for IDs; consider adding a JSON output for robust parsing
  - scripts/install‑aws‑load‑balancer‑controller.sh — required for ALB only approach
- Enhancement candidates
  - handle‑infrastructure‑conflicts.sh — expand imports/guards; fail fast on collisions
  - update‑database‑config.sh — ensure idempotent secret upserts and echo of effective values
- Archive candidates
  - Any NGINX/NLB installation/apply snippets (removed from CI); legacy k8s manifests not used by GitOps

---

### 4) Documentation Audit & Consolidation
- Already aligned
  - ALB‑Configuration‑Guide.md — prescribes ALB‑only; no NLB
  - Stage‑3‑observability‑doc.md — promotes port‑forward access; ingress optional
- Consolidate/Clarify
  - MASTER‑SETUP‑GUIDE.md / OPERATIONS.md — call out ALB‑only standard and that observability is internal by default in dev (port‑forward)
  - TROUBLESHOOTING.md — add a quick section: “If Deploy Application fails” with steps (check ALB controller, describe ingress, verify DB Secret)
- Archive
  - Any doc sections explicitly instructing NGINX/NLB or `type: LoadBalancer` Services for monitoring/logging

---

### 5) Cost Optimization — NLB Removal (Implemented)
- Removed Network Load Balancer usage entirely from CI workflow
- Observability (Grafana/Prometheus/Alertmanager/ArgoCD) is not exposed via external LB in dev; use port‑forward
- Application ingress remains on ALB only (grouped, internet‑facing, target‑type ip)

Benefits:
- Fewer external LBs (cost reduction)
- Simpler controller surface; eliminate cross‑controller conflicts

Trade‑offs:
- Observability requires `kubectl port-forward` for access in dev (acceptable for student/training environments). Production can later add host‑based ALB ingresses per tool if needed.

---

### 6) Actionable Remediation Checklist
Applied now:
- [x] Remove NLB/NGINX from stage3-ci workflow
- [x] Keep ALB ingress only for app
- [x] Remove hardcoded FRONTEND_URL from backend manifest
- [x] Backend CORS: reflect request origin (dynamic)

Next changes recommended:
- [ ] Add explicit waits for ALB controller and app ingress addressing
- [ ] Enhance handle‑infrastructure‑conflicts.sh to import/guard and fail fast
- [ ] Update MASTER‑SETUP‑GUIDE and OPERATIONS with ALB‑only + port‑forward defaults (observability)
- [ ] Add troubleshooting snippets (describe ingress, controller logs)

---

### 7) Risks & Mitigations
- CORS permissiveness (dev): reflecting request origin is convenient but looser. Mitigate by scoping allowed origins via env in production.
- Observability access UX: port‑forward is CLI‑centric. Mitigate by documenting a helper script and/or optional ALB ingresses with host‑based rules when DNS is available.

---

### 8) Summary & Go‑Forward Plan
- Standardize on ALB for external access; eliminate NLB to reduce cost and failure modes
- Keep observability internal by default; emphasize GitOps and consistent IaC
- Harden pipeline ordering and idempotency (imports, waits, diagnostics)
- Iterate documentation to reflect the simplified, reliable path

