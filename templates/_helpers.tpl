{{/*
Labels shared across the umbrella's own resources (not the sub-charts').
*/}}
{{- define "helm-gitlab.labels" -}}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: helm-gitlab
{{- end -}}

{{/*
Require a value to be set, or fail the render with a helpful message.
Usage:  {{ include "helm-gitlab.required" (dict "value" .Values.x "name" "foo") }}
*/}}
{{- define "helm-gitlab.required" -}}
{{- if not .value -}}
{{- fail (printf "REQUIRED value '%s' is not set. See values.example.yaml." .name) -}}
{{- end -}}
{{- .value -}}
{{- end -}}

{{/*
Fail-fast REQUIRED value helpers.
*/}}
{{- define "helm-gitlab.image.registry" -}}
{{- required "image.registry is REQUIRED — set it to your container registry (e.g. docker.io or registry.example.com)" .Values.image.registry -}}
{{- end -}}

{{- define "helm-gitlab.host.gitlab" -}}
{{- required "hostnames.gitlab is REQUIRED — set it to your GitLab hostname (e.g. gitlab.example.com)" .Values.hostnames.gitlab -}}
{{- end -}}

{{- define "helm-gitlab.host.registry" -}}
{{- required "hostnames.registry is REQUIRED — set it to your registry hostname (e.g. registry.example.com)" .Values.hostnames.registry -}}
{{- end -}}

{{- define "helm-gitlab.host.kas" -}}
{{- required "hostnames.kas is REQUIRED — set it to your KAS hostname (e.g. kas.example.com)" .Values.hostnames.kas -}}
{{- end -}}

{{- define "helm-gitlab.host.ssh" -}}
{{- required "hostnames.ssh is REQUIRED — set it to your SSH hostname (e.g. gitlab.example.com)" .Values.hostnames.ssh -}}
{{- end -}}

{{- define "helm-gitlab.storageClass" -}}
{{- required "storageClass is REQUIRED — set it to a RWO StorageClass name on your cluster" .Values.storageClass -}}
{{- end -}}

{{- define "helm-gitlab.ingressClassName" -}}
{{- required "ingressClassName is REQUIRED — set it to your ingress class name" .Values.ingressClassName -}}
{{- end -}}

{{/*
Toolbox SSH derived names.
*/}}
{{- define "helm-gitlab.toolboxSsh.sa" -}}
{{- .Values.toolboxSsh.serviceAccountName | default (printf "%s-toolbox-ssh" .Release.Name) -}}
{{- end -}}

{{- define "helm-gitlab.toolboxSsh.svc" -}}
{{- .Values.toolboxSsh.serviceName | default (printf "%s-toolbox-ssh" .Release.Name) -}}
{{- end -}}

{{- define "helm-gitlab.toolboxSsh.secret" -}}
{{- .Values.toolboxSsh.secretName | default (printf "%s-toolbox-ssh-key" .Release.Name) -}}
{{- end -}}

{{/*
Postgres image — falls back to <image.registry>/postgres-pgbackrest:18 when empty.
*/}}
{{- define "helm-gitlab.postgres.image" -}}
{{- .Values.postgres.image | default (printf "%s/postgres-pgbackrest:18" (include "helm-gitlab.image.registry" .)) -}}
{{- end -}}

{{/*
Postgres storage class — falls back to top-level storageClass.
*/}}
{{- define "helm-gitlab.postgres.storageClass" -}}
{{- .Values.postgres.storage.storageClass | default (include "helm-gitlab.storageClass" .) -}}
{{- end -}}

{{/*
helm-gitlab.valkeyPassword — stable across upgrades via lookup.
*/}}
{{- define "helm-gitlab.valkeyPassword" -}}
{{- $name := .Values.valkeyAuth.secretName -}}
{{- $existing := (lookup "v1" "Secret" .Release.Namespace $name) -}}
{{- if and $existing (hasKey $existing.data "password") -}}
{{- index $existing.data "password" | b64dec -}}
{{- else -}}
{{- randAlphaNum (int .Values.valkeyAuth.generatedPasswordLength) -}}
{{- end -}}
{{- end -}}

