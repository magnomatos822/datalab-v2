# Exemplo de Pipeline Apache Hop - DataLab v2

## 📋 Pipeline: PostgreSQL para MinIO

Este é um exemplo básico de como criar um pipeline no Apache Hop que lê dados do PostgreSQL e escreve no MinIO/S3.

### 🎯 Objetivo
Demonstrar um fluxo ETL simples que:
1. Conecta ao PostgreSQL
2. Executa uma query
3. Transforma os dados
4. Salva no bucket do MinIO

### 🛠️ Passos para Criar o Pipeline

#### 1. **Acesse o Apache Hop**
- URL: http://localhost:8080/hop/
- URL: http://localhost:8081/hop/
- Login: admin / supersecretpassword

#### 2. **Crie uma Nova Conexão PostgreSQL**
```
Nome: postgres_datalab
Tipo: PostgreSQL
Host: ${POSTGRES_HOST}
Porta: ${POSTGRES_PORT}
Database: ${POSTGRES_DATABASE}
Usuário: ${POSTGRES_USERNAME}
Senha: ${POSTGRES_PASSWORD}
```

#### 3. **Crie uma Conexão S3/MinIO**
```
Nome: minio_datalab
Tipo: S3
Endpoint: ${S3_ENDPOINT}
Access Key: ${S3_ACCESS_KEY}
Secret Key: ${S3_SECRET_KEY}
Bucket: ${S3_BUCKET_WAREHOUSE}
```

#### 4. **Estrutura do Pipeline**

```
[Table Input] → [Select Values] → [Filter Rows] → [CSV File Output]
```

##### **Transform 1: Table Input**
- Conexão: postgres_datalab
- SQL:
```sql
SELECT 
    id,
    name,
    email,
    created_at,
    status
FROM users 
WHERE created_at >= CURRENT_DATE - INTERVAL '7 days'
```

##### **Transform 2: Select Values**
- Selecionar campos: id, name, email, created_at, status
- Renomear: status → user_status
- Alterar tipo: created_at → String (formato: yyyy-MM-dd)

##### **Transform 3: Filter Rows**
- Condição: user_status <> 'deleted'

##### **Transform 4: CSV File Output**
- Arquivo: s3a://warehouse/users/active_users_${date}.csv
- Separador: ,
- Encoding: UTF-8
- Header: Yes

### 🔄 Workflow de Orquestração

Crie um workflow que:
1. Verifica se há dados novos
2. Executa o pipeline
3. Valida a saída
4. Envia notificação

```
[Start] → [Check Data] → [Run Pipeline] → [Validate Output] → [Success]
```

### 📊 Exemplos de Casos de Uso

#### **1. Data Quality Check**
```
[Table Input] → [Data Validator] → [Write Report] → [Alert if Issues]
```

#### **2. Incremental Load**
```
[Get Max Date] → [Extract New Records] → [Transform] → [Load to S3] → [Update Control Table]
```

#### **3. API to Data Lake**
```
[REST Client] → [JSON Input] → [Normalize] → [Partition by Date] → [Parquet Output]
```

### 🔧 Configurações Avançadas

#### **Paralelização**
- Configure o número de cópias para transforms pesados
- Use "Execute SQL" para controle de transações

#### **Error Handling**
- Adicione steps de tratamento de erro
- Configure hop de erro entre transforms

#### **Logging**
- Ative logging detalhado para debugging
- Configure alerts para falhas

### 📈 Monitoramento

#### **Métricas Importantes**
- Número de registros processados
- Tempo de execução
- Taxa de erro
- Throughput (registros/segundo)

#### **Alertas**
- Falha de conexão com banco/S3
- Pipeline executando por muito tempo
- Qualidade dos dados abaixo do esperado

### 🚀 Próximos Passos

1. **Teste o pipeline** com dados pequenos primeiro
2. **Configure agendamento** via workflows
3. **Adicione validações** de qualidade de dados
4. **Implemente retry logic** para resiliência
5. **Configure alertas** para monitoramento

### 📝 Notas

- Use variáveis de ambiente sempre que possível
- Teste em ambiente de desenvolvimento primeiro  
- Documente transformações complexas
- Mantenha pipelines simples e modulares
- Use naming conventions consistentes
