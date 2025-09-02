# Stage-3B Observability Stack – Planning & Implementation (Temporary Working Doc)

Purpose: This working document tracks planning, scope, technical specs, and delivery of the Stage‑3 Observability stack via GitOps (ArgoCD‑first, idempotent, cost‑aware).

Status: DRAFT (to be iterated during implementation)
Owner: DevOps Team

---

## Primary Reference Documents
- RoadMap-For-Stage-3.md (Primary driver for this phase: “Stage‑3B – Enterprise Observability”)
- ARCHITECTURE-guide.md (Context diagrams and system layout)
- OPERATIONS.md (Will host Monitoring Operations runbooks; keep in sync)
- TROUBLESHOOTING.md (Will host observability troubleshooting; keep in sync)
- README.md (Documentation index for discoverability)

---

## Objectives & Principles
- Full‑fidelity visibility for metrics, logs, and traces
- GitOps-first (ArgoCD Applications), idempotent and repeatable
- Cost‑aware defaults (bounded retention, right‑sized PVs/requests)
- Minimal friction for operators (curated dashboards, actionable alerts)
- Secure access (RBAC & NetworkPolicies), no plain‑text secrets in repo

---

## Target Architecture (Dev profile)
Namespaces:
- monitoring: Prometheus, Alertmanager, Grafana, kube-state-metrics, node-exporter
- logging: Elasticsearch (single-node dev), Fluent Bit (DaemonSet), Kibana
- tracing: Jaeger all-in-one (Collector, Query, UI)

Storage (gp3 EBS):
- Prometheus: 50–100Gi, retention 15d (dev)
- Elasticsearch: 50–100Gi, retention 7d (dev)
- Jaeger (dev all-in-one): in‑cluster storage (no PV) or small PV (optional)

Networking & Access:
- Ingress via existing ALB controller if UI exposure is required (Grafana/Kibana/Jaeger)
- RBAC for read-only viewers vs. admins
- NetworkPolicies to restrict cross‑namespace access to UIs and backends

Security & Secrets:
- Alertmanager receivers via K8s Secrets (consider SealedSecrets/SOPS if repo storage is required)
- No plain‑text secrets in Git

---

## GitOps Integration (ArgoCD)
Structure (proposed):
- gitops/
  - observability/
    - monitoring/ (kube-prometheus-stack)
      - application.yaml (ArgoCD Application)
      - values-dev.yaml
    - logging/ (EFK)
      - application.yaml
      - values-dev.yaml
    - tracing/ (Jaeger)
      - application.yaml
      - values-dev.yaml
- Sync order: CRDs and operators first, then CRs (use ArgoCD sync-waves/health checks)

Helm Charts:
- Metrics/Alerting: kube-prometheus-stack (Prometheus, Alertmanager, Grafana)
- Logging: Elastic Helm charts (Elasticsearch, Kibana) + Fluent Bit (or Elastic Agent; prefer Fluent Bit)
- Tracing: Jaeger (all-in-one for dev)

Idempotency:
- All configuration via values files; no ad-hoc kubectl
- Stable resource names and labels to avoid duplicates

---

## Technical Specifications
Metrics & Alerting (kube-prometheus-stack):
- Prometheus persistence enabled; retention: 15d
- kube-state-metrics + node-exporter enabled
- Alertmanager enabled; receivers configurable via Secret
- Grafana admin secret via K8s Secret; curated dashboards imported at start
- ServiceMonitor for backend API (expose /metrics); scrapeInterval: 15–30s

Dashboards:
- Kubernetes/Nodes/Pods/Cluster/ETCD/API Server (standard)
- App dashboard: HTTP RPS, p95 latency, error rate (%5xx/%4xx), DB latency/connection pool, pod restarts

Logging (EFK):
- Elasticsearch: single‑node dev, JVM heap ~1–2Gi (tuned), 50–100Gi PV, 7d ILM retention
- Fluent Bit: Tail container logs, add k8s metadata, parse JSON logs, exclude noisy namespaces as needed
- Kibana: basic auth; index patterns preconfigured

Tracing (Jaeger):
- Dev: all-in-one with default sampling; expose UI for developers
- Backend: OpenTelemetry SDK (Node.js) to instrument HTTP/Express and Prisma/pg as available

Security & Access:
- NetworkPolicies to restrict UI access (Grafana/Kibana/Jaeger) to admin IP ranges or VPN (configurable)
- RBAC roles: viewer and admin bindings per namespace

Cost Controls:
- Conservative retention defaults
- Right‑size requests/limits; avoid oversubscription
- Option flags to disable heavy components in dev

