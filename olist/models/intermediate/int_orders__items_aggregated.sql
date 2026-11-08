with

items as (
    select
        order_id,
        count(*)           as items_count,
        sum(price)         as items_amount,
        sum(freight_value) as freight_amount
    from {{ ref('stg_olist__order_items') }}
    group by 1
),

payments as (
    select 
	    order_id,
	    count(*)										as qtd_formas_pgto,
	    sum(payment_installments)						as qtd_total_parcelas,
	    sum(payment_value)								as valor_parcela,
	    sum(payment_value)*sum(payment_installments)	as valor_total_pgto
from {{ ref('stg_olist__order_payments') }}
group by 1
),

orders as (
    select * from {{ ref('stg_olist__orders') }}
)

select
    orders.order_id,
    orders.status,
    items.items_count,
    items.items_amount,
    items.freight_amount,
    payments.qtd_formas_pgto,
    payments.qtd_total_parcelas,
    payments.valor_total_pgto
from orders
left join items    using (order_id)
left join payments using (order_id)