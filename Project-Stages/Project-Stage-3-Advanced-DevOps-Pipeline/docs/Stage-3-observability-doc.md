# Stage‑3 Observability – Complete Guide (MVP)

Purpose
- A single, student‑friendly reference for deploying and using the Stage‑3 Observability stack via GitOps
- Covers architecture, setup, credentials, pipeline integration, verification, and troubleshooting

Applies To
- EKS dev environment for Stage‑3 Healthcare Management System
- MVP scope: Metrics (Prometheus/Grafana/Alertmanager) + Logs (EFK). Tracing (Jaeger) is post‑MVP

---

## 1) Architecture Overview

Components (MVP)
- Metrics & Alerting: kube‑prometheus‑stack (Prometheus, Alertmanager, Grafana)
- Logging: EFK (Elasticsearch single‑node, Fluent Bit, Kibana)
- Access: Port‑forward defaults for students (ingress optional)
- Security: No credentials in Git; Secrets created locally by users

Namespaces
- monitoring: Prometheus, Alertmanager, Grafana
- logging: Elasticsearch, Kibana, Fluent Bit
- tracing: Jaeger (post‑MVP; present but optional)

Storage (dev defaults)
- Prometheus: 15‑day retention; 10Gi PV
- Elasticsearch: 7‑day retention; 10Gi PV

GitOps structure (ArgoCD)
- Parent Applications (app‑of‑apps):
  - gitops/applications/observability‑monitoring.yaml
  - gitops/applications/observability‑logging.yaml
  - gitops/applications/observability‑tracing.yaml (post‑MVP)
- Child Applications and settings:
  - gitops/observability/monitoring/application.yaml
  - gitops/observability/logging/application.yaml
  - gitops/observability/tracing/application.yaml
- Project: gitops/projects/healthcare‑stage3.yaml

References
- MASTER‑SETUP‑GUIDE.md → Observability (GitOps) – Student‑Friendly Walkthrough (MVP)
- OPERATIONS.md → Credential Handling for Observability (Student‑Friendly)
- TROUBLESHOOTING.md → Quickstart: Verify MVP Observability Stack
- README.md → Observability overview
- 2‑sept‑Observability‑stack.md → Detailed plan & timeline

---

## 2) Setup Instructions (MVP)

Prerequisites
- EKS, ArgoCD installed and connected to this repo
- Kubeconfig for your cluster

Steps
1) Apply parent Applications (if not already applied by pipeline)
```bash
kubectl get pods -n argocd
kubectl apply -f Project-Stages/Project-Stage-3-Advanced-DevOps-Pipeline/gitops/applications/observability-monitoring.yaml
kubectl apply -f Project-Stages/Project-Stage-3-Advanced-DevOps-Pipeline/gitops/applications/observability-logging.yaml
# Post‑MVP (optional)
# kubectl apply -f Project-Stages/Project-Stage-3-Advanced-DevOps-Pipeline/gitops/applications/observability-tracing.yaml
```

2) Local‑only credentials (MVP)
- No email/Slack needed; Alertmanager UI only
- If you want to log into Grafana, create a local Secret first (see Credential Management below)

3) Verify sync in ArgoCD UI

5) Access UIs (additional: Prometheus, Alertmanager, ArgoCD)
```bash
# Prometheus
kubectl port-forward -n monitoring svc/kube-prometheus-stack-prometheus 9090:9090 &
# Alertmanager
kubectl port-forward -n monitoring svc/kube-prometheus-stack-alertmanager 9093:9093 &
# ArgoCD UI
kubectl port-forward -n argocd svc/argocd-server 8080:443 &
```

Default credentials and access
- Grafana: username admin; password from Secret grafana-admin in monitoring (created by pipeline if missing)
- ArgoCD: initial admin password
  ```bash
  kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d; echo
  ```
  Then open https://localhost:8080 and login with admin/<password>
- Alertmanager: no auth by default (dev mode). Open http://localhost:9093
- Prometheus: no auth by default (dev mode). Open http://localhost:9090

Navigation tips
- Grafana: Dashboards -> Browse -> “Healthcare Platform - Stage 3”
- Prometheus: Status -> Targets; verify healthcare-backend and healthcare-frontend jobs
- Alertmanager: Alerts -> check firing/silenced alerts
- ArgoCD: Applications -> observability-monitoring/logging/jaeger (if enabled) -> Health/Synced

- New apps should appear and get Healthy/Synced status

4) Access UIs (student‑friendly via port‑forward)
```bash
# Grafana
kubectl port-forward -n monitoring svc/kube-prometheus-stack-grafana 3000:80 &
# Kibana
kubectl port-forward -n logging svc/kibana-kibana 5601:5601 &
```

---

## 3) Credential Management (Student‑Friendly)

Principles
- Never commit credentials. Students create Secrets locally.
- Use App Passwords or provider tokens for email later; not needed for MVP.

Options
- Option A (Recommended later): Gmail App Password
- Option B: Another SMTP (SendGrid/Mailgun/AWS SES)
- Option C (MVP default): No SMTP (UI only), set email later

Examples (templates provided; do not commit)
- docs/examples-not-for-commit/grafana-admin-secret.example.yaml
- docs/examples-not-for-commit/alertmanager-email-secret.example.yaml

Commands (example)
```bash
kubectl apply -f grafana-admin-secret.yaml
# Optional later
kubectl apply -f alertmanager-secret.yaml
```

