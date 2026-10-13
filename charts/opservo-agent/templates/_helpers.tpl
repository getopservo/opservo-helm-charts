{{/* Common labels. */}}
{{- define "opservo-agent.labels" -}}
app.kubernetes.io/name: opservo-k8s-agent
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" }}
{{- end -}}

{{- define "opservo-agent.selectorLabels" -}}
app.kubernetes.io/name: opservo-k8s-agent
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/* Cluster-scoped objects are named per release so two releases can't collide. */}}
{{- define "opservo-agent.clusterName" -}}
{{- if eq .Release.Name "opservo-agent" -}}opservo-k8s-agent{{- else -}}{{ printf "opservo-k8s-agent-%s" .Release.Name | trunc 63 | trimSuffix "-" }}{{- end -}}
{{- end -}}

{{- define "opservo-agent.enrollSecret" -}}
{{- if .Values.enrollment.existingSecret -}}{{ .Values.enrollment.existingSecret }}{{- else -}}opservo-k8s-agent-enroll{{- end -}}
{{- end -}}
