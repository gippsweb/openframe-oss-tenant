{{- define "app-helpers.fleet.ignoreDifferences" -}}
- group: apps
  kind: Deployment
  name: fleet
  namespace: integrated-tools
  jqPathExpressions:
    - .spec.template.spec.containers[] | select(.name=="fleet") | .startupProbe
{{- end }}
