{# Adapted from original version by @jthandy and @ericalouie #}

{% macro coalesce_fields(relation) %}

    {%- set cols = get_columns_in_relation(relation) -%}
    {%- set cols_to_coalesce = [] -%}
    {%- set colnames_tofix = [] -%}
    {%- set clean_cols = [] -%}
    {%- set finals = [] -%}

    {%- for col in cols -%}

        {%- set status = 'innocent' -%}

        {#- Stitch-synced duplicate columns are named `field__datatype` or
        `field__dt`, where dt = abbreviated datatype -#}
        {%- if '__' in col.column -%}

            {%- set col_split = col.column.split('__') -%}
            {%- if col_split|length > 1 and col_split[-1]|lower in (
                'de','fl','bl','st','it','bigint','string','double','boolean'
            ) -%}

                {%- set status = 'guilty' -%}

                {%- set name_without_datatype = col_split[:-1]|join('__') -%}

                {%- set column =
                    {
                        'name' : adapter.quote(col.column | string),
                        'datatype' : col.data_type,
                        'name_without_datatype' : adapter.quote(name_without_datatype)
                    }
                -%}

                {#- keep lists of columns to fix -#}
                {%- do cols_to_coalesce.append(column) -%}
                {%- do colnames_tofix.append(name_without_datatype) -%}

            {%- endif -%}

        {%- endif %}

        {%- if status == 'innocent' -%}
            {%- do clean_cols.append(col) -%}
        {%- endif -%}
    {%- endfor -%}

    {%- for col in clean_cols %}
        {#- check clean column name against coalesce output and
        add all unduplicated, unmatched columns to final list -#}
        {%- if col.column not in colnames_tofix %}
            {%- set clean_col = adapter.quote(col.column) -%}
            {%- do finals.append(clean_col) -%}
        {% else -%}
        {#- if clean column has datatyped cousin, add to list for fixing -#}
            {%- set column =
                {
                    'name' : adapter.quote(col.column | string),
                    'datatype' : col.data_type,
                    'name_without_datatype' : adapter.quote(col.column | string)
                }
            -%}

            {%- do cols_to_coalesce.append(column) -%}
        {% endif -%}
    {% endfor %}

    {#- group duplicate columns by their cleaned name -#}
    {%- for group in cols_to_coalesce|groupby('name_without_datatype') %}
        {#- add print-ready coalesce statement to final list -#}
        {%- set column_exp -%}
            coalesce(
            {%- for column in group.list -%}
                {#- handle booleans with especial care -#}
                {%- if column.datatype == 'boolean' %}
                case
                    when {{column.name}} = true then cast('true' as {{dbt_utils.type_string()}})
                    when {{column.name}} = false then cast('false' as {{dbt_utils.type_string()}})
                    else null end
                {% else %}
                cast({{column.name}} as {{dbt_utils.type_string()}}){%- endif -%}{{- "," if not loop.last -}}
            {% endfor -%}
            ) as {{ group.grouper }}
        {%- endset -%}
        {%- do finals.append(column_exp) -%}
    {%- endfor %}


select

    {% for final in finals %}
    {{final}}{{- ',' if not loop.last -}}
    {% endfor %}

from {{relation}}

{% endmacro %}
