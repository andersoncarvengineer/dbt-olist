-- Receita oficial nunca é negativa. Retorna os pedidos que violam a regra.
select
    order_id,
    revenue_amount
from {{ ref('fct_orders') }}
where revenue_amount < 0