---

## 4) Pipeline Integration

Triggering (Stage‑3 CI)
- GitHub Actions workflow: .github/workflows/stage3-ci.yml
- Triggers on changes under Project-Stages/Project-Stage-3-Advanced-DevOps-Pipeline/src-code/** (by design)
- The pipeline builds and pushes images to ECR, then updates GitOps manifests (update-gitops job) with the commit SHA

ArgoCD Sync
- ArgoCD watches gitops/ for environment and observability Applications
- On pipeline commits that update images or add files, ArgoCD syncs changes

Observability Monitoring of Pipeline Deployments
- Prometheus monitors cluster health; app metrics can be scraped via:
  - ServiceMonitor CRDs targeting the app’s Service label selectors, or
  - Temporary Service annotations: prometheus.io/scrape=true, prometheus.io/port=<port>
- EFK captures application logs (stdout/stderr) and container events, useful during deployments

End‑to‑end flow
1) Developer commit in src‑code → pipeline triggers
2) Build/push images → update GitOps manifests with new tags
3) ArgoCD detects Git changes → syncs deploys
4) Prometheus scrapes targets; Grafana dashboards update
5) Fluent Bit ships logs to Elasticsearch; view in Kibana

---

## 5) Verification Steps (MVP)

ArgoCD
```bash
kubectl get applications -n argocd | egrep 'kube-prometheus-stack|efk|kibana|fluent-bit'
```

Prometheus Targets Count
```bash
kubectl port-forward -n monitoring svc/kube-prometheus-stack-prometheus 9090:9090 &
curl -s http://localhost:9090/api/v1/targets | jq '.data.activeTargets | length'
```

Grafana Access
```bash
kubectl port-forward -n monitoring svc/kube-prometheus-stack-grafana 3000:80 &
open http://localhost:3000 || xdg-open http://localhost:3000 || true
```

Kibana & Elasticsearch
```bash
kubectl port-forward -n logging svc/kibana-kibana 5601:5601 &
open http://localhost:5601 || xdg-open http://localhost:5601 || true

kubectl exec -n logging statefulset/elasticsearch-master -- curl -s localhost:9200/_cat/indices
```

Scraping your backend (two approaches)
- A) Add Service annotations (quickest)
```bash
kubectl annotate svc backend-stage3-svc -n healthcare-stage3-dev \
  prometheus.io/scrape=true prometheus.io/port=3001 --overwrite
```
- B) Add a ServiceMonitor (preferred GitOps approach)
```yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: healthcare-backend-monitor

Common access issues and fixes
- ArgoCD UI 404 or connection refused: ensure argocd namespace exists and argocd-server is Ready; re-run port-forward
- Grafana login fails: reset password by recreating grafana-admin Secret in monitoring; restart grafana pod
- Prometheus targets empty: ensure Service annotations or ServiceMonitor exist and match labels/port name
- Kibana not ready: check elasticsearch-master pod health in logging; increase resources or PVC size
- Namespaces missing: pipeline should auto-create; if absent, check Stage-3 CI logs around "Install and Bootstrap ArgoCD and Observability"
- CRDs missing (Application): ArgoCD not installed; wait for CRD or ensure install step ran

  namespace: monitoring
spec:
  selector:
    matchLabels:
      app: healthcare-backend-stage3
  namespaceSelector:
    matchNames: [ "healthcare-stage3-dev" ]
  endpoints:
  - port: http
    path: /metrics
    interval: 30s
```
Note: Ensure the Service in healthcare-stage3-dev has label app: healthcare-backend-stage3 and port name http.

Example PromQL (after data appears)
```text
sum(rate(container_cpu_usage_seconds_total{namespace="healthcare-stage3-dev"}[5m]))
rate(http_requests_total[5m])
```

Logs
```bash
kubectl logs -n logging daemonset/fluent-bit | tail -n 50
kubectl exec -n logging statefulset/elasticsearch-master -- curl -s localhost:9200/_cat/indices
```

---

## 6) Troubleshooting (Common Issues)

Observability apps not visible in ArgoCD
- Check parent Applications applied
- Check ArgoCD can reach repo (argocd-repo-server logs; TROUBLESHOOTING.md has commands)

No application metrics in Prometheus
- Ensure ServiceMonitor exists or annotate the app Service
- Verify scrape port and path; confirm Service port is named http (matches ServiceMonitor)

No logs in Kibana
- Ensure Fluent Bit pods are running in logging namespace
- Check Elasticsearch health; confirm 10Gi PV bound

Alerting not sending emails (by design in MVP)
- Use Alertmanager UI only; add SMTP or Slack later following OPERATIONS.md

---

## 7) Next Steps (Post‑MVP)
- Add email/Slack receivers (Alertmanager Secret) or Slack webhook
- Add Jaeger (observability‑tracing Application) and instrument backend with OpenTelemetry
- Curate Grafana dashboards for app latency, error rates, DB metrics
- Add ServiceMonitors for ArgoCD, ALB Controller, DB exporter

---

## 8) Appendix – Useful Paths
- GitOps parents: gitops/applications/observability-*.yaml
- Monitoring app: gitops/observability/monitoring/application.yaml
- Logging app: gitops/observability/logging/application.yaml
- Tracing app: gitops/observability/tracing/application.yaml (optional in MVP)
- Secrets examples: docs/examples-not-for-commit/*.example.yaml

