{# Adapted from original version by Tristan and Erica #}

{% macro coalesce_fields(from) %}

    {%- if from.name -%}
        {%- set schema_name, table_name = from.schema, from.name -%}
    {%- elif ((from | string).split(".") | length ) == 3 -%}
        {%- set database, schema_name, table_name = (from | string).split(".") -%}
    {%- else -%}
        {%- set schema_name, table_name = (from | string).split(".") -%}
    {%- endif -%}

    select

    {%- set cols = adapter.get_columns_in_table(schema_name, table_name, database) -%}
    {%- set cols_to_coalesce = [] -%}
    {%- set clean_cols = [] -%}

    {%- for col in cols -%}

        {%- if '__' in col.column -%}

            {%- set name_without_datatype, datatype =
                "__".join(col.column.split('__')[:-1]),
                col.column.split('__')[-1]
                %}

            {%- set _ = cols_to_coalesce.append(
                { 'name' : col.column | string,
                  'datatype' : datatype,
                  'name_without_datatype' : name_without_datatype
                }
                ) -%}

        {%- else %}
            {%- set _ = clean_cols.append(col) -%}
        {%- endif -%}
    {%- endfor -%}


    {%- for col in clean_cols %}
        {{col.column}}{% if not loop.last %},{% endif %}
    {% endfor %}


    {%- for group in cols_to_coalesce|groupby('name_without_datatype') %}
        , coalesce(
        {%- for col in group.list -%}
            {%- if col.datatype == 'BO' -%}
            case {{col.name}}
                when true then cast('true' as {{dbt_utils.type_string()}})
                when false then cast('false' as {{dbt_utils.type_string()}})
                else null end
            {%- else -%}
            cast({{col.name}} as {{dbt_utils.type_string()}})
            {%- endif -%}{% if not loop.last %}, {% endif %}
        {%- endfor -%}
        ) as {{ group.grouper }}
    {%- endfor %}

    {% if database is not none -%}
        from {{database}}.{{schema_name}}.{{table_name}}
    {%- else -%}
        from {{schema_name}}.{{table_name}}
    {%- endif %}

{% endmacro %}