Acceptance (MVP):
- Prometheus scraping k8s + backend metrics; Grafana accessible; at least one alert firing in test
- Fluent Bit shipping application logs; searchable in Kibana with namespace/pod fields
- (Optional for MVP) Jaeger endpoints accept spans; traces visible for sample requests

---

## Detailed Timeline & Workstreams
Note: Ranges assume typical EKS dev cluster; items can run in parallel.

1) Foundations (0.5–1 day)
- Create namespaces (monitoring, logging, tracing) and baseline RBAC
- Validate StorageClasses (gp3) and capacity; decide PV sizes
- Define ArgoCD Applications structure and sync-waves
Acceptance: Namespaces present; storage plan documented; ArgoCD Apps skeletons in repo

2) Metrics & Alerting (1.5–2.5 days)
- Add kube-prometheus-stack Application + values
- Enable Prometheus persistence; set retention; enable kube-state-metrics/node-exporter
- Configure Alertmanager (placeholder receiver); expose Grafana (Ingress/port-forward)
- Add ServiceMonitor for backend; verify targets are up
Acceptance: Grafana dashboards populated; Alertmanager alerts fire in test; backend metrics visible

3) Dashboards (0.5–1 day)
- Import curated k8s dashboards (nodes, pods, cluster, API server)
- Add custom app dashboard (latency, error rate, DB metrics)
Acceptance: Dashboards render data and are navigable from Grafana home

4) Centralized Logging – EFK (1.5–2.5 days)
- Deploy Elasticsearch + Kibana (Helm) via ArgoCD; size PV; set ILM to ~7d
- Deploy Fluent Bit DaemonSet; add k8s metadata; parse JSON
- Validate new pod logs visible within 30–60s; add saved searches
Acceptance: Logs searchable by namespace/pod/level; storage usage within plan; ILM active

5) Tracing – Jaeger (1–2 days)
- Deploy Jaeger all‑in‑one via ArgoCD
- Instrument backend with OpenTelemetry; export to Jaeger
- Validate end‑to‑end traces for key endpoints
Acceptance: Traces present in Jaeger UI (HTTP handler → DB spans)

6) Security & Access (0.5–1 day)
- RBAC profiles for viewers/admins
- NetworkPolicies to restrict UIs
- Secrets managed via K8s Secret (optionally SealedSecrets/SOPS)
Acceptance: Only authorized roles reach UIs; secrets not present in plain‑text in repo

7) Documentation & Runbooks (0.5–1 day)
- Create docs/Observability/OBSERVABILITY-GUIDE.md (new) – architecture, access, retention, limits
- Update OPERATIONS.md (Monitoring Operations), TROUBLESHOOTING.md (observability issues)
Acceptance: A new operator can locate and use UIs, dashboards, alerts, and logs

8) Validation & Tuning (0.5–1 day)
- Smoke tests: verify metrics/alerts/logs/traces
- Tune noisy alerts; verify cost targets (PV usage, CPU/mem)
Acceptance: Healthy ArgoCD apps; stable alerts; cost within envelope

---

## Delivery Options
- Minimal Viable Observability (3–5 working days)
  - Metrics + Grafana with k8s/app metrics, baseline alerting
  - EFK logs with 7d retention and basic parsing
  - Optional: lightweight Jaeger preview (if time permits)

- Full Stack (7–10 working days)
  - Metrics, curated dashboards, actionable alerts
  - EFK with tuned retention and saved views
  - Jaeger tracing with backend instrumentation
  - RBAC/NetworkPolicies, docs/runbooks, validation

---

## Risks & Potential Schedule Impacts
- Alertmanager channels (Slack/Email) access delays
- Cluster capacity/storage constraints (PV quotas, node sizing)
- Scope of custom dashboards and SLO definitions
- GitOps reconciliation issues (CRDs ordering, health checks)
- Elasticsearch resource pressure; consider sizing or Loki alternative later

Mitigations:
- Start with placeholders for receivers; switch to real channels when credentials are ready
- Conservative defaults; monitor usage; iterate
- Define minimal SLOs first; expand later
- Use ArgoCD sync-waves and readiness gates for CRDs/Controllers

---

## Immediate Next Steps
- Confirm Alertmanager channel (Slack or Email) and provide credentials (or approve placeholder)
- Approve dev retention/sizing defaults:
  - Prometheus: 15d, 50–100Gi PV
  - Elasticsearch: 7d, 50–100Gi PV
- Approve GitOps folder layout under gitops/observability/*
- After approval: prepare ArgoCD Applications + values and begin rollout

