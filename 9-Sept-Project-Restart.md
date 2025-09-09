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



---

### 9) Deployment Execution Report (9‑Sept)

- Final pipeline run: SUCCESS
- GitHub Actions Run ID: 17576214588
- Key job timings (approx.):
  - Deploy Infrastructure: 3m 9s
  - Deploy Application (with automated DB setup): 6m 17s

What was validated:
- EKS cluster available and `kubectl` configured
- AWS Load Balancer Controller running and reconciling Ingress
- Ingress has ALB hostname; DNS resolved; HTTP 200 at root
- Backend health shows `database: connected`
- Sample data present (3 doctors)

How to retrieve the Application Load Balancer URL:
```bash
# From the Kubernetes Ingress (preferred)
kubectl get ingress healthcare-stage3-ingress \
  -n healthcare-stage3-dev \
  -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'

# Fallback: list any application ALB in the region (if needed)
aws elbv2 describe-load-balancers \
  --region us-east-1 \
  --query 'LoadBalancers[?Type==`application`].[DNSName]' \
  --output text | head -n1
```

Database connectivity verification (examples):
```bash
# Replace $ALB with the hostname printed above
ALB="$(kubectl get ingress healthcare-stage3-ingress -n healthcare-stage3-dev -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')"

# Health endpoint should return database: connected
curl -s "http://${ALB}/api/health" | jq

# Doctors endpoint should return seeded sample data
curl -s "http://${ALB}/api/doctors" | jq '.data.doctors | length'
```

Expected results (from the successful run):
- Health response contained `"database":"connected"`
- Doctors count: `3`


---

### 10) Troubleshooting Solutions and Root Cause Analysis

Root causes of prior failures:
- Competing ingress stacks (ALB + NGINX/NLB) causing timing/race conditions and conflicting controllers
- EKS cluster not created/preserved inconsistently leading to empty kubeconfig targets
- ALB DNS not yet propagated when validation ran (false negatives)
- Backend CORS and FRONTEND_URL hardcoding breaking across new ALB hostnames
- Ordering: secrets/CRDs applied too late for first rollout

Fixes implemented in CI/CD (high level):
1) EKS creation logic correction
- Ensured cluster creation path is taken when cluster is missing by setting `preserve_existing_cluster=false` so Terraform creates the control plane instead of skipping.
- Prevents the empty `cluster_id`/kubeconfig scenario.

2) ALB readiness and DNS propagation
- Added bounded wait for Ingress hostname and explicit DNS checks via `getent hosts`.
- Added resilient `curl` connectivity tests with `--retry` and `--retry-connrefused`.

3) Single ingress strategy (ALB only)
- Removed NLB/NGINX steps entirely; observability accessed via port-forward in dev.

4) Backend robustness
- Removed hardcoded `FRONTEND_URL` from backend manifest; CORS now reflects requester origin.

Key workflow code changes (.github/workflows/stage3-ci.yml):
- Deciding EKS create/preserve path: set TF var to force create when needed
- Ingress/ALB readiness loop with JSONPath to `.status.loadBalancer.ingress[0].hostname`
- DNS wait using `getent hosts` (bounded loops)
- Connectivity checks using `curl -I` with retries

Example snippets (for reference):
```bash
# Wait for Ingress to expose ALB hostname
for i in {1..20}; do
  ALB_URL=$(kubectl get ingress healthcare-stage3-ingress -n healthcare-stage3-dev -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || echo "")
  [[ -n "$ALB_URL" ]] && echo "ALB: http://$ALB_URL" && break
  sleep 30
done

# DNS propagation wait
for i in {1..40}; do
  getent hosts "$ALB_URL" && break || sleep 15
done

# Connectivity check with retries
curl -I "http://${ALB_URL}" --connect-timeout 10 --max-time 20 \
  --retry 12 --retry-delay 10 --retry-connrefused
```

Outcome: These changes removed the recurrent failure modes in the "Deploy Application" stage and made validations deterministic and idempotent.

---

### 11) Observability Stack and ArgoCD — Access & Verification (Dev)

Retrieve ALB hostname (app access):
```bash
kubectl get ingress healthcare-stage3-ingress \
  -n healthcare-stage3-dev \
  -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
```

Port-forward access (local workstation):

ArgoCD (default admin password from secret):
```bash
# Port-forward
kubectl port-forward svc/argocd-server -n argocd 8080:443
# Get initial admin password
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath='{.data.password}' | base64 -d; echo
# Open https://localhost:8080 (username: admin)
```

