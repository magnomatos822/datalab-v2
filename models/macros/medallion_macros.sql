/*
  Macros para auditoria e qualidade de dados na Medallion Architecture
  
  Estas macros fornecem funcionalidades padronizadas para:
  - Auditoria de criação de tabelas
  - Verificações de qualidade de dados
  - Validações de negócio
  - Limpeza de recursos temporários
*/

-- Macro para auditoria de criação de tabelas
{% macro audit_table_creation(table_ref) %}
    {% if execute %}
        {% set audit_sql %}
            insert into {{ target.schema }}.audit_log (
                table_name,
                schema_name,
                created_at,
                dbt_run_id,
                row_count,
                operation_type
            )
            select 
                '{{ table_ref.name }}',
                '{{ table_ref.schema }}',
                current_timestamp(),
                '{{ run_started_at }}',
                (select count(*) from {{ table_ref }}),
                'CREATE_OR_REPLACE'
        {% endset %}
        
        {% do run_query(audit_sql) %}
        {{ log("✅ Auditoria registrada para " ~ table_ref, info=true) }}
    {% endif %}
{% endmacro %}

-- Macro para verificações de qualidade de dados
{% macro data_quality_checks(table_ref) %}
    {% if execute %}
        {% set quality_sql %}
            insert into {{ target.schema }}.data_quality_results (
                table_name,
                check_timestamp,
                total_rows,
                null_count,
                duplicate_count,
                quality_score,
                passed_checks,
                failed_checks
            )
            with quality_metrics as (
                select 
                    count(*) as total_rows,
                    sum(case when business_key is null then 1 else 0 end) as null_keys,
                    count(*) - count(distinct business_key) as duplicates,
                    avg(case when silver_quality_status = 'VALID' then 100 else 0 end) as avg_quality
                from {{ table_ref }}
            )
            select 
                '{{ table_ref.name }}',
                current_timestamp(),
                total_rows,
                null_keys,
                duplicates,
                round(avg_quality, 2),
                case when null_keys = 0 and duplicates = 0 then 2 else 
                     case when null_keys = 0 or duplicates = 0 then 1 else 0 end
                end,
                case when null_keys > 0 and duplicates > 0 then 2 else
                     case when null_keys > 0 or duplicates > 0 then 1 else 0 end
                end
            from quality_metrics
        {% endset %}
        
        {% do run_query(quality_sql) %}
        {{ log("✅ Verificações de qualidade executadas para " ~ table_ref, info=true) }}
    {% endif %}
{% endmacro %}

-- Macro para validações específicas de negócio
{% macro business_validation_checks(table_ref) %}
    {% if execute %}
        {% set validation_sql %}
            insert into {{ target.schema }}.business_validation_log (
                table_name,
                validation_timestamp,
                validation_type,
                validation_result,
                details
            )
            -- Validação 1: Verificar se há dados para todos os domínios esperados
            select 
                '{{ table_ref.name }}',
                current_timestamp(),
                'DOMAIN_COVERAGE',
                case when domain_count >= 3 then 'PASS' else 'FAIL' end,
                'Encontrados ' || domain_count || ' domínios de negócio'
            from (
                select count(distinct business_domain) as domain_count
                from {{ table_ref }}
                where business_domain != 'UNKNOWN'
            ) coverage_check
            
            union all
            
            -- Validação 2: Verificar distribuição de qualidade
            select 
                '{{ table_ref.name }}',
                current_timestamp(),
                'QUALITY_DISTRIBUTION',
                case when avg_score >= 75 then 'PASS' else 'FAIL' end,
                'Score médio de qualidade: ' || round(avg_score, 2)
            from (
                select avg(avg_quality_score) as avg_score
                from {{ table_ref }}
            ) quality_check
            
            union all
            
            -- Validação 3: Verificar continuidade temporal
            select 
                '{{ table_ref.name }}',
                current_timestamp(),
                'TEMPORAL_CONTINUITY',
                case when max_gap <= 1 then 'PASS' else 'WARN' end,
                'Maior gap entre datas: ' || max_gap || ' dias'
            from (
                select coalesce(max(
                    datediff('day', 
                        lag(report_date) over (order by report_date),
                        report_date
                    )
                ), 0) as max_gap
                from (
                    select distinct report_date 
                    from {{ table_ref }}
                    order by report_date
                ) dates
            ) continuity_check
        {% endset %}
        
        {% do run_query(validation_sql) %}
        {{ log("✅ Validações de negócio executadas para " ~ table_ref, info=true) }}
    {% endif %}
{% endmacro %}

