{{- define "app-helpers.fleet.ignoreDifferences" -}}
- group: apps
  kind: Deployment
  name: fleet
  namespace: integrated-tools
  jqPathExpressions:
    - .spec.template.spec.containers[] | select(.name=="fleet") | .startupProbe
    - .spec.template.spec.containers[] | select(.name=="fleet") | .livenessProbe.timeoutSeconds
    - .spec.template.spec.containers[] | select(.name=="fleet") | .readinessProbe.timeoutSeconds
{{- end }}
