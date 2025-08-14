/*
  SILVER LAYER - Cleaned and Validated Data
  
  Este modelo transforma dados da camada bronze aplicando:
  - Limpeza de dados
  - Validação de qualidade
  - Normalização de formatos
  - Deduplicação
  
  Features:
  - Transações ACID via Snowflake
  - Data Quality checks
  - Schema validation
  - Business rules enforcement
*/

{{ config(
    materialized='table',
    unique_key='business_key',
    tags=['silver', 'cleaned', 'validated'],
    meta={
        'owner': 'data-engineering',
        'layer': 'silver',
        'description': 'Cleaned and validated business data'
    }
) }}

-- Aplicação de regras de limpeza e validação
with cleaned_data as (
    select
        -- Chave de negócio limpa
        trim(upper(source_id)) as business_key,
        
        -- Dados limpos e normalizados
        case 
            when trim(raw_data) = '' then null
            else trim(raw_data)
        end as cleaned_data,
        
        -- Normalização de sistema de origem
        upper(trim(source_system)) as source_system_normalized,
        
        -- Validação de qualidade aprimorada
        case
            when cleaned_data is not null 
                and length(cleaned_data) > 0 
                and source_system_normalized in ('SYSTEM_A', 'SYSTEM_B', 'SYSTEM_C')
            then 'VALID'
            when cleaned_data is null then 'MISSING_DATA'
            when source_system_normalized not in ('SYSTEM_A', 'SYSTEM_B', 'SYSTEM_C') then 'INVALID_SOURCE'
            else 'INVALID'
        end as silver_quality_status,
        
        -- Metadados de transformação
        current_timestamp() as silver_processed_at,
        bronze_ingested_at,
        dbt_run_id,
        
        -- Versionamento para ACID compliance
        row_number() over (
            partition by trim(upper(source_id)) 
            order by bronze_ingested_at desc
        ) as version_rank,
        
        -- Hash para Change Data Capture
        md5(concat_ws('|',
            coalesce(trim(upper(source_id)), ''),
            coalesce(trim(raw_data), ''),
            coalesce(upper(trim(source_system)), '')
        )) as silver_row_hash,
        
        -- Campos de auditoria para compliance
        bronze_table_name as source_table,
        file_name as source_file,
        ingestion_timestamp as original_ingestion_time
        
    from {{ ref('bronze_raw_data') }}
    where data_quality_status = 'VALID'
),

-- Deduplicação mantendo apenas a versão mais recente
deduplicated_data as (
    select * 
    from cleaned_data
    where version_rank = 1
      and silver_quality_status = 'VALID'
),

-- Aplicação de regras de negócio específicas
business_rules as (
    select
        *,
        
        -- Classificação de dados por domínio
        case
            when source_system_normalized = 'SYSTEM_A' then 'FINANCE'
            when source_system_normalized = 'SYSTEM_B' then 'SALES'
            when source_system_normalized = 'SYSTEM_C' then 'MARKETING'
            else 'UNKNOWN'
        end as business_domain,
        
        -- Flags de processamento
        case
            when length(cleaned_data) > 1000 then true
            else false
        end as is_large_record,
        
        -- Scoring de qualidade
        case
            when silver_quality_status = 'VALID' 
                and business_domain != 'UNKNOWN'
                and cleaned_data is not null
            then 100
            when silver_quality_status = 'VALID' 
                and business_domain = 'UNKNOWN'
            then 75
            else 0
        end as quality_score

    from deduplicated_data
)

select * from business_rules

-- Post-hook para auditoria e monitoramento
{% if execute %}
    -- Log estatísticas da transformação
    {% set stats_query %}
        select 
            count(*) as total_records,
            count(case when silver_quality_status = 'VALID' then 1 end) as valid_records,
            count(case when quality_score >= 75 then 1 end) as high_quality_records,
            avg(quality_score) as avg_quality_score
        from business_rules
    {% endset %}
    
    {% set results = run_query(stats_query) %}
    {% if results.rows|length > 0 %}
        {% for row in results.rows %}
            {{ log("SILVER LAYER STATS - Total: " ~ row[0] ~ ", Valid: " ~ row[1] ~ ", High Quality: " ~ row[2] ~ ", Avg Score: " ~ row[3], info=true) }}
        {% endfor %}
    {% endif %}
{% endif %}
