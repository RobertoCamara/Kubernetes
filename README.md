# 🚀 Kubernetes Dev Environment

Ambiente local completo de desenvolvimento com Kubernetes, preparado para arquiteturas modernas, mensageria com Kafka e múltiplas ferramentas de observabilidade.

> Ambiente testado e validado nas seguintes combinações:

- 🐧 **WSL2 com Debian** → uso preferencial de **K3d**
- 🐧 **WSL2 com Ubuntu** → uso preferencial de **Kind**


## 📌 Visão Geral

Este ambiente simula um ecossistema próximo de produção com os seguintes componentes:

- **Kafka Broker** no modo KRaft, eliminando a necessidade de ZooKeeper
- **Kafka Connect** com plugins Debezium para captura de mudanças em bancos MySQL, PostgreSQL e MongoDB
- **Sink Connectors** configurados para Redis, Elasticsearch e S3
- **Interfaces de observabilidade**: Kafka UI, Portainer, Kubernetes Dashboard e Kubevious para monitoramento visual e gestão do ambiente
- Organização de **Helm charts** e manifests para facilitar deploy e versionamento
- **Scripts automatizados** para build, instalação e gerenciamento do ambiente



## 🧭 Escolha seu Cluster

Este repositório contém dois ambientes distintos de cluster Kubernetes local:

| Cluster         | Recomendado para              | Caminho           |
|-----------------|-------------------------------|-------------------|
| K3d             | WSL2 com Debian               | [`k3d-cluster`](./k3d-cluster) |
| Kind            | WSL2 com Ubuntu               | [`kind-cluster`](./kind-cluster) |

> 💡 Ambas as opções oferecem os mesmos recursos e estrutura de serviços. Escolha com base na compatibilidade do seu sistema operacional.

---

## 🛠️ Tecnologias Utilizadas

- Kubernetes via [K3d](https://k3d.io/) ou [Kind](https://kind.sigs.k8s.io/)
- [Helm](https://helm.sh/)
- [Kafka (Bitnami)](https://bitnami.com/stack/kafka/helm)
- [Debezium](https://debezium.io/)
- [Kafka UI](https://github.com/provectus/kafka-ui)
- [Kafka Connect UI](https://github.com/lensesio/kafka-connect-ui)
- [Kubevious](https://github.com/kubevious/kubevious)
- [Portainer](https://www.portainer.io/)
- [Kubernetes Dashboard](https://github.com/kubernetes/dashboard)
- [Kong Gateway](https://docs.konghq.com/)
- [Konga UI](https://pantsel.github.io/konga/)


---

## ▶️ Como Usar

### 1. Clonar o Repositório

```bash
git clone https://github.com/RobertoCamara/Kubernetes.git
cd Kubernetes
```

### 2. Executar o Setup

#### Para K3d (WSL2 com Debian):

```bash
cd k3d-cluster
./setup-all.sh
```

#### Para Kind (WSL2 com Ubuntu):

```bash
cd kind-cluster
./setup-all.sh
```

---

## 📁 Estrutura do Projeto

```
Kubernetes/
├── k3d-cluster/
│   ├── docker/
│   ├── kafka/
│   ├── kong/
│   ├── manifests/
│   ├── setup/
│   └── setup-all.sh
│
├── kind-cluster/
│   ├── docker/
│   ├── kafka/
│   ├── kong/
│   ├── manifests/
│   ├── setup/
│   └── setup-all.sh
│
└── README.md
```

---

## 🌐 Acesse os Serviços

| Serviço                  | URL                                                |
|--------------------------|----------------------------------------------------|
| Kafka UI                 | [http://localhost:8080](http://localhost:8080)     |
| Konga UI                 | [http://localhost:8081](http://localhost:8081)     |
| Kubevious                | [http://localhost:8082](http://localhost:8082)     |
| Kafka Connect REST API   | [http://localhost:8083](http://localhost:8083)     |
| Kong Admin API           | [http://localhost:8085](http://localhost:8085)     |
| Kafka Connect UI         | [http://localhost:8086](http://localhost:8086)     |
| Portainer                | [http://localhost:9000](http://localhost:9000)     |

---


## 💡 Futuras Melhorias

- Testes de carga com K6 ou Locust
- Simulação de falhas com Chaos Mesh
- Monitoramento com Prometheus + Grafana
- Tracing com Jaeger ou OpenTelemetry

---

## ❓ FAQ - Perguntas Frequentes

**1. Preciso instalar algo antes de rodar o script `setup-all.sh`?**  
Você só precisa ter o **Docker** instalado e funcionando. O script inicial do setup verifica e instala automaticamente os pré-requisitos como `kubectl`, `k3d` e `helm`.

**2. Compatível com quais sistemas?**  
O ambiente foi desenvolvido considerando o uso do WSL2 no Windows (testado). Para Linux e Mac, ajustes podem ser necessários, mas o ambiente é compatível desde que Docker, K3d e Helm estejam instalados e funcionando.

**3. Posso usar ambos os clusters (k3d e kind)?**  
Sim, mas não simultaneamente. Delete um antes de criar o outro.

**4. Quanto tempo leva para rodar o setup completo?**  
Depende da sua máquina e da velocidade da internet, mas normalmente leva entre 5 e 10 minutos.

**5. Como adicionar novos conectores Debezium?**  
Edite o `Dockerfile.connect` para adicionar os plugins dos conectores desejados e reconstrua a imagem Kafka Connect.

**6. O Kafka está rodando em modo KRaft, qual a vantagem?**  
O modo KRaft elimina a necessidade do Zookeeper, simplificando a arquitetura, facilitando a manutenção e melhorando a performance.

**7. Como faço para parar e remover o cluster?**  
Execute o comando correspondente ao seu cluster:

```bash
# Para K3d
k3d cluster delete kubelocal-cluster

# Para Kind
kind delete cluster --name kubelocal-cluster
```

---

## ✒️ Autor

**Roberto Camara**  
Software Architect & Senior Software Engineer  
🔗 [LinkedIn](https://www.linkedin.com/in/robertoalvescamara/)