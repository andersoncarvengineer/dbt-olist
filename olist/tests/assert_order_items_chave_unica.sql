-- A chave de stg_olist__order_items é order_id + order_item_id.
-- Retorna as combinações repetidas; o teste falha se houver alguma.
select
    order_id,
    order_item_id,
    count(*) as ocorrencias
from {{ ref('stg_olist__order_items') }}
group by 1, 2
having count(*) > 1