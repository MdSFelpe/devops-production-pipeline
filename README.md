# 🚀 Java Spring Boot API + PostgreSQL (DevSecOps, Kubernetes & AWS Cloud Pipeline)

Este repositório contém a arquitetura completa de uma API RESTful em **Java 21 + Spring Boot** integrada a um banco de dados **PostgreSQL**. O projeto abrange desde a execução local containerizada e orquestração via **Kubernetes (Minikube)** até o provisionamento automatizado em nuvem na **AWS com Terraform** e pipeline **CI/CD no GitHub Actions**.

---

## 🧐 O que este projeto faz?

* **Aplicação:** Executa uma API Spring Boot em Java 21 comunicando com um banco de dados PostgreSQL (local ou gerenciado na AWS RDS) e expondo endpoint de health check (`/health`).
* **Segurança de Contêiner:** O contêiner da API utiliza *multi-stage build* (`eclipse-temurin:21-jre-alpine`) e roda sob o usuário sem privilégios `appuser` (não-root) para mitigar riscos de escalada de privilégios.
* **Infraestrutura como Código na AWS (Terraform):** Provisiona uma rede isolada (VPC `10.0.0.0/16`) com subnets públicas para a aplicação (EC2) e subnets privadas sem acesso à internet para o banco de dados (RDS PostgreSQL 16).
* **Gestão de Configurações e Segredos:** Gerencia variáveis não sensíveis via `ConfigMap` e credenciais via `Secret` no Kubernetes, além de injeção dinâmica de variáveis de ambiente (`SPRING_DATASOURCE_*`) na AWS sem segredos expostos no código.
* **Controle de Recursos:** Define limites rigorosos de CPU, Memória e Armazenamento Temporário (`ephemeral-storage`) no Kubernetes para prevenir problemas de *noisy neighbor*.
* **CI/CD & DevSecOps Integrado:** Pipeline no GitHub Actions para compilação Maven, varredura de vulnerabilidades com **Trivy**, publicação automática da imagem no **GitHub Container Registry (`ghcr.io`)**, validação sintática dos manifestos YAML/Terraform e análise estática via SonarQube.

---

## 🏗️ Arquitetura Cloud (AWS + CI/CD)

```text
[ Developer Push (main) ]
          │
          ▼
[ GitHub Actions CI/CD ]
  ├── 1. Maven Build & Test (Java 21)
  ├── 2. Multi-stage Docker Build (Alpine JRE + non-root appuser)
  ├── 3. Vulnerability Scan (Trivy)
  ├── 4. Push Image -> GitHub Container Registry (ghcr.io)
  └── 5. Terraform & Kubernetes Manifest Validation
          │
          ▼
[ AWS Cloud (us-east-1) - Provisioned via Terraform ]
  └── Custom VPC (10.0.0.0/16)
        ├── Public Subnets (AZ-1 / AZ-2) + Internet Gateway
        │     └── EC2 Instance (t3.micro) -> Spring Boot Container (:8080)
        │           └── app_sg (Ingress: 8080, 22 | Lifecycle: create_before_destroy)
        └── Private Subnets (AZ-1 / AZ-2) — Isoladas da Internet
              └── AWS RDS PostgreSQL 16 (db.t3.micro)
                    └── rds_sg (Ingress: 5432 exclusivamente do app_sg)
```

---

## 🛠️ Tecnologias Utilizadas

* **Linguagem / Framework:** Java 21 / Spring Boot 4
* **Banco de Dados:** PostgreSQL 15 / 16 (AWS RDS)
* **Containerização & Registry:** Docker (Multi-stage build com usuário não-root) e GitHub Container Registry (`ghcr.io`)
* **Cloud & IaC:** AWS (VPC, EC2, RDS, Security Groups, IGW) e Terraform
* **Orquestração Local:** Kubernetes (Deployments, Services, ConfigMaps, Secrets)
* **CI/CD & Segurança:** GitHub Actions, Trivy Security Scanner e SonarQube / SonarLint (0 avisos)

