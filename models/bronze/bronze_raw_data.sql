/*
  BRONZE LAYER - Raw Data Ingestion
  
  Este modelo demonstra a ingestão de dados brutos seguindo a Medallion Architecture.
  Dados são carregados sem transformação, mantendo formato original.
  
  Features:
  - Carregamento incremental
  - Auditoria de dados
  - Preservação de metadados de origem
*/

{{ config(
    materialized='incremental',
    unique_key='source_id',
    on_schema_change='fail',
    tags=['bronze', 'raw', 'source_system'],
    meta={
        'owner': 'data-engineering',
        'layer': 'bronze',
        'description': 'Raw data from external sources'
    }
) }}

-- Exemplo de ingestão de dados brutos
with source_data as (
    select
        -- Chaves primárias e identificadores
        id as source_id,
        external_ref_id,
        
        -- Dados de negócio (raw)
        raw_data,
        source_system,
        
        -- Metadados de auditoria
        current_timestamp() as bronze_ingested_at,
        '{{ run_started_at }}' as dbt_run_id,
        '{{ this }}' as bronze_table_name,
        
        -- Controle de versão e qualidade
        case 
            when raw_data is not null then 'VALID'
            else 'INVALID'
        end as data_quality_status,
        
        -- Informações de origem
        file_name,
        file_path,
        ingestion_timestamp,
        
        -- Hash para detecção de mudanças
        md5(concat_ws('|', 
            coalesce(cast(id as string), ''),
            coalesce(raw_data, ''),
            coalesce(source_system, '')
        )) as row_hash

    from {{ source('external', 'raw_table') }}
    
    {% if is_incremental() %}
        where ingestion_timestamp > (
            select max(ingestion_timestamp) 
            from {{ this }}
        )
    {% endif %}
)

select * from source_data

-- Adiciona restrições de qualidade no nível bronze
{% if is_incremental() %}
    -- Testa se não há duplicatas na carga incremental
    {% set duplicate_check %}
        select source_id, count(*) as cnt
        from source_data
        group by source_id
        having count(*) > 1
    {% endset %}
    
    {% if execute %}
        {% set results = run_query(duplicate_check) %}
        {% if results.rows|length > 0 %}
            {{ log("ERRO: Duplicatas detectadas na carga bronze!", info=true) }}
            {{ exceptions.raise_compiler_error("Duplicatas encontradas na fonte de dados") }}
        {% endif %}
    {% endif %}
{% endif %}
