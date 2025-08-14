/*
  GOLD LAYER - Business Ready Analytics Data
  
  Este modelo agrega dados da camada silver para criar datasets
  prontos para consumo em analytics, dashboards e ML.
  
  Features:
  - Agregações de negócio
  - Métricas calculadas
  - Dimensões e fatos
  - Otimizações para consulta
  - Garantias ACID via Snowflake
*/

{{ config(
    materialized='table',
    unique_key='analytics_key',
    tags=['gold', 'analytics', 'business_ready'],
    cluster_by=['business_domain', 'report_date'],
    meta={
        'owner': 'analytics-team',
        'layer': 'gold',
        'description': 'Business ready analytics data for reporting and ML'
    }
) }}

-- Agregações por domínio de negócio
with business_metrics as (
    select
        -- Chaves de dimensão
        business_domain,
        date(silver_processed_at) as report_date,
        source_system_normalized,
        
        -- Métricas de volume
        count(*) as total_records,
        count(distinct business_key) as unique_entities,
        
        -- Métricas de qualidade
        avg(quality_score) as avg_quality_score,
        min(quality_score) as min_quality_score,
        max(quality_score) as max_quality_score,
        
        -- Distribuição por status
        count(case when silver_quality_status = 'VALID' then 1 end) as valid_count,
        count(case when is_large_record then 1 end) as large_record_count,
        
        -- Cálculos de proporção
        round(
            100.0 * count(case when silver_quality_status = 'VALID' then 1 end) / count(*), 
            2
        ) as valid_percentage,
        
        -- Metadados de processamento
        min(original_ingestion_time) as earliest_ingestion,
        max(original_ingestion_time) as latest_ingestion,
        current_timestamp() as gold_processed_at,
        
        -- Chave analítica composta
        md5(concat_ws('|',
            business_domain,
            date(silver_processed_at),
            source_system_normalized
        )) as analytics_key

    from {{ ref('silver_cleaned_data') }}
    group by 
        business_domain,
        date(silver_processed_at),
        source_system_normalized
),

-- Cálculos de tendências e variações
trend_analysis as (
    select
        *,
        
        -- Análise temporal
        lag(total_records) over (
            partition by business_domain, source_system_normalized 
            order by report_date
        ) as prev_day_records,
        
        -- Cálculo de crescimento
        case
            when lag(total_records) over (
                partition by business_domain, source_system_normalized 
                order by report_date
            ) > 0
            then round(
                100.0 * (total_records - lag(total_records) over (
                    partition by business_domain, source_system_normalized 
                    order by report_date
                )) / lag(total_records) over (
                    partition by business_domain, source_system_normalized 
                    order by report_date
                ), 2
            )
            else null
        end as daily_growth_rate,
        
        -- Médias móveis para suavização
        avg(total_records) over (
            partition by business_domain, source_system_normalized
            order by report_date
            rows between 6 preceding and current row
        ) as ma_7_day_records,
        
        -- Ranking por qualidade
        rank() over (
            partition by report_date
            order by avg_quality_score desc
        ) as quality_rank_daily

    from business_metrics
),

-- Classificações e segmentações para ML
ml_features as (
    select
        *,
        
        -- Features categóricas
        case
            when total_records < 100 then 'LOW_VOLUME'
            when total_records < 1000 then 'MEDIUM_VOLUME'
            else 'HIGH_VOLUME'
        end as volume_category,
        
        case
            when avg_quality_score >= 90 then 'EXCELLENT'
            when avg_quality_score >= 75 then 'GOOD'
            when avg_quality_score >= 50 then 'FAIR'
            else 'POOR'
        end as quality_tier,
        
        -- Features numéricas normalizadas
        case
            when daily_growth_rate is not null
            then case
                when daily_growth_rate > 20 then 'HIGH_GROWTH'
                when daily_growth_rate > 0 then 'POSITIVE_GROWTH'
                when daily_growth_rate = 0 then 'STABLE'
                else 'DECLINING'
            end
            else 'NO_HISTORY'
        end as growth_trend,
        
        -- Flags para alertas
        case
            when avg_quality_score < 50 then true
            else false
        end as quality_alert,
        
        case
            when daily_growth_rate < -50 then true
            else false
        end as volume_alert,
        
        -- Scoring composto para dashboards
        round(
            (avg_quality_score * 0.4) + 
            (valid_percentage * 0.3) + 
            (case when daily_growth_rate > 0 then 30 else 0 end), 
            2
        ) as composite_health_score

    from trend_analysis
)

select * from ml_features

-- Validações de negócio para garantir consistência
{% if execute %}
    -- Validação: Não deve haver lacunas de datas
    {% set date_gap_check %}
        with date_gaps as (
            select 
                business_domain,
                source_system_normalized,
                report_date,
                lag(report_date) over (
                    partition by business_domain, source_system_normalized 
                    order by report_date
                ) as prev_date,
                datediff('day', 
                    lag(report_date) over (
                        partition by business_domain, source_system_normalized 
                        order by report_date
                    ),
                    report_date
                ) as days_diff
            from ml_features
        )
        select count(*) as gap_count
        from date_gaps
        where days_diff > 1 and prev_date is not null
    {% endset %}
    
    {% set gap_results = run_query(date_gap_check) %}
    {% if gap_results.rows|length > 0 and gap_results.rows[0][0] > 0 %}
        {{ log("AVISO: " ~ gap_results.rows[0][0] ~ " lacunas de data detectadas na camada GOLD!", info=true) }}
    {% else %}
        {{ log("✅ Validação de continuidade de datas aprovada", info=true) }}
    {% endif %}
    
    -- Validação: Score de saúde deve estar em range válido
    {% set health_score_check %}
        select count(*) as invalid_scores
        from ml_features
        where composite_health_score < 0 or composite_health_score > 100
    {% endset %}
    
    {% set score_results = run_query(health_score_check) %}
    {% if score_results.rows|length > 0 and score_results.rows[0][0] > 0 %}
        {{ exceptions.raise_compiler_error("Scores de saúde inválidos detectados!") }}
    {% else %}
        {{ log("✅ Validação de scores de saúde aprovada", info=true) }}
    {% endif %}
{% endif %}
