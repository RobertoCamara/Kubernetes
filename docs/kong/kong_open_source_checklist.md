# ✅ Checklist Técnico: Adoção do Kong Open Source em Suas Aplicações

## Segurança e Autenticação

| Requisito | Atende com Kong OS? | Observações |
|-----------|----------------------|-------------|
| Suporte a autenticação via JWT | ✅ | Plugin nativo (`jwt`) |
| Integração com Cognito ou outro provedor OAuth2/OpenID | ✅ | Via plugin `oauth2` ou JWT |
| Suporte a mTLS entre gateway e serviços internos | ✅ | Configurável no proxy + Ingress |
| Rate limiting (por consumidor, IP, etc.) | ✅ | Plugin `rate-limiting` |
| Rejeição de requisições malformadas | ✅ | Plugins + Kong Ingress Admission |
| Logging de requisições (auditoria externa) | ✅ | Integra com Datadog, Prometheus, Loki |
| RBAC na administração do gateway | ❌ | Disponível apenas na versão Enterprise |

## Governança e Gestão de APIs

| Requisito | Atende com Kong OS? | Observações |
|-----------|----------------------|-------------|
| Gestão de rotas por código (GitOps via YAML/Helm/CRDs) | ✅ | Helm Charts e Ingress CRDs disponíveis |
| Versionamento de APIs | ✅ | Por path, header ou query param |
| Transformação de payload (Request/Response) | ✅ | Plugins `request-transformer`, `response-transformer` |
| Reescrita e redirecionamento de URLs | ✅ | Plugins ou regras de Ingress |
| Documentação pública de APIs (Dev Portal) | ❌ | Disponível apenas na versão Enterprise |
| Limitação de plugins por rota/serviço | ✅ | Configuração via declarative config |

## Monitoramento e Observabilidade

| Requisito | Atende com Kong OS? | Observações |
|-----------|----------------------|-------------|
| Exposição de métricas Prometheus | ✅ | Plugin `prometheus` |
| Integração com Grafana ou Datadog | ✅ | Via exporters e logs |
| Logging estruturado (JSON) para ELK/Loki | ✅ | Configurações nativas no proxy |
| Tracing distribuído (Zipkin, Jaeger, Datadog APM) | ✅ | Plugin `zipkin` ou `opentelemetry` |
| Analytics com painel visual | ❌ | Disponível apenas na versão Enterprise (Kong Vitals) |

## Execução, Deploy e Escalabilidade

| Requisito | Atende com Kong OS? | Observações |
|-----------|----------------------|-------------|
| Suporte completo a Kubernetes via Ingress Controller | ✅ | Helm chart oficial + CRDs |
| Suporte a deployment DB-less | ✅ | Recomendado para GitOps |
| Escalabilidade horizontal do gateway | ✅ | Stateless com autoscaling |
| Rodar localmente com Docker/k3d | ✅ | Ideal para testes e PoC |
| Suporte a plugins customizados | ✅ | Lua ou Go (via `go-pluginserver`) |
| Facilidade de CI/CD com Helm e Kustomize | ✅ | Amplamente suportado |