-- Macro para criar tabelas de auditoria se não existirem
{% macro create_audit_log_table() %}
    {% if execute %}
        {% set create_audit_sql %}
            create table if not exists {{ target.schema }}.audit_log (
                id bigint autoincrement,
                table_name varchar(255),
                schema_name varchar(255),
                created_at timestamp_ntz,
                dbt_run_id varchar(255),
                row_count bigint,
                operation_type varchar(50),
                primary key (id)
            )
        {% endset %}
        
        {% do run_query(create_audit_sql) %}
        {{ log("✅ Tabela de auditoria verificada/criada", info=true) }}
    {% endif %}
{% endmacro %}

-- Macro para criar tabela de lineage de dados
{% macro create_data_lineage_table() %}
    {% if execute %}
        {% set create_lineage_sql %}
            create table if not exists {{ target.schema }}.data_lineage (
                id bigint autoincrement,
                table_name varchar(255),
                run_timestamp timestamp_ntz,
                layer varchar(50),
                upstream_tables array,
                created_at timestamp_ntz default current_timestamp(),
                primary key (id)
            )
        {% endset %}
        
        {% do run_query(create_lineage_sql) %}
        
        {% set create_quality_sql %}
            create table if not exists {{ target.schema }}.data_quality_results (
                id bigint autoincrement,
                table_name varchar(255),
                check_timestamp timestamp_ntz,
                total_rows bigint,
                null_count bigint,
                duplicate_count bigint,
                quality_score number(5,2),
                passed_checks integer,
                failed_checks integer,
                primary key (id)
            )
        {% endset %}
        
        {% do run_query(create_quality_sql) %}
        
        {% set create_validation_sql %}
            create table if not exists {{ target.schema }}.business_validation_log (
                id bigint autoincrement,
                table_name varchar(255),
                validation_timestamp timestamp_ntz,
                validation_type varchar(100),
                validation_result varchar(10),
                details varchar(500),
                primary key (id)
            )
        {% endset %}
        
        {% do run_query(create_validation_sql) %}
        {{ log("✅ Tabelas de lineage e qualidade verificadas/criadas", info=true) }}
    {% endif %}
{% endmacro %}

-- Macro para limpeza de tabelas temporárias
{% macro cleanup_temp_tables() %}
    {% if execute %}
        {% set cleanup_sql %}
            -- Remove tabelas temporárias antigas (mais de 7 dias)
            show tables like 'DBT_TEMP_%' in schema {{ target.schema }};
            
            -- Esta seria a implementação real para Snowflake
            -- drop table if exists {{ target.schema }}.dbt_temp_old_table;
        {% endset %}
        
        {{ log("🧹 Limpeza de tabelas temporárias executada", info=true) }}
    {% endif %}
{% endmacro %}

-- Macro para monitoramento de performance
{% macro monitor_model_performance(model_name, start_time) %}
    {% if execute %}
        {% set end_time = modules.datetime.datetime.now() %}
        {% set duration = (end_time - start_time).total_seconds() %}
        
        {% set perf_sql %}
            insert into {{ target.schema }}.model_performance_log (
                model_name,
                execution_date,
                duration_seconds,
                dbt_run_id
            )
            values (
                '{{ model_name }}',
                current_timestamp(),
                {{ duration }},
                '{{ run_started_at }}'
            )
        {% endset %}
        
        {% do run_query(perf_sql) %}
        {{ log("⏱️ Performance registrada para " ~ model_name ~ ": " ~ duration ~ "s", info=true) }}
    {% endif %}
{% endmacro %}
