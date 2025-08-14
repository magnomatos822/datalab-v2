# Apache NiFi - DataLab v2

## 🌊 Visão Geral

O Apache NiFi foi integrado ao DataLab v2 para fornecer capacidades avançadas de processamento de fluxo de dados em tempo real, complementando o Airbyte com uma interface visual para criar pipelines complexos de ETL.

## 🚀 Acesso e Login

### Interface Web
- **URL**: https://localhost:8443/nifi/
- **Usuário**: admin
- **Senha**: supersecretpassword (configurável via variável `NIFI_PASSWORD` no .env)

⚠️ **Nota**: O NiFi usa HTTPS por padrão. Aceite o certificado auto-assinado no navegador.

## 🔗 Conectividade com Outros Serviços

O NiFi está pré-configurado com variáveis para conectar-se facilmente aos outros serviços do DataLab:

### 📊 PostgreSQL
- **Host**: `#{postgres.host}` (postgres)
- **Porta**: `#{postgres.port}` (5432)
- **Database**: `#{postgres.database}` (main_db)
- **Usuário**: `#{postgres.username}`
- **Senha**: `#{postgres.password}`

### 🗄️ MinIO (S3)
- **Endpoint**: `#{minio.endpoint}` (http://minio:9000)
- **Access Key**: `#{minio.access.key}`
- **Secret Key**: `#{minio.secret.key}`

### ⚡ Apache Spark
- **Master URL**: `#{spark.master.url}` (spark://spark-master:7077)

### 🔄 Airbyte
- **API URL**: `#{airbyte.api.url}` (http://airbyte-server:8001)

### 🚀 Prefect
- **API URL**: `#{prefect.api.url}` (http://prefect-server:4200/api)

### 🤖 MLflow
- **Tracking URI**: `#{mlflow.tracking.uri}` (http://mlflow-server:5000)

## 📋 Casos de Uso Recomendados

### 1. **Ingestão em Tempo Real**
- Monitoramento de diretórios para novos arquivos
- Consumo de streams Kafka/MQTT
- APIs REST polling
- Transformações em tempo real

### 2. **Integração de Dados**
- Mover dados entre PostgreSQL e MinIO
- Transformar dados antes de enviar ao Spark
- Sincronização entre diferentes fontes de dados

### 3. **Pipeline de ML**
- Preparação de dados para MLflow
- Feature engineering automatizado
- Deployamento de modelos via API calls

### 4. **Orquestração Complementar**
- Triggers baseados em eventos
- Workflows condicionais
- Monitoramento de qualidade de dados

## 🛠️ Processadores Principais Disponíveis

### **Entrada de Dados**
- `GetFile` - Monitora diretórios
- `ConsumeKafka` - Consome mensagens Kafka
- `InvokeHTTP` - Chamadas HTTP/REST
- `GetS3Object` - Lê objetos do MinIO/S3

### **Transformação**
- `JoltTransformJSON` - Transformações JSON
- `ConvertRecord` - Conversão entre formatos
- `ExecuteScript` - Scripts Python/Groovy customizados
- `QueryRecord` - Consultas SQL em streams

### **Saída de Dados**
- `PutFile` - Escreve arquivos
- `PutS3Object` - Escreve no MinIO/S3
- `PutDatabaseRecord` - Insere no PostgreSQL
- `InvokeHTTP` - Chamadas HTTP para APIs

## 🔧 Configurações Avançadas

### **JVM Settings**
- Heap inicial: 2GB
- Heap máximo: 4GB
- Configurável via variáveis de ambiente

### **Volumes Persistentes**
- `nifi_database_repository`: Metadados do NiFi
- `nifi_flowfile_repository`: FlowFiles em trânsito
- `nifi_content_repository`: Conteúdo dos FlowFiles
- `nifi_provenance_repository`: Histórico de processamento
- `nifi_state`: Estado dos processadores
- `nifi_logs`: Logs do sistema
- `nifi_conf`: Configurações

## 🔄 Integração com o Ecosystem

### **Com Airbyte**
- NiFi para dados em tempo real, Airbyte para batch
- NiFi pode triggerar jobs do Airbyte via API
- Dados processados pelo NiFi podem alimentar connections do Airbyte

### **Com Spark**
- NiFi prepara dados para processamento Spark
- Pode submeter jobs Spark via REST API
- Monitoramento de outputs do Spark

### **Com MLflow**
- Pipeline de feature engineering
- Automatização de treinamento de modelos
- Deployamento automatizado baseado em métricas

### **Com Prefect**
- Triggers baseados em eventos para flows Prefect
- Monitoramento de status de flows
- Coordenação entre sistemas

## 🚀 Próximos Passos

1. **Acesse a interface**: https://localhost:8443/nifi/
2. **Explore os templates**: Crie seu primeiro pipeline
3. **Configure conexões**: Use as variáveis pré-definidas
4. **Monitore**: Acompanhe o status dos flows
5. **Escale**: Adicione mais workers conforme necessário

## 📚 Recursos Adicionais

- [Documentação Oficial do NiFi](https://nifi.apache.org/docs.html)
- [NiFi Expression Language Guide](https://nifi.apache.org/docs/nifi-docs/html/expression-language-guide.html)
- [Processor Documentation](https://nifi.apache.org/docs/nifi-docs/components/)
