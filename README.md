# 🚀 Java Spring Boot API + PostgreSQL (DevSecOps Pipeline)

Repositório para a pipeline de integração e entrega contínua (CI/CD) de uma API RESTful em Java 21 Spring Boot conectada a um banco de dados PostgreSQL 15. O projeto inclui containerização multi-stage, orquestração local via Kubernetes (Minikube) com práticas de DevSecOps e automação via GitHub Actions.

---

## 📂 Estrutura do Repositório

```text
devops-production-pipeline/
├── .github/
│   └── workflows/
│       └── ci-cd.yaml           # Pipeline de build, scan Trivy, push GHCR e validação IaC
├── docker-java-api/
│   ├── src/                     # Código-fonte Spring Boot (inclui endpoint /health)
│   ├── Dockerfile               # Multi-stage build com usuário não-root
│   ├── .dockerignore            # Otimização de contexto de build
│   └── pom.xml                  # Dependências Maven (Java 21 + PostgreSQL Driver)
├── k8s/                         # Manifestos Kubernetes validados na pipeline
└── terraform/
    ├── vpc.tf                   # VPC customizada (10.0.0.0/16)
    ├── subnets.tf               # Subnets públicas e privadas multi-AZ
    ├── gateways.tf              # Internet Gateway e Route Tables
    ├── security_groups.tf       # Regras de firewall encadeadas (app_sg -> rds_sg)
    ├── rds.tf                   # Instância gerenciada PostgreSQL 16
    ├── ec2.tf                   # Instância EC2 com bootstrap automatizado via user_data
    └── outputs.tf               # Exposição do IP público da API e endpoint do RDS
```
