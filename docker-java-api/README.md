# 🚀 Java Spring Boot API + PostgreSQL (DevSecOps & Kubernetes Pipeline)

Este repositório contém a arquitetura completa de uma API RESTful em Java Spring Boot integrada a um banco de dados PostgreSQL. O projeto foi estruturado aplicando práticas de **DevSecOps**, containerização otimizada e orquestração local via Kubernetes.

---

## 🧐 O que este projeto faz?

- **Aplicação:** Executa uma API Spring Boot em Java 21 comunicando com um banco de dados PostgreSQL 15.
- **Segurança de Contêiner:** O contêiner da API roda sob o usuário sem privilégios `appuser` (não-root) para mitigar riscos de escalada de privilégios.
- **Gestão de Configurações (IaC):** O Kubernetes gerencia configurações não sensíveis via `ConfigMap` e credenciais de acesso via `Secret` codificadas em Base64.
- **Controle de Recursos:** Define limites rigorosos de consumo de CPU, Memória e Armazenamento Temporário (`ephemeral-storage`) para prevenir problemas de *noisy neighbor*.
- **CI/CD Integrado:** Pipeline no GitHub Actions para compilação automática, validação sintática dos manifestos YAML e análise estática do código.

---

## 🛠️ Tecnologias Utilizadas

- **Linguagem / Framework:** Java 21 / Spring Boot 4
- **Banco de Dados:** PostgreSQL 15
- **Containerização:** Docker (Multi-stage build com usuário não-root)
- **Orquestração:** Kubernetes (Deployments, Services, ConfigMaps, Secrets)
- **CI/CD:** GitHub Actions
- **Qualidade & Segurança:** SonarQube / SonarLint (0 avisos)

---

## 🚀 Como Executar o Projeto

### 1. Com Docker Compose (Execução Rápida)

Na raiz do repositório, execute:

```bash
docker compose -f docker-java-api/docker-compose.yml up --build
```

### 2. Com Kubernetes (Minikube)

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

4. Confirme se os Pods estão em execução:

```bash
kubectl get pods
```

5. Verifique os logs da aplicação para confirmar a conexão com o banco de dados:

```bash
kubectl logs -l app=api-java --tail=50
```

---

## 🧹 Como Desfazer Tudo e Limpar o Ambiente

Se você quiser desligar a aplicação, limpar os recursos ou reiniciar o ambiente em caso de erro, utilize os procedimentos abaixo:

### 1. Apagar os Recursos do Kubernetes
Para remover todos os Pods, Services, Deployments, ConfigMaps e Secrets sem desligar o cluster:

```bash
kubectl delete -f k8s/
```

### 2. Reiniciar a Aplicação do Zero (Reset em Caso de Erro)
Se algo falhar ou os Pods entrarem em estado de erro, execute a sequência de limpeza e recriação:

```bash
# Remove a infraestrutura atual e reconstrói a imagem
kubectl delete -f k8s/
docker build -t docker-java-api:1.0.0 ./docker-java-api
kubectl apply -f k8s/
```

### 3. Parar e Apagar o Cluster Minikube
Quando finalizar os testes no Kubernetes:

Pausar o cluster:

```bash
minikube stop
```

Apagar completamente o cluster e liberar memória RAM/disco:

```bash
minikube delete
```

### 4. Parar a Aplicação no Docker Compose
Se tiver executado via Docker Compose, pare os contêineres e remova os volumes temporários com:

```bash
docker compose -f docker-java-api/docker-compose.yml down -v
```
