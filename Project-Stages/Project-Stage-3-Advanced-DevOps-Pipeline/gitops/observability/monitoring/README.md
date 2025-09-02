# Observability: Monitoring (kube-prometheus-stack)

This ArgoCD Application installs Prometheus, Alertmanager, Grafana, node-exporter, and kube-state-metrics with dev-grade storage/retention.

Requires the following Kubernetes Secrets in `monitoring` namespace (do NOT commit secrets):

1) Grafana admin credentials Secret `grafana-admin`
```
apiVersion: v1
kind: Secret
metadata:
  name: grafana-admin
  namespace: monitoring
stringData:
  admin-user: admin
  admin-password: <choose-strong-password>
```

2) Alertmanager email config Secret `alertmanager-config`
```
apiVersion: v1
kind: Secret
metadata:
  name: alertmanager-config
  namespace: monitoring
stringData:
  alertmanager.yaml: |
    global:
      smtp_smarthost: 'smtp.gmail.com:587'
      smtp_from: 'ambivert.skill@gmail.com'
      smtp_auth_username: 'ambivert.skill@gmail.com'
      smtp_auth_password: '<APP_PASSWORD>'
      smtp_require_tls: true
    route:
      receiver: 'email'
    receivers:
    - name: 'email'
      email_configs:
      - to: 'ambivert.skill@gmail.com'
        send_resolved: true
```

NOTE: For Gmail, use an App Password (recommended). Do NOT store cleartext passwords in Git. Create the Secret locally:
```
kubectl apply -f grafana-admin-secret.yaml
kubectl apply -f alertmanager-secret.yaml
```

