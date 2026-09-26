{{/* last_verified: 2026-09-26 · Helm n/a */}}
{{/*
Shared helpers consumed by the app chart via `include`.
Naming convention: "<library-chart-name>.<helper>".
*/}}

{{/* Common labels applied to every rendered object. */}}
{{- define "lib-common.labels" -}}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- with .Values.commonLabels }}
{{- toYaml . | nindent 0 }}
{{- end }}
{{- end }}

{{/* Short resource name: <release>-<chart>. */}}
{{- define "lib-common.fullname" -}}
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/* Single place where repository + tag are joined. */}}
{{- define "lib-common.image" -}}
{{- printf "%s:%s" .Values.image.repository (.Values.image.tag | toString) }}
{{- end }}
