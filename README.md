# DataLab v2 🚀

## 🏗️ Arquitetura Moderna de Data Lakehouse

O DataLab v2 é uma plataforma completa de dados que combina as melhores tecnologias para ingestão, processamento, orquestração e MLOps em uma arquitetura de lakehouse moderna.

## 🧩 Componentes da Plataforma

### 📊 **Armazenamento & Catálogo**
- **PostgreSQL** (porta 5433): Banco de dados para metadados
- **MinIO** (portas 9000/9001): Object storage compatível com S3
- **Nessie** (porta 19120): Catálogo de dados com versionamento Git-like

### ⚡ **Processamento**
- **Apache Spark** (porta 8080): Cluster distribuído com integração Iceberg
- **dbt**: Transformações de dados como código

### 🌊 **Ingestão de Dados**
- **Apache Hop** (porta 8080): ETL/ELT visual e orquestração de dados

### 🚀 **Orquestração**
- **Prefect** (porta 4200): Orquestração moderna de pipelines

### 🤖 **MLOps**
- **MLflow** (porta 5000): Gerenciamento do ciclo de vida de ML

## 🚀 Quick Start

### 1. **Pré-requisitos**
```bash
# Docker e Docker Compose instalados
docker --version
docker-compose --version
```

### 2. **Inicialização**
```bash
# Clone o repositório
git clone <repo-url>
cd datalab-v2

# Inicie todos os serviços
docker-compose up -d

# Verifique o status
docker-compose ps
```

### 3. **Acesso aos Serviços**

| Serviço           | URL                        | Usuário | Senha               |
| ----------------- | -------------------------- | ------- | ------------------- |
| **Apache Hop**    | http://localhost:8081/hop/ui/ | admin   | supersecretpassword |
| **Spark Master**  | http://localhost:8082      | -       | -                   |
| **MinIO Console** | http://localhost:9001      | admin   | supersecretpassword |
| **Prefect**       | http://localhost:4200      | -       | -                   |
| **MLflow**        | http://localhost:5000      | -       | -                   |
| **Nessie**        | http://localhost:19120     | -       | -                   |

## 🔧 Configuração

Todas as configurações estão centralizadas no arquivo `.env`:

```bash
# Credenciais principais
POSTGRES_USER=admin
POSTGRES_PASSWORD=supersecretpassword
MINIO_ROOT_USER=admin
MINIO_ROOT_PASSWORD=supersecretpassword
HOP_PASSWORD=supersecretpassword
```

## 📁 Estrutura do Projeto

```
datalab-v2/
├── docker-compose.yml          # Orquestração de serviços
├── .env                        # Variáveis de ambiente
├── hop/                        # Configurações do Apache Hop
│   ├── projects/             # Projetos template
│   └── README.md            # Documentação específica
├── postgres/                   # Scripts de inicialização
│   └── init-db.sh            # Criação de databases
├── spark/                      # Configurações do Spark
│   └── spark-defaults.conf    # Iceberg + Nessie + S3
├── mlflow/                     # Dockerfile customizado
│   └── Dockerfile            # MLflow com S3 support
└── models/                     # Configurações dbt
    └── profiles.yml          # Profile Spark
```

## 🔄 Fluxos de Dados Recomendados

### **1. Ingestão Visual (Apache Hop)**
```
Fontes → Hop ETL → MinIO/S3 → Spark/Iceberg → Nessie
```

### **2. Transformações**
```
Raw Data → dbt/Spark → Curated Data → Analytics
```

### **4. Machine Learning**
```
Curated Data → MLflow → Modelos → Deployment
```

### **5. Orquestração**
```
Prefect → (Hop + Spark + MLflow)
```

## 🛠️ Casos de Uso

### **🔄 ETL/ELT Visual**
- Combine Apache Hop (visual) + dbt (transformação)
- Versionamento de schemas com Nessie
- Armazenamento eficiente com Iceberg

### **🤖 ML Platform**
- Feature stores com Iceberg
- Experiment tracking com MLflow
- Pipelines automatizados com Prefect

### **📊 Analytics Self-Service**
- Catálogo de dados centralizado
- Queries SQL diretas no lakehouse
- Governança de dados com versionamento

## 🔍 Monitoramento

### **Health Checks**
```bash
# Verificar status de todos os serviços
docker-compose ps

# Logs específicos
docker-compose logs hop
docker-compose logs spark-master
```

### **URLs de Saúde**
- MinIO: http://localhost:9000/minio/health/live
- Apache Hop: http://localhost:8081/hop/ui/
- Spark: http://localhost:8082

## 🚨 Troubleshooting

### **Problemas Comuns**

1. **Serviços não sobem**
   ```bash
   docker-compose down
   docker system prune -f
   docker-compose up -d
   ```

2. **Problemas de conectividade**
   - Verifique se as portas estão disponíveis
   - Confirme as configurações no `.env`

3. **Performance**
   - Ajuste heap do NiFi e Spark conforme recursos
   - Configure workers adicionais se necessário

## 📚 Documentação Detalhada

- [Apache Hop Setup & Integration](./hop/README.md)
- [Spark + Iceberg Configuration](./spark/)
- [MLflow S3 Integration](./mlflow/)

## 🤝 Contribuição

1. Fork o projeto
2. Crie uma branch para sua feature
3. Faça commit das mudanças
4. Abra um Pull Request

## 📜 Licença

Este projeto está sob licença MIT. Veja o arquivo LICENSE para detalhes.