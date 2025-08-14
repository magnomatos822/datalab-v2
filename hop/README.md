# Apache Hop - DataLab v2

## 🔄 Visão Geral

O Apache Hop foi integrado ao DataLab v2 como a principal ferramenta para design visual de ETL/ELT. O Hop é uma evolução do Pentaho Data Integration (Kettle) com arquitetura moderna, suporte nativo a nuvem e integração com tecnologias big data.

## 🚀 Acesso e Login

### Interface Web
- **URL**: http://localhost:8081/hop/
- **Usuário**: admin
- **Senha**: supersecretpassword (configurável via variável `HOP_PASSWORD` no .env)

## 🏗️ Arquitetura do Apache Hop

### **Conceitos Principais**
- **Pipelines**: Fluxos de dados (antigo "Transformations")
- **Workflows**: Orquestração de pipelines (antigo "Jobs")
- **Projects**: Conjunto de pipelines e workflows organizados
- **Environments**: Configurações específicas por ambiente (dev, prod, etc.)

## 🔗 Conectividade Pré-Configurada

O Apache Hop está configurado com variáveis de ambiente para conectar-se facilmente aos outros serviços:

### 📊 **PostgreSQL**
- **Host**: `${POSTGRES_HOST}` (postgres)
- **Porta**: `${POSTGRES_PORT}` (5432)
- **Database**: `apache_hop` (banco de metadados do Hop)
- **Usuário**: `${POSTGRES_USERNAME}` (admin)
- **Senha**: `${POSTGRES_PASSWORD}`

