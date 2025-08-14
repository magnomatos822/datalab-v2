# Apache Spark - DataLab v2

## ⚡ Visão Geral

O Apache Spark é o coração do processamento de dados distribuído no DataLab v2. Ele é configurado para operar em modo cluster com um nó *master* e um ou mais nós *workers*.

-   **Spark Master**: Responsável por coordenar o cluster e distribuir tarefas.
-   **Spark Worker**: Responsável por executar as tarefas de processamento (os "braços" do cluster).

A integração com o ecossistema é feita através do arquivo `spark-defaults.conf`, que configura o Spark para usar:

-   **MinIO (S3)**: Para ler e escrever dados no Data Lake.
-   **Nessie**: Como catálogo de dados para habilitar transações ACID e versionamento (time-travel) sobre as tabelas Iceberg.
-   **Apache Iceberg**: Como o formato de tabela open-source para o Data Lakehouse.

## 🔧 Configuração de Recursos

Você pode controlar os recursos alocados para cada nó worker diretamente do arquivo `.env`, tornando o ambiente flexível para diferentes cargas de trabalho.

-   `SPARK_WORKER_CORES`: O número de cores de CPU que cada worker pode usar.
-   `SPARK_WORKER_MEMORY`: A quantidade de memória RAM alocada para cada worker (ex: `2G`, `512M`).

**Exemplo no `.env`:**

```properties
# Aloca 2 cores e 4GB de RAM para cada worker
SPARK_WORKER_CORES=2
SPARK_WORKER_MEMORY=4G
```

## 🚀 Escalando o Cluster

A arquitetura foi projetada para escalar horizontalmente. Para adicionar mais poder de processamento ao seu cluster, você pode iniciar múltiplos containers `spark-worker` com um único comando.

**Exemplo para iniciar 3 workers:**

```bash
docker-compose up -d --build --scale spark-worker=3
```

Você pode verificar os workers conectados acessando a UI do Spark Master:
-   **URL**: http://localhost:8082

## 🔄 Integração com dbt

O projeto dbt (`dbt_project/`) é montado diretamente nos containers do Spark. Isso permite que você execute modelos dbt que se materializam como tabelas Iceberg no Data Lake, usando o poder de processamento do Spark.

**Para executar o dbt:**

1.  Acesse o container do master:
    ```bash
    docker-compose exec spark-master bash
    ```

2.  Navegue até o projeto e execute os comandos dbt:
    ```bash
    cd /opt/bitnami/spark/dbt_project
    dbt run
    dbt test
    ```

## 📚 Recursos Adicionais

-   Documentação do Spark sobre configuração
-   Integração dbt-spark
-   Projeto Nessie
-   Apache Iceberg