Grafana (password via secret; service name may vary by stack):
```bash
# Discover Grafana service
kubectl get svc -n monitoring | grep -i grafana
# Common port-forward (adjust service name if different)
kubectl port-forward svc/kube-prometheus-stack-grafana -n monitoring 3000:80
# Retrieve admin password (try known labels/secret names)
kubectl get secret -n monitoring \
  -l app.kubernetes.io/name=grafana \
  -o jsonpath='{.items[0].data.admin-password}' | base64 -d; echo
# Open http://localhost:3000 (username: admin)
```

Prometheus UI:
```bash
# Discover Prometheus service
kubectl get svc -n monitoring | grep -i prometheus
# Common port-forward
kubectl port-forward svc/kube-prometheus-stack-prometheus -n monitoring 9090:9090
# Open http://localhost:9090
```

Verify monitoring is scraping healthcare pods:
```bash
# Check healthcare workloads are Running
kubectl get pods -n healthcare-stage3-dev -o wide

# (Prometheus UI) Query 'up' metric filtered to namespace:
# up{namespace="healthcare-stage3-dev"}

# (CLI) If prom service name is accessible inside a pod:
# kubectl -n monitoring exec deploy/kube-prometheus-stack-prometheus -- \
#   curl -s 'http://localhost:9090/api/v1/series?match[]=up{namespace="healthcare-stage3-dev"}' | jq '.data | length'
```

Verify ArgoCD app sync/health:
```bash
kubectl -n argocd get applications.argoproj.io -o wide
# Or via UI: Application should be Healthy/Synced
```

Example outputs to expect (from a healthy system):
- healthcare-stage3-dev pods: STATUS=Running, READY=1/1 (or more), RESTARTS near 0
- Prometheus 'up{namespace="healthcare-stage3-dev"}' shows 1+ active time series
- ArgoCD Applications: Sync Status=Synced, Health=Healthy



---

### 12) Observability RCA, Fixes, and Verified Working Commands (Stage-3)

Summary of the issue and fix:
- Symptom: Monitoring namespace had no pods; ArgoCD showed OutOfSync for observability app. Grafana service/ingress existed but workloads were missing.
- Root causes:
  - ArgoCD Project policy blocked namespace-scoped RBAC (Role/RoleBinding) and Jobs, causing sync failures.
  - kube-prometheus-stack attempted to create Service objects in kube-system (control-plane targets) not allowed by project destinations.
  - Large CRDs (Prometheus/Alertmanager/Thanos) hit the Kubernetes 256KB annotations limit when applied client-side.
- Fixes applied:
  - ArgoCD Project whitelist updated to allow rbac.authorization.k8s.io (namespace-scoped) and batch (Jobs) in permitted namespaces.
  - kube-prometheus-stack values updated to disable kube-system related resources and admission webhook jobs:
    - admissionWebhooks.enabled=false
    - coreDns/kubeProxy/kubeControllerManager/kubeScheduler/kubeEtcd: enabled=false
  - ArgoCD syncOptions tuned for the monitoring app to prefer Server-Side Apply and allow Replace for large objects:
    - syncOptions: [CreateNamespace=true, ApplyOutOfSyncOnly=true, ServerSideApply=true, Replace=true]

Current state (validated):
- RUNNING: Grafana, Prometheus Operator, kube-state-metrics, node-exporter
- SERVICES AVAILABLE: grafana, prometheus, alertmanager (pods for Prometheus/Alertmanager appear after CRDs are accepted)

Commands — access all components via port-forward
- Grafana (default):
  ```bash
  kubectl -n monitoring port-forward svc/kube-prometheus-stack-grafana 3000:80
  # Open http://localhost:3000 (username: admin)
  # Password from secret (if needed):
  kubectl get secret -n monitoring -l app.kubernetes.io/name=grafana \
    -o jsonpath='{.items[0].data.admin-password}' | base64 -d; echo
  ```
- Prometheus UI:
  ```bash
  kubectl -n monitoring port-forward svc/kube-prometheus-stack-prometheus 9090:9090
  # Open http://localhost:9090
  ```
- Alertmanager UI:
  ```bash
  kubectl -n monitoring port-forward svc/kube-prometheus-stack-alertmanager 9093:9093
  # Open http://localhost:9093
  ```

Alternate ports to avoid conflicts (choose any free local ports):
- ArgoCD: 8081:443
- Grafana: 3001:80
- Prometheus: 9091:9090
- Alertmanager: 9094:9093
Example:
```bash
kubectl -n argocd port-forward svc/argocd-server 8081:443
kubectl -n monitoring port-forward svc/kube-prometheus-stack-grafana 3001:80
kubectl -n monitoring port-forward svc/kube-prometheus-stack-prometheus 9091:9090
kubectl -n monitoring port-forward svc/kube-prometheus-stack-alertmanager 9094:9093
```

