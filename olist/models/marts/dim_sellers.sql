with

sellers as (
    select * from {{ ref('stg_olist__sellers') }}
),

order_items as (
    select * from {{ ref('stg_olist__order_items') }}
),

orders as (
    select order_id, purchased_at, is_canceled
    from {{ ref('fct_orders') }}
),

-- só itens de pedidos válidos
valid_items as (

    select
        order_items.seller_id,
        order_items.order_id,
        order_items.price,
        order_items.freight_value,
        orders.purchased_at
    from order_items
    inner join orders using (order_id)
    where not orders.is_canceled

),

seller_sales as (

    select
        seller_id,
        count(distinct order_id)                           as orders_count,
        count(*)                                           as items_sold,
        sum(price + freight_value)                         as revenue_amount,
        min(purchased_at)                                  as first_sale_at,
        max(purchased_at)                                  as last_sale_at
    from valid_items
    group by 1

),

final as (

    select
        sellers.seller_id,
        sellers.seller_zip_code_prefix                     as zip_code_prefix,
        sellers.seller_city                                as city,
        sellers.seller_state                               as state,
        coalesce(seller_sales.orders_count, 0)             as orders_count,
        coalesce(seller_sales.items_sold, 0)               as items_sold,
        coalesce(seller_sales.revenue_amount, 0)           as revenue_amount,
        seller_sales.first_sale_at,
        seller_sales.last_sale_at
    from sellers
    left join seller_sales using (seller_id)

)

select * from final