{{/*
helm-gitlab.s3AccessKey — plain S3 access-key-id for SeaweedFS.
*/}}
{{- define "helm-gitlab.s3AccessKey" -}}
{{- $name := .Values.seaweedfsAuth.secretName -}}
{{- $existing := (lookup "v1" "Secret" .Release.Namespace $name) -}}
{{- if and $existing (hasKey $existing.data "accessKey") -}}
{{- index $existing.data "accessKey" | b64dec -}}
{{- else -}}
{{- randAlphaNum 20 -}}
{{- end -}}
{{- end -}}

{{/*
helm-gitlab.s3SecretKey — plain S3 secret-access-key for SeaweedFS.
*/}}
{{- define "helm-gitlab.s3SecretKey" -}}
{{- $name := .Values.seaweedfsAuth.secretName -}}
{{- $existing := (lookup "v1" "Secret" .Release.Namespace $name) -}}
{{- if and $existing (hasKey $existing.data "secretKey") -}}
{{- index $existing.data "secretKey" | b64dec -}}
{{- else -}}
{{- randAlphaNum 40 -}}
{{- end -}}
{{- end -}}

{{/*
helm-gitlab.pgPassword — stable across upgrades via lookup.

Usage:
  {{ include "helm-gitlab.pgPassword" (dict "ctx" . "key" "password") }}
*/}}
{{- define "helm-gitlab.pgPassword" -}}
{{- $name := .ctx.Values.postgres.secretName -}}
{{- $key := .key -}}
{{- $existing := (lookup "v1" "Secret" .ctx.Release.Namespace $name) -}}
{{- if and $existing (hasKey $existing.data $key) -}}
{{- index $existing.data $key | b64dec -}}
{{- else -}}
{{- randAlphaNum 32 -}}
{{- end -}}
{{- end -}}

{{/*
helm-gitlab.s3Endpoint — in-cluster DNS of the SeaweedFS S3 Service.
Service name is seaweedfs-s3 (NOT release-prefixed, see seaweedfs.fullnameOverride).
*/}}
{{- define "helm-gitlab.s3Endpoint" -}}
{{- printf "http://seaweedfs-s3:%d" (int .Values.seaweedfs.s3.port) -}}
{{- end -}}

{{/*
Credentials + endpoint for the disposable runner-cache SeaweedFS.
*/}}
{{- define "helm-gitlab.cacheS3AccessKey" -}}
{{- $name := .Values.seaweedfsCacheAuth.secretName -}}
{{- $existing := (lookup "v1" "Secret" .Release.Namespace $name) -}}
{{- if and $existing (hasKey $existing.data "accessKey") -}}
{{- index $existing.data "accessKey" | b64dec -}}
{{- else -}}
{{- randAlphaNum 20 -}}
{{- end -}}
{{- end -}}

{{- define "helm-gitlab.cacheS3SecretKey" -}}
{{- $name := .Values.seaweedfsCacheAuth.secretName -}}
{{- $existing := (lookup "v1" "Secret" .Release.Namespace $name) -}}
{{- if and $existing (hasKey $existing.data "secretKey") -}}
{{- index $existing.data "secretKey" | b64dec -}}
{{- else -}}
{{- randAlphaNum 40 -}}
{{- end -}}
{{- end -}}

{{- define "helm-gitlab.cacheS3Endpoint" -}}
{{- printf "http://seaweedfs-cache-s3:8333" -}}
{{- end -}}

{{/*
helm-gitlab.backupS3cmdConfig — renders an s3cmd `.s3cfg` for the GitLab
toolbox backup-utility (consumed via gitlab.gitlab.toolbox.backups.
objectStorage.config). GitLab 19 (chart 10.x) dropped bundled object storage
and now hard-fails the render unless this is configured.

Object storage in this chart is the in-cluster SeaweedFS gateway, so the
config is path-style + http against seaweedfs-s3. Credentials come from the
same lookup-stable helpers as the rest of the stack (helm-gitlab.s3AccessKey/
s3SecretKey, backed by the seaweedfsAuth Secret).
*/}}
{{- define "helm-gitlab.backupS3cmdConfig" -}}
{{- $ak := include "helm-gitlab.s3AccessKey" . -}}
{{- $sk := include "helm-gitlab.s3SecretKey" . -}}
{{- $port := int .Values.seaweedfs.s3.port -}}
[default]
access_key = {{ $ak }}
secret_key = {{ $sk }}
host_base = seaweedfs-s3:{{ $port }}
host_bucket = seaweedfs-s3:{{ $port }}
use_https = False
signature_v2 = False
{{- end -}}
