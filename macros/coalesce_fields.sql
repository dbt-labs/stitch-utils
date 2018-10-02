{# Adapted from original version by @jthandy and @ericalouie #}

{% macro coalesce_fields(table) %}

    {%- if table.name -%}
        {%- set schema_name, table_name = table.schema, table.name -%}
    {%- elif ((table | string).split(".") | length ) == 3 -%}
        {%- set database, schema_name, table_name = (table | string).split(".") -%}
    {%- else -%}
        {%- set schema_name, table_name = (table | string).split(".") -%}
    {%- endif -%}

    {#- in Snowflake and BigQuery, raw data is often in a separate database/project namespace -#}
    {%- if database -%}
        {%- set cols = adapter.get_columns_in_table(schema_name, table_name, database) -%}
    {%- else -%}
        {%- set cols = adapter.get_columns_in_table(schema_name, table_name) -%}
    {%- endif -%}
    {%- set cols_to_coalesce = [] -%}
    {%- set colnames_tofix = [] -%}
    {%- set clean_cols = [] -%}
    {%- set finals = [] -%}

    {%- for col in cols -%}

        {#- Stitch-synced duplicate columns are named `field__dt`, where dt = abbreviated datatype -#}
        {%- if '__' in col.column -%}

            {%- set name_without_datatype, datatype =
                "__".join(col.column.split('__')[:-1]),
                col.column.split('__')[-1]
                %}

            {#- keep lists of columns to fix -#}
            {%- set _ = cols_to_coalesce.append(
                { 'name' : col.column | string,
                  'datatype' : datatype | lower,
                  'name_without_datatype' : name_without_datatype
                }
                ) -%}
                
            {%- set _ = colnames_tofix.append(name_without_datatype) -%}

        {%- else %}
            {%- set _ = clean_cols.append(col) -%}
        {%- endif -%}
    {%- endfor -%}

    {%- for col in clean_cols %}
        {#- check clean column name against coalesce output and 
        add all unduplicated, unmatched columns to final list -#}
        {%- if col.column not in colnames_tofix %}
            {%- set _ = finals.append(col.column) -%}
        {% else -%}
        {#- if clean column has datatyped cousin, add to list for fixing -#}
            {%- set _ = cols_to_coalesce.append(
                { 'name' : col.column | string,
                  'datatype' : 'st',
                  'name_without_datatype' : col.column | string
                }
                ) -%}
        {% endif -%}
    {% endfor %}

    {#- group duplicate columns by their true name -#}
    {%- for group in cols_to_coalesce|groupby('name_without_datatype') %}
        {#- add print-ready coalesce statement to final list -#}
        {%- set colexp -%}
            coalesce(
            {%- for col in group.list -%}
                {#- handle booleans with especial care -#}
                {%- if col.datatype == 'bo' %}
                case
                    when {{col.name}} = true then cast('true' as {{dbt_utils.type_string()}})
                    when {{col.name}} = false then cast('false' as {{dbt_utils.type_string()}})
                    else null end
                {% else %}
                cast({{col.name}} as {{dbt_utils.type_string()}}){%- endif -%}{{"," if not loop.last}}
            {% endfor -%}
            ) as {{ group.grouper }}
        {%- endset -%}
        {%- set _ = finals.append(colexp) -%}
    {%- endfor %}
    
    
select

    {% for final in finals %}
    {{final}}{{"," if not loop.last}}
    {% endfor %}

from {{table}}

{% endmacro %}
