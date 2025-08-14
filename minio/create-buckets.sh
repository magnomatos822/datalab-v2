#!/bin/sh
# Faz o script parar em caso de erro
set -e

echo "🚀 Iniciando criação de buckets com Medallion Architecture..."

# Adiciona o host do MinIO à configuração do mc
/usr/bin/mc config host add minio http://minio:9000 "$MINIO_ROOT_USER" "$MINIO_ROOT_PASSWORD"

# =============================================================================
# MEDALLION ARCHITECTURE BUCKETS
# =============================================================================

# BRONZE LAYER - Dados brutos/raw (formato original)
echo "🥉 Criando buckets da camada BRONZE..."
/usr/bin/mc mb minio/bronze-raw-data --ignore-existing
/usr/bin/mc mb minio/bronze-streaming --ignore-existing
/usr/bin/mc mb minio/bronze-batch --ignore-existing
/usr/bin/mc mb minio/bronze-external --ignore-existing

# SILVER LAYER - Dados limpos e normalizados
echo "🥈 Criando buckets da camada SILVER..."
/usr/bin/mc mb minio/silver-cleaned --ignore-existing
/usr/bin/mc mb minio/silver-validated --ignore-existing
/usr/bin/mc mb minio/silver-normalized --ignore-existing

# GOLD LAYER - Dados agregados e prontos para consumo
echo "🥇 Criando buckets da camada GOLD..."
/usr/bin/mc mb minio/gold-analytics --ignore-existing
/usr/bin/mc mb minio/gold-reporting --ignore-existing
/usr/bin/mc mb minio/gold-ml-features --ignore-existing

# =============================================================================
# OPERATIONAL BUCKETS
# =============================================================================

# MLOps e Experimentação
echo "🤖 Criando buckets de MLOps..."
/usr/bin/mc mb minio/mlflow-artifacts --ignore-existing
/usr/bin/mc mb minio/ml-models --ignore-existing
/usr/bin/mc mb minio/feature-store --ignore-existing

# Orquestração e Workflows
echo "⚙️ Criando buckets de orquestração..."
/usr/bin/mc mb minio/prefect-flows --ignore-existing
/usr/bin/mc mb minio/workflow-logs --ignore-existing
/usr/bin/mc mb minio/job-results --ignore-existing

# Backup e Archive
echo "💾 Criando buckets de backup..."
/usr/bin/mc mb minio/archive-cold --ignore-existing
/usr/bin/mc mb minio/backup-metadata --ignore-existing
/usr/bin/mc mb minio/disaster-recovery --ignore-existing

# Desenvolvimento e Teste
echo "🔧 Criando buckets de desenvolvimento..."
/usr/bin/mc mb minio/dev-sandbox --ignore-existing
/usr/bin/mc mb minio/test-data --ignore-existing
/usr/bin/mc mb minio/temp-workspace --ignore-existing

# =============================================================================
# CONFIGURAÇÃO DE POLÍTICAS E LIFECYCLE
# =============================================================================

echo "🔐 Configurando políticas de acesso..."

# Bronze Layer - Acesso restrito para ingestão
/usr/bin/mc anonymous set none minio/bronze-raw-data
/usr/bin/mc anonymous set none minio/bronze-streaming
/usr/bin/mc anonymous set none minio/bronze-batch
/usr/bin/mc anonymous set none minio/bronze-external

# Silver Layer - Acesso de leitura para processamento
/usr/bin/mc anonymous set download minio/silver-cleaned
/usr/bin/mc anonymous set download minio/silver-validated
/usr/bin/mc anonymous set download minio/silver-normalized

# Gold Layer - Acesso público para consumo (ambiente dev)
/usr/bin/mc anonymous set download minio/gold-analytics
/usr/bin/mc anonymous set download minio/gold-reporting
/usr/bin/mc anonymous set download minio/gold-ml-features

# Desenvolvimento - Acesso público temporário
/usr/bin/mc anonymous set public minio/dev-sandbox
/usr/bin/mc anonymous set public minio/test-data
/usr/bin/mc anonymous set public minio/temp-workspace

# =============================================================================
# ESTRUTURA DE DIRETÓRIOS PADRONIZADA
# =============================================================================

echo "📂 Criando estrutura de diretórios padronizada..."

# Estrutura temporal padrão para cada camada
for layer in bronze silver gold; do
    for bucket in $(mc ls minio/ | grep $layer | awk '{print $NF}' | tr -d '/'); do
        # Estrutura por ano/mês/dia
        mc mkdir -p minio/$bucket/year=$(date +%Y)/month=$(date +%m)/day=$(date +%d)/ || true
        
        # Estrutura por domínio de dados
        mc mkdir -p minio/$bucket/domain=finance/ || true
        mc mkdir -p minio/$bucket/domain=sales/ || true
        mc mkdir -p minio/$bucket/domain=marketing/ || true
        mc mkdir -p minio/$bucket/domain=operations/ || true
        mc mkdir -p minio/$bucket/domain=hr/ || true
    done
done

# =============================================================================
# VERSIONAMENTO E CONFIGURAÇÕES AVANÇADAS
# =============================================================================

echo "🔄 Configurando versionamento..."

# Habilita versionamento para buckets críticos
for bucket in bronze-raw-data silver-cleaned gold-analytics mlflow-artifacts backup-metadata; do
    /usr/bin/mc version enable minio/$bucket || echo "⚠️ Versionamento não suportado para $bucket"
done

echo "✅ Buckets criados com sucesso seguindo Medallion Architecture!"
echo ""
echo "📊 RESUMO DA ARQUITETURA:"
echo "🥉 BRONZE (Raw Data):"
echo "   - bronze-raw-data, bronze-streaming, bronze-batch, bronze-external"
echo "🥈 SILVER (Cleaned Data):"
echo "   - silver-cleaned, silver-validated, silver-normalized"
echo "🥇 GOLD (Business Data):"
echo "   - gold-analytics, gold-reporting, gold-ml-features"
echo ""
echo "📁 Buckets disponíveis:"
/usr/bin/mc ls minio/

exit 0