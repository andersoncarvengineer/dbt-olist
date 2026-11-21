{{ config(severity = 'warn') }}

-- Parcelas são um número inteiro entre 1 e 24.
-- Severidade warn: a fonte tem 2 pagamentos em cartão com 0 parcelas
-- (pedidos 744bade1... e 1a571083...). Anomalia conhecida, sem efeito na receita.
-- Se a contagem passar de 2, investigar a ingestão.
select
    order_id,
    max_installments
from {{ ref('fct_orders') }}
where max_installments is not null
  and (cast(max_installments as int) not between 1 and 24
       or pg_typeof(max_installments)::text <> 'integer')