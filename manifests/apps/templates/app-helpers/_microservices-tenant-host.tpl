{{- define "app-helpers.openframe-gateway.ignoreDifferences" -}}
- group: apps
  kind: Deployment
  name: openframe-gateway
  namespace: microservices
  jqPathExpressions:
    - .spec.template.spec.containers[].env[] | select(.name=="TENANT_HOST_URL")
{{- end }}

{{- define "app-helpers.openframe-api.ignoreDifferences" -}}
- group: apps
  kind: Deployment
  name: openframe-api
  namespace: microservices
  jqPathExpressions:
    - .spec.template.spec.containers[].env[] | select(.name=="TENANT_HOST_URL")
{{- end }}

{{- define "app-helpers.openframe-authorization-server.ignoreDifferences" -}}
- group: apps
  kind: Deployment
  name: openframe-authorization-server
  namespace: microservices
  jqPathExpressions:
    - .spec.template.spec.containers[].env[] | select(.name=="TENANT_HOST_URL")
{{- end }}

{{- define "app-helpers.openframe-management.ignoreDifferences" -}}
- group: apps
  kind: Deployment
  name: openframe-management
  namespace: microservices
  jqPathExpressions:
    - .spec.template.spec.containers[].env[] | select(.name=="TENANT_HOST_URL")
{{- end }}
