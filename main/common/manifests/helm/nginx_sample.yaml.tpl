serviceAccount:
  create: true
rbac:
  create: true

controller:
  image:
    allowPrivilegeEscalation: false
  replicaCount: ${replicas}
  service:
    externalTrafficPolicy: Local
    type: ${service_type}
    targetPorts:
      http: 8080
      # NLB 에서 TLS 종료를 진행하기 때문에 https -> http 변경
      https: http

  config: 
    allow-snippet-annotations: "true"
    compute-full-forwarded-for: "true"
    server-tokens: "false"
    use-forwarded-headers: "true"
    ssl-redirect: "false"
    use-proxy-protocol: "true"
    proxy-body-size: 300m
    http-snippet: |
      map true $pass_access_scheme {
        default "https";
      }
      map true $pass_port {
        default 443;
      }
      server {
        listen 8080 proxy_protocol;
        return 308 https://$host$request_uri;
      }
  metrics:
    enabled: true
  autoscaling:
    maxReplicas: 1
    minReplicas: 1
    enabled: true