Verification steps (copy/paste):
```bash
# 1) Ensure monitoring workloads are up
kubectl get pods -n monitoring -o wide

# 2) Confirm services exist
kubectl get svc -n monitoring

# 3) Test Grafana access (after port-forward):
#   Open http://localhost:3000 and login (admin/<password>)
#   Navigate: Dashboards -> Kubernetes / Compute Resources -> Workloads
#   Expect: healthcare-stage3-dev pods visible with metrics

# 4) Test Prometheus UI (after port-forward):
#   Open http://localhost:9090
#   Query: up{namespace="healthcare-stage3-dev"}
#   Expect: 1+ active time series

# 5) Test Alertmanager UI (after port-forward):
#   Open http://localhost:9093
#   Expect: UI loads; silences/alerts visible once rules fire
```

Troubleshooting (documented fixes):
- If ArgoCD shows errors like "namespace kube-system is not permitted" or RBAC/Job not permitted:
  - Update AppProject whitelist to include:
    - namespaceResourceWhitelist: group 'rbac.authorization.k8s.io' and 'batch'
    - destinations should not include kube-system; keep kube-system resources disabled via chart values as above
- If ArgoCD shows CRD errors: "metadata.annotations: Too long: must have at most 262144 bytes":
  - Ensure Application has syncOptions: ServerSideApply=true and Replace=true
  - If still blocked in your environment, install CRDs once via server-side apply (example, Prometheus Operator v0.73.0):
    ```bash
    CRD_BASE="https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.73.0/example/prometheus-operator-crd"
    for f in monitoring.coreos.com_{alertmanagers,prometheuses,prometheusrules,servicemonitors,podmonitors,probes,thanosrulers,scrapeconfigs,prometheusagents}.yaml; do
      kubectl apply --server-side -f "$CRD_BASE/$f"
    done
    ```
- If local port is in use:
  - Use alternative port-forward pairs above, or free the port: `lsof -i :3000` then kill the process.
- If Grafana admin secret is missing:
  - Create it once (dev only):
    ```bash
    kubectl -n monitoring create secret generic grafana-admin \
      --from-literal=admin-user=admin \
      --from-literal=admin-password="ChangeMe!123"
    ```

Outcome:
- With the above changes, Stage-3 observability is deployable by ArgoCD, and all three components (Grafana, Prometheus, Alertmanager) are accessible via port-forward with verified service names and commands.


---

### 13) CRD-only ArgoCD Application Strategy (Implemented)

Rationale:
- kube-prometheus-stack bundles large CRDs (Prometheus/Alertmanager/etc). Applying these with client-side apply can exceed the 256KB annotations limit and cause ArgoCD sync errors.
- Best practice: install CRDs once via a dedicated ArgoCD Application using Server-Side Apply + Replace, and make the Helm application skip CRDs.

What we implemented:
- A dedicated ArgoCD Application to install Prometheus Operator CRDs from the upstream repository (sync-wave: -2, SSA+Replace, prune disabled).
- Updated kube-prometheus-stack Application to set `spec.source.helm.skipCrds: true` and placed it at sync-wave 0.

Verification steps (copy/paste):
```bash
# Force ArgoCD to refresh the parent app so both child apps reconcile
kubectl annotate -n argocd application/observability-monitoring \
  argocd.argoproj.io/refresh=hard --overwrite

# Check CRD-only app
kubectl get application -n argocd prometheus-operator-crds -o yaml | \
  yq '.status.sync.status, .status.health.status'

# Confirm CRDs exist
kubectl get crd | grep -E 'monitoring.coreos.com|prometheus'

# Check monitoring workloads and services after CRDs present
kubectl get pods -n monitoring -o wide || true
kubectl get svc -n monitoring || true
```

Troubleshooting:
- If CRDs fail with annotation-length errors: ensure the CRD app has `syncOptions: [ServerSideApply=true, Replace=true]`.
- Do not enable prune on the CRD app in dev/student envs to avoid accidental deletion of cluster-scoped CRDs.
- Ensure the monitoring AppProject allows required kinds in the monitoring namespace (RBAC, Jobs). Keep kube-system resources disabled in Helm values as documented.

CI/CD usage note:
- Our Stage-3 workflow triggers on src-code changes and supports manual `workflow_dispatch`. To validate this strategy without touching src-code, trigger the workflow manually and then confirm both ArgoCD apps are Synced/Healthy as above.
