# 🚀 Java Spring Boot API + PostgreSQL (DevSecOps, Kubernetes & AWS Cloud Pipeline)

Este repositório contém a arquitetura completa de uma API RESTful em **Java 21 + Spring Boot** integrada a um banco de dados **PostgreSQL**. O projeto abrange desde a execução local containerizada e orquestração via **Kubernetes (Minikube)** até o provisionamento automatizado em nuvem na **AWS com Terraform** e pipeline **CI/CD com Deploy Contínuo via AWS SSM no GitHub Actions**.

---

## 🧐 O que este projeto faz?

- **Aplicação:** Executa uma API Spring Boot em Java 21 comunicando com um banco de dados PostgreSQL (local ou gerenciado na AWS RDS) e expondo endpoint de health check (`/health`).
- **Segurança de Contêiner:** O contêiner da API utiliza *multi-stage build* (`eclipse-temurin:21-jre-alpine`) e roda sob o usuário sem privilégios `appuser` (não-root) para mitigar riscos de escalada de privilégios.
- **Infraestrutura como Código na AWS (Terraform):** Provisiona uma rede isolada (VPC `10.0.0.0/16`) com subnets públicas para a aplicação (EC2) e subnets privadas sem acesso à internet para o banco de dados (RDS PostgreSQL 16).
- **Deploy Contínuo Zero-SSH (AWS SSM):** Atualiza automaticamente o container na EC2 a cada push na branch `main` utilizando **AWS Systems Manager (`Send-Command`)** e **IAM Instance Profile**, eliminando a necessidade de abrir a porta SSH (22) ou armazenar chaves privadas `.pem`.
- **Gestão de Configurações e Segredos:** Gerencia variáveis não sensíveis via `ConfigMap` e credenciais via `Secret` no Kubernetes, além de injeção dinâmica de variáveis de ambiente (`SPRING_DATASOURCE_*`) na AWS e GitHub Secrets sem credenciais expostas no código.
- **Controle de Recursos:** Define limites rigorosos de CPU, Memória e Armazenamento Temporário (`ephemeral-storage`) no Kubernetes para prevenir problemas de *noisy neighbor*.
- **CI/CD & DevSecOps Integrado:** Pipeline no GitHub Actions para compilação Maven, varredura de vulnerabilidades com **Trivy**, publicação automática da imagem no **GitHub Container Registry (`ghcr.io`)**, validação sintática dos manifestos YAML/Terraform e análise estática via SonarQube.

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
  ├── 5. Terraform & Kubernetes Manifest Validation
  └── 6. Continuous Deployment -> AWS SSM Send-Command (Zero-SSH)
          │
          ▼
[ AWS Cloud (us-east-1) - Provisioned via Terraform ]
  └── Custom VPC (10.0.0.0/16)
        ├── Public Subnets (AZ-1 / AZ-2) + Internet Gateway
        │     └── EC2 Instance (t3.micro + IAM SSM Role) -> Spring Boot (:8080)
        │           └── app_sg (Ingress: 8080 | Lifecycle: create_before_destroy)
        └── Private Subnets (AZ-1 / AZ-2) — Isoladas da Internet
              └── AWS RDS PostgreSQL 16 (db.t3.micro)
                    └── rds_sg (Ingress: 5432 exclusivamente do app_sg)
```

---

## 🛠️ Tecnologias Utilizadas

- **Linguagem / Framework:** Java 21 / Spring Boot 4
- **Banco de Dados:** PostgreSQL 15 / 16 (AWS RDS)
- **Containerização & Registry:** Docker (Multi-stage build com usuário não-root) e GitHub Container Registry (`ghcr.io`)
- **Cloud & IaC:** AWS (VPC, EC2, RDS, IAM, Systems Manager / SSM, Security Groups, IGW) e Terraform
- **Orquestração Local:** Kubernetes (Deployments, Services, ConfigMaps, Secrets)
- **CI/CD & Segurança:** GitHub Actions, Trivy Security Scanner e SonarQube / SonarLint (0 avisos)

---

## 📂 Estrutura do Repositório

```text
devops-production-pipeline/
├── .github/
│   └── workflows/
│       └── ci-cd.yaml           # Pipeline de build, push GHCR, validação IaC e deploy via SSM
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
    ├── ec2.tf                   # Instância EC2 + IAM Role SSM + bootstrap via user_data
    └── outputs.tf               # Exposição do IP público da API e endpoint do RDS
