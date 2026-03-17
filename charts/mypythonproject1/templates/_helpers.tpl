{{/*
Expand the name of the chart.
*/}}
{{- define "mypythonproject1.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "mypythonproject1.fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{/*
Chart label.
*/}}
{{- define "mypythonproject1.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels applied to all resources.
*/}}
{{- define "mypythonproject1.labels" -}}
helm.sh/chart: {{ include "mypythonproject1.chart" . }}
app.kubernetes.io/name: {{ include "mypythonproject1.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
{{- end }}

{{/*
Selector labels (stable subset — used in pod selectors; must not change after first deploy).
*/}}
{{- define "mypythonproject1.selectorLabels" -}}
app.kubernetes.io/name: {{ include "mypythonproject1.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Backend-specific selector labels.
*/}}
{{- define "mypythonproject1.backendSelectorLabels" -}}
{{ include "mypythonproject1.selectorLabels" . }}
app.kubernetes.io/component: backend
{{- end }}

{{/*
Frontend-specific selector labels.
*/}}
{{- define "mypythonproject1.frontendSelectorLabels" -}}
{{ include "mypythonproject1.selectorLabels" . }}
app.kubernetes.io/component: frontend
{{- end }}

{{/*
ServiceAccount name.
*/}}
{{- define "mypythonproject1.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "mypythonproject1.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Fully qualified image reference.
Usage: {{ include "mypythonproject1.image" (dict "registry" .Values.global.registry "values" .Values.backend) }}
*/}}
{{- define "mypythonproject1.image" -}}
{{- $reg := .registry }}
{{- $repo := .values.image.repository }}
{{- $tag  := .values.image.tag | default "latest" }}
{{- if $reg }}
{{- printf "%s/%s:%s" $reg $repo $tag }}
{{- else }}
{{- printf "%s:%s" $repo $tag }}
{{- end }}
{{- end }}
