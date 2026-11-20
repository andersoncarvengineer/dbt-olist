-- A receita total precisa ser a mesma no fato e nas duas dimensões.
-- Retorna uma linha se alguma diferença passar de 1 centavo.
with

totais as (
    select
        (select sum(revenue_amount)   from {{ ref('fct_orders') }})    as fato,
        (select sum(lifetime_revenue) from {{ ref('dim_customers') }}) as clientes,
        (select sum(revenue_amount)   from {{ ref('dim_sellers') }})   as vendedores
)

select *
from totais
where abs(fato - clientes)   > 0.01
   or abs(fato - vendedores) > 0.01