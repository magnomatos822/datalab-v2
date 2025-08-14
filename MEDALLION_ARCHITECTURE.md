# 🏗️ Medallion Architecture + Snowflake ACID Implementation

## 📊 Visão Geral da Arquitetura

Este projeto implementa uma **Medallion Architecture** robusta integrada com **Snowflake** para garantir propriedades **ACID** em todas as transformações de dados.

### 🎯 Objetivos

- ✅ **Separação clara de responsabilidades** por camadas (Bronze, Silver, Gold)
- ✅ **Garantias ACID** através do Snowflake para transações críticas
- ✅ **Qualidade de dados** com validações automatizadas
- ✅ **Auditoria completa** de lineage e transformações
- ✅ **Escalabilidade** horizontal e vertical
- ✅ **Observabilidade** com métricas e alertas

## 🏛️ Camadas da Arquitetura

### 🥉 **BRONZE LAYER - Raw Data**
- **Propósito**: Ingestão de dados brutos sem transformação
- **Características**:
  - Preserva formato original dos dados
  - Auditoria completa de origem
  - Detecção de duplicatas
  - Versionamento para rastreabilidade

**Buckets MinIO:**
```
bronze-raw-data/       # Dados brutos de sistemas externos
bronze-streaming/      # Dados de streaming em tempo real  
bronze-batch/         # Extrações em lote
bronze-external/      # Fontes externas (APIs, FTP, etc.)
```

### 🥈 **SILVER LAYER - Cleaned Data**
- **Propósito**: Dados limpos, validados e normalizados
- **Características**:
  - Limpeza e validação de dados
  - Deduplicação inteligente
  - Normalização de formatos
  - Aplicação de regras de negócio básicas
  - **Transações ACID** via Snowflake

**Buckets MinIO:**
```
silver-cleaned/       # Dados limpos e validados
silver-validated/     # Dados com regras de negócio aplicadas
silver-normalized/    # Dados normalizados e padronizados
```

### 🥇 **GOLD LAYER - Business Ready**
- **Propósito**: Dados agregados e prontos para consumo
- **Características**:
  - Agregações de negócio
  - Métricas calculadas
  - Dimensões e fatos
  - Otimizações para consulta
  - **Garantias ACID** para consistência

**Buckets MinIO:**
```
gold-analytics/       # Dados para analytics e BI
gold-reporting/       # Datasets para relatórios
gold-ml-features/     # Features para Machine Learning
```

## 🔄 Propriedades ACID com Snowflake

### **Atomicity (Atomicidade)**
- Todas as transformações DBT são executadas em transações
- Rollback automático em caso de falha
- Operações all-or-nothing

### **Consistency (Consistência)**
- Validações de schema automáticas
- Testes de qualidade obrigatórios
- Regras de negócio enforçadas

### **Isolation (Isolamento)**
- Transações concorrentes isoladas
- Prevenção de dirty reads
- Versionamento de dados

### **Durability (Durabilidade)**
- Persistência garantida no Snowflake
- Backup automático
- Recuperação point-in-time

## 🛠️ Stack Tecnológica

### **Armazenamento**
- **MinIO**: Data Lake com buckets organizados por camada
- **PostgreSQL**: Metadados e catálogo
- **Snowflake**: Data Warehouse com garantias ACID

### **Processamento**
- **Apache Spark**: Processamento distribuído
- **dbt**: Transformações SQL com controle de qualidade
- **Apache Hop**: ETL visual e workflows

### **Orquestração**
- **Prefect**: Orquestração de workflows
- **Nessie**: Versionamento de dados

### **MLOps**
- **MLflow**: Gerenciamento de modelos
- **Feature Store**: Features organizadas por domínio

## 📁 Estrutura de Buckets (Medalha)

```
📦 MinIO Buckets
├── 🥉 BRONZE (Raw Data)
│   ├── bronze-raw-data/
│   │   ├── year=2025/month=08/day=14/
│   │   ├── domain=finance/
│   │   ├── domain=sales/
│   │   └── domain=operations/
│   ├── bronze-streaming/
│   ├── bronze-batch/
│   └── bronze-external/
│
├── 🥈 SILVER (Cleaned Data)  
│   ├── silver-cleaned/
│   ├── silver-validated/
│   └── silver-normalized/
│
├── 🥇 GOLD (Business Ready)
│   ├── gold-analytics/
│   ├── gold-reporting/
│   └── gold-ml-features/
│
└── 🔧 OPERATIONAL
    ├── mlflow-artifacts/
    ├── feature-store/
    ├── backup-metadata/
    └── dev-sandbox/
```

## 🏃 Como Executar

### 1️⃣ **Inicializar Infraestrutura**
```bash
# Subir todos os serviços
docker compose up -d --build

# Verificar status
docker compose ps
```

### 2️⃣ **Configurar Snowflake** (Opcional para desenvolvimento)
```bash
# Para desenvolvimento, usar PostgreSQL como fallback
export DBT_TARGET=postgres_local

# Para produção com Snowflake real
export SNOWFLAKE_ACCOUNT=your-account.snowflakecomputing.com
export SNOWFLAKE_USER=your-user
export SNOWFLAKE_PASSWORD=your-password
export DBT_TARGET=snowflake_prod
```

### 3️⃣ **Executar Pipeline DBT**
```bash
# Dentro do container Spark
docker exec -it spark_master bash

# Instalar dependências dbt
pip install dbt-snowflake dbt-postgres dbt-spark

# Executar transformações
cd /opt/bitnami/spark/dbt_project
dbt deps
dbt run --target snowflake_dev

# Executar testes de qualidade
dbt test

# Gerar documentação
dbt docs generate
dbt docs serve
```

## 📊 Monitoramento e Qualidade

### **Métricas Automáticas**
- ✅ Volume de dados por camada
- ✅ Scores de qualidade
- ✅ Tempo de processamento
- ✅ Taxa de sucesso/falha
- ✅ Detecção de anomalias

### **Alertas Configurados**
- 🚨 Queda de qualidade > 20%
- 🚨 Falhas em transformações críticas
- 🚨 Lacunas temporais nos dados
- 🚨 Violações de schema

### **Dashboards Disponíveis**
- 📈 **Data Quality Dashboard**: Métricas de qualidade por camada
- 📊 **Operational Dashboard**: Performance e SLAs
- 🔍 **Data Lineage**: Rastreamento de origem a destino

## 🔐 Segurança e Compliance

### **Controle de Acesso**
- Bronze: Acesso restrito para ingestão
- Silver: Leitura para processamento
- Gold: Consumo por aplicações

### **Auditoria**
- Log completo de todas as operações
- Rastreamento de lineage automático
- Versionamento de schemas

### **Compliance**
- Retenção de dados configurável por camada
- Anonymização automática
- Backup e recovery point-in-time

## 🚀 Próximos Passos

1. **Implementar Streaming**: Kafka + Spark Streaming para dados real-time
2. **ML Automation**: AutoML pipelines integrados
3. **Data Mesh**: Federação de domínios de dados
4. **Advanced Analytics**: Graph analytics e time series
5. **Multi-Cloud**: Replicação entre provedores

## 📞 Contato e Suporte

- **Data Engineering Team**: data-engineering@company.com
- **Documentation**: [Confluence Link]
- **Slack Channel**: #datalab-medallion
- **On-Call**: PagerDuty rotation

---

**🎯 Esta arquitetura garante alta qualidade, confiabilidade e escalabilidade para todos os dados da organização, seguindo as melhores práticas da indústria.**
