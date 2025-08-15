{{/*
Expand the name of the chart.
*/}}
{{- define "healthcare-system.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "healthcare-system.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "healthcare-system.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "healthcare-system.labels" -}}
helm.sh/chart: {{ include "healthcare-system.chart" . }}
{{ include "healthcare-system.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: healthcare-system
environment: {{ .Values.environment }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "healthcare-system.selectorLabels" -}}
app.kubernetes.io/name: {{ include "healthcare-system.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "healthcare-system.serviceAccountName" -}}
{{- if .Values.security.serviceAccount.create }}
{{- default (include "healthcare-system.fullname" .) .Values.security.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.security.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the namespace
*/}}
{{- define "healthcare-system.namespace" -}}
{{- if .Values.namespace.create }}
{{- .Values.namespace.name }}
{{- else }}
{{- "default" }}
{{- end }}
{{- end }}

{{/*
Frontend image
*/}}
{{- define "healthcare-system.frontend.image" -}}
{{- $registry := .Values.global.imageRegistry -}}
{{- $repository := .Values.frontend.image.repository -}}
{{- $tag := .Values.frontend.image.tag -}}
{{- printf "%s%s:%s" $registry $repository $tag }}
{{- end }}

{{/*
Backend image
*/}}
{{- define "healthcare-system.backend.image" -}}
{{- $registry := .Values.global.imageRegistry -}}
{{- $repository := .Values.backend.image.repository -}}
{{- $tag := .Values.backend.image.tag -}}
{{- printf "%s%s:%s" $registry $repository $tag }}
{{- end }}

{{/*
Database connection string
*/}}
{{- define "healthcare-system.database.connectionString" -}}
{{- if .Values.database.external }}
{{- .Values.database.externalConnectionString }}
{{- else }}
{{- printf "postgresql://%s:%s@%s-postgresql:5432/%s" .Values.database.postgresql.auth.username .Values.database.postgresql.auth.password (include "healthcare-system.fullname" .) .Values.database.postgresql.auth.database }}
{{- end }}
{{- end }}

{{/*
Common environment variables
*/}}
{{- define "healthcare-system.commonEnv" -}}
- name: ENVIRONMENT
  value: {{ .Values.environment | quote }}
- name: NAMESPACE
  valueFrom:
    fieldRef:
      fieldPath: metadata.namespace
- name: POD_NAME
  valueFrom:
    fieldRef:
      fieldPath: metadata.name
- name: POD_IP
  valueFrom:
    fieldRef:
      fieldPath: status.podIP
- name: NODE_NAME
  valueFrom:
    fieldRef:
      fieldPath: spec.nodeName
{{- end }}

{{/*
Security context for containers
*/}}
{{- define "healthcare-system.securityContext" -}}
allowPrivilegeEscalation: false
capabilities:
  drop:
  - ALL
readOnlyRootFilesystem: true
runAsNonRoot: true
runAsUser: 1001
{{- end }}

{{/*
Pod security context
*/}}
{{- define "healthcare-system.podSecurityContext" -}}
runAsNonRoot: true
runAsUser: 1001
fsGroup: 1001
seccompProfile:
  type: RuntimeDefault
{{- end }}

{{/*
Resource limits and requests
*/}}
{{- define "healthcare-system.resources" -}}
{{- if .resources }}
resources:
  {{- if .resources.limits }}
  limits:
    {{- if .resources.limits.cpu }}
    cpu: {{ .resources.limits.cpu }}
    {{- end }}
    {{- if .resources.limits.memory }}
    memory: {{ .resources.limits.memory }}
    {{- end }}
  {{- end }}
  {{- if .resources.requests }}
  requests:
    {{- if .resources.requests.cpu }}
    cpu: {{ .resources.requests.cpu }}
    {{- end }}
    {{- if .resources.requests.memory }}
    memory: {{ .resources.requests.memory }}
    {{- end }}
  {{- end }}
{{- end }}
{{- end }}

{{/*
Ingress annotations
*/}}
{{- define "healthcare-system.ingress.annotations" -}}
{{- if .annotations }}
{{- range $key, $value := .annotations }}
{{ $key }}: {{ $value | quote }}
{{- end }}
{{- end }}
nginx.ingress.kubernetes.io/proxy-body-size: "50m"
nginx.ingress.kubernetes.io/proxy-read-timeout: "300"
nginx.ingress.kubernetes.io/proxy-send-timeout: "300"
nginx.ingress.kubernetes.io/configuration-snippet: |
  more_set_headers "X-Frame-Options: DENY";
  more_set_headers "X-Content-Type-Options: nosniff";
  more_set_headers "X-XSS-Protection: 1; mode=block";
  more_set_headers "Referrer-Policy: strict-origin-when-cross-origin";
{{- end }}
