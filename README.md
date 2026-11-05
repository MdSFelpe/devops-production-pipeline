# 🚀 Java Spring Boot API + PostgreSQL (DevSecOps Pipeline)

Repositório para a pipeline de integração e entrega contínua (CI/CD) de uma API RESTful em Java 21 Spring Boot conectada a um banco de dados PostgreSQL 15. O projeto inclui containerização multi-stage, orquestração local via Kubernetes (Minikube) com práticas de DevSecOps e automação via GitHub Actions.

---

## 📂 Estrutura do Repositório

```text
devops-production-pipeline/
├── .github/
│   └── workflows/
│       └── ci-cd.yaml              # Pipeline automatizada de CI/CD (Build, Testes e Validação IaC)
├── docker-java-api/
│   ├── Dockerfile                  # Build multi-stage otimizado (usuário não-root appuser)
│   ├── docker-compose.yml          # Execução local rápida da API + PostgreSQL
│   ├── pom.xml                     # Dependências e configurações do Maven
│   └── src/                        # Código-fonte da aplicação Java Spring Boot
├── k8s/
│   ├── app-deployment.yaml         # Deployment e Service da API Java (com limits e privilégios mínimos)
│   ├── postgres-configmap.yaml     # Variáveis de ambiente não sensíveis do banco de dados
│   ├── postgres-deployment.yaml    # Deployment, Service e Volume do PostgreSQL
│   └── postgres-secret.yaml        # Credenciais sensíveis codificadas em Base64
├── .gitignore                      # Regras para ignorar arquivos de IDEs e binários compilados
└── README.md                       # Documentação principal do repositório
```
