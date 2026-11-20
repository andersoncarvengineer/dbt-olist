-- A chave de stg_olist__order_reviews é review_id + order_id.
-- Retorna as combinações repetidas; o teste falha se houver alguma.
select
    order_id,
    count(*) as ocorrencias
from {{ ref('stg_olist__order_items') }}
group by 1
having count(*) > 1