---

## 📂 Estrutura do Repositório

```text
devops-production-pipeline/
├── .github/
│   └── workflows/
│       └── ci-cd.yaml           # Pipeline de build, scan Trivy, push GHCR e validação IaC
├── docker-java-api/
│   ├── src/                     # Código-fonte Spring Boot (inclui endpoint /health)
│   ├── Dockerfile               # Multi-stage build com usuário não-root (appuser)
│   ├── .dockerignore            # Otimização de contexto de build
│   ├── docker-compose.yml       # Execução local rápida
│   └── pom.xml                  # Dependências Maven (Java 21 + PostgreSQL Driver)
├── k8s/                         # Manifestos Kubernetes (Deployment, Service, ConfigMap, Secret)
└── terraform/
    ├── vpc.tf                   # VPC customizada (10.0.0.0/16)
    ├── subnets.tf               # Subnets públicas e privadas multi-AZ
    ├── gateways.tf              # Internet Gateway e Route Tables
    ├── security_groups.tf       # Regras de firewall encadeadas (app_sg -> rds_sg)
    ├── rds.tf                   # Instância gerenciada PostgreSQL 16
    ├── ec2.tf                   # Instância EC2 com bootstrap automatizado via user_data
    └── outputs.tf               # Exposição do IP público da API e endpoint do RDS
```

---

## 🚀 Como Executar o Projeto

### 1. Na Nuvem AWS com Terraform (Ambiente de Produção)

1. Acesse a pasta de infraestrutura e inicialize o Terraform:
   ```bash
   cd terraform
   terraform init
   terraform validate
   ```
2. Provisione a VPC, o banco RDS PostgreSQL e a instância EC2 (informe a senha desejada para o banco quando solicitado):
   ```bash
   terraform apply
   ```
3. Aguarde o bootstrap automático (`user_data`) e valide a aplicação usando o IP público retornado em `ec2_public_ip`:
   ```bash
   curl http://<ec2_public_ip>:8080/health
   # Resposta esperada: {"service":"java-springboot-api","status":"UP"}
   ```

### 2. Localmente com Docker Compose (Execução Rápida)

Na raiz do repositório, execute:
```bash
docker compose -f docker-java-api/docker-compose.yml up --build
```

### 3. Localmente com Kubernetes (Minikube)

1. Inicie o cluster local:
   ```bash
   minikube start
   ```
2. Construa a imagem Docker no ambiente local:
   ```bash
   docker build -t docker-java-api:1.0.0 ./docker-java-api
   ```
3. Aplique todos os manifestos do Kubernetes:
   ```bash
   kubectl apply -f k8s/
   ```
4. Confirme se os Pods estão em execução e verifique os logs de conexão com o banco:
   ```bash
   kubectl get pods
   kubectl logs -l app=api-java --tail=50
   ```

---

## 🧹 Como Desfazer Tudo e Limpar o Ambiente

### 1. Encerrar Recursos na AWS (Controle de Custos)
Para destruir a instância EC2 e o banco RDS mantendo a rede base gratuita na AWS:
```bash
cd terraform
terraform destroy -target="aws_db_instance.postgres_db" -target="aws_instance.app_server"
```
*(Ou execute `terraform destroy` para remover toda a infraestrutura).*

### 2. Apagar Recursos do Kubernetes (Minikube)
* **Remover apenas os manifestos da aplicação:**
  ```bash
  kubectl delete -f k8s/
  ```
* **Reiniciar a aplicação do zero em caso de erro:**
  ```bash
  kubectl delete -f k8s/
  docker build -t docker-java-api:1.0.0 ./docker-java-api
  kubectl apply -f k8s/
  ```
* **Pausar ou apagar completamente o cluster Minikube:**
  ```bash
  minikube stop
  minikube delete
  ```

### 3. Parar a Aplicação no Docker Compose
```bash
docker compose -f docker-java-api/docker-compose.yml down -v
```