```

---

## 🔌 Endpoints da API

| Método | Rota | Descrição | Resposta Esperada |
| :--- | :--- | :--- | :--- |
| `GET` | `/health` | Verifica a disponibilidade da aplicação e conectividade | `{"service":"java-springboot-api","status":"UP"}` |

---

## 📋 Pré-requisitos

- **Geral:**
  - **Git** instalado para clonar o repositório.
- **Para deploy na AWS e CI/CD:**
  - Conta ativa na **AWS** (com acesso ao Console para criação de usuário IAM e acompanhamento dos recursos).
  - **AWS CLI** instalada e autenticada no terminal via `aws configure` (com `Access Key ID`, `Secret Access Key` e região `us-east-1`).
  - **Terraform** (`>= 1.5`) instalado.
  - **Repository Secrets no GitHub** (`Settings` -> `Secrets and variables` -> `Actions`) configurados para o Deploy Contínuo via SSM:
    - `AWS_ACCESS_KEY_ID` e `AWS_SECRET_ACCESS_KEY` (credenciais IAM com permissão `ssm:SendCommand` e `ec2:DescribeInstances`)
    - `RDS_ENDPOINT` (endpoint do banco RDS provisionado)
    - `DB_PASSWORD` (senha definida para o PostgreSQL)
- **Para execução local:**
  - **Docker** e **Docker Compose** instalados.
  - **Minikube** e **kubectl** (caso utilize a orquestração local em Kubernetes).

---

## 🚀 Como Executar o Projeto

### 0. Clonar o Repositório

```bash
git clone [https://github.com/MdsCalcifer/devops-production-pipeline.git](https://github.com/MdsCalcifer/devops-production-pipeline.git)
cd devops-production-pipeline
```

### 1. Na Nuvem AWS com Terraform (Ambiente de Produção)

> **⚠️ Nota sobre Custos (AWS Free Tier):** A infraestrutura utiliza instâncias elegíveis ao nível gratuito da AWS (`t3.micro` para EC2 e `db.t3.micro` para RDS). Ainda assim, manter esses recursos ligados continuamente fora da cota gratuita gera cobrança por hora. Sempre execute os comandos da seção **Limpeza do Ambiente** ao finalizar seus testes.

> **📦 Nota sobre o Container Registry (`ghcr.io`):** Por padrão, o script de inicialização em `terraform/ec2.tf` baixa a imagem pública `ghcr.io/mdsfelpe/docker-java-api:latest`. Caso você faça um *fork* deste projeto para publicar sua própria imagem, atualize o endereço da imagem no `terraform/ec2.tf` e garanta que o pacote esteja configurado como **Public** na aba *Packages* do seu GitHub.

1. Garanta que suas credenciais da AWS estão ativas no terminal:
   ```bash
   aws sts get-caller-identity
   ```
2. Acesse a pasta de infraestrutura e inicialize o Terraform:
   ```bash
   cd terraform
   terraform init
   terraform validate
   ```
3. Provisione a VPC, o banco RDS PostgreSQL e a instância EC2 (informe a senha desejada para o banco quando solicitado):
   ```bash
   terraform apply
   ```
4. Aguarde o bootstrap automático (`user_data`) e valide a aplicação usando o IP público retornado em `ec2_public_ip`:
   ```bash
   curl http://<ec2_public_ip>:8080/health
   # Resposta esperada: {"service":"java-springboot-api","status":"UP"}
   ```
5. **Deploy Contínuo (CD):** Com a infraestrutura ativa e os *Secrets* configurados no GitHub, qualquer `git push` na branch `main` compila a nova imagem e atualiza automaticamente o container na EC2 via **AWS SSM** (caso a EC2 esteja desligada/destruída, o pipeline ignora o deploy com segurança sem falhar).

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
- **Remover apenas os manifestos da aplicação:**
  ```bash
  kubectl delete -f k8s/
  ```
- **Reiniciar a aplicação do zero em caso de erro:**
  ```bash
  kubectl delete -f k8s/
  docker build -t docker-java-api:1.0.0 ./docker-java-api
  kubectl apply -f k8s/
  ```
- **Pausar ou apagar completamente o cluster Minikube:**
  ```bash
  minikube stop
  minikube delete
  ```

### 3. Parar a Aplicação no Docker Compose
```bash
docker compose -f docker-java-api/docker-compose.yml down -v
```