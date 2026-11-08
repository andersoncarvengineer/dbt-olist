with

orders as (
    select * from {{ ref('stg_olist__orders') }}
),

order_amounts as (
    select * from {{ ref('int_orders__items_aggregated') }}
),

customers as (
    select customer_id, unique_id
    from {{ ref('stg_olist__customers') }}
),

final as (

    select
        -- chaves
        orders.order_id,
        customers.unique_id                                as customer_unique_id,

        -- datas
        orders.purchased_at,
        cast(orders.purchased_at as date)                  as purchase_date,
        orders.delivered_to_customer_at,
        orders.estimated_delivery_date,

        -- status
        orders.status,
        orders.status in ('canceled', 'unavailable')       as is_canceled,

        -- valores
        coalesce(order_amounts.items_count, 0)             as items_count,
        coalesce(order_amounts.items_amount, 0)            as items_amount,
        coalesce(order_amounts.freight_amount, 0)          as freight_amount,
        coalesce(order_amounts.items_amount, 0) +  coalesce(order_amounts.freight_amount, 0) as order_amount,
        case 
            when orders.status in ('canceled', 'unavailable') then 0 
            else coalesce(order_amounts.items_amount, 0) +  coalesce(order_amounts.freight_amount, 0)
        end as revenue_amount,
        order_amounts.paid_amount,
        order_amounts.payments_count,
        order_amounts.max_installments,
        case
            when orders.delivered_to_customer_at > orders.estimated_delivery_date then 1
            else 0
        end as is_late

    from orders
    
    left join order_amounts using (order_id)
    left join customers     using (customer_id)

)

select * from final