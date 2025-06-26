
# 🚀 Kubernetes Dev Environment

Este projeto configura um ambiente local completo de desenvolvimento em Kubernetes com **K3d**, incluindo suporte a mensageria via Kafka, conectores CDC com Debezium, múltiplas interfaces gráficas e automações para acelerar seu fluxo de trabalho.

Tudo o que você precisa para construir, testar e validar aplicações distribuídas com arquitetura moderna, escalável e resiliente.

---

## 📌 Visão Geral

Este ambiente simula um ecossistema de produção com:

- Kafka Broker (modo KRaft) e Kafka Connect com plugins Debezium (MySQL, PostgreSQL, MongoDB)
- Sink Connectors como Redis, Elasticsearch e S3
- UIs para observabilidade: Kafka UI, Portainer, Kubernetes Dashboard e Kubevious
- Helm charts e manifests organizados
- Scripts automatizados para build, instalação e gerenciamento

---

## 🛠️ Tecnologias Utilizadas

- [K3d](https://k3d.io/) – Kubernetes local rodando sobre Docker
- [Helm](https://helm.sh/) – Gerenciador de pacotes Kubernetes
- [Kafka (Bitnami)](https://bitnami.com/stack/kafka/helm) – Broker Kafka
- [Debezium](https://debezium.io/) – Conectores CDC
- [Kafka UI](https://github.com/provectus/kafka-ui)
- [Kafka Connect UI](https://github.com/lensesio/kafka-connect-ui)
- [Kubevious](https://github.com/kubevious/kubevious)
- [Portainer](https://www.portainer.io/)
- [Kubernetes Dashboard](https://github.com/kubernetes/dashboard)
- Docker, Docker Compose e Bash scripts

---

## 📁 Estrutura do Projeto

```
Kubernetes/
├── k3d-cluster/ # Diretório principal do cluster local com K3d
│
├── docker/ # Dockerfile e script para build da imagem Kafka Connect customizada
│ ├── build-kafka-connect-custom.sh
│ └── Dockerfile.connect
│
├── manifests/ # YAMLs de configuração estática para componentes do Kafka
│ └── kafka/
│ ├── kafka-connect-ui.yaml
│ ├── kafka-connect.yaml
│ └── kafka-ui.yaml
│
├── setup/ # Scripts de automação para instalação dos componentes
│ ├── kafka/
│ │ ├── 00-install-kafka.sh
│ │ └── values-kafka-kraft.yaml # Configurações específicas para Kafka em modo KRaft
│ │
│ └── ui/
│ ├── 00-install-portainer.sh
│ ├── 01-install-kubernetes-dashboard.sh
│ ├── 02-install-kubevious.sh
│ ├── 03-create-portainer-agent.sh
│ ├── create-token.sh # Geração de token para acessar Kubernetes Dashboard
│ └── setup-ui.sh # Script mestre de instalação das UIs
│
├── 00-check-requirements.sh # Instala kubectl, helm e k3d se necessário
├── 01-create-cluster.sh # Cria o cluster com K3d
├── docker-compose.yaml # (Opcional) Compose auxiliar se necessário
├── setup-all.sh # ⚠️ Script principal que orquestra todo o setup
└── README.md # Este arquivo de documentação
```

---

## ▶️ Instalação Rápida

Execute o script principal para instalar tudo de forma automática:

```bash
./scripts/setup-all.sh
```

Esse script irá:

- ✅ Criar o cluster Kubernetes com K3d
- ✅ Construir e importar a imagem Kafka Connect customizada
- ✅ Instalar o Kafka com Helm
- ✅ Instalar as UIs e serviços auxiliares

---

## 🌐 Acesse os Serviços

| Serviço              | URL                                               |
|----------------------|--------------------------------------------------|
| Kafka UI             | [http://localhost:8080](http://localhost:8080)   |
| Kafka Connect UI     | [http://localhost:8086](http://localhost:8086)   |
| Kubevious            | [http://localhost:8082](http://localhost:8082)   |
| Portainer            | [http://localhost:9000](http://localhost:9000)   |
| Kubernetes Dashboard | [https://localhost:8084](https://localhost:8084) |

---

## 🧪 Atenção

Para acessar o **Kubernetes Dashboard**, é necessário um token. Gere-o executando:

```bash
./scripts/ui/create-token.sh
```

---

## 💡 Próximos Passos

Em versões futuras, planejo adicionar ferramentas para:

- Testes de carga e stress (ex: K6, Locust)
- Testes de resiliência (ex: Chaos Mesh)
- Monitoramento com Prometheus + Grafana
- Tracing distribuído com Jaeger ou OpenTelemetry
- Simulação de falhas em brokers/consumidores

---

## ❓ FAQ - Perguntas Frequentes

**1. Preciso instalar algo antes de rodar o script `setup-all.sh`?**  
Você só precisa ter o **Docker** instalado e funcionando. O script inicial do setup verifica e instala automaticamente os pré-requisitos como `kubectl`, `k3d` e `helm`.

**2. Quanto tempo leva para rodar o setup completo?**  
Depende da sua máquina e da velocidade da internet, mas normalmente leva entre 5 e 10 minutos.

**3. Posso usar esse ambiente em Windows, Linux e Mac?**  
O ambiente foi desenvolvido considerando o uso do WSL no Windows. Para Linux e Mac, ajustes podem ser necessários, mas o ambiente é compatível desde que Docker, K3d e Helm estejam instalados e funcionando.

**4. Como adicionar novos conectores Debezium?**  
Edite o `Dockerfile.connect` para adicionar os plugins dos conectores desejados e reconstrua a imagem Kafka Connect.

**5. O Kafka está rodando em modo KRaft, qual a vantagem?**  
O modo KRaft elimina a necessidade do Zookeeper, simplificando a arquitetura, facilitando a manutenção e melhorando a performance.

**6. Como faço para parar e remover o cluster?**  
Execute o comando `k3d cluster delete <nome-do-cluster>`. O nome padrão do cluster é `kubelocal-cluster`.

---

## ✒️ Autor

**Roberto Camara**  
Software Architect & Senior Software Engineer  
.NET, C#, Kafka, RabbitMQ, Azure Service Bus, Docker, Cloud, Microservices  

🔗 [LinkedIn](https://www.linkedin.com/in/robertoalvescamara/)
