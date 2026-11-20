{% macro to_reais(column_name) -%}
    cast({{ column_name }} as numeric(12, 2))
{%- endmacro %}