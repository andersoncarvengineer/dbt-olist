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
        count(*)                  as payments_count,
        max(payment_installments) as max_installments,
        sum(payment_value)        as paid_amount
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
    payments.payments_count,
    payments.max_installments,
    payments.paid_amount
from orders
left join items    using (order_id)
left join payments using (order_id)