Run set -e
  set -e
  echo "🌐 Applying NGINX Ingresses for Grafana/Prometheus/Alertmanager/ArgoCD"
  # Grafana - requires X-Forwarded-Prefix for sub-path
  cat <<'EOF' | kubectl apply -f -
  apiVersion: networking.k8s.io/v1
  kind: Ingress
  metadata:
    name: grafana-basic
    namespace: monitoring
    annotations:
      kubernetes.io/ingress.class: nginx
      nginx.ingress.kubernetes.io/rewrite-target: /$2
      nginx.ingress.kubernetes.io/use-regex: "true"
      nginx.ingress.kubernetes.io/auth-type: basic
      nginx.ingress.kubernetes.io/auth-secret: grafana-basic-auth
      nginx.ingress.kubernetes.io/auth-realm: 'Authentication Required - Grafana'
      nginx.ingress.kubernetes.io/configuration-snippet: |
        proxy_set_header X-Forwarded-Prefix /grafana;
  spec:
    rules:
    - http:
        paths:
        - path: /grafana(/|$)(.*)
          pathType: Prefix
          backend:
            service:
              name: kube-prometheus-stack-grafana
              port:
                number: 80
  ---
  apiVersion: networking.k8s.io/v1
  kind: Ingress
  metadata:
    name: prometheus-basic
    namespace: monitoring
    annotations:
      kubernetes.io/ingress.class: nginx
      nginx.ingress.kubernetes.io/rewrite-target: /$2
      nginx.ingress.kubernetes.io/use-regex: "true"
      nginx.ingress.kubernetes.io/auth-type: basic
      nginx.ingress.kubernetes.io/auth-secret: prometheus-basic-auth
      nginx.ingress.kubernetes.io/auth-realm: 'Authentication Required - Prometheus'
  spec:
    rules:
    - http:
        paths:
        - path: /prometheus(/|$)(.*)
          pathType: Prefix
          backend:
            service:
              name: kube-prometheus-stack-prometheus
              port:
                number: 9090
  ---
  apiVersion: networking.k8s.io/v1
  kind: Ingress
  metadata:
    name: alertmanager-basic
    namespace: monitoring
    annotations:
      kubernetes.io/ingress.class: nginx
      nginx.ingress.kubernetes.io/rewrite-target: /$2
      nginx.ingress.kubernetes.io/use-regex: "true"
      nginx.ingress.kubernetes.io/auth-type: basic
      nginx.ingress.kubernetes.io/auth-secret: alertmanager-basic-auth
      nginx.ingress.kubernetes.io/auth-realm: 'Authentication Required - Alertmanager'
  spec:
    rules:
    - http:
        paths:
        - path: /alertmanager(/|$)(.*)
          pathType: Prefix
          backend:
            service:
              name: kube-prometheus-stack-alertmanager
              port:
                number: 9093
  ---
  apiVersion: networking.k8s.io/v1
  kind: Ingress
  metadata:
    name: argocd-basic
    namespace: argocd
    annotations:
      kubernetes.io/ingress.class: nginx
      nginx.ingress.kubernetes.io/rewrite-target: /$2
      nginx.ingress.kubernetes.io/use-regex: "true"
      nginx.ingress.kubernetes.io/auth-type: basic
      nginx.ingress.kubernetes.io/auth-secret: argocd-basic-auth
      nginx.ingress.kubernetes.io/auth-realm: 'Authentication Required - ArgoCD'
  spec:
    rules:
    - http:
        paths:
        - path: /argocd(/|$)(.*)
          pathType: Prefix
          backend:
            service:
              name: argocd-server
              port:
                number: 80
  EOF
  shell: /usr/bin/bash -e {0}
  env:
    SOURCE_CODE_PATH: ./Project-Stages/Project-Stage-3-Advanced-DevOps-Pipeline/src-code
    TERRAFORM_PATH: ./Project-Stages/Project-Stage-3-Advanced-DevOps-Pipeline/terraform
    STAGE: stage-3
    AWS_REGION: us-east-1
    AWS_DEFAULT_REGION: us-east-1
    AWS_ACCESS_KEY_ID: ***
    AWS_SECRET_ACCESS_KEY: ***
    TERRAFORM_CLI_PATH: /home/runner/work/_temp/6988d894-05cb-44ca-80c9-05d85f942aeb
    OBS_NLB: k8s-ingressn-ingressn-77de8e603a-b7b0bf7543353dcf.elb.us-east-1.amazonaws.com
🌐 Applying NGINX Ingresses for Grafana/Prometheus/Alertmanager/ArgoCD
Warning: annotation "kubernetes.io/ingress.class" is deprecated, please use 'spec.ingressClassName' instead
Warning: path /grafana(/|$)(.*) cannot be used with pathType Prefix
Warning: path /prometheus(/|$)(.*) cannot be used with pathType Prefix
Warning: path /alertmanager(/|$)(.*) cannot be used with pathType Prefix
Warning: path /argocd(/|$)(.*) cannot be used with pathType Prefix
Error from server (BadRequest): error when creating "STDIN": admission webhook "validate.nginx.ingress.kubernetes.io" denied the request: ingress contains invalid paths: path /grafana(/|$)(.*) cannot be used with pathType Prefix
Error from server (BadRequest): error when creating "STDIN": admission webhook "validate.nginx.ingress.kubernetes.io" denied the request: ingress contains invalid paths: path /prometheus(/|$)(.*) cannot be used with pathType Prefix
Error from server (BadRequest): error when creating "STDIN": admission webhook "validate.nginx.ingress.kubernetes.io" denied the request: ingress contains invalid paths: path /alertmanager(/|$)(.*) cannot be used with pathType Prefix
Error from server (BadRequest): error when creating "STDIN": admission webhook "validate.nginx.ingress.kubernetes.io" denied the request: ingress contains invalid paths: path /argocd(/|$)(.*) cannot be used with pathType Prefix
Error: Process completed with exit code 1.