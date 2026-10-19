# last_verified: 2026-10-19 · Helm 3.13
# Named templates shared across the chart. Files starting with an
# underscore are not rendered as Kubernetes manifests on their own.
{{- define "polished-service.labels" -}}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{- define "polished-service.selector" -}}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}