### 🗄️ **MinIO/S3**
- **Endpoint**: `${S3_ENDPOINT}` (http://minio:9000)
- **Access Key**: `${S3_ACCESS_KEY}`
- **Secret Key**: `${S3_SECRET_KEY}`
- **Bucket Bronze**: `${S3_BRONZE_BUCKET}` (bronze)
- **Bucket Silver**: `${S3_SILVER_BUCKET}` (silver)
- **Bucket Gold**: `${S3_GOLD_BUCKET}` (gold)

### ⚡ **Apache Spark**
- **Master URL**: `${SPARK_MASTER}` (spark://spark-master:7077)
- **Web UI**: `${SPARK_WEB_UI}` (http://spark-master:8080)

### 🔄 **Integração com Outros Serviços**
- **Prefect API**: `${PREFECT_API}` (http://prefect-server:4200/api)
- **MLflow**: `${MLFLOW_TRACKING_URI}` (http://mlflow-server:5000)
- **Nessie Catalog**: `${NESSIE_URI}` (http://nessie:19120/api/v2)

## 📁 Estrutura de Projetos

### **Projeto Template: DataLab ETL**
Localizado em `/opt/hop/projects/datalab-etl`, contém:

```
datalab-etl/
├── metadata/          # Conexões, datasets, etc.
├── pipelines/         # Transformações de dados
├── workflows/         # Orquestração
├── tests/            # Testes unitários
├── datasets/         # Dados de exemplo (CSV)
├── data/             # Dados locais
└── logs/             # Logs de execução
```

## 🛠️ Casos de Uso Principais

### **1. ETL Tradicional**
```
Source Systems → Hop Pipeline → Staging (S3) → Data Warehouse
```

### **2. ELT Moderno**
```
Source Systems → Hop Pipeline → Data Lake (S3) → Spark Processing
```

### **3. Real-time Streaming**
```
Kafka/Queue → Hop Streaming Pipeline → Real-time Analytics
```

### **4. Data Quality**
```
Raw Data → Hop Validation Pipeline → Quality Reports → Clean Data
```

## 🔧 Principais Transforms (Componentes)

### **Input**
- **Table Input**: Consultas SQL em bancos de dados
- **CSV File Input**: Leitura de arquivos CSV
- **Excel Input**: Planilhas Excel
- **JSON Input**: Arquivos e streams JSON
- **S3 File Input**: Objetos do MinIO/S3

### **Transform**
- **Select Values**: Seleção e renomeação de campos
- **Filter Rows**: Filtros condicionais
- **Sort Rows**: Ordenação de dados
- **Group By**: Agregações
- **Join Rows**: Junções entre streams
- **JavaScript**: Scripts personalizados

### **Output**
- **Table Output**: Inserção em bancos de dados
- **CSV File Output**: Escrita de arquivos CSV
- **JSON Output**: Saída em formato JSON
- **S3 File Output**: Upload para MinIO/S3
- **Kafka Producer**: Envio para filas

### **Big Data**
- **Spark Submit**: Submissão de jobs Spark
- **Hadoop Copy Files**: Operações HDFS
- **Beam Pipeline**: Apache Beam integration

## 🚀 Workflows de Exemplo

### **1. Ingestão Diária de Dados**
```
Start → Check Source → Extract Data → Validate → Transform → Load → Notify
```

### **2. Pipeline de ML**
```
Start → Feature Engineering → Model Training → Model Validation → Deploy → Monitor
```

### **3. Data Quality Check**
```
Start → Data Profiling → Quality Rules → Generate Report → Alert if Issues
```

## 🔄 Integração com o Ecosystem DataLab

### **Com Spark**
- Hop prepara dados para processamento Spark
- Pode submeter jobs Spark via REST API
- Monitoramento de outputs do Spark

### **Com MLflow**
- Pipeline de feature engineering
- Automatização de treinamento de modelos
- Deployamento automatizado baseado em métricas

### **Com Prefect**
- Hop workflows podem ser chamados via Prefect
- Orquestração híbrida (Prefect + Hop)
- Monitoramento centralizado

## 📊 Monitoramento e Logging

### **Logs**
- Logs de execução salvos em `/opt/hop/audit`
- Métricas de performance por pipeline
- Alertas configuráveis para falhas

### **Métricas**
- Throughput de dados processados
- Tempo de execução dos pipelines
- Uso de recursos (CPU, memória)

## 🔐 Configurações de Segurança

### **Desenvolvimento**
- Autenticação simples (admin/password)
- Conexões HTTP internas
- Dados de teste apenas

### **Produção (Recomendações)**
- LDAP/AD integration
- HTTPS com certificados válidos
- Criptografia de dados sensíveis
- Backup automático de projetos

## 🚀 Próximos Passos

1. **Acesse a interface**: http://localhost:8080/hop/
2. **Explore o projeto template**: `datalab-etl` em `/opt/hop/projects-templates`
3. **Crie seu primeiro pipeline**: 
   - Conecte ao PostgreSQL
   - Leia dados de uma tabela
   - Transforme os dados
   - Salve no MinIO/S3
4. **Configure conexões**: Use as variáveis pré-definidas
5. **Teste workflows**: Crie orquestração de múltiplos pipelines

## 📚 Recursos Adicionais

- [Documentação Oficial do Apache Hop](https://hop.apache.org/manual/latest/)
- [Apache Hop GitHub](https://github.com/apache/hop)
- [Hop Community](https://hop.apache.org/community/)
- [Tutorials e Examples](https://hop.apache.org/manual/latest/tutorials/)

## 🔧 Troubleshooting

### **Problemas Comuns**

1. **Interface não carrega**
   ```bash
   docker logs hop_etl_studio
   ```

2. **Conexão com PostgreSQL falha**
   - Verifique se o serviço postgres está rodando
   - Confirme as variáveis de ambiente

3. **Erro ao acessar MinIO**
   - Verifique se o MinIO está healthy
   - Confirme credenciais S3

4. **Performance lenta**
   - Ajuste `HOP_OPTIONS` para mais memória
   - Configure paralelismo nos pipelines

### **Comandos Úteis**
```bash
# Restart do Apache Hop
docker-compose restart apache-hop

# Logs detalhados
docker-compose logs -f apache-hop

# Status dos serviços
docker-compose